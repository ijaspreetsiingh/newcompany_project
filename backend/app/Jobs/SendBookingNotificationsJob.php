<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendBookingNotificationsJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;
    public int $timeout = 30;

    protected array $notifications;
    protected int $bookingId;
    protected string $userRole;
    protected ?int $providerId;

    public function __construct(array $notifications, int $bookingId, string $userRole, ?int $providerId = null)
    {
        $this->notifications = $notifications;
        $this->bookingId = $bookingId;
        $this->userRole = $userRole;
        $this->providerId = $providerId;
    }

    public function handle(): void
    {
        $booking = \Modules\BookingModule\Entities\Booking::with(['customer', 'provider.owner', 'serviceman.user'])->find($this->bookingId);
        if (!$booking) {
            return;
        }

        $booking_notification_status = business_config('booking', 'notification_settings')->live_values ?? null;
        if (!isset($booking_notification_status['push_notification_booking'])) {
            return;
        }

        foreach ($this->notifications as $notification) {
            $key = $notification['key'] ?? null;
            $settingsType = $notification['settings_type'] ?? null;
            if (!$key || !$settingsType) {
                continue;
            }

            $this->sendNotification($booking, $key, $settingsType);
        }
    }

    protected function sendNotification($booking, string $key, string $settingsType): void
    {
        if ($settingsType == 'customer_notification') {
            $user = $booking->customer;
            $repeatOrRegular = $booking->is_repeated ? 'repeat' : 'regular';
            $title = get_push_notification_message($key, $settingsType, $user?->current_language_key);
            $permission = isNotificationActive(null, 'booking', 'notification', 'user');
            if ($user?->fcm_token && $user?->is_active && $title && $permission) {
                device_notification($user?->fcm_token, $title, null, null, $booking->id, 'booking', null, null, null, null, $repeatOrRegular);
            }
        }

        if ($settingsType == 'provider_notification') {
            if ((!business_config('suspend_on_exceed_cash_limit_provider', 'provider_config')->live_values || $booking->provider?->is_suspended == 0) && $booking->booking_status == 'pending') {
                $provider = $booking->provider?->owner;
                $repeatOrRegular = $booking->is_repeated ? 'repeat' : 'regular';
                $title = get_push_notification_message($key, $settingsType, $provider?->current_language_key);
                if ($provider?->fcm_token && $title && sendDeviceNotificationPermission($booking->provider_id)) {
                    device_notification($provider?->fcm_token, $title, null, null, $booking->id, 'booking', null, null, null, null, $repeatOrRegular);
                }
            } else {
                $provider = $booking->provider?->owner;
                $repeatOrRegular = $booking->is_repeated ? 'repeat' : 'regular';
                $title = get_push_notification_message($key, $settingsType, $provider?->current_language_key);
                if ($provider?->fcm_token && $title && sendDeviceNotificationPermission($booking->provider_id)) {
                    device_notification($provider?->fcm_token, $title, null, null, $booking->id, 'booking', null, null, null, null, $repeatOrRegular);
                }
            }
        }

        if ($settingsType == 'serviceman_notification') {
            $serviceman = $booking->serviceman?->user;
            $title = get_push_notification_message($key, $settingsType, $serviceman?->current_language_key);
            if ($serviceman?->fcm_token && $title) {
                device_notification($serviceman?->fcm_token, $title, null, null, $booking->id, 'booking');
            }
        }
    }
}
