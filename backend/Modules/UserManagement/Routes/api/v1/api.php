<?php

use Illuminate\Support\Facades\Route;
use Modules\UserManagement\Http\Controllers\Api\V1\OTPVerificationController;
use Modules\UserManagement\Http\Controllers\Api\V1\PasswordResetController;
use Modules\UserManagement\Http\Controllers\Api\V1\Admin\UserController;

//admin
Route::group(['prefix' => 'admin', 'as' => 'admin.', 'namespace' => 'Api\V1\Admin', 'middleware' => ['auth:api']], function () {
    Route::group(['prefix' => 'user', 'as' => 'user.',], function () {
        Route::get('list', [UserController::class, 'index']);
    });
});


//User
Route::group(['prefix' => 'member', 'namespace' => 'Api\V1'], function () {
    //verification
    Route::group(['prefix' => 'validation'], function () {
        Route::post('transmit-pin', [OTPVerificationController::class, 'check']);
        Route::post('check-pin', [OTPVerificationController::class, 'verify']);

        Route::post('firebase-access-check', [OTPVerificationController::class, 'firebaseAuthVerify']);
        Route::post('signin-pin-check', [OTPVerificationController::class, 'loginVerifyOTP']);
        Route::post('signup-with-pin', [OTPVerificationController::class, 'registrationWithOTP']);
    });

    //forget password
    Route::group(['prefix' => 'lost-secret'], function () {
        Route::post('transmit-pin', [PasswordResetController::class, 'check']);
        Route::post('check-pin', [PasswordResetController::class, 'verify']);
        Route::put('restore', [PasswordResetController::class, 'resetPassword']);
    });

    Route::post('verify-member-exists', [OTPVerificationController::class, 'checkExistingCustomer']);
});

