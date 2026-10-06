<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;

/*
|--------------------------------------------------------------------------
| Console Routes
|--------------------------------------------------------------------------
|
| This file is where you may define all of your Closure based console
| commands. Each Closure is bound to a command instance allowing a
| simple approach to interacting with each command's IO methods.
|
*/

// AUTO-ASSIGN: har 30 seconds me expired timers check karo (provider + serviceman)
Schedule::job(new \App\Jobs\AutoApproveBookingJob)->everyThirtySeconds()->withoutOverlapping();

// RECHECK: 15 din ka window nikal jaye to recheck auto-close (daily 00:15)
Schedule::call(function () {
    \Modules\BookingModule\Entities\BookingRecheck::query()
        ->whereIn('status', ['requested', 'in_progress'])
        ->whereNotNull('due_at')
        ->where('due_at', '<', now())
        ->update(['status' => 'expired', 'updated_at' => now()]);
})->dailyAt('00:15')->name('expire-booking-rechecks')->withoutOverlapping();
