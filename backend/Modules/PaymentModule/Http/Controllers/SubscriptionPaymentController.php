<?php

namespace Modules\PaymentModule\Http\Controllers;

use Illuminate\Contracts\Foundation\Application;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Routing\Redirector;
use Illuminate\Support\Facades\Validator;
use Modules\BusinessSettingsModule\Entities\SubscriptionPackage;
use Modules\PaymentModule\Library\Payer;
use Modules\PaymentModule\Library\Payment as Payment;
use Modules\PaymentModule\Library\Receiver;
use Modules\PaymentModule\Traits\Payment as PaymentTrait;
use Modules\ProviderManagement\Entities\Provider;
use Modules\UserManagement\Entities\User;

class SubscriptionPaymentController extends Controller
{
    /**
     * @param Request $request
     * @return JsonResponse|Redirector|RedirectResponse|Application
     */
    public function index(Request $request): JsonResponse|Redirector|RedirectResponse|Application
    {
        $validator = Validator::make($request->all(), [
            'payment_method' => 'required|in:' . implode(',', array_column(GATEWAYS_PAYMENT_METHODS, 'key')),
            'package_id' => 'required|uuid',
            'provider_id' => 'required|uuid',
            'package_status' => 'required|in:subscription_purchase,subscription_renew,subscription_shift,business_plan_change',
            'payment_platform' => 'nullable|in:web,app',
        ]);

        $safeCallback = paymentRedirectUrl($request['callback'] ?? null);

        if ($validator->fails()) {
            if ($safeCallback) return redirect($safeCallback . '?flag=fail');
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $isAdmin = auth()->check() && in_array(auth()->user()->user_type, ADMIN_USER_TYPES);
        // App flow token bhejta hai; web panel same domain session cookie ke
        // saath aata hai. Dono me se koi ek identity chahiye.
        $sessionUser = (!$isAdmin && auth()->check()) ? auth()->user() : null;
        $resolvedUser = resolveUserFromApiToken($request['access_token'] ?? null);
        $ownerUser = $resolvedUser ?? $sessionUser;

        if (!$isAdmin && !$ownerUser) {
            \Log::warning('Rejected unauthenticated subscription payment', ['ip' => $request->ip()]);
            if ($safeCallback) return redirect($safeCallback . '?flag=fail');
            return response()->json(response_formatter(DEFAULT_401), 401);
        }

        $provider = Provider::find($request['provider_id']);
        if (!$provider) {
            if ($safeCallback) return redirect($safeCallback . '?flag=fail');
            return response()->json(response_formatter(DEFAULT_400), 400);
        }

        // Sirf provider khud (ya admin) subscription pay kar sakta hai.
        if (!$isAdmin && (string) $provider->user_id !== (string) $ownerUser->id) {
            \Log::warning('Rejected subscription payment for another provider', ['ip' => $request->ip()]);
            if ($safeCallback) return redirect($safeCallback . '?flag=fail');
            return response()->json(response_formatter(DEFAULT_403), 403);
        }

        $package = SubscriptionPackage::where('id', $request['package_id'])->ofStatus(1)->first();
        if (!$package) {
            if ($safeCallback) return redirect($safeCallback . '?flag=fail');
            return response()->json(response_formatter(DEFAULT_400), 400);
        }

        // SECURITY: amount client se kabhi na lo; package price + VAT server par.
        $vatPercentage = (int) ((business_config('subscription_vat', 'subscription_Setting'))->live_values ?? 0);
        $amount = round((float) $package->price + ((float) $package->price * $vatPercentage / 100), 2);

        if ($amount <= 0) {
            if ($safeCallback) return redirect($safeCallback . '?flag=fail');
            return response()->json(response_formatter(DEFAULT_400), 400);
        }

        $request->merge([
            'amount' => $amount,
            'name' => $package->name,
        ]);

        $customer = User::find($provider->user_id);
        if (!$customer) {
            if ($safeCallback) return redirect($safeCallback . '?flag=fail');
            return response()->json(response_formatter(DEFAULT_400), 400);
        }

        $payer = new Payer($customer['first_name'] . ' ' . $customer['last_name'], $customer['email'], $customer['phone'], '');

        $additionalData = $request->all();
        $additionalData['access_token'] = base64_encode((string) $provider->user_id);
        $additionalData['amount'] = $amount;

        $payment_info = new Payment(
            success_hook: 'subscription_success',
            failure_hook: 'subscription_fail',
            currency_code: currency_code(),
            payment_method: $request['payment_method'],
            payment_platform: $request['payment_platform'],
            payer_id: $provider->user_id,
            receiver_id: null,
            additional_data: $additionalData,
            payment_amount: $amount,
            external_redirect_link: $safeCallback,
            attribute: 'provider_id',
            attribute_id: time()
        );

        $receiver_info = new Receiver('receiver_name', 'example.png');
        $redirect_link = PaymentTrait::generate_link($payer, $payment_info, $receiver_info);
        return redirect($redirect_link);
    }
}
