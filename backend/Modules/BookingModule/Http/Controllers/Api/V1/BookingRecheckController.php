<?php

namespace Modules\BookingModule\Http\Controllers\Api\V1;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Validator;
use Modules\BookingModule\Entities\Booking;
use Modules\BookingModule\Entities\BookingRecheck;

class BookingRecheckController extends Controller
{
    /**
     * Customer: completed booking ko "rechecking" me daalta hai.
     * Sirf completion ke 15 din tak. Recheck 15 din ka hota hai
     * (requested -> in_progress -> completed | expired).
     */
    public function requestRecheck(Request $request, string $bookingId): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $booking = $this->bookingQuery($request)
            ->with(['status_histories', 'serviceman.user', 'provider.owner'])
            ->where('id', $bookingId)
            ->first();

        if (!isset($booking)) {
            return response()->json(response_formatter(DEFAULT_204), 204);
        }

        if ($booking->booking_status !== 'completed') {
            return response()->json(response_formatter(RECHECK_ONLY_COMPLETED_400), 400);
        }

        if (!BookingRecheck::canRequestFor($booking)) {
            return response()->json(response_formatter(RECHECK_WINDOW_CLOSED_400), 400);
        }

        $existing = BookingRecheck::where('booking_id', $booking->id)
            ->active()
            ->latest('requested_at')
            ->first();

        if ($existing) {
            $existing->expireIfNeeded();
            if (in_array($existing->status, [BookingRecheck::STATUS_REQUESTED, BookingRecheck::STATUS_IN_PROGRESS], true)) {
                return response()->json(response_formatter(RECHECK_ALREADY_REQUESTED_400), 400);
            }
        }

        $recheck = new BookingRecheck();
        $recheck->booking_id = $booking->id;
        $recheck->customer_id = $booking->customer_id;
        $recheck->provider_id = $booking->provider_id;
        $recheck->serviceman_id = $booking->serviceman_id;
        $recheck->status = BookingRecheck::STATUS_REQUESTED;
        $recheck->reason = $request->input('reason');
        $recheck->requested_at = now();
        $recheck->due_at = now()->addDays(BookingRecheck::WINDOW_DAYS);
        $recheck->save();

        $this->notifyStakeholders($booking, $recheck);

        return response()->json(response_formatter(RECHECK_REQUEST_SUCCESS_200, $recheck), 200);
    }

    /**
     * Customer: booking ke saath recheck status (button state ke liye).
     */
    public function recheckStatus(Request $request, string $bookingId): JsonResponse
    {
        $booking = $this->bookingQuery($request)->where('id', $bookingId)->first();

        if (!isset($booking)) {
            return response()->json(response_formatter(DEFAULT_204), 204);
        }

        $recheck = BookingRecheck::where('booking_id', $booking->id)
            ->latest('requested_at')
            ->first();

        if ($recheck) {
            $recheck->expireIfNeeded();
        }

        $payload = [
            'recheck' => $recheck,
            'can_request' => $booking->booking_status === 'completed'
                && BookingRecheck::canRequestFor($booking)
                && (is_null($recheck) || in_array($recheck->status, [BookingRecheck::STATUS_COMPLETED, BookingRecheck::STATUS_EXPIRED], true)),
            'window_ends_in_days' => $this->remainingDays($booking),
        ];

        return response()->json(response_formatter(DEFAULT_200, $payload), 200);
    }

    /**
     * Serviceman: mujhe assigned recheck tasks (uske completed bookings).
     */
    public function servicemanRecheckList(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'limit' => 'required|numeric|min:1|max:200',
            'offset' => 'required|numeric|min:1|max:100000',
            'status' => 'nullable|in:all,requested,in_progress,completed,expired',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $serviceman = $request->user()->serviceman;

        $query = BookingRecheck::where('serviceman_id', $serviceman?->id ?? '')
            ->with(['booking.customer', 'booking.detail.service', 'customer']);

        $status = $request->input('status', 'all');
        if ($status !== 'all') {
            $query->where('status', $status);
        } else {
            $query->whereIn('status', [
                BookingRecheck::STATUS_REQUESTED,
                BookingRecheck::STATUS_IN_PROGRESS,
                BookingRecheck::STATUS_COMPLETED,
            ]);
        }

        $rechecks = $query->latest('requested_at')
            ->paginate($request['limit'], ['*'], 'offset', $request['offset'])
            ->withPath('');

        foreach ($rechecks as $recheck) {
            $recheck->expireIfNeeded();
        }

        return response()->json(response_formatter(DEFAULT_200, $rechecks), 200);
    }

    /**
     * Serviceman: recheck shuru / complete karta hai (wapas jakar check karne ke baad).
     */
    public function servicemanRecheckUpdate(Request $request, string $recheckId): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:in_progress,completed',
            'serviceman_note' => 'required_if:status,completed|nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $recheck = BookingRecheck::find($recheckId);

        if (!isset($recheck)) {
            return response()->json(response_formatter(DEFAULT_204), 204);
        }

        $serviceman = $request->user()->serviceman;
        if ($recheck->serviceman_id !== ($serviceman?->id ?? '')) {
            return response()->json(response_formatter(DEFAULT_403), 403);
        }

        if (in_array($recheck->status, [BookingRecheck::STATUS_COMPLETED, BookingRecheck::STATUS_EXPIRED], true)) {
            return response()->json(response_formatter(RECHECK_ALREADY_CLOSED_400), 400);
        }

        $recheck->expireIfNeeded();
        if ($recheck->status === BookingRecheck::STATUS_EXPIRED) {
            return response()->json(response_formatter(RECHECK_ALREADY_CLOSED_400), 400);
        }

        $recheck->status = $request->input('status');
        if ($recheck->status === BookingRecheck::STATUS_COMPLETED) {
            $recheck->serviceman_note = $request->input('serviceman_note');
            $recheck->completed_at = now();
        }
        $recheck->save();

        if ($recheck->status === BookingRecheck::STATUS_COMPLETED) {
            $this->notifyProviderRecheckCompleted($recheck);
        }

        return response()->json(response_formatter(DEFAULT_STATUS_UPDATE_200, $recheck), 200);
    }

    /**
     * Provider (Zone Admin) dashboard: har serviceman ki recheck count + list.
     */
    public function providerRecheckSummary(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'limit' => 'required|numeric|min:1|max:200',
            'offset' => 'required|numeric|min:1|max:100000',
            'status' => 'nullable|in:all,requested,in_progress,completed,expired',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $providerId = $request->user()->provider?->id;

        // Har serviceman ki recheck count (15 din ki window me)
        $since = now()->subDays(BookingRecheck::WINDOW_DAYS);

        $counts = BookingRecheck::where('provider_id', $providerId)
            ->where('requested_at', '>=', $since)
            ->where('serviceman_id', '!=', '')
            ->groupBy('serviceman_id')
            ->selectRaw('serviceman_id, COUNT(*) as recheck_count')
            ->orderByDesc('recheck_count')
            ->pluck('recheck_count', 'serviceman_id');

        $servicemen = \Modules\UserManagement\Entities\Serviceman::with('user')
            ->whereIn('id', $counts->keys())
            ->get()
            ->map(function ($serviceman) use ($counts) {
                return [
                    'serviceman_id' => $serviceman->id,
                    'name' => trim(($serviceman->user?->first_name ?? '') . ' ' . ($serviceman->user?->last_name ?? '')),
                    'phone' => $serviceman->user?->phone,
                    'profile_image' => $serviceman->user?->profile_image,
                    'recheck_count' => (int) ($counts[$serviceman->id] ?? 0),
                ];
            })
            ->sortByDesc('recheck_count')
            ->values();

        $query = BookingRecheck::where('provider_id', $providerId)
            ->with(['booking.customer', 'booking.detail.service', 'customer', 'serviceman.user']);

        $status = $request->input('status', 'all');
        if ($status !== 'all') {
            $query->where('status', $status);
        }

        $list = $query->latest('requested_at')
            ->paginate($request['limit'], ['*'], 'offset', $request['offset'])
            ->withPath('');

        foreach ($list as $recheck) {
            $recheck->expireIfNeeded();
        }

        $totals = [
            'total_last_15_days' => (int) $counts->sum(),
            'open' => BookingRecheck::where('provider_id', $providerId)
                ->whereIn('status', [BookingRecheck::STATUS_REQUESTED, BookingRecheck::STATUS_IN_PROGRESS])->count(),
            'completed' => BookingRecheck::where('provider_id', $providerId)
                ->where('status', BookingRecheck::STATUS_COMPLETED)
                ->where('completed_at', '>=', $since)->count(),
            'expired' => BookingRecheck::where('provider_id', $providerId)
                ->where('status', BookingRecheck::STATUS_EXPIRED)
                ->where('updated_at', '>=', $since)->count(),
        ];

        return response()->json(response_formatter(DEFAULT_200, [
            'summary' => $totals,
            'servicemen' => $servicemen,
            'rechecks' => $list,
        ]), 200);
    }

    private function bookingQuery(Request $request)
    {
        $user = $request->user();

        return Booking::where('customer_id', $user->id);
    }

    private function remainingDays(Booking $booking): ?int
    {
        $completedAt = $booking->status_histories()
            ->where('booking_status', 'completed')
            ->latest('created_at')
            ->value('created_at');

        $reference = $completedAt ? \Carbon\Carbon::parse($completedAt) : $booking->updated_at;
        if (!$reference) {
            return null;
        }

        $daysLeft = $reference->copy()->addDays(BookingRecheck::WINDOW_DAYS)->diffInDays(now(), false);

        return $daysLeft > 0 ? (int) ceil($daysLeft) : 0;
    }

    /**
     * Recheck raise hote hi serviceman + provider ko push notification.
     */
    private function notifyStakeholders(Booking $booking, BookingRecheck $recheck): void
    {
        $title = 'New recheck requested for booking #' . $booking->readable_id;
        $description = 'Customer reported an issue. Please revisit and re-inspect within '
            . BookingRecheck::WINDOW_DAYS . ' days.';

        $servicemanUser = $booking->serviceman?->user;
        if ($servicemanUser?->fcm_token) {
            device_notification(
                $servicemanUser->fcm_token,
                $title,
                $description,
                null,
                $booking->id,
                'booking',
                null,
                null,
                null,
                null,
                null,
                null
            );
        }

        $providerOwner = $booking->provider?->owner;
        if ($providerOwner?->fcm_token) {
            device_notification(
                $providerOwner->fcm_token,
                $title,
                'Recheck assigned to your serviceman. Track it from your dashboard.',
                null,
                $booking->id,
                'booking',
                null,
                $booking->provider_id,
                null,
                null,
                null,
                null
            );
        }
    }

    private function notifyProviderRecheckCompleted(BookingRecheck $recheck): void
    {
        $booking = $recheck->booking;
        if (!$booking) {
            return;
        }

        $providerOwner = $booking->provider?->owner;
        if ($providerOwner?->fcm_token) {
            device_notification(
                $providerOwner->fcm_token,
                'Recheck completed for booking #' . $booking->readable_id,
                'Your serviceman finished the recheck inspection.',
                null,
                $booking->id,
                'booking',
                null,
                $booking->provider_id,
                null,
                null,
                null,
                null
            );
        }
    }
}
