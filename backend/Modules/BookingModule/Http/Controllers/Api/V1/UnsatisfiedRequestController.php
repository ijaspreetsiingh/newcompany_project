<?php

namespace Modules\BookingModule\Http\Controllers\Api\V1;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Validator;
use Modules\BookingModule\Entities\Booking;
use Modules\BookingModule\Entities\UnsatisfiedRequest;
use Modules\UserManagement\Entities\Serviceman;

class UnsatisfiedRequestController extends Controller
{
    /**
     * Customer: completed booking par "Not satisfied with service" raise karta hai.
     *
     * Rules:
     * - Booking completed honi chahiye.
     * - Provider ke window-days (admin wizard, default 7) andar hona chahiye.
     * - Ek booking par ek hi active request.
     *
     * Raise hote hi backend ORIGINAL booking clone karke FREE re-service
     * booking banata hai (amount 0, accepted) — usi serviceman ke paas jo
     * pehle kaam karke gaya tha. Provider + serviceman ko push jaata hai.
     */
    public function raise(Request $request, string $bookingId): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $booking = Booking::where('customer_id', $request->user()->id)
            ->with(['status_histories', 'serviceman.user', 'provider.owner', 'detail.service'])
            ->where('id', $bookingId)
            ->first();

        if (!isset($booking)) {
            return response()->json(response_formatter(DEFAULT_204), 204);
        }

        if ($booking->is_re_service) {
            // Re-service booking par dobara unsatisfied nahi — wapas original par hi
            return response()->json(response_formatter(DEFAULT_400, null, [
                ['error_code' => 'unsatisfied', 'message' => translate('Re-service bookings cannot raise another unsatisfied request.')],
            ]), 400);
        }

        if ($booking->booking_status !== 'completed') {
            return response()->json(response_formatter(DEFAULT_400, null, [
                ['error_code' => 'unsatisfied', 'message' => translate('Only a completed booking can raise an unsatisfied request.')],
            ]), 400);
        }

        $windowDays = UnsatisfiedRequest::windowDaysFor($booking->provider);
        if (!UnsatisfiedRequest::canRequestFor($booking, $windowDays)) {
            return response()->json(response_formatter(DEFAULT_400, null, [
                ['error_code' => 'unsatisfied', 'message' => translate('The unsatisfied window for this booking has ended.')],
            ]), 400);
        }

        $existing = UnsatisfiedRequest::where('booking_id', $booking->id)
            ->latest('requested_at')
            ->first();

        if ($existing) {
            $existing->expireIfNeeded();
            if ($existing->status === UnsatisfiedRequest::STATUS_REQUESTED) {
                return response()->json(response_formatter(DEFAULT_400, null, [
                    ['error_code' => 'unsatisfied', 'message' => translate('An unsatisfied request is already open for this booking.')],
                ]), 400);
            }
        }

        $reservice = $this->createReserviceBooking($booking);

        $unsatisfied = new UnsatisfiedRequest();
        $unsatisfied->booking_id = $booking->id;
        $unsatisfied->customer_id = $booking->customer_id;
        $unsatisfied->provider_id = $booking->provider_id;
        $unsatisfied->serviceman_id = $booking->serviceman_id;
        $unsatisfied->reservice_booking_id = $reservice->id;
        $unsatisfied->status = UnsatisfiedRequest::STATUS_REQUESTED;
        $unsatisfied->reason = $request->input('reason');
        $unsatisfied->requested_at = now();
        $unsatisfied->due_at = now()->addDays($windowDays);
        $unsatisfied->save();

        $this->notifyStakeholders($booking, $reservice, $unsatisfied);

        return response()->json(response_formatter(DEFAULT_200, [
            'unsatisfied' => $unsatisfied,
            'reservice_booking_id' => $reservice->id,
        ]), 200);
    }

    /**
     * Customer: booking ke saath unsatisfied status (button state ke liye).
     */
    public function status(Request $request, string $bookingId): JsonResponse
    {
        $booking = Booking::where('customer_id', $request->user()->id)
            ->with('status_histories')
            ->where('id', $bookingId)
            ->first();

        if (!isset($booking)) {
            return response()->json(response_formatter(DEFAULT_204), 204);
        }

        $unsatisfied = UnsatisfiedRequest::where('booking_id', $booking->id)
            ->latest('requested_at')
            ->first();

        if ($unsatisfied) {
            $unsatisfied->expireIfNeeded();
        }

        $windowDays = UnsatisfiedRequest::windowDaysFor($booking->provider);

        $payload = [
            'unsatisfied' => $unsatisfied,
            'can_raise' => $booking->booking_status === 'completed'
                && !$booking->is_re_service
                && $windowDays > 0
                && UnsatisfiedRequest::canRequestFor($booking, $windowDays)
                && (is_null($unsatisfied) || $unsatisfied->status === UnsatisfiedRequest::STATUS_EXPIRED),
            'window_days' => $windowDays,
            'window_ends_in_days' => $this->remainingDays($booking, $windowDays),
        ];

        return response()->json(response_formatter(DEFAULT_200, $payload), 200);
    }

    /**
     * Provider (Zone Admin) dashboard: unsatisfied requests — serviceman-wise
     * count, service-wise count, totals + recent list.
     */
    public function providerSummary(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'limit' => 'required|numeric|min:1|max:200',
            'offset' => 'required|numeric|min:1|max:100000',
            'status' => 'nullable|in:all,requested,completed,expired',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $provider = $request->user()->provider;
        $providerId = $provider?->id;
        $windowDays = UnsatisfiedRequest::windowDaysFor($provider);
        $since = now()->subDays(max(1, $windowDays));

        $recentCounts = UnsatisfiedRequest::where('provider_id', $providerId)
            ->where('requested_at', '>=', $since)
            ->where('serviceman_id', '!=', '')
            ->groupBy('serviceman_id')
            ->selectRaw('serviceman_id, COUNT(*) as unsatisfied_count')
            ->pluck('unsatisfied_count', 'serviceman_id');

        $servicemen = Serviceman::with('user')
            ->whereIn('id', $recentCounts->keys())
            ->get()
            ->map(function ($serviceman) use ($recentCounts) {
                return [
                    'serviceman_id' => $serviceman->id,
                    'name' => trim(($serviceman->user?->first_name ?? '') . ' ' . ($serviceman->user?->last_name ?? '')),
                    'phone' => $serviceman->user?->phone,
                    'profile_image' => $serviceman->user?->profile_image,
                    'unsatisfied_count' => (int) ($recentCounts[$serviceman->id] ?? 0),
                ];
            })
            ->sortByDesc('unsatisfied_count')
            ->values();

        // Service-wise counts (window ke andar ki requests)
        $serviceCounts = [];
        UnsatisfiedRequest::where('provider_id', $providerId)
            ->where('requested_at', '>=', $since)
            ->with('booking.detail.service')
            ->get()
            ->each(function ($req) use (&$serviceCounts) {
                foreach ($req->booking?->detail ?? [] as $row) {
                    $name = $row->service?->name ?? 'unknown_service';
                    $serviceCounts[$name] = ($serviceCounts[$name] ?? 0) + 1;
                }
            });
        arsort($serviceCounts);

        $query = UnsatisfiedRequest::where('provider_id', $providerId)
            ->with(['booking.customer', 'booking.detail.service', 'customer', 'serviceman.user', 'reserviceBooking']);

        $status = $request->input('status', 'all');
        if ($status !== 'all') {
            $query->where('status', $status);
        }

        $list = $query->latest('requested_at')
            ->paginate($request['limit'], ['*'], 'offset', $request['offset'])
            ->withPath('');

        foreach ($list as $unsatisfied) {
            $unsatisfied->expireIfNeeded();
        }

        $totals = [
            'window_days' => $windowDays,
            'total_in_window' => (int) $recentCounts->sum(),
            'open' => UnsatisfiedRequest::where('provider_id', $providerId)
                ->where('status', UnsatisfiedRequest::STATUS_REQUESTED)->count(),
            'completed' => UnsatisfiedRequest::where('provider_id', $providerId)
                ->where('status', UnsatisfiedRequest::STATUS_COMPLETED)
                ->where('completed_at', '>=', $since)->count(),
            'expired' => UnsatisfiedRequest::where('provider_id', $providerId)
                ->where('status', UnsatisfiedRequest::STATUS_EXPIRED)
                ->where('updated_at', '>=', $since)->count(),
        ];

        return response()->json(response_formatter(DEFAULT_200, [
            'summary' => $totals,
            'servicemen' => $servicemen,
            'services' => collect($serviceCounts)->map(fn ($count, $name) => [
                'service_name' => $name,
                'unsatisfied_count' => $count,
            ])->values(),
            'requests' => $list,
        ]), 200);
    }

    /**
     * Original booking ka clone — FREE re-service, usi serviceman ke paas.
     */
    private function createReserviceBooking(Booking $booking): Booking
    {
        $reservice = $booking->replicate();
        // HasUuid + readable_id creating-hook naya id/readable_id denge

        $reservice->booking_status = 'accepted';
        $reservice->is_paid = 1;
        $reservice->payment_method = 'cash_after_service';
        $reservice->transaction_id = null;
        $reservice->total_booking_amount = 0;
        $reservice->total_tax_amount = 0;
        $reservice->total_discount_amount = 0;
        $reservice->total_campaign_discount_amount = 0;
        $reservice->total_coupon_discount_amount = 0;
        $reservice->coupon_code = null;
        $reservice->additional_charge = 0;
        $reservice->additional_tax_amount = 0;
        $reservice->additional_discount_amount = 0;
        $reservice->additional_campaign_discount_amount = 0;
        $reservice->service_schedule = now();
        $reservice->is_re_service = 1;
        $reservice->re_service_of = $booking->id;
        $reservice->start_otp = null;
        $reservice->start_otp_generated_at = null;
        $reservice->serviceman_reached_at = null;
        $reservice->booking_otp = null;
        $reservice->evidence_photos = null;
        $reservice->auto_assigned = 0;
        $reservice->serviceman_assign_expires_at = null;
        $reservice->save();

        foreach ($booking->detail as $row) {
            $copy = $row->replicate();
            $copy->booking_id = $reservice->id;
            $copy->save();
        }

        return $reservice;
    }

    private function remainingDays(Booking $booking, int $windowDays): ?int
    {
        if ($windowDays <= 0) {
            return 0;
        }

        $completedAt = $booking->status_histories()
            ->where('booking_status', 'completed')
            ->latest('created_at')
            ->value('created_at');

        $reference = $completedAt ? \Carbon\Carbon::parse($completedAt) : $booking->updated_at;
        if (!$reference) {
            return null;
        }

        $daysLeft = $reference->copy()->addDays($windowDays)->diffInDays(now(), false);

        return $daysLeft > 0 ? (int) ceil($daysLeft) : 0;
    }

    /**
     * Raise hote hi: serviceman (jo pehle kaam kar gaya tha) + provider ko push.
     */
    private function notifyStakeholders(Booking $original, Booking $reservice, UnsatisfiedRequest $unsatisfied): void
    {
        $title = translate('Unsatisfied re-service requested') . ' #' . $original->readable_id;
        $description = translate('The customer was not satisfied. A free re-service has been assigned to you. Please redo the service properly.');

        $servicemanUser = $original->serviceman?->user;
        if ($servicemanUser?->fcm_token) {
            device_notification(
                $servicemanUser->fcm_token,
                $title,
                $description,
                null,
                $reservice->id,
                'booking'
            );
        }

        $providerOwner = $original->provider?->owner;
        if ($providerOwner?->fcm_token) {
            device_notification(
                $providerOwner->fcm_token,
                $title,
                translate('A free re-service has been assigned. Track it from your dashboard.'),
                null,
                $reservice->id,
                'booking',
                null,
                $original->provider_id
            );
        }
    }
}
