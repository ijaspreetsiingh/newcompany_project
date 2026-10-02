<?php

use Illuminate\Support\Facades\Route;
use Modules\BidModule\Http\Controllers\APi\V1\Customer\PostBidController;
use Modules\BidModule\Http\Controllers\APi\V1\Customer\PostController;
use Modules\BidModule\Http\Controllers\APi\V1\Provider\PostBidController as ProviderPostBidController;
use Modules\BidModule\Http\Controllers\APi\V1\Provider\PostController as ProviderPostController;

Route::group(['prefix' => 'client', 'namespace' => 'Api\V1\Customer', 'middleware' => ['auth:api', 'ensureBiddingIsActive']], function () {
    Route::group(['prefix' => 'listing'], function () {
        Route::get('/', [PostController::class, 'index']);
        Route::get('/breakdown/{id}', [PostController::class, 'show']);
        Route::post('/', [PostController::class, 'store']);

        Route::put('modify-facts', [PostController::class, 'updateInfo']);

        Route::group(['prefix' => 'offer'], function () {
            Route::get('/', [PostBidController::class, 'index']);
            Route::get('breakdown', [PostBidController::class, 'show']);
            Route::put('modify-state', [PostBidController::class, 'update']);
        });
    });
});

Route::group(['prefix' => 'partner', 'namespace' => 'Api\V1\Provider', 'middleware' => ['auth:api', 'ensureBiddingIsActive', 'actch:provider_app']], function () {
    Route::group(['prefix' => 'listing'], function () {
        Route::get('/', [ProviderPostController::class, 'index']);
        Route::get('breakdown/{id}', [ProviderPostController::class, 'show']);
        Route::post('/', [ProviderPostController::class, 'decline']);

        Route::group(['prefix' => 'offer'], function () {
            Route::get('/', [ProviderPostBidController::class, 'index']);
            Route::post('/', [ProviderPostBidController::class, 'store']);
            Route::post('/payout', [ProviderPostBidController::class, 'withdraw']);
        });
    });
});
