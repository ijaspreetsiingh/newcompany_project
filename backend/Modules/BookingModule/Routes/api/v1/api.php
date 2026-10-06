<?php

use Illuminate\Support\Facades\Route;
use Modules\BookingModule\Http\Controllers\Api\V1\Customer\BookingController;
use Modules\BookingModule\Http\Controllers\Api\V1\Provider\BookingController as ProviderBookingController;
use Modules\BookingModule\Http\Controllers\Api\V1\Serviceman\BookingController as ServicemanBookingController;
use Modules\BookingModule\Http\Controllers\Api\V1\Admin\BookingController as AdminBookingController;
use Modules\BookingModule\Http\Controllers\Api\V1\BookingRecheckController;

Route::group(['prefix' => 'client', 'as' => 'customer.', 'namespace' => 'Api\V1\Customer', 'middleware' => ['auth:api']], function () {
    Route::group(['prefix' => 'order', 'as' => 'booking.'], function () {
        Route::get('/', [BookingController::class, 'index']);
        Route::get('/{booking_id}', [BookingController::class, 'show']);
        Route::get('individual/{booking_id}', [BookingController::class, 'singleDetails']);
        Route::post('submission/transmit', [BookingController::class, 'placeRequest'])->middleware('hitLimiter')->withoutMiddleware('auth:api');
        Route::put('state-change/{booking_id}', [BookingController::class, 'statusUpdate']);
        Route::post('individual-recurring-abort/{repeat_id}', [BookingController::class, 'singleBookingCancel']);
        Route::post('trace/{readable_id}', [BookingController::class, 'track'])->withoutMiddleware('auth:api');
        Route::post('persist-cash-record', [BookingController::class, 'storeOfflinePaymentData'])->withoutMiddleware('auth:api');
        Route::post('change-pay-mode', [BookingController::class, 'switchPaymentMethod'])->withoutMiddleware('auth:api');
        Route::get('serviceman-location/{booking_id}', [BookingController::class, 'servicemanLocation']);

        // ----- RECHECK (15 din ka window) -----
        Route::post('recheck/{booking_id}', [BookingRecheckController::class, 'requestRecheck']);
        Route::get('recheck-status/{booking_id}', [BookingRecheckController::class, 'recheckStatus']);
    });
});
Route::any('gateway-booking-reply', [BookingController::class, 'digitalPaymentBookingResponse']);

Route::group(['prefix' => 'admin', 'as' => 'admin.', 'namespace' => 'Api\V1\Admin', 'middleware' => ['auth:api']], function () {
    Route::group(['prefix' => 'booking', 'as' => 'booking.'], function () {
        Route::post('/', [AdminBookingController::class, 'index']);
        Route::get('{id}', [AdminBookingController::class, 'show']);
        Route::put('status-update/{booking_id}', [AdminBookingController::class, 'status_update']);
        Route::put('schedule-update/{booking_id}', [AdminBookingController::class, 'schedule_update']);
        Route::get('data/download', [AdminBookingController::class, 'download']);
    });
});

Route::group(['prefix' => 'partner', 'as' => 'provider.', 'namespace' => 'Api\V1\Provider', 'middleware' => ['auth:api', 'actch:provider_app']], function () {
    Route::group(['prefix' => 'order', 'as' => 'booking.'], function () {
        Route::post('/', [ProviderBookingController::class, 'index']);
        Route::get('{id}', [ProviderBookingController::class, 'show']);
        Route::get('individual/{id}', [ProviderBookingController::class, 'singleDetails']);
        Route::put('submission-approve/{booking_id}', [ProviderBookingController::class, 'requestAccept']);
        Route::post('submission-dismiss/{booking_id}', [ProviderBookingController::class, 'requestIgnore']);
        Route::post('individual-recurring-abort/{repeat_id}', [ProviderBookingController::class, 'singleBookingCancel']);
        Route::put('individual-recurring-state-change/{repeat_id}', [ProviderBookingController::class, 'singleBookingStatusUpdate']);
        Route::put('state-change/{booking_id}', [ProviderBookingController::class, 'statusUpdate']);
        Route::put('timetable-modify/{booking_id}', [ProviderBookingController::class, 'scheduleUpdate']);
        Route::put('assign-technician/{booking_id}', [ProviderBookingController::class, 'assignServiceman']);
        Route::get('assign-suggestions/{booking_id}', [ProviderBookingController::class, 'assignSuggestions']);
        Route::put('assign-servicemen/{booking_id}', [ProviderBookingController::class, 'assignServicemen']);
        Route::get('records/export', [ProviderBookingController::class, 'download']);
        Route::get('one-time-pin/alert-dispatch', [ProviderBookingController::class, 'notificationSend']);
        Route::get('task/dossier', [ProviderBookingController::class, 'getServiceInfo']);
        Route::put('task/revise/modify-order', [ProviderBookingController::class, 'updateBooking']);
        Route::put('recurring/task/revise/modify-order', [ProviderBookingController::class, 'updateBookingRepeat']);
        Route::put('task/revise/task-detach', [ProviderBookingController::class, 'removeService']);
        Route::post('change-task-position', [ProviderBookingController::class, 'changeServiceLocation']);
        Route::get('scheduler/preview', [ProviderBookingController::class, 'bookingCalendar']);        // ----- AUTO-ASSIGN -----
        Route::put('auto-assign-switch', [ProviderBookingController::class, 'toggleAutoAssign']);
        Route::put('auto-assign-delay-window', [ProviderBookingController::class, 'updateAutoAssignWaitTime']);
        Route::get('auto-assign-state/{booking_id}', [ProviderBookingController::class, 'getAutoAssignStatus']);

        // ----- RECHECK DASHBOARD -----
        Route::get('recheck-summary', [BookingRecheckController::class, 'providerRecheckSummary']);
    });
});


Route::group(['prefix' => 'technician', 'as' => 'serviceman.', 'namespace' => 'Api\V1\Serviceman', 'middleware' => ['auth:api', 'actch:serviceman_app']], function () {
    Route::group(['prefix' => 'order', 'as' => 'booking.'], function () {
        Route::put('state-change/{booking_id}', [ServicemanBookingController::class, 'statusUpdate']);
        Route::put('individual-recurring-state-change/{booking_id}', [ServicemanBookingController::class, 'singleBookingStatusUpdate']);
        Route::put('pay-state-change/{booking_id}', [ServicemanBookingController::class, 'paymentStatusUpdate']);
        Route::get('index', [ServicemanBookingController::class, 'bookingList']);
        Route::get('info/{id}', [ServicemanBookingController::class, 'bookingDetails']);
        Route::get('individual/info/{id}', [ServicemanBookingController::class, 'singleBookingDetails']);
        Route::get('one-time-pin/alert-dispatch', [ServicemanBookingController::class, 'notificationSend']);
        Route::get('task/dossier', [ServicemanBookingController::class, 'getServiceInfo']);
        Route::put('task/revise/modify-order', [ServicemanBookingController::class, 'updateBooking']);
        Route::put('recurring/task/revise/modify-order', [ServicemanBookingController::class, 'updateBookingRepeat']);
        Route::put('task/revise/task-detach', [ServicemanBookingController::class, 'removeService']);

        // ----- SERVICEMAN ACCEPT / REJECT -----
        Route::put('approve/{booking_id}', [ServicemanBookingController::class, 'acceptBooking']);
        Route::put('decline/{booking_id}', [ServicemanBookingController::class, 'rejectBooking']);

        // ----- RECHECK TASKS -----
        Route::get('recheck-list', [BookingRecheckController::class, 'servicemanRecheckList']);
        Route::put('recheck/{recheck_id}', [BookingRecheckController::class, 'servicemanRecheckUpdate']);
    });
});
