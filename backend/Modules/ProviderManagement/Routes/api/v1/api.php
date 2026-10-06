<?php

use Illuminate\Support\Facades\Route;
use Modules\ProviderManagement\Http\Controllers\Api\V1\Customer\FavoriteProviderController;
use Modules\ProviderManagement\Http\Controllers\Api\V1\Customer\ProviderController;
use Modules\ProviderManagement\Http\Controllers\Api\V1\Provider\CategoryAssignmentController;
use Modules\ProviderManagement\Http\Controllers\Api\V1\Provider\ConfigController as ProviderConfigController;
use Modules\ProviderManagement\Http\Controllers\Api\V1\Provider\Report\BookingReportController;
use Modules\ProviderManagement\Http\Controllers\Api\V1\Provider\Report\BusinessReportController;
use Modules\ProviderManagement\Http\Controllers\Api\V1\Provider\Report\TransactionReportController;
use Modules\ProviderManagement\Http\Controllers\Api\V1\Provider\TimeScheduleController;
use Modules\ProviderManagement\Http\Controllers\Api\V1\Provider\ProviderController as ProviderProviderController;
use Modules\ProviderManagement\Http\Controllers\Api\V1\Provider\ServiceController;
use Modules\ProviderManagement\Http\Controllers\Api\V1\Provider\AccountController;
use Modules\ProviderManagement\Http\Controllers\Api\V1\Provider\WithdrawController;
use Modules\ProviderManagement\Http\Controllers\Api\V1\Admin\ProviderController as AdminProviderController;



Route::group(['prefix' => 'partner', 'as' => 'provider.', 'namespace' => 'Api\V1\Provider'], function () {
    Route::post('secret-recovery', [ProviderProviderController::class, 'forgotPassword']);
    Route::post('pin-validation', [ProviderProviderController::class, 'otpVerification']);
    Route::put('secret-restore', [ProviderProviderController::class, 'resetPassword']);
    Route::post('locale-switch', [ProviderProviderController::class, 'changeLanguage']);
});

Route::group(['prefix' => 'partner', 'as' => 'provider.', 'namespace' => 'Api\V1\Provider', 'middleware' => ['auth:api', 'actch:provider_app']], function () {
    Route::get('/', [ProviderProviderController::class, 'index']);
    Route::get('overview', [ProviderProviderController::class, 'dashboard']);
    Route::get('overview/income', [ProviderProviderController::class, 'earningStatistics']);
    Route::get('fetch-bank-facts', [ProviderProviderController::class, 'getBankDetails']);
    Route::put('modify-bank-facts', [ProviderProviderController::class, 'updateBankDetails']);

    Route::get('setup', [ProviderConfigController::class, 'config'])->withoutMiddleware(['auth:api', 'actch:provider_app']);
    Route::get('setup/page-facts/{key}', [ProviderConfigController::class, 'pageDetails'])->withoutMiddleware('auth:api');

    Route::get('dossier', [ProviderProviderController::class, 'index']);
    Route::get('reconcile', [ProviderProviderController::class, 'adjust']);
    Route::get('alert-feed', [ProviderProviderController::class, 'notifications']);
    Route::put('modify/push-key', [ProviderProviderController::class, 'updateFcmToken']);
    Route::put('modify/account', [ProviderProviderController::class, 'updateProfile']);
    Route::put('modify/secret', [ProviderProviderController::class, 'updatePassword']);
    Route::post('modify/guide', [ProviderProviderController::class, 'updateTutorial']);
    Route::get('setup/fetch-paths', [ProviderConfigController::class, 'getRoutes']);
    Route::delete('erase', [ProviderProviderController::class, 'deleteProvider']);
    Route::get('ledger-entry', [ProviderProviderController::class, 'transaction']);
    Route::get('enrolled/child-groups', [ProviderProviderController::class, 'subscribedSubCategories']);

    // Category assignment: current tree + admin ko replace/change/cancel request
    Route::get('category-assignment', [CategoryAssignmentController::class, 'show']);
    Route::post('category-assignment/request', [CategoryAssignmentController::class, 'store']);

    Route::group(['prefix' => 'task', 'as' => 'service.',], function () {
        Route::post('modify-membership', [ServiceController::class, 'updateSubscription']);
    });

    Route::group(['prefix' => 'identity', 'as' => 'account.',], function () {
        Route::get('summary', [AccountController::class, 'overview']);
        Route::get('identity-refine', [AccountController::class, 'accountEdit']);
        Route::put('identity-modify', [AccountController::class, 'accountUpdate']);
        Route::get('payout-share-facts', [AccountController::class, 'commissionInfo']);
    });

//    Route::resource('payout', 'WithdrawController', ['only' => ['index', 'store']]);
    Route::get('/payout', [WithdrawController::class, 'index']);
    Route::post('/payout', [WithdrawController::class, 'store']);

    Route::group(['prefix' => 'pay-mode-record', 'as' => 'payment-information.'], function () {
        Route::get('browse', [WithdrawController::class, 'paymentInformationIndex'])->name('index');
        Route::post('save', [WithdrawController::class, 'paymentInformationStore'])->name('store');
        Route::get('revise/{id}', [WithdrawController::class, 'paymentInformationEdit'])->name('edit');
        Route::post('modify/{id}', [WithdrawController::class, 'paymentInformationUpdate'])->name('update');
        Route::get('state-change/{id}', [WithdrawController::class, 'paymentInformationStatusUpdate'])->name('status-update');
        Route::get('default-state-change/{id}', [WithdrawController::class, 'paymentInformationDefaultStatusUpdate'])->name('default-status-update');
        Route::delete('erase/{id}', [WithdrawController::class, 'paymentInformationDelete'])->name('delete');
    });

    Route::get('feedback', [ProviderProviderController::class, 'review']);

    Route::get('work-window-plan', [TimeScheduleController::class, 'getAvailableTimeSchedule']);
    Route::put('work-window-plan', [TimeScheduleController::class, 'setAvailableTimeSchedule']);

    //REPORT
    Route::group(['prefix' => 'statement', 'namespace' => 'Report'], function () {
        //Transaction Report
        Route::post('ledger-entry', [TransactionReportController::class, 'getTransactionReport']);
        Route::post('ledger-entry/export', [TransactionReportController::class, 'downloadTransactionReport']);

        //Booking Report
        Route::post('order', [BookingReportController::class, 'getBookingReport']);
        Route::post('order/export', [BookingReportController::class, 'getBookingReportDownload']);

        //Business Report
        Route::group(['prefix' => 'company', 'as' => 'business.'], function () {
            Route::post('summary', [BusinessReportController::class, 'getBusinessOverviewReport']);
            Route::post('income', [BusinessReportController::class, 'getBusinessEarningReport']);
            Route::post('cost-track', [BusinessReportController::class, 'getBusinessExpenseReport']);
        });
    });
});

Route::group(['prefix' => 'client', 'as' => 'customer.', 'namespace' => 'Api\V1\Customer'], function () {
    Route::group(['prefix' => 'partner', 'as' => 'provider.'], function () {
        Route::post('index', [ProviderController::class, 'getProviderList']);
        Route::get('index-by-childgroup', [ProviderController::class, 'getProviderListBySubCategory']);
        Route::get('search-radius', [ProviderController::class, 'searchRadius']);
    });

    Route::group(['prefix' => 'saved', 'as' => 'favorite.', 'middleware' => ['auth:api']], function () {
        Route::get('partner-index', [FavoriteProviderController::class, 'list']);
        Route::post('partner', [FavoriteProviderController::class, 'store']);
        Route::post('partner-remove/{provider_id}', [FavoriteProviderController::class, 'destroy']);
    });

    Route::get('partner-facts', [ProviderController::class, 'getProviderDetails']);

    Route::post('available-provider', [ProviderController::class, 'getAvailableProvider']);
    Route::post('available-service', [ProviderController::class, 'getAvailableService']);
    Route::post('reorder-facts', [ProviderController::class, 'rebookingInformation']);
});

//admin
Route::group(['prefix' => 'admin', 'as' => 'admin.', 'namespace' => 'Api\V1\Admin', 'middleware' => ['auth:api']], function () {
   // Route::resource('provider', 'ProviderController', ['only' => ['index', 'store', 'edit', 'update']]);
    Route::group(['prefix' => 'provider', 'as' => 'provider.',], function () {
        Route::get('data/overview/{user_id}', [AdminProviderController::class, 'overview']);
        Route::put('settings/update/{provider_id}', [AdminProviderController::class, 'settingsUpdate']);

        Route::put('status/update', [AdminProviderController::class, 'statusUpdate']);
        Route::delete('delete', [AdminProviderController::class, 'destroy']);
        Route::delete('remove-image', [AdminProviderController::class, 'removeImage']);

        Route::get('data/reviews/{provider_id}', [AdminProviderController::class, 'reviews']);
        Route::get('data/requests', [AdminProviderController::class, 'providerRequest']);
        Route::get('data/requests/search', [AdminProviderController::class, 'searchRequest']);
        Route::get('data/serviceman/list/{provider_id}', [AdminProviderController::class, 'servicemanList']);

        Route::get('data/bookings/{provider_id}', [AdminProviderController::class, 'bookings']);
        Route::get('subscribed/sub-categories/{provider_id}', [AdminProviderController::class, 'subscribedSubCategories']);
        Route::put('update-subscription/sub-categories/{provider_id}', [AdminProviderController::class, 'updateSubscription']);
    });
});
