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

// W4.28: pehle se maujood lekin kabhi schedule nahi kiye gaye commands
Schedule::command('email:subscription-time-end-mail')->dailyAt('00:30')->withoutOverlapping();
Schedule::command('email:free-trial-end-mail')->dailyAt('00:40')->withoutOverlapping();
Schedule::command('app:maintenance-mode-end')->dailyAt('00:50')->withoutOverlapping();
Schedule::command('email:send-renewal-reminder')->dailyAt('01:00')->withoutOverlapping();

// W2.15/W4.24: Laravel 12 me app/Console/Kernel.php schedule() call hi nahi hota —
// isliye backup + queue prune yahin routes/console.php se schedule ho rahe hain
Schedule::command('backup:run --disable-notifications')->dailyAt('02:30')->withoutOverlapping();
Schedule::command('backup:clean --disable-notifications')->dailyAt('03:30')->withoutOverlapping();
Schedule::command('queue:prune-failed --hours=48')->dailyAt('04:00');
Schedule::command('queue:prune --hours=48')->dailyAt('04:15');
