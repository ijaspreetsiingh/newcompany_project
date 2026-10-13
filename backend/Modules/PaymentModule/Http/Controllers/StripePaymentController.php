<?php

namespace Modules\PaymentModule\Http\Controllers;

use Stripe\Stripe;
use Illuminate\Http\Request;
use Stripe\Checkout\Session;
use Illuminate\Http\JsonResponse;
use Illuminate\Routing\Controller;
use Illuminate\Contracts\View\View;
use Illuminate\Contracts\View\Factory;
use Illuminate\Support\Facades\Validator;
use Modules\PaymentModule\Traits\Processor;
use Illuminate\Contracts\Foundation\Application;
use Modules\PaymentModule\Entities\PaymentRequest;

class StripePaymentController extends Controller
{
    use Processor;

    private $config_values;
    private PaymentRequest $payment;

    public function __construct(PaymentRequest $payment)
    {
        $config = $this->payment_config('stripe', 'payment_config');
        if (!is_null($config) && $config->mode == 'live') {
            $this->config_values = json_decode($config->live_values);
        } elseif (!is_null($config) && $config->mode == 'test') {
            $this->config_values = json_decode($config->test_values);
        }
        $this->payment = $payment;
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
        $config = $this->config_values;

        return view('paymentmodule::stripe', compact('data', 'config'));
    }

    public function payment_process_3d(Request $request): JsonResponse
    {
        $data = $this->payment::where(['id' => $request['payment_id']])->where(['is_paid' => 0])->first();
        if (!isset($data)) {
            return response()->json($this->response_formatter(GATEWAYS_DEFAULT_204), 200);
        }
        $payment_amount = $data['payment_amount'];

        Stripe::setApiKey($this->config_values->api_key);
        header('Content-Type: application/json');
        $currency_code = $data->currency_code;

        if ($data['additional_data'] != null) {
            $business = json_decode($data['additional_data']);
            $business_name = $business->business_name ?? "my_business";
            $business_logo = $business->business_logo ??  url('/');
        } else {
            $business_name = "my_business";
            $business_logo = url('/');
        }
        $business_name =  (business_config('business_name', 'business_information'))->live_values ?? 'my_business';
        //$business_logo = asset('storage/app/public/business').'/' . business_config('business_logo', 'business_information')?->live_values??"";
        $business_logo = getBusinessSettingsImageFullPath(key: 'business_logo', settingType: 'business_information', path: 'business/',  defaultPath : 'public/assets/admin-module/img/placeholder.png');

        $checkout_session = Session::create([
            'payment_method_types' => ['card'],
            'line_items' => [[
                'price_data' => [
                    'currency' => $currency_code ?? 'usd',
                    'unit_amount' => round($payment_amount, 2) * 100,
                    'product_data' => [
                        'name' => $business_name,
                        'images' => [$business_logo],
                    ],
                ],
                'quantity' => 1,
            ]],
            'mode' => 'payment',
            'success_url' => url('/') . '/payment/stripe/success?session_id={CHECKOUT_SESSION_ID}&payment_id=' . $data->id,
            'cancel_url' => url()->previous(),
            'metadata' => ['payment_id' => (string) $data->id],
        ]);

        return response()->json(['id' => $checkout_session->id]);
    }

    public function success(Request $request)
    {
        Stripe::setApiKey($this->config_values->api_key);
        $session = Session::retrieve($request->get('session_id'));

        $data = $this->payment::where(['id' => $request['payment_id']])->first();

        // IDEMPOTENCY: already paid -> success page dobara, hook dobara mat chalao
        if (isset($data) && (int) $data->is_paid === 1) {
            return $this->payment_response($data, 'success');
        }

        // SECURITY: session ko hamare payment row se bind karo (metadata + amount + currency)
        // bina verify session_id badal ke kisi aur ka payment mark nahi karwa sakta.
        $expectedMinor = (int) round(((float) ($data->payment_amount ?? 0)) * 100);
        $amountMatch = isset($data) && (int) ($session->amount_total ?? -1) === $expectedMinor;
        $currencyMatch = !isset($data) || ($session->currency ?? null) === null
            || strtolower((string) $session->currency) === strtolower((string) $data->currency_code);
        $metaPid = $session->metadata->payment_id ?? null;
        $metaMatch = $metaPid === null || $metaPid === (string) ($data->id ?? '');

        if ($session->payment_status == 'paid' && $session->status == 'complete' && $amountMatch && $currencyMatch && $metaMatch) {

            // IDEMPOTENCY: sirf tab update+hook jab 0 se 1 transition ho
            $updated = $this->payment::where(['id' => $request['payment_id']])->where('is_paid', 0)->update([
                'payment_method' => 'stripe',
                'is_paid' => 1,
                'transaction_id' => $session->payment_intent,
            ]);

            $data = $this->payment::where(['id' => $request['payment_id']])->first();

            if ($updated > 0 && isset($data) && function_exists($data->success_hook)) {
                call_user_func($data->success_hook, $data);
            }

            return $this->payment_response($data,'success');
        }

        \Log::warning('Stripe success rejected', [
            'payment_id' => $request['payment_id'] ?? null,
            'session_id' => $request->get('session_id'),
            'payment_status' => $session->payment_status ?? null,
            'amount_total' => $session->amount_total ?? null,
            'expected' => $expectedMinor ?? null,
        ]);

        $payment_data = $this->payment::where(['id' => $request['payment_id']])->first();
        if (isset($payment_data) && function_exists($payment_data->failure_hook)) {
            call_user_func($payment_data->failure_hook, $payment_data);
        }
        return isset($payment_data) ? $this->payment_response($payment_data, 'fail') : redirect()->route('payment-fail');
    }
}
