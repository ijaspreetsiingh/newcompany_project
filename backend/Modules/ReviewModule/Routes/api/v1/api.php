<?php

use Illuminate\Support\Facades\Route;
use Modules\ReviewModule\Http\Controllers\Api\V1\Customer\ReviewController;
use Modules\ReviewModule\Http\Controllers\Api\V1\Provider\ReviewController as ProviderReviewController;

Route::group(['prefix' => 'partner', 'as' => 'provider.', 'namespace' => 'Api\V1\Provider', 'middleware' => ['auth:api', 'actch:provider_app']], function () {
    Route::group(['prefix' => 'feedback', 'as' => 'review.',], function () {
        Route::get('index', [ProviderReviewController::class, 'index']);
        Route::get('records/lookup', [ProviderReviewController::class, 'search']);
    });
});


Route::group(['prefix' => 'client', 'as' => 'customer.', 'namespace' => 'Api\V1\Customer', 'middleware' => ['auth:api']], function () {
    Route::group(['prefix' => 'feedback', 'as' => 'review.',], function () {
        Route::get('/', [ReviewController::class, 'index']);
        Route::post('dispatch', [ReviewController::class, 'store']);
    });
});
