<?php

namespace Modules\BookingModule\Listeners;

use Illuminate\Support\Facades\Mail;
use Modules\BookingModule\Emails\BookingMail;
use Modules\BookingModule\Events\BookingRequested;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Contracts\Queue\ShouldQueue;

class SendBookingRequestEmail
{
    /**
     * Create the event listener.
     *
     * @return void
     */
    public function __construct()
    {
        //
    }

    /**
     * Handle the event.
     *
     * @param BookingRequested $event
     * @return void
     */
    public function handle(BookingRequested $event)
    {
        try {
            $email = isNotificationActive(null, 'booking', 'email', 'user');
            $emailServices =  business_config('email_config_status', 'email_config');

            if (isset($event->booking->customer->email) && isset($emailServices) && $emailServices->live_values == 1 && $email) {
                Mail::to($event->booking->customer->email)->send(new BookingMail($event->booking));
            }
        } catch (\Exception $exception) {
            info($exception);
        }

        // Push notification yahan NAHI bhejte — booking_place push model observer
        // (SendBookingNotificationsJob) se already jaata hai. Pehle dono jagah se
        // bhejne par customer ko same notification 2 baar milta tha.
    }
}
