<?php

use Illuminate\Support\Facades\Route;
use Modules\BusinessSettingsModule\Http\Controllers\Api\V1\Admin\ConfigurationController as AdminConfigurationController;
use Modules\BusinessSettingsModule\Http\Controllers\Api\V1\Admin\BusinessInformationController as AdminBusinessInformationController;
use Modules\BusinessSettingsModule\Http\Controllers\Api\V1\Provider\BusinessInformationController as ProviderBusinessInformationController;
use Modules\BusinessSettingsModule\Http\Controllers\Api\V1\Provider\ConfigurationController;
use Modules\BusinessSettingsModule\Http\Controllers\Api\V1\Provider\SubscriptionPackageController;


Route::group(['prefix' => 'admin', 'as' => 'admin.', 'namespace' => 'Api\V1\Admin', 'middleware' => ['auth:api']], function () {
    Route::group(['prefix' => 'business-settings'], function () {
        Route::get('get-business-information', [AdminBusinessInformationController::class, 'business_information_get']);
        Route::put('set-business-information', [AdminBusinessInformationController::class, 'business_information_set']);

        Route::get('get-service-setup', [AdminBusinessInformationController::class, 'service_setup_get']);
        Route::put('set-service-setup', [AdminBusinessInformationController::class, 'service_setup_set']);

        Route::get('get-pages-setup', [AdminBusinessInformationController::class, 'pages_setup_get']);
        Route::put('set-pages-setup', [AdminBusinessInformationController::class, 'pages_setup_set']);

        Route::get('get-notification-setting', [AdminConfigurationController::class, 'notification_settings_get']);
        Route::put('set-notification-setting', [AdminConfigurationController::class, 'notification_settings_set']);

        Route::get('get-email-config', [AdminConfigurationController::class, 'email_config_get']);
        Route::put('set-email-config', [AdminConfigurationController::class, 'email_config_set']);

        Route::get('get-third-party-config', [AdminConfigurationController::class, 'third_party_config_get']);
        Route::put('set-third-party-config', [AdminConfigurationController::class, 'third_party_config_set']);
    });
});

Route::group(['prefix' => 'partner', 'as' => 'provider.', 'middleware' => ['auth:api']], function () {
    Route::group(['prefix' => 'company-preferences'], function () {
        Route::get('fetch-company-preferences', [ProviderBusinessInformationController::class, 'businessSettingsGet']);
        Route::put('set-company-preferences', [ProviderBusinessInformationController::class, 'businessSettingsSet']);
    });
    Route::group(['prefix' => 'membership', 'as' => 'subscription.'], function () {
        Route::get('ledger',  [SubscriptionPackageController::class, 'transactions']);

        Route::group(['prefix' => 'plan', 'as' => 'package.'], function () {
            Route::get('index',  [SubscriptionPackageController::class, 'index'])->withoutMiddleware('auth:api');
            Route::get('subscriber-facts',  [SubscriptionPackageController::class, 'subscriber']);
            Route::post('extend',  [SubscriptionPackageController::class, 'renew']);
            Route::post('roster',  [SubscriptionPackageController::class, 'shift']);
            Route::post('procure',  [SubscriptionPackageController::class, 'purchase']);
            Route::post('payout-share',  [SubscriptionPackageController::class, 'commission']);
            Route::post('abort',  [SubscriptionPackageController::class, 'cancel']);
        });
    });

    Route::group(['prefix' => 'preferences', 'as' => 'configuration.'], function () {
        Route::get('fetch-alert-settings',  [ConfigurationController::class, 'notificationSettingsGet']);
        Route::post('modify-alert-state',  [ConfigurationController::class, 'updateStatus']);
    });
});
