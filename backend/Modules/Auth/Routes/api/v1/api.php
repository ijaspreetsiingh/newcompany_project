<?php

use Illuminate\Support\Facades\Route;
use Modules\Auth\Http\Controllers\Api\V1\LoginController;
use Modules\Auth\Http\Controllers\Api\V1\RegisterController;

Route::group(['prefix' => 'admin', 'as' => 'admin', 'namespace' => 'Api\V1'], function () {

    Route::group(['prefix' => 'auth', 'as' => 'auth.'], function () {
        Route::post('login', [LoginController::class, 'adminLogin'])->name('login');
    });

});

Route::group(['prefix' => 'partner', 'as' => 'provider', 'namespace' => 'Api\V1', 'middleware' => ['actch:provider_app']], function () {
    Route::group(['prefix' => 'access', 'as' => 'auth.'], function () {
        Route::post('signup', [RegisterController::class, 'providerRegister'])->name('registration');
        Route::post('signin', [LoginController::class, 'providerLogin'])->name('login');
    });
});

Route::group(['prefix' => 'client', 'as' => 'customer', 'namespace' => 'Api\V1'], function () {
    Route::group(['prefix' => 'access', 'as' => 'auth.'], function () {
        Route::post('signup', [RegisterController::class, 'customerRegister'])->name('registration');
        Route::post('signin', [LoginController::class, 'customerLogin'])->name('login');
        Route::post('signin-via-social', [LoginController::class, 'customerSocialLogin'])->name('social-login');
        Route::post('account-probe', [LoginController::class, 'existingAccountCheck']);
        Route::post('signup-via-social', [LoginController::class, 'registrationWithSocialMedia']);
        Route::post('signout', [LoginController::class, 'customerLogOut'])->middleware('auth:api');
    });
});

Route::group(['prefix' => 'technician', 'as' => 'serviceman', 'namespace' => 'Api\V1', 'middleware' => ['actch:serviceman_app']], function () {
    Route::group(['prefix' => 'access', 'as' => 'auth.'], function () {
        Route::post('signin', [LoginController::class, 'servicemanLogin'])->name('login');
    });
});


Route::group(['prefix' => 'member', 'as' => 'user.', 'middleware' => ['auth:api'], 'namespace' => 'Api\V1'], function () {
    Route::post('signout', [LoginController::class, 'logout'])->name('logout');
});

