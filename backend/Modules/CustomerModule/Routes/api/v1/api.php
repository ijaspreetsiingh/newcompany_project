<?php

use Illuminate\Support\Facades\Route;
use Modules\CustomerModule\Http\Controllers\Api\V1\Customer\CustomerController;
use Modules\CustomerModule\Http\Controllers\Api\V1\Admin\CustomerController as AdminCustomerController;
use Modules\CustomerModule\Http\Controllers\Api\V1\Customer\SubscribeNewsletterController;
use Modules\CustomerModule\Http\Controllers\Api\V1\Customer\ConfigController;
use  Modules\CustomerModule\Http\Controllers\Api\V1\Customer\AddressController;


Route::group(['prefix' => 'admin', 'as'=>'admin.', 'namespace' => 'Api\V1\Admin','middleware'=>['auth:api']], function () {
//    Route::resource('customer', 'CustomerController', ['only' => ['index', 'store', 'edit', 'update']]);
    Route::group(['prefix' => 'customer', 'as' => 'customer.',], function () {
        Route::put('status/update', [AdminCustomerController::class, 'statusUpdate']);
        Route::delete('delete', [AdminCustomerController::class, 'destroy']);

        Route::group(['prefix' => 'data', 'as' => 'data.',], function () {
            Route::get('overview/{id}', [AdminCustomerController::class, 'overview']);
            Route::get('bookings/{id}', [AdminCustomerController::class, 'bookings']);
            Route::get('reviews/{id}', [AdminCustomerController::class, 'reviews']);

            Route::post('store-address', [AdminCustomerController::class, 'storeAddress']);
            Route::get('edit-address/{id}', [AdminCustomerController::class, 'editAddress']);
            Route::put('update-address/{id}', [AdminCustomerController::class, 'updateAddress']);
            Route::delete('delete/{id}', [AdminCustomerController::class, 'destroyAddress']);
        });

    });
});

Route::group(['prefix' => 'client', 'as' => 'customer.', 'namespace' => 'Api\V1\Customer'], function () {

    Route::post('alert-enroll-topic', [CustomerController::class, 'fcmSubscribeToTopic']);

    Route::group(['prefix' => 'setup'], function () {
        Route::get('/', [ConfigController::class, 'configuration']);
        Route::get('pages', [ConfigController::class, 'pages']);
        Route::get('page-facts/{key}', [ConfigController::class, 'pageDetails']);
        Route::get('fetch-region-id', [ConfigController::class, 'getZone']);
        Route::get('geo-suggest', [ConfigController::class, 'placeApiAutocomplete']);
        Route::get('distance-api', [ConfigController::class, 'distanceApi']);
        Route::get('geo-spot-facts', [ConfigController::class, 'placeApiDetails']);
        Route::get('geo-coder', [ConfigController::class, 'geocodeApi']);
    });

    Route::resource('place', 'AddressController', ['only' => ['index', 'store', 'edit', 'update', 'destroy']])->withoutMiddleware(['api:auth']);

    Route::withoutMiddleware(['api:auth'])->group(function () {
        Route::get('/place', [AddressController::class, 'index']);
        Route::post('/place', [AddressController::class, 'store']);
        Route::get('/place/{address}/edit', [AddressController::class, 'edit']);
        Route::put('/place/{address}', [AddressController::class, 'update']);
        Route::delete('/place/{address}', [AddressController::class, 'destroy']);
    });

    Route::group(['middleware' => ['auth:api']], function () {
        Route::get('dossier', [CustomerController::class, 'index']);
        Route::put('modify/account',[CustomerController::class, 'updateProfile']);
        Route::put('modify/push-key',[CustomerController::class, 'updateFcmToken']);
        Route::delete('account-delete', [CustomerController::class, 'removeAccount']);

        Route::post('reward-points/purse-move', [CustomerController::class, 'transferLoyaltyPointToWallet']);
        Route::get('purse-ledger', [CustomerController::class, 'walletTransaction']);
        Route::get('reward-points-ledger', [CustomerController::class, 'loyaltyPointTransaction']);
    });

    Route::post('locale-switch', [CustomerController::class, 'changeLanguage']);
    Route::post('broken-link', [CustomerController::class, 'errorLink']);

    Route::post('join-bulletin', [SubscribeNewsletterController::class, 'subscribeNewsletter'])->name('subscribe-newsletter');

});

