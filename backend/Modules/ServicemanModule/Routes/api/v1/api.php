<?php

use Illuminate\Support\Facades\Route;
use Modules\ServicemanModule\Http\Controllers\Api\V1\Serviceman\ConfigController as ServicemanConfigController;
use Modules\ServicemanModule\Http\Controllers\Api\V1\Provider\ServicemanController as ServicemanProviderController;
use Modules\ServicemanModule\Http\Controllers\Api\V1\Serviceman\ServicemanController;

//provider routes
Route::group(['prefix' => 'partner', 'as' => 'provider', 'namespace' => 'Api\V1\Provider', 'middleware' => ['auth:api', 'actch:provider_app']], function () {

    //serviceman
    Route::group(['prefix' => 'technician', 'as' => 'serviceman.'], function () {
        Route::get('/', [ServicemanProviderController::class, 'index']);
        Route::post('/', [ServicemanProviderController::class, 'store']);
        Route::get('{id}/revise', [ServicemanProviderController::class, 'edit']);
        Route::put('{id}', [ServicemanProviderController::class, 'update']);
        Route::get('{id}', [ServicemanProviderController::class, 'show']);

        Route::delete('erase', [ServicemanProviderController::class, 'destroy']);
        Route::put('state/modify', [ServicemanProviderController::class, 'changeActiveStatus']);
    });

});

//customer section
Route::group(['prefix' => 'technician', 'as' => 'serviceman.', 'namespace' => 'Api\V1\Serviceman'], function () {

    Route::post('secret-recovery', [ServicemanController::class, 'forgotPassword']);
    Route::post('pin-validation', [ServicemanController::class, 'otpVerification']);
    Route::put('secret-restore', [ServicemanController::class, 'resetPassword']);

    Route::group(['middleware' => ['auth:api', 'actch:serviceman_app']], function () {
        Route::get('overview', [ServicemanController::class, 'dashboard']);
        Route::get('overview/order-metrics', [ServicemanController::class, 'bookingStatistics']);

        Route::group(['prefix' => 'setup'], function () {
            Route::get('/', [ServicemanConfigController::class, 'configuration'])->withoutMiddleware(['auth:api', 'actch:serviceman_app']);
            Route::get('page-facts/{key}', [ServicemanConfigController::class, 'pageDetails'])->withoutMiddleware('auth:api');

            Route::get('fetch-region-id', [ServicemanConfigController::class, 'getZone']);
            Route::get('geo-suggest', [ServicemanConfigController::class, 'placeApiAutocomplete']);
            Route::get('range-api', [ServicemanConfigController::class, 'distanceApi']);
            Route::get('geo-spot-facts', [ServicemanConfigController::class, 'placeApiDetails']);
            Route::get('geo-coder', [ServicemanConfigController::class, 'geocodeApi']);
            Route::get('fetch-paths', [ServicemanConfigController::class, 'getRoutes']);
        });

        Route::get('dossier', [ServicemanController::class, 'index']);
        Route::put('modify/account', [ServicemanController::class, 'updateProfile']);
        Route::put('modify/push-key', [ServicemanController::class, 'updateFcmToken']);
        Route::put('modify/position', [ServicemanController::class, 'updateLocation']);
        Route::get('push-alerts', [ServicemanController::class, 'pushNotifications']);

        Route::group(['prefix' => 'account', 'middleware' => ['auth:api']], function () {
            Route::put('dossier', [ServicemanController::class, 'profileInfo']);
            Route::put('alter-secret', [ServicemanController::class, 'changePassword']);
        });
    });

    Route::post('locale-switch', [ServicemanController::class, 'changeLanguage']);
});

