<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;

class SendFcmPushJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable;

    public int $tries = 3;
    public int $timeout = 30;
    public int $backoff = 5;

    public array $postData;

    public function __construct(array $postData)
    {
        $this->postData = $postData;
    }

    public function handle(): void
    {
        sendNotificationToHttp($this->postData);
    }
}
