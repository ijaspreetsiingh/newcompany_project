<?php

namespace Modules\PaymentModule\Http\Controllers;

use App\Models\User;
use Razorpay\Api\Api;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Routing\Controller;
use Illuminate\Routing\Redirector;
use Illuminate\Support\Facades\DB;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Contracts\View\Factory;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Validator;
use Modules\PaymentModule\Traits\Processor;
use Illuminate\Contracts\Foundation\Application;
use Modules\PaymentModule\Entities\PaymentRequest;

class RazorPayController extends Controller
{
    use Processor;

    private PaymentRequest $payment;
    private $user;

    public function __construct(PaymentRequest $payment, User $user)
    {
        $config = $this->payment_config('razor_pay', 'payment_config');
        $razor = false;
        if (!is_null($config) && $config->mode == 'live') {
            $razor = json_decode($config->live_values);
        } elseif (!is_null($config) && $config->mode == 'test') {
            $razor = json_decode($config->test_values);
        }

        if ($razor) {
            $config = array(
                'api_key' => $razor->api_key,
                'api_secret' => $razor->api_secret,
                // Webhook secret (optional) — Razorpay dashboard → Settings → Webhooks
                'webhook_secret' => $razor->webhook_secret ?? '',
            );
            Config::set('razor_config', $config);
        }

        $this->payment = $payment;
        $this->user = $user;
    }

    public function index(Request $request): View|Factory|JsonResponse|Application
    {
        $validator = Validator::make($request->all(), [
            'payment_id' => 'required|uuid'
        ]);

        if ($validator->fails()) {
            return response()->json($this->response_formatter(GATEWAYS_DEFAULT_400, null, $this->error_processor($validator)), 400);
        }

        $data = $this->payment::where(['id' => $request['payment_id']])->where(['is_paid' => 0])->first();
        if (!isset($data)) {
            return response()->json($this->response_formatter(GATEWAYS_DEFAULT_204), 200);
        }
        $payer = json_decode($data['payer_information']);

        if ($data['additional_data'] != null) {
            $business = json_decode($data['additional_data']);
            $business_name = $business->business_name ?? "my_business";
            $business_logo = $business->business_logo ?? url('/');
        } else {
            $business_name = "my_business";
            $business_logo = url('/');
        }

        $business_name =  (business_config('business_name', 'business_information'))->live_values ?? 'my_business';
        $business_logo = getBusinessSettingsImageFullPath(key: 'business_logo', settingType: 'business_information', path: 'business/',  defaultPath : 'public/assets/admin-module/img/placeholder.png');

        return view('paymentmodule::razor-pay', compact('data', 'payer', 'business_logo', 'business_name'));
    }

    public function payment(Request $request): JsonResponse|Redirector|RedirectResponse|Application
    {
        $input = $request->all();

        if (!config('razor_config.api_key') || !config('razor_config.api_secret')) {
            \Log::warning('Razorpay payment attempted without configuration', ['ip' => $request->ip()]);
            return redirect()->route('payment-fail');
        }

        $api = new Api(config('razor_config.api_key'), config('razor_config.api_secret'));

        if (count($input) && !empty($input['razorpay_payment_id'])) {
            $data = $this->payment::where(['id' => $request['payment_id']])->first();
            if (!isset($data)) {
                return redirect()->route('payment-fail');
            }

            // IDEMPOTENCY: pehle se paid hai to success page dobara, hook dobara mat chalao
            if ((int) $data->is_paid === 1) {
                return $this->payment_response($data, 'success');
            }

            // VERIFY: payment Razorpay par exist karta hai + amount match karti hai
            // (attacker kisi aur ka payment_id bhej ke free booking nahi kara sakta)
            try {
                $payment = $api->payment->fetch($input['razorpay_payment_id']);
            } catch (\Throwable $e) {
                \Log::warning('RazorPay payment fetch failed: ' . $e->getMessage());
                return redirect()->route('payment-fail');
            }

            $expectedMinor = (int) round(((float) $data->payment_amount) * 100);
            $paidCurrency = strtoupper((string) ($payment['currency'] ?? ''));

            // SECURITY: payment kis order ka hai? Wahi order hona chahiye jo
            // is PaymentRequest ke liye banaya gaya tha. Warna same Razorpay
            // payment id doosri booking par replay ho sakti hai.
            if (!$this->razorpayOrderMatches($data, $payment)) {
                \Log::warning('RazorPay payment does not belong to this request', [
                    'payment_id' => $data->id,
                    'razorpay_order' => $payment['order_id'] ?? null,
                ]);
                return redirect()->route('payment-fail');
            }

            $paidStatus = strtolower((string) ($payment['status'] ?? ''));

            if ((int) ($payment['amount'] ?? 0) < $expectedMinor
                || $paidCurrency !== strtoupper((string) $data->currency_code)
                || !in_array($paidStatus, ['captured', 'authorized'], true)) {
                \Log::warning('RazorPay amount/currency/status mismatch', [
                    'payment_id' => $data->id,
                    'expected' => $expectedMinor,
                    'expected_currency' => $data->currency_code,
                    'got' => $payment['amount'] ?? null,
                    'got_currency' => $paidCurrency,
                    'status' => $paidStatus,
                ]);
                return redirect()->route('payment-fail');
            }

            // Capture poora authorised amount (fee subtract karna merchant loss tha).
            // Already captured payment par dobara capture API error deta hai.
            if ($paidStatus === 'authorized') {
                try {
                    $api->payment->fetch($input['razorpay_payment_id'])
                        ->capture(['amount' => (int) $payment['amount']]);
                } catch (\Throwable $exception) {
                    \Log::warning('RazorPay capture failed: ' . $exception->getMessage(), [
                        'payment_id' => $data->id,
                    ]);
                    return redirect()->route('payment-fail');
                }
            }
            $updated = $this->payment::where(['id' => $request['payment_id']])->where('is_paid', 0)->update([
                'payment_method' => 'razor_pay',
                'is_paid' => 1,
                'transaction_id' => $input['razorpay_payment_id'],
            ]);
            $data = $this->payment::where(['id' => $request['payment_id']])->first();
            if ($updated > 0 && isset($data) && function_exists($data->success_hook)) {
                call_user_func($data->success_hook, $data);
            }
            return $this->payment_response($data, 'success');
        }
        $payment_data = $this->payment::where(['id' => $request['payment_id']])->first();
        if (isset($payment_data) && function_exists($payment_data->failure_hook)) {
            call_user_func($payment_data->failure_hook, $payment_data);
        }
        return $this->payment_response($payment_data, 'fail');
    }

    public function createOrder(Request $request): JsonResponse|Redirector|RedirectResponse|Application
    {
        $validator = Validator::make($request->all(), [
            'payment_request_id' => 'required|uuid',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => 'Invalid payment request.'], 400);
        }

        // SECURITY: amount/currency hamesha server-side PaymentRequest se aate
        // hain. Pehle client ka payment_amount use hota tha, jisse Rs.1 ka
        // order banake poori booking paid mark ki ja sakti thi.
        $data = $this->payment::where(['id' => $request['payment_request_id']])->where('is_paid', 0)->first();

        if (!isset($data)) {
            return response()->json(['status' => false, 'message' => 'Payment request not found.'], 404);
        }

        try {
            $api = new Api(config('razor_config.api_key'), config('razor_config.api_secret'));

            $razorpayOrder = $api->order->create([
                'receipt' => 'order_' . $data->id,
                'amount' => (int) round(((float) $data->payment_amount) * 100),
                'currency' => strtoupper((string) $data->currency_code),
                'payment_capture' => 1,
                'notes' => [
                    'payment_request_id' => $data->id,
                ],
            ]);

            // Order id PaymentRequest se link karo — webhook se booking dhundhne ke liye
            $this->persistRazorpayOrderId($data, (string) $razorpayOrder['id']);

            return response()->json([
                'status' => true,
                'payment_request_id' => $data->id,
                'order_id' => $razorpayOrder['id'],
                'amount' => $razorpayOrder['amount'],
                'currency' => $razorpayOrder['currency'],
            ]);
        } catch (\Exception $exception) {
            \Log::error('Razorpay order creation failed: ' . $exception->getMessage(), ['payment_id' => $data->id]);
            return response()->json([
                'status' => false,
                'message' => 'Unable to start payment. Please try again.',
            ], 500);
        }
    }

    /**
     * RAZORPAY WEBHOOK
     * Browser band ho jaye ya app crash ho jaye — tab bhi payment capture hua
     * to booking ban jati hai (payment.captured event).
     *
     * Security: webhook secret se signature verify + Razorpay API se payment
     * (existence, amount, currency, status, order) verify. Duplicate events
     * idempotent hain (is_paid=1 ho to kuch nahi hota).
     */
    public function webhook(Request $request): JsonResponse
    {
        $rawBody = (string) $request->getContent();
        $signature = (string) $request->header('X-Razorpay-Signature', '');

        // 1) Signature verify (agar webhook secret set hai)
        $secret = (string) (config('razor_config.webhook_secret') ?? '');
        if ($secret !== '') {
            $expected = hash_hmac('sha256', $rawBody, $secret);
            if ($signature === '' || !hash_equals($expected, $signature)) {
                \Log::warning('Razorpay webhook signature mismatch', ['ip' => $request->ip()]);
                return response()->json(['status' => false, 'message' => 'Invalid signature'], 400);
            }
        }

        $payload = json_decode($rawBody, true);
        if (!is_array($payload)) {
            return response()->json(['status' => false, 'message' => 'Invalid payload'], 400);
        }

        $event = (string) ($payload['event'] ?? '');
        if (!in_array($event, ['payment.captured', 'order.paid'], true)) {
            return response()->json(['status' => true, 'message' => 'Event ignored'], 200);
        }

        $entity = $payload['payload']['payment']['entity'] ?? null;
        if (!is_array($entity)) {
            $entity = $payload['payload']['order']['entity'] ?? null;
        }
        if (!is_array($entity)) {
            return response()->json(['status' => false, 'message' => 'Unsupported event payload'], 400);
        }

        $paymentId = (string) ($entity['id'] ?? '');
        $orderId = (string) ($entity['order_id'] ?? '');

        if ($paymentId === '' && $orderId === '') {
            return response()->json(['status' => false, 'message' => 'Missing payment reference'], 400);
        }

        try {
            $api = new Api(config('razor_config.api_key'), config('razor_config.api_secret'));
        } catch (\Throwable $e) {
            \Log::error('Razorpay webhook: API init failed - ' . $e->getMessage());
            return response()->json(['status' => false], 500);
        }

        // 2) PaymentRequest dhoondo (order id se)
        $data = $this->findPaymentRequestByOrderId($orderId);

        // 3) Verify payment (Razorpay API se — amount/currency/status/order)
        $payment = null;
        if ($paymentId !== '') {
            try {
                $payment = $api->payment->fetch($paymentId);
            } catch (\Throwable $e) {
                \Log::warning('Razorpay webhook: payment fetch failed - ' . $e->getMessage());
                return response()->json(['status' => false], 200);
            }
        }

        if (!$data && $payment !== null) {
            $orderId = (string) ($payment['order_id'] ?? $orderId);
            $data = $this->findPaymentRequestByOrderId($orderId);
        }

        if (!$data) {
            \Log::info('Razorpay webhook: no matching payment request', [
                'order_id' => $orderId,
                'payment_id' => $paymentId,
            ]);
            return response()->json(['status' => true, 'message' => 'No matching payment request'], 200);
        }

        // IDEMPOTENCY: pehle se process ho chuka (browser callback)
        if ((int) $data->is_paid === 1) {
            return response()->json(['status' => true, 'message' => 'Already processed'], 200);
        }

        if ($payment === null) {
            return response()->json(['status' => true, 'message' => 'Payment not verifiable'], 200);
        }

        $expectedMinor = (int) round(((float) $data->payment_amount) * 100);
        $paidMinor = (int) ($payment['amount'] ?? 0);
        $paidCurrency = strtoupper((string) ($payment['currency'] ?? ''));
        $paidStatus = strtolower((string) ($payment['status'] ?? ''));

        if ($paidMinor < $expectedMinor
            || $paidCurrency !== strtoupper((string) $data->currency_code)
            || !in_array($paidStatus, ['captured', 'authorized'], true)) {
            \Log::warning('Razorpay webhook rejected (amount/currency/status mismatch)', [
                'payment_id' => $data->id,
                'expected_minor' => $expectedMinor,
                'paid_minor' => $paidMinor,
                'paid_currency' => $paidCurrency,
                'status' => $paidStatus,
            ]);
            return response()->json(['status' => true, 'message' => 'Rejected'], 200);
        }

        if (!$this->razorpayOrderMatches($data, $payment)) {
            \Log::warning('Razorpay webhook: payment does not belong to this request', [
                'payment_id' => $data->id,
                'razorpay_order' => $payment['order_id'] ?? null,
            ]);
            return response()->json(['status' => true, 'message' => 'Rejected'], 200);
        }

        // authorised payment ko capture karo
        if ($paidStatus === 'authorized') {
            try {
                $api->payment->fetch($paymentId)->capture(['amount' => $paidMinor]);
            } catch (\Throwable $e) {
                \Log::warning('Razorpay webhook capture failed: ' . $e->getMessage(), ['payment_id' => $data->id]);
                return response()->json(['status' => true, 'message' => 'Capture pending'], 200);
            }
        }

        $updated = $this->payment::where('id', $data->id)->where('is_paid', 0)->update([
            'payment_method' => 'razor_pay',
            'is_paid' => 1,
            'transaction_id' => $paymentId,
        ]);
        $data = $this->payment::where('id', $data->id)->first();
        if ($updated > 0 && isset($data) && function_exists($data->success_hook)) {
            call_user_func($data->success_hook, $data);
        }

        return response()->json(['status' => true], 200);
    }

    /**
     * PaymentRequest se Razorpay order id link karo (additional_data me).
     */
    private function persistRazorpayOrderId(PaymentRequest $data, string $orderId): void
    {
        if ($orderId === '') {
            return;
        }

        $additional = json_decode((string) $data->additional_data, true);
        if (!is_array($additional)) {
            $additional = [];
        }
        $additional['razorpay_order_id'] = $orderId;

        $data->additional_data = json_encode($additional);
        $data->saveQuietly();
    }

    /**
     * Razorpay order id se PaymentRequest dhoondo.
     * (a) create-order par humne order id PaymentRequest me save kiya tha
     * (b) warna Razorpay API se order fetch → notes/receipt se
     */
    private function findPaymentRequestByOrderId(string $orderId): ?PaymentRequest
    {
        if ($orderId === '') {
            return null;
        }

        // (a) additional_data me saved order id
        $saved = $this->payment::where('additional_data', 'like', '%' . $orderId . '%')
            ->orderByDesc('id')
            ->limit(50)
            ->get();
        foreach ($saved as $request) {
            $additional = json_decode((string) $request->additional_data, true);
            if (is_array($additional) && (string) ($additional['razorpay_order_id'] ?? '') === $orderId) {
                return $request;
            }
        }

        // (b) Razorpay API se order → receipt / notes
        try {
            $api = new Api(config('razor_config.api_key'), config('razor_config.api_secret'));
            $order = $api->order->fetch($orderId);
        } catch (\Throwable $e) {
            \Log::warning('Razorpay order fetch failed (webhook): ' . $e->getMessage());
            return null;
        }

        $notes = $order['notes'] ?? [];
        $notePaymentRequest = is_array($notes)
            ? (string) ($notes['payment_request_id'] ?? '')
            : (string) ($notes->payment_request_id ?? '');

        if ($notePaymentRequest !== '') {
            return $this->payment::where('id', $notePaymentRequest)->first();
        }

        $receipt = (string) ($order['receipt'] ?? '');
        if (str_starts_with($receipt, 'order_')) {
            return $this->payment::where('id', substr($receipt, 6))->first();
        }

        return null;
    }

    public function verifyPayment(Request $request): JsonResponse|Redirector|RedirectResponse|Application
    {
        $validator = Validator::make($request->all(), [
            'payment_request_id' => 'required|uuid',
            'payment_id' => 'required|string',
            'order_id' => 'required|string',
            'signature' => 'required|string',
        ]);

        if ($validator->fails()) {
            return redirect()->route('payment-fail');
        }

        $data = $this->payment::where(['id' => $request['payment_request_id']])->first();
        if (!isset($data)) {
            return redirect()->route('payment-fail');
        }

        if ((int) $data->is_paid === 1) {
            return $this->payment_response($data, 'success');
        }

        try {
            $api = new Api(config('razor_config.api_key'), config('razor_config.api_secret'));

            $api->utility->verifyPaymentSignature([
                'razorpay_order_id' => $request['order_id'],
                'razorpay_payment_id' => $request['payment_id'],
                'razorpay_signature' => $request['signature'],
            ]);

            $payment = $api->payment->fetch($request['payment_id']);
        } catch (\Throwable $exception) {
            \Log::warning('Razorpay verification failed: ' . $exception->getMessage(), ['payment_id' => $data->id]);
            return $this->payment_response($data, 'fail');
        }

        $expectedMinor = (int) round(((float) $data->payment_amount) * 100);
        $paidMinor = (int) ($payment['amount'] ?? 0);
        $paidCurrency = strtoupper((string) ($payment['currency'] ?? ''));
        $paidStatus = (string) ($payment['status'] ?? '');

        if (!$this->razorpayOrderMatches($data, $payment)) {
            \Log::warning('Razorpay verify: payment does not belong to this request', [
                'payment_id' => $data->id,
                'razorpay_order' => $payment['order_id'] ?? null,
            ]);
            return $this->payment_response($data, 'fail');
        }

        // Amount kam / currency alag / status captured-authorised nahi -> fail.
        if ($paidMinor < $expectedMinor
            || $paidCurrency !== strtoupper((string) $data->currency_code)
            || !in_array($paidStatus, ['captured', 'authorized'], true)) {
            \Log::warning('Razorpay verify rejected', [
                'payment_id' => $data->id,
                'expected_minor' => $expectedMinor,
                'paid_minor' => $paidMinor,
                'currency' => $paidCurrency,
                'status' => $paidStatus,
            ]);
            return $this->payment_response($data, 'fail');
        }

        // IDEMPOTENCY: sirf tab update+hook jab 0 se 1 transition ho
        $updated = $this->payment::where(['id' => $data->id])->where('is_paid', 0)->update([
            'payment_method' => 'razor_pay',
            'is_paid' => 1,
            'transaction_id' => $request['payment_id'],
        ]);
        $data = $this->payment::where(['id' => $data->id])->first();
        if ($updated > 0 && isset($data) && function_exists($data->success_hook)) {
            call_user_func($data->success_hook, $data);
        }
        return $this->payment_response($data, 'success');
    }

    public function callback(Request $request): JsonResponse|Redirector|RedirectResponse|Application
    {
        $input = $request->all();
        $data_id = $request->filled('payment_data')
            ? base64_decode((string) $request->payment_data, true)
            : null;

        if (count($input) && !empty($input['razorpay_payment_id'])) {
            $data = $this->payment::where(['id' => $data_id])->first();

            // IDEMPOTENCY: already paid -> success page, hook dobara mat chalao
            if (isset($data) && (int) $data->is_paid === 1) {
                return $this->payment_response($data, 'success');
            }

            if (isset($data)) {
                // SECURITY: callback par payment Razorpay API se verify karo
                // (existence + status + amount) — bina verify mark-paid = free booking.
                try {
                    $api = new Api(config('razor_config.api_key'), config('razor_config.api_secret'));
                    $rzPayment = $api->payment->fetch($input['razorpay_payment_id']);
                } catch (\Throwable $e) {
                    \Log::warning('RazorPay callback verify failed: ' . $e->getMessage());
                    return redirect()->route('payment-fail');
                }

                $expectedMinor = (int) round(((float) $data->payment_amount) * 100);
                $rzAmount = (int) ($rzPayment['amount'] ?? 0);
                $rzStatus = $rzPayment['status'] ?? '';
                $rzCurrency = strtoupper((string) ($rzPayment['currency'] ?? ''));

                if (!$this->razorpayOrderMatches($data, $rzPayment)) {
                    \Log::warning('RazorPay callback: payment does not belong to this request', [
                        'payment_id' => $data->id,
                        'razorpay_order' => $rzPayment['order_id'] ?? null,
                    ]);
                    return redirect()->route('payment-fail');
                }

                if ($rzAmount < $expectedMinor
                    || $rzCurrency !== strtoupper((string) $data->currency_code)
                    || !in_array($rzStatus, ['captured', 'authorized'], true)) {
                    \Log::warning('RazorPay callback rejected', [
                        'payment_id' => $data->id,
                        'expected' => $expectedMinor,
                        'got' => $rzAmount,
                        'status' => $rzStatus,
                    ]);
                    return redirect()->route('payment-fail');
                }

                $updated = $this->payment::where(['id' => $data_id])->where('is_paid', 0)->update([
                    'payment_method' => 'razor_pay',
                    'is_paid' => 1,
                    'transaction_id' => $input['razorpay_payment_id'],
                ]);
                $data = $this->payment::where(['id' => $data_id])->first();
                if ($updated > 0 && isset($data) && function_exists($data->success_hook)) {
                    call_user_func($data->success_hook, $data);
                }
                return $this->payment_response($data, 'success');
            }
        }
        return redirect()->route('payment-fail');
    }
    public function cancel(Request $request): JsonResponse|Redirector|RedirectResponse|Application
    {
        $payment_data = $this->payment::where(['id' => $request['payment_id']])->first();
        return $this->payment_response($payment_data, 'fail');
    }

    /**
     * Har Razorpay payment ek order se juda hota hai. Order ka receipt/notes
     * isi PaymentRequest ka hona chahiye, tabhi payment accept karo.
     */
    private function razorpayOrderMatches(PaymentRequest $data, $payment): bool
    {
        $orderId = (string) ($payment['order_id'] ?? '');
        if ($orderId === '') {
            return false;
        }

        try {
            $api = new Api(config('razor_config.api_key'), config('razor_config.api_secret'));
            $order = $api->order->fetch($orderId);
        } catch (\Throwable $exception) {
            \Log::warning('Razorpay order fetch failed: ' . $exception->getMessage());
            return false;
        }

        $receipt = (string) ($order['receipt'] ?? '');
        $notes = $order['notes'] ?? [];
        $notePaymentRequest = is_array($notes)
            ? (string) ($notes['payment_request_id'] ?? '')
            : (string) ($notes->payment_request_id ?? '');

        return $receipt === 'order_' . $data->id
            || $notePaymentRequest === (string) $data->id;
    }
}
