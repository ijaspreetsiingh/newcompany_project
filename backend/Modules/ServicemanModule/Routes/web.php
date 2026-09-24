<?php

use Illuminate\Support\Facades\Route;
use Modules\ServicemanModule\Http\Controllers\Web\Provider\ServicemanController;
use Modules\ServicemanModule\Http\Controllers\Web\Serviceman\ServicemanPanelController;

Route::group(['prefix' => 'provider', 'as' => 'provider.', 'namespace' => 'Web\Provider', 'middleware' => ['provider']], function () {

    Route::group(['prefix' => 'serviceman', 'as' => 'serviceman.'], function () {
        Route::any('/list', [ServicemanController::class, 'index'])->name('list');
        Route::get('create', [ServicemanController::class, 'create'])->name('create');
        Route::post('store', [ServicemanController::class, 'store'])->name('store');
        Route::get('show/{id}', [ServicemanController::class, 'show'])->name('show');
        Route::get('edit/{id}', [ServicemanController::class, 'edit'])->name('edit');
        Route::put('update/{id}', [ServicemanController::class, 'update'])->name('update');
        Route::any('status-update/{id}', [ServicemanController::class, 'statusUpdate'])->name('status-update');
        Route::delete('delete/{id}', [ServicemanController::class, 'destroy'])->name('delete');
        Route::any('download', [ServicemanController::class, 'download'])->name('download');
    });
});

Route::group(['prefix' => 'serviceman', 'as' => 'serviceman.', 'namespace' => 'Web\Serviceman', 'middleware' => ['serviceman']], function () {
    Route::get('dashboard', [ServicemanPanelController::class, 'dashboard'])->name('dashboard');

    Route::group(['prefix' => 'booking', 'as' => 'booking.'], function () {
        Route::get('list', [ServicemanPanelController::class, 'bookingList'])->name('list');
        Route::get('details/{id}', [ServicemanPanelController::class, 'bookingDetails'])->name('details');
        Route::post('status-update', [ServicemanPanelController::class, 'statusUpdate'])->name('status-update');
    });

    Route::post('update-location', [ServicemanPanelController::class, 'updateLocation'])->name('update-location');

    Route::group(['prefix' => 'profile', 'as' => 'profile.'], function () {
        Route::get('/', [ServicemanPanelController::class, 'profile'])->name('index');
        Route::post('update', [ServicemanPanelController::class, 'updateProfile'])->name('update');
        Route::post('change-password', [ServicemanPanelController::class, 'changePassword'])->name('change-password');
    });
});

