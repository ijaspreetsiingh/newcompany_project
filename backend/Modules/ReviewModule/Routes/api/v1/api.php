<?php

use Illuminate\Support\Facades\Route;
use Modules\ReviewModule\Http\Controllers\Api\V1\Customer\ReviewController;
use Modules\ReviewModule\Http\Controllers\Api\V1\Provider\ReviewController as ProviderReviewController;
use Modules\ReviewModule\Http\Controllers\Api\V1\Serviceman\ReviewController as ServicemanReviewController;

Route::group(['prefix' => 'partner', 'as' => 'provider.', 'namespace' => 'Api\V1\Provider', 'middleware' => ['auth:api', 'actch:provider_app']], function () {
    Route::group(['prefix' => 'feedback', 'as' => 'review.'], function () {
        Route::get('index', [ProviderReviewController::class, 'index']);
        Route::get('records/lookup', [ProviderReviewController::class, 'search']);
        Route::get('booking/{booking_id}', [ProviderReviewController::class, 'booking']);
        Route::get('serviceman-ratings', [ProviderReviewController::class, 'servicemanRatings']);
    });
});

//serviceman (technician) reviews
Route::group(['prefix' => 'technician', 'as' => 'serviceman.', 'namespace' => 'Api\V1\Serviceman', 'middleware' => ['auth:api', 'actch:serviceman_app']], function () {
    Route::group(['prefix' => 'feedback', 'as' => 'review.'], function () {
        Route::get('index', [ServicemanReviewController::class, 'index']);
        Route::get('booking/{booking_id}', [ServicemanReviewController::class, 'booking']);
    });
});


Route::group(['prefix' => 'client', 'as' => 'customer.', 'namespace' => 'Api\V1\Customer', 'middleware' => ['auth:api']], function () {
    Route::group(['prefix' => 'feedback', 'as' => 'review.'], function () {
        Route::get('/', [ReviewController::class, 'index']);
        Route::post('dispatch', [ReviewController::class, 'store']);
    });
});
