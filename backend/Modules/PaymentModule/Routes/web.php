<?php

use App\Http\Middleware\VerifyCsrfToken;
use Illuminate\Support\Facades\Route;
use Modules\PaymentModule\Http\Controllers\CashfreeController;
use Modules\PaymentModule\Http\Controllers\PaytmController;
use Modules\PaymentModule\Http\Controllers\PaymentController;
use Modules\PaymentModule\Http\Controllers\PaystackController;
use Modules\PaymentModule\Http\Controllers\RazorPayController;
use Modules\PaymentModule\Http\Controllers\SenangPayController;
use Modules\PaymentModule\Http\Controllers\FlutterwaveV3Controller;
use Modules\PaymentModule\Http\Controllers\StripePaymentController;
use Modules\PaymentModule\Http\Controllers\SubscriptionPaymentController;
use Modules\PaymentModule\Http\Controllers\Web\Admin\BonusController;
use Modules\PaymentModule\Http\Controllers\SslCommerzPaymentController;
use Modules\PaymentModule\Http\Controllers\Web\Admin\PaymentConfigController;
use Modules\PaymentModule\Http\Controllers\Web\Admin\OfflinePaymentController;


$isPublished = 0;
try {
    $fullData = include('Modules/Gateways/Addon/info.php');
    $isPublished = $fullData['is_published'] == 1 ? 1 : 0;
} catch (\Exception $exception) {}


Route::match(['get', 'post'],'payment', [PaymentController::class, 'index'])->middleware('throttle:payment');
Route::match(['get', 'post'],'payment/subscription', [SubscriptionPaymentController::class, 'index'])->middleware('throttle:payment');

/*
 * LIVE GATEWAYS: sirf Razorpay aur Cashfree.
 *
 * Purane gateways (Stripe, SSLCommerz, Paystack, Paytm, Flutterwave,
 * SenangPay) ki routes hata di gayi hain. Admin panel me bhi wo select nahi
 * ho sakte, isliye koi direct URL se bhi unhe trigger nahi kar sakta.
 */
Route::group(['prefix' => 'payment', 'middleware' => 'throttle:payment'], function () {
    Route::match(['get', 'post'],'/', [PaymentController::class, 'index']);

    //RAZOR-PAY
    Route::group(['prefix' => 'razor-pay', 'as' => 'razor-pay.'], function () {
        Route::get('pay', [RazorPayController::class, 'index']);
        Route::post('payment', [RazorPayController::class, 'payment'])->name('payment')->withoutMiddleware([VerifyCsrfToken::class]);
        Route::post('callback', [RazorPayController::class, 'callback'])->name('callback')->withoutMiddleware([VerifyCsrfToken::class]);
        Route::any('cancel', [RazorPayController::class, 'cancel'])->name('cancel')->withoutMiddleware([VerifyCsrfToken::class]);
        Route::any('create-order', [RazorPayController::class, 'createOrder'])->name('create-order')->withoutMiddleware([VerifyCsrfToken::class]);
        Route::any('verify-payment', [RazorPayController::class, 'verifyPayment'])->name('verify-payment')->withoutMiddleware([VerifyCsrfToken::class]);
    });

    //CASHFREE
    Route::group(['prefix' => 'cashfree', 'as' => 'cashfree.'], function () {
        Route::get('pay', [CashfreeController::class, 'index'])->name('pay');
        Route::match(['get', 'post'], 'callback', [CashfreeController::class, 'callback'])->name('callback');
    });
});

// Webhook Cashfree ke servers se aata hai; IP throttle ke bahar rakha gaya
// hai taaki high traffic par bhi gateway ke retries block na hon.
Route::post('payment/cashfree/webhook', [CashfreeController::class, 'webhook'])
    ->name('cashfree.webhook')
    ->withoutMiddleware([VerifyCsrfToken::class]);

// Webhook Razorpay ke servers se aata hai (browser band hone par bhi booking
// ban jaati hai). Throttle group ke bahar + CSRF exempt.
Route::post('payment/razor-pay/webhook', [RazorPayController::class, 'webhook'])
    ->name('razor-pay.webhook')
    ->withoutMiddleware([VerifyCsrfToken::class]);

Route::get('payment-success', [PaymentController::class, 'success'])->name('payment-success');
Route::get('payment-fail', [PaymentController::class, 'fail'])->name('payment-fail');

/** Admin */
Route::group(['prefix' => 'admin', 'as' => 'admin.', 'namespace' => 'Web\Admin', 'middleware' => ['admin']], function () {
    Route::group(['prefix' => 'configuration', 'as' => 'configuration.'], function () {
        Route::put('payment-set', [PaymentConfigController::class, 'setPaymentConfig'])->name('payment-set');
        Route::post('update-payment-status/{gateway}/{status}', [PaymentConfigController::class, 'UpdateStatus'])->name('update-payment-status');

        Route::group(['prefix' => 'offline-payment', 'as'=>'offline-payment.'], function () {
            Route::any('list', [OfflinePaymentController::class, 'methodList'])->name('list');
            Route::get('create', [OfflinePaymentController::class, 'methodCreate'])->name('create');
            Route::post('store', [OfflinePaymentController::class, 'methodStore'])->name('store');
            Route::get('edit/{id}', [OfflinePaymentController::class, 'methodEdit'])->name('edit');
            Route::put('update', [OfflinePaymentController::class, 'methodUpdate'])->name('update');
            Route::delete('delete/{id}', [OfflinePaymentController::class, 'methodDestroy'])->name('delete');
            Route::any('status-update/{id}', [OfflinePaymentController::class, 'statusUpdate'])->name('status-update');
        });
    });

    Route::group(['prefix' => 'bonus', 'as' => 'bonus.'], function () {
        Route::any('list', [BonusController::class, 'list'])->name('list');
        Route::get('create', [BonusController::class, 'create'])->name('create');
        Route::post('store', [BonusController::class, 'store'])->name('store');
        Route::get('edit/{id}', [BonusController::class, 'edit'])->name('edit');
        Route::put('update/{id}', [BonusController::class, 'update'])->name('update');
        Route::delete('delete/{id}', [BonusController::class, 'destroy'])->name('delete');
        Route::any('status-update/{id}', [BonusController::class, 'statusUpdate'])->name('status-update');
        Route::any('download', [BonusController::class, 'download'])->name('download');
    });
});
