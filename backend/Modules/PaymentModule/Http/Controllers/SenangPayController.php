<?php

namespace Modules\PaymentModule\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Routing\Controller;
use Illuminate\Routing\Redirector;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Contracts\View\Factory;
use Illuminate\Support\Facades\Validator;
use Modules\PaymentModule\Traits\Processor;
use Illuminate\Contracts\Foundation\Application;
use Modules\PaymentModule\Entities\PaymentRequest;

class SenangPayController extends Controller
{
    use Processor;

    private $config_values;

    private PaymentRequest $payment;
    private $user;

    public function __construct(PaymentRequest $payment, User $user)
    {
        $config = $this->payment_config('senang_pay', 'payment_config');
        if (!is_null($config) && $config->mode == 'live') {
            $this->config_values = json_decode($config->live_values);
        } elseif (!is_null($config) && $config->mode == 'test') {
            $this->config_values = json_decode($config->test_values);
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

        $payment_data = $this->payment::where(['id' => $request['payment_id']])->where(['is_paid' => 0])->first();
        if (!isset($payment_data)) {
            return response()->json($this->response_formatter(GATEWAYS_DEFAULT_204), 200);
        }
        $payer = json_decode($payment_data['payer_information']);
        $config = $this->config_values;
        session()->put('payment_id', $payment_data->id);
        return view('paymentmodule::senang-pay', compact('payment_data', 'payer', 'config'));
    }

    public function return_senang_pay(Request $request): JsonResponse|Redirector|RedirectResponse|Application
    {
        $paymentId = session()->get('payment_id');
        $data = $this->payment::where(['id' => $paymentId])->first();

        // IDEMPOTENCY: already paid -> success page dobara, hook dobara mat chalao
        if (isset($data) && (int) $data->is_paid === 1) {
            return $this->payment_response($data, 'success');
        }

        if ($request['status_id'] == 1) {
            // SECURITY: SenangPay callback hash verify karo (docs: md5(secret_key . status_id . order_id . transaction_id . msg))
            // bina verify mark-paid = attacker fake status_id=1 bhej ke free booking le sakta tha.
            $secret = (string) ($this->config_values->secret_key ?? '');
            $receivedHash = (string) ($request['hash'] ?? '');
            $expectedHash = md5(
                $secret
                . $request['status_id']
                . $request['order_id']
                . $request['transaction_id']
                . $request['msg']
            );

            if ($receivedHash === '' || !hash_equals($expectedHash, $receivedHash)) {
                \Log::warning('SenangPay callback hash mismatch', [
                    'payment_id' => $paymentId,
                    'order_id' => $request['order_id'] ?? null,
                ]);
                // null payment row par payment_response crash hota hai (pre-existing) — guard
                return isset($data) ? $this->payment_response($data, 'fail') : redirect()->route('payment-fail');
            }

            // Amount check: callback amount booking amount se match honi chahiye
            $expected = (float) ($data->payment_amount ?? 0);
            $callbackAmount = (float) ($request['amount'] ?? -1);
            if (abs($callbackAmount - $expected) > 0.01) {
                \Log::warning('SenangPay amount mismatch', [
                    'payment_id' => $paymentId,
                    'expected' => $expected,
                    'got' => $callbackAmount,
                ]);
                return isset($data) ? $this->payment_response($data, 'fail') : redirect()->route('payment-fail');
            }

            // IDEMPOTENCY: sirf tab update+hook jab 0 se 1 transition ho
            $updated = $this->payment::where(['id' => $paymentId])->where('is_paid', 0)->update([
                'payment_method' => 'senang_pay',
                'is_paid' => 1,
                'transaction_id' => $request['transaction_id'],
            ]);
            $data = $this->payment::where(['id' => $paymentId])->first();
            if ($updated > 0 && isset($data) && function_exists($data->success_hook)) {
                call_user_func($data->success_hook, $data);
            }
            return $this->payment_response($data, 'success');
        }
        $payment_data = $this->payment::where(['id' => $paymentId])->first();
        if (isset($payment_data) && function_exists($payment_data->failure_hook)) {
            call_user_func($payment_data->failure_hook, $payment_data);
        }
        return isset($payment_data) ? $this->payment_response($payment_data, 'fail') : redirect()->route('payment-fail');
    }
}
