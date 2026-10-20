<?php

namespace Modules\BookingModule\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Modules\BookingModule\Entities\Booking;
use Modules\BookingModule\Entities\BookingRepeat;
use Modules\ProviderManagement\Entities\Provider;
use Modules\UserManagement\Entities\Serviceman;

/**
 * Protects the app-facing invoice URLs.
 *
 * Before this middleware, /admin/booking/customer-invoice/{booking_uuid}/en
 * was completely public: anyone with (or guessing) a booking UUID could read
 * the customer name, phone, address and service list. The apps now append
 * their Passport token as ?token=..., and this middleware verifies that the
 * token owner really owns the booking.
 *
 * Admin sessions keep working (admin panel invoice buttons).
 */
class AuthorizeInvoiceAccess
{
    public function handle(Request $request, Closure $next, string $role = 'customer')
    {
        if (auth()->check() && in_array(auth()->user()->user_type, ADMIN_USER_TYPES)) {
            return $next($request);
        }

        $rawToken = $request->query('token') ?: $request->bearerToken();
        $user = resolveUserFromApiToken(is_string($rawToken) ? $rawToken : null);

        if (!$user) {
            abort(403, 'This invoice link is invalid or has expired.');
        }

        $id = $request->route('id');

        // Subscription invoice: transaction provider ka hona chahiye.
        if ($role === 'subscription') {
            $transaction = \Modules\TransactionModule\Entities\Transaction::with('packageLog')->find($id);
            if (!$transaction) {
                abort(404);
            }

            $providerProfileId = Provider::where('user_id', $user->id)->value('id');
            $allowed = (string) $transaction->from_user_id === (string) $user->id
                || (string) $transaction->to_user_id === (string) $user->id
                || ($providerProfileId && (string) ($transaction->packageLog?->provider_id) === (string) $providerProfileId);

            if (!$allowed) {
                abort(403, 'You are not allowed to view this invoice.');
            }

            $response = $next($request);
            if (method_exists($response, 'headers')) {
                $response->headers->set('Referrer-Policy', 'no-referrer');
                $response->headers->set('X-Robots-Tag', 'noindex, nofollow');
            }
            return $response;
        }

        $path = $request->path();
        $isRepeatInvoice = str_contains($path, 'single-invoice');

        if ($isRepeatInvoice) {
            $booking = BookingRepeat::with('booking:id,customer_id')->find($id);
            $customerId = $booking?->booking?->customer_id;
        } else {
            $booking = Booking::find($id);
            $customerId = $booking?->customer_id;
        }

        if (!$booking) {
            abort(404);
        }

        $providerProfileId = $role === 'provider' ? Provider::where('user_id', $user->id)->value('id') : null;
        $servicemanProfileId = $role === 'serviceman' ? Serviceman::where('user_id', $user->id)->value('id') : null;

        $allowed = match ($role) {
            'customer' => $customerId !== null && (string) $customerId === (string) $user->id,
            'provider' => $providerProfileId !== null && (string) $booking->provider_id === (string) $providerProfileId,
            'serviceman' => $servicemanProfileId !== null && (string) $booking->serviceman_id === (string) $servicemanProfileId,
            default => false,
        };

        if (!$allowed) {
            abort(403, 'You are not allowed to view this invoice.');
        }

        // Tokens are in the URL; never leak them through the Referer header.
        $response = $next($request);
        if (method_exists($response, 'headers')) {
            $response->headers->set('Referrer-Policy', 'no-referrer');
            $response->headers->set('X-Robots-Tag', 'noindex, nofollow');
        }

        return $response;
    }
}
