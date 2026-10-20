<?php

namespace Modules\PaymentModule\Http\Controllers;

use Illuminate\Contracts\Foundation\Application;
use Illuminate\Contracts\View\Factory;
use Illuminate\Contracts\View\View;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Routing\Redirector;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Modules\PaymentModule\Entities\PaymentRequest;
use Modules\PaymentModule\Traits\Processor;

/**
 * Cashfree Payment Gateway (Orders API v4 + hosted checkout).
 *
 * The order id is derived from the local payment request id, so the callback
 * and the webhook can always be tied back to a single PaymentRequest row.
 * Every callback/webhook re-checks the payment with Cashfree's API before the
 * local request is marked paid (never trust the browser redirect alone).
 */
class CashfreeController extends Controller
{
    use Processor;

    private ?array $credentials = null;
    private string $baseUrl = '';
    private string $checkoutMode = 'sandbox';

    public function __construct()
    {
        $config = $this->payment_config('cashfree', 'payment_config');

        if ($config) {
            $rawValues = $config->mode === 'live' ? $config->live_values : $config->test_values;
            $values = is_string($rawValues) ? json_decode($rawValues) : (object) $rawValues;

            $this->checkoutMode = $config->mode === 'live' ? 'production' : 'sandbox';
            $this->baseUrl = $config->mode === 'live'
                ? 'https://api.cashfree.com/pg'
                : 'https://sandbox.cashfree.com/pg';

            if (!empty($values->app_id) && !empty($values->secret_key)) {
                $this->credentials = [
                    'app_id' => (string) $values->app_id,
                    'secret_key' => (string) $values->secret_key,
                ];
            }
        }
    }

    /**
     * Create a Cashfree order and render the hosted checkout.
     */
    public function index(Request $request): View|Factory|JsonResponse|Application|RedirectResponse
    {
        $validator = Validator::make($request->all(), [
            'payment_id' => 'required|uuid',
        ]);

        if ($validator->fails()) {
            return response()->json($this->response_formatter(GATEWAYS_DEFAULT_400, null, $this->error_processor($validator)), 400);
        }

        /** @var PaymentRequest|null $data */
        $data = PaymentRequest::where('id', $request['payment_id'])->where('is_paid', 0)->first();

        if (!isset($data)) {
            return response()->json($this->response_formatter(GATEWAYS_DEFAULT_204), 200);
        }

        if (!$this->credentials) {
            Log::error('Cashfree is not configured (missing app_id/secret_key).');
            return $this->payment_response($data, 'fail');
        }

        if (strtoupper((string) $data->currency_code) !== 'INR') {
            Log::warning('Cashfree only supports INR, order rejected.', [
                'payment_id' => $data->id,
                'currency' => $data->currency_code,
            ]);
            return $this->payment_response($data, 'fail');
        }

        // Har attempt ke liye naya order id: user page refresh kare to Cashfree
        // "order already exists" error na de.
        $orderId = $this->newOrderIdFor($data);
        $payer = json_decode($data->payer_information, true) ?: [];

        // route() pehle se ?payment_id=... lagata hai, isliye order_id '&' se.
        $returnUrl = route('cashfree.callback', ['payment_id' => $data->id]) . '&order_id={order_id}';
        $notifyUrl = route('cashfree.webhook');

        $body = [
            'order_id' => $orderId,
            'order_amount' => round((float) $data->payment_amount, 2),
            'order_currency' => 'INR',
            'customer_details' => [
                'customer_id' => substr((string) ($data->payer_id ?: $data->id), 0, 50),
                'customer_name' => substr((string) ($payer['name'] ?? 'Customer'), 0, 100),
                'customer_email' => (string) ($payer['email'] ?? 'customer@example.com'),
                'customer_phone' => preg_replace('/\D+/', '', (string) ($payer['phone'] ?? '')) ?: '9999999999',
            ],
            'order_meta' => [
                'return_url' => $returnUrl,
                'notify_url' => $notifyUrl,
            ],
            'order_note' => 'Payment ' . $data->id,
        ];

        try {
            $response = Http::withHeaders($this->headers())
                ->timeout(20)
                ->acceptJson()
                ->post($this->baseUrl . '/orders', $body);
        } catch (\Throwable $exception) {
            Log::error('Cashfree order creation failed: ' . $exception->getMessage(), ['payment_id' => $data->id]);
            return $this->payment_response($data, 'fail');
        }

        if (!$response->successful() || empty($response['payment_session_id'])) {
            Log::error('Cashfree order rejected', [
                'payment_id' => $data->id,
                'status' => $response->status(),
                'body' => $response->json() ?? $response->body(),
            ]);
            return $this->payment_response($data, 'fail');
        }

        $businessName = business_config('business_name', 'business_information')?->live_values ?? 'my_business';

        return view('paymentmodule::cashfree', [
            'data' => $data,
            'paymentSessionId' => $response['payment_session_id'],
            'checkoutMode' => $this->checkoutMode,
            'businessName' => $businessName,
            'cancelUrl' => route('payment-fail'),
        ]);
    }

    /**
     * Browser return URL. The payment is verified server-to-server before the
     * success hook runs.
     */
    public function callback(Request $request): Application|JsonResponse|Redirector|RedirectResponse
    {
        $paymentId = $request['payment_id'];
        $orderId = $request['order_id'] ?? null;

        /** @var PaymentRequest|null $data */
        $data = PaymentRequest::where('id', $paymentId)->first();

        if (!isset($data)) {
            return redirect()->route('payment-fail');
        }

        if ((int) $data->is_paid === 1) {
            return $this->payment_response($data, 'success');
        }

        if (!$orderId) {
            $orderId = $this->orderIdFor($data);
        }

        if (!$this->orderBelongsTo($orderId, $data)) {
            Log::warning('Cashfree callback order id mismatch', ['payment_id' => $paymentId]);
            return $this->payment_response($data, 'fail');
        }

        if ($this->markPaidIfSuccessful($data, $orderId) === true) {
            return $this->payment_response($data, 'success');
        }

        return $this->payment_response($data, 'fail');
    }

    /**
     * Server-to-server webhook (source of truth if the browser closes early).
     */
    public function webhook(Request $request): JsonResponse
    {
        $rawBody = $request->getContent();
        $signature = (string) $request->header('x-webhook-signature', '');
        $timestamp = (string) $request->header('x-webhook-timestamp', '');

        if (!$this->credentials || $signature === '') {
            return response()->json(['status' => 'ignored'], 200);
        }

        $expected = base64_encode(hash_hmac('sha256', $timestamp . $rawBody, $this->credentials['secret_key'], true));
        if (!hash_equals($expected, $signature)) {
            Log::warning('Cashfree webhook signature mismatch');
            return response()->json(['status' => 'invalid'], 401);
        }

        $payload = json_decode($rawBody, true) ?: [];
        $orderId = $payload['data']['order']['order_id'] ?? null;
        $paymentId = $this->paymentIdFromOrder($orderId);

        if (!$paymentId) {
            return response()->json(['status' => 'ignored'], 200);
        }

        /** @var PaymentRequest|null $data */
        $data = PaymentRequest::where('id', $paymentId)->first();
        if (!$data) {
            return response()->json(['status' => 'ignored'], 200);
        }

        if ((int) $data->is_paid === 0) {
            $verification = $this->markPaidIfSuccessful($data, $orderId);
            // null = Cashfree API se answer nahi mila. 503 dene se Cashfree
            // webhook retry karega, warna paid user ka booking lost ho jata.
            if ($verification === null) {
                return response()->json(['status' => 'retry'], 503);
            }
        }

        return response()->json(['status' => 'ok'], 200);
    }

    /**
     * @return bool|null true = paid, false = not paid, null = retry karo
     */
    private function markPaidIfSuccessful(PaymentRequest $data, string $orderId): ?bool
    {
        if (!$this->credentials) {
            return null;
        }

        try {
            $response = Http::withHeaders($this->headers())
                ->timeout(20)
                ->acceptJson()
                ->get($this->baseUrl . '/orders/' . rawurlencode($orderId) . '/payments');
        } catch (\Throwable $exception) {
            Log::error('Cashfree verification failed: ' . $exception->getMessage(), ['payment_id' => $data->id]);
            return null;
        }

        if (!$response->successful()) {
            Log::warning('Cashfree verification rejected', [
                'payment_id' => $data->id,
                'status' => $response->status(),
            ]);
            return null;
        }

        $expectedAmount = round((float) $data->payment_amount, 2);
        $successful = null;

        foreach ((array) $response->json() as $payment) {
            $status = strtoupper((string) ($payment['payment_status'] ?? ''));
            $amount = round((float) ($payment['payment_amount'] ?? 0), 2);
            $currency = strtoupper((string) ($payment['payment_currency'] ?? 'INR'));

            if ($status === 'SUCCESS' && $currency === 'INR' && $amount + 0.01 >= $expectedAmount) {
                $successful = $payment;
                break;
            }
        }

        if (!$successful) {
            Log::warning('Cashfree payment not successful/amount mismatch', [
                'payment_id' => $data->id,
                'expected' => $expectedAmount,
            ]);
            return false;
        }

        $updated = PaymentRequest::where('id', $data->id)->where('is_paid', 0)->update([
            'payment_method' => 'cashfree',
            'is_paid' => 1,
            'transaction_id' => (string) ($successful['cf_payment_id'] ?? $orderId),
        ]);

        if ($updated > 0) {
            $fresh = PaymentRequest::find($data->id);
            if ($fresh && function_exists($fresh->success_hook)) {
                call_user_func($fresh->success_hook, $fresh);
            }
            return true;
        }

        return (int) PaymentRequest::where('id', $data->id)->value('is_paid') === 1;
    }

    private function headers(): array
    {
        return [
            'x-client-id' => $this->credentials['app_id'] ?? '',
            'x-client-secret' => $this->credentials['secret_key'] ?? '',
            'x-api-version' => '2023-08-01',
            'Content-Type' => 'application/json',
        ];
    }

    private function orderIdFor(PaymentRequest $data): string
    {
        return 'cf_' . $data->id;
    }

    private function newOrderIdFor(PaymentRequest $data): string
    {
        return $this->orderIdFor($data) . '_' . substr(bin2hex(random_bytes(4)), 0, 8);
    }

    private function orderBelongsTo(?string $orderId, PaymentRequest $data): bool
    {
        $orderId = (string) $orderId;
        return $orderId === $this->orderIdFor($data)
            || str_starts_with($orderId, $this->orderIdFor($data) . '_');
    }

    private function paymentIdFromOrder(?string $orderId): ?string
    {
        $orderId = (string) $orderId;
        if (!str_starts_with($orderId, 'cf_')) {
            return null;
        }

        // cf_<uuid> ya cf_<uuid>_<random> — UUID fixed 36 chars hota hai.
        $paymentId = substr($orderId, 3, 36);
        return \Illuminate\Support\Str::isUuid($paymentId) ? $paymentId : null;
    }
}
