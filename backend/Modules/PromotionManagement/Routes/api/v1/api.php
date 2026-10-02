<?php

use Illuminate\Support\Facades\Route;
use Modules\PromotionManagement\Http\Controllers\Api\V1\Customer\CouponController;
use Modules\PromotionManagement\Http\Controllers\Api\V1\Admin\DiscountController;
use Modules\PromotionManagement\Http\Controllers\Api\V1\Admin\CouponController as AdminCouponController;
use Modules\PromotionManagement\Http\Controllers\Api\V1\Admin\CampaignController as AdminCampaignController;
use Modules\PromotionManagement\Http\Controllers\Api\V1\Admin\BannerController as AdminBannerController;
use Modules\PromotionManagement\Http\Controllers\Api\V1\Admin\PushNotificationController as AdminPushNotificationController;
use Modules\PromotionManagement\Http\Controllers\Api\V1\Customer\BannerController;
use Modules\PromotionManagement\Http\Controllers\Api\V1\Customer\CampaignController;
use Modules\PromotionManagement\Http\Controllers\Api\V1\Customer\AdvertisementsController;
use Modules\PromotionManagement\Http\Controllers\Api\V1\Provider\AdvertisementsController as ProviderAdvertisementsController;

Route::group(['prefix' => 'admin', 'as' => 'admin.', 'namespace' => 'Api\V1\Admin', 'middleware' => ['auth:api']], function () {
    // Route::resource('discount', 'DiscountController', ['only' => ['index', 'store', 'edit', 'update']]);
    Route::group(['prefix' => 'discount', 'as' => 'discount.',], function () {
        Route::put('status/update', [DiscountController::class, 'statusUpdate']);
        Route::delete('delete', [DiscountController::class, 'destroy']);
    });

//    Route::resource('coupon', 'CouponController', ['only' => ['index', 'store', 'edit', 'update']]);
    Route::group(['prefix' => 'coupon', 'as' => 'coupon.',], function () {
        Route::get('config', [AdminCouponController::class, 'config']);
        Route::put('status/update', [AdminCouponController::class, 'statusUpdate']);
        Route::delete('delete', [AdminCouponController::class, 'destroy']);
    });

//    Route::resource('campaign', 'CampaignController', ['only' => ['index', 'store', 'edit', 'update']]);
    Route::group(['prefix' => 'campaign', 'as' => 'campaign.',], function () {
        Route::put('status/update', [AdminCampaignController::class, 'statusUpdate']);
        Route::delete('delete', [AdminCampaignController::class, 'destroy']);
    });

//    Route::resource('banner', 'BannerController', ['only' => ['index', 'store', 'edit', 'update']]);
    Route::group(['prefix' => 'banner', 'as' => 'banner.',], function () {
        Route::put('status/update', [AdminBannerController::class, 'statusUpdate']);
        Route::delete('delete', [AdminBannerController::class, 'destroy']);
    });

//    Route::resource('push-notification', 'PushNotificationController', ['only' => ['index', 'store', 'edit', 'update']]);
    Route::group(['prefix' => 'push-notification', 'as' => 'push-notification.',], function () {
        Route::put('status/update', [AdminPushNotificationController::class, 'statusUpdate']);
        Route::delete('delete', [AdminPushNotificationController::class, 'destroy']);
    });
});

Route::group(['prefix' => 'client', 'as' => 'customer.', 'namespace' => 'Api\V1\Customer'], function () {
    Route::group(['prefix' => 'carousel', 'as' => 'banner.',], function () {
        Route::get('/', [BannerController::class, 'index']);
    });

    Route::group(['prefix' => 'alerts', 'as' => 'notification.',], function () {
        Route::get('/', 'NotificationController@index');
    });

//    Route::resource('promo', 'CouponController', ['only' => ['index']]);
    Route::prefix('promo')->as('coupon.')->group(function () {
        Route::get('/', [CouponController::class, 'index']);
        Route::get('delete', [CouponController::class, 'removeCoupon']);
        Route::post('redeem', [CouponController::class, 'applyCoupon']);
        Route::get('applicable', [CouponController::class, 'applicable']);
    });

//    Route::resource('drive', 'CampaignController', ['only' => ['index']]);
    Route::group(['prefix' => 'drive', 'as' => 'campaign.', 'middleware' => ['auth:api']], function () {
        Route::get('/', [CampaignController::class, 'index'])->withoutMiddleware('auth:api');
        Route::get('records/entries', [CampaignController::class, 'campaignItems'])->withoutMiddleware('auth:api');
    });

    Route::group(['prefix' => 'showcases', 'as' => 'advertisements.'], function () {
        Route::get('showcase-feed', [AdvertisementsController::class, 'AdsList']);
    });
});

Route::group(['prefix' => 'partner', 'as' => 'provider.', 'namespace' => 'Api\V1\Provider', 'middleware' => ['auth:api', 'actch:provider_app']], function () {
    Route::group(['prefix' => 'showcases', 'as' => 'advertisements.'], function () {
        Route::get('showcase-feed', [ProviderAdvertisementsController::class, 'AdsList']);
        Route::post('showcase-save', [ProviderAdvertisementsController::class, 'AdsStore']);
        Route::get('breakdown/{id}', [ProviderAdvertisementsController::class, 'details']);
        Route::get('revise/{id}', [ProviderAdvertisementsController::class, 'edit']);
        Route::put('modify/{id}', [ProviderAdvertisementsController::class, 'update']);
        Route::any('state-change/{id}/{type}', [ProviderAdvertisementsController::class, 'statusUpdate']);
        Route::delete('erase/{id}', [ProviderAdvertisementsController::class, 'destroy']);
        Route::post('save-resubmit/{id}', [ProviderAdvertisementsController::class, 'storeReSubmit']);
    });
});
