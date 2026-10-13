<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    /**
     * Define the application's command schedule.
     *
     * @param Schedule $schedule
     * @return void
     */
    protected function schedule(Schedule $schedule): void
    {
        // W2.15: daily DB+app backup (spatie/laravel-backup) + retention prune.
        // Offsite push ke liye config/backup.php me s3 disk + .env me AWS_* bharo.
        $schedule->command('backup:run --disable-notifications')->dailyAt('02:30')->withoutOverlapping();
        $schedule->command('backup:clean --disable-notifications')->dailyAt('03:30')->withoutOverlapping();

        // W4.24: failed queue jobs 48h baad prune; redis reserved jobs bhi
        $schedule->command('queue:prune-failed --hours=48')->dailyAt('04:00');
        $schedule->command('queue:prune --hours=48')->dailyAt('04:15');
    }

    /**
     * Register the commands for the application.
     *
     * @return void
     */
    protected function commands(): void
    {
        $this->load(__DIR__.'/Commands');

        require base_path('routes/console.php');
    }
}
