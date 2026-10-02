<?php

use Illuminate\Support\Facades\Route;
use Modules\CartModule\Http\Controllers\Api\V1\Customer\CartController;


Route::group(['prefix' => 'client', 'as' => 'customer.', 'namespace' => 'Api\V1\Customer'], function () {
    Route::group(['prefix' => 'basket', 'as' => 'cart.',], function () {
        Route::post('insert', [CartController::class, 'addToCart']);
        Route::get('index', [CartController::class, 'list']);
        Route::put('modify-count/{id}', [CartController::class, 'updateQty']);
        Route::put('modify/partner', [CartController::class, 'updateProvider']);
        Route::delete('delete/{id}', [CartController::class, 'remove']);
        Route::delete('records/wipe', [CartController::class, 'emptyCart']);
    });

    Route::group(['prefix' => 'reorder', 'as' => 'rebook.',], function () {
        Route::post('basket-attach', [CartController::class, 'rebookAddToCart']);
    });
});

