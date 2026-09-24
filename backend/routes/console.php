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
