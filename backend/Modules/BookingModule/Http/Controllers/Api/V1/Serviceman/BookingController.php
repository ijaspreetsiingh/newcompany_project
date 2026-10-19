<?php

namespace Modules\BookingModule\Http\Controllers\Api\V1\Serviceman;

use Illuminate\Contracts\Support\Renderable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Modules\BookingModule\Entities\Booking;
use Modules\BookingModule\Entities\BookingDetail;
use Modules\BookingModule\Entities\BookingRepeat;
use Modules\BookingModule\Entities\BookingRepeatDetails;
use Modules\BookingModule\Entities\BookingRepeatHistory;
use Modules\BookingModule\Entities\BookingScheduleHistory;
use Modules\BookingModule\Entities\BookingStatusHistory;
use Modules\BookingModule\Http\Traits\BookingTrait;
use Modules\ServiceManagement\Entities\Service;

class BookingController extends Controller
{

    private Booking $booking;
    private BookingStatusHistory $bookingStatusHistory;
    private BookingDetail $bookingDetail;
    private BookingRepeat $bookingRepeat;
    private BookingRepeatDetails $bookingRepeatDetail;
    private BookingRepeatHistory $bookingRepeatHistory;

    use BookingTrait;

    public function __construct(Booking $booking, BookingStatusHistory $bookingStatusHistory, BookingDetail $bookingDetail, BookingRepeat $bookingRepeat, BookingRepeatDetails $bookingRepeatDetail, BookingRepeatHistory $bookingRepeatHistory)
    {
        $this->booking = $booking;
        $this->bookingStatusHistory = $bookingStatusHistory;
        $this->bookingDetail = $bookingDetail;
        $this->bookingRepeat = $bookingRepeat;
        $this->bookingRepeatDetail = $bookingRepeatDetail;
        $this->bookingRepeatHistory = $bookingRepeatHistory;
    }

    /**
     * Show the specified resource.
     * @param Request $request
     * @param string $bookingId
     * @return JsonResponse
     */
    public function statusUpdate(Request $request, string $bookingId): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'booking_status' => 'required|in:all,' . implode(',', array_column(BOOKING_STATUSES, 'key')),
            'booking_otp' => ((business_config('booking_otp', 'booking_setup'))->live_values == 1 && $request->booking_status == 'completed') ? 'required' : 'nullable',
            'evidence_photos' => 'nullable|array',
            'evidence_photos.*' => 'image|max:'. uploadMaxFileSizeInKB('image') .'|mimes:' . implode(',', array_column(IMAGEEXTENSION, 'key')),
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $booking = $this->booking->where('id', $bookingId)->where(['serviceman_id' => $request->user()->serviceman->id])->first();
        $bookingStatus = $request->booking_status;

        if (isset($booking)) {

            if ($booking->payment_method == 'offline_payment' && $booking->is_paid == 0 && in_array($request->booking_status, ['ongoing', 'completed'])) {
                if ($booking->booking_offline_payments->isEmpty()) {
                    return response()->json(response_formatter(UPDATE_FAILED_FOR_OFFLINE_PAYMENT_VERIFICATION_200), 200);
                }
                if ($booking->booking_offline_payments->isNotEmpty() && $booking->booking_offline_payments?->first()?->payment_status != 'approved'){
                    return response()->json(response_formatter(UPDATE_FAILED_FOR_OFFLINE_PAYMENT_VERIFICATION_200), 200);
                }
            }

            $evidencePhotos = [];
            if ($bookingStatus == 'completed' && (business_config('booking_otp', 'booking_setup'))?->live_values == 1) {
                if ($booking->booking_otp != $request['booking_otp']) {
                    return response()->json(response_formatter(OTP_VERIFICATION_FAIL_403), 200);
                }
            }

            // SPEC: serviceman customer ke 300m radius me aakar "Reached" mark
            // karta hai -> start OTP generate hota hai (customer app me dikhta
            // hai). 'ongoing' start karne se pehle wo OTP verify karega.
            if ($bookingStatus == 'ongoing') {
                if ($booking->booking_status !== 'accepted') {
                    return response()->json(response_formatter(DEFAULT_400, null, [
                        ['error_code' => 'status', 'message' => translate('Only an accepted booking can be started.')],
                    ]), 400);
                }
                if (is_null($booking->start_otp)) {
                    return response()->json(response_formatter(DEFAULT_400, null, [
                        ['error_code' => 'otp', 'message' => translate('Reach the customer location (within 300m) and generate the start OTP first.')],
                    ]), 400);
                }
                if ($request['start_otp'] != $booking->start_otp) {
                    return response()->json(response_formatter(OTP_VERIFICATION_FAIL_403), 200);
                }
            }

            if ($bookingStatus == 'completed' && (business_config('service_complete_photo_evidence', 'booking_setup'))?->live_values == 1) {
                if ($request->has('evidence_photos')) {
                    foreach ($request->evidence_photos as $image) {
                        $imageName = file_uploader('booking/evidence/', APPLICATION_IMAGE_FORMAT, $image);
                        $evidencePhotos[] = ['image'=>$imageName, 'storage'=> getDisk()];
                    }
                }
            }

            if($booking->payment_method != 'cash_after_service' && $request['booking_status'] == 'canceled' && $booking->additional_charge > 0){
                return response()->json(response_formatter(BOOKING_ALREADY_EDITED), 200);
            }

            $booking->booking_status = $request['booking_status'];
            $booking->evidence_photos = $evidencePhotos;

            $bookingStatusHistory = $this->bookingStatusHistory;
            $bookingStatusHistory->booking_id = $bookingId;
            $bookingStatusHistory->changed_by = $request->user()->id;
            $bookingStatusHistory->booking_status = $request['booking_status'];

            DB::transaction(function () use ($bookingStatusHistory, $booking) {
                $booking->save();
                $bookingStatusHistory->save();
            });

            return response()->json(response_formatter(BOOKING_STATUS_UPDATE_SUCCESS_200, $booking), 200);
        }
        return response()->json(response_formatter(DEFAULT_204), 200);
    }
    /**
     * Show the specified resource.
     * @param Request $request
     * @param string $bookingId
     * @return JsonResponse
     */
    public function singleBookingStatusUpdate(Request $request, string $bookingId): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'booking_status' => 'required|in:all,' . implode(',', array_column(BOOKING_STATUSES, 'key')),
            'booking_otp' => ((business_config('booking_otp', 'booking_setup'))->live_values == 1 && $request->booking_status == 'completed') ? 'required' : 'nullable',
            'evidence_photos' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $booking = $this->bookingRepeat->where('id', $bookingId)->where(['serviceman_id' => $request->user()->serviceman->id])->first();
        $bookingStatus = $request->booking_status;

        if (isset($booking)) {

            if ($bookingStatus == 'ongoing') {
                if ($booking->booking_status !== 'accepted') {
                    return response()->json(response_formatter(DEFAULT_400, null, [
                        ['error_code' => 'status', 'message' => translate('Only an accepted booking can be started.')],
                    ]), 400);
                }
                if (is_null($booking->start_otp) || is_null($booking->serviceman_reached_at)) {
                    return response()->json(response_formatter(DEFAULT_400, null, [
                        ['error_code' => 'otp', 'message' => translate('Reach the customer location (within 300m) and generate the start OTP first.')],
                    ]), 400);
                }
                if ((string) $request->input('start_otp') !== (string) $booking->start_otp) {
                    return response()->json(response_formatter(OTP_VERIFICATION_FAIL_403), 200);
                }
            }

            $evidencePhotos = [];
            if ($bookingStatus == 'completed' && (business_config('booking_otp', 'booking_setup'))?->live_values == 1) {
                if ($booking->booking_otp != $request['booking_otp']) {
                    return response()->json(response_formatter(OTP_VERIFICATION_FAIL_403), 200);
                }
            }

            if ($bookingStatus == 'completed' && (business_config('service_complete_photo_evidence', 'booking_setup'))?->live_values == 1) {
                if ($request->has('evidence_photos')) {
                    foreach ($request->evidence_photos as $image) {
                        $imageName = file_uploader('booking/evidence/', APPLICATION_IMAGE_FORMAT, $image);
                        $evidencePhotos[] = ['image'=>$imageName, 'storage'=> getDisk()];
                    }
                }
            }

            $booking->booking_status = $request['booking_status'];
            $booking->evidence_photos = $evidencePhotos;

            $bookingStatusHistory = $this->bookingStatusHistory;
            $bookingStatusHistory->booking_id = 0;
            $bookingStatusHistory->changed_by = $request->user()->id;
            $bookingStatusHistory->booking_status = $request['booking_status'];
            $bookingStatusHistory->booking_repeat_id = $bookingId;

            if ($request['booking_status'] == 'canceled' && $booking->extra_fee > 0){

                $repeats = $this->booking->where('id', $booking->booking_id)->first();
                $sortedRepeats = $repeats->repeat->sortBy(function ($repeat) {
                    $parts = explode('-', $repeat->readable_id);
                    $suffix = end($parts);
                    return $this->readableIdToNumber($suffix);
                });

                $repeats['repeats'] = $sortedRepeats->values()->toArray();

                $nextService = collect($repeats['repeats'])
                    ->where('booking_status', 'ongoing')
                    ->skip(1)
                    ->first();

                if (!$nextService) {
                    $nextService = collect($repeats['repeats'])
                        ->where('booking_status', 'accepted')
                        ->skip(1)
                        ->first();
                }

                if (!$nextService) {
                    $nextService = collect($repeats['repeats'])
                        ->where('booking_status', 'pending')
                        ->skip(1)
                        ->first();
                }

                if (isset($nextService)){
                    $nextServiceId = $nextService['id'];
                    $nextServiceFee = $this->bookingRepeat->where('id', $nextServiceId)->first();
                    $nextServiceFee->extra_fee = $booking->extra_fee;
                    $nextServiceFee->total_booking_amount += $booking->extra_fee;
                    $nextServiceFee->save();

                    $booking->total_booking_amount -= $booking->extra_fee;
                    $booking->extra_fee = 0;
                }
            }

            DB::transaction(function () use ($bookingStatusHistory, $booking) {
                $booking->save();
                $bookingStatusHistory->save();

                $fullBooking = $this->bookingRepeat->where('booking_id', $booking->booking_id)->get();
                $allInactive = $fullBooking->every(function ($repeat) {
                    return !in_array($repeat->booking_status, ['pending', 'accepted', 'ongoing']);
                });

                if ($allInactive) {
                    $booking->booking->booking_status = 'completed';
                    $booking->booking->is_paid = 1;
                    $booking->booking->save();
                }

                if (in_array($booking->booking_status, ['ongoing', 'completed', 'canceled'])) {
                    if ($booking->booking->booking_status != 'ongoing' && $booking->booking->booking_status != 'completed' && $booking->booking->booking_status != 'canceled') {
                        $booking->booking->booking_status = 'ongoing';
                        $booking->booking->save();
                    }
                }
            });

            return response()->json(response_formatter(BOOKING_STATUS_UPDATE_SUCCESS_200, $booking), 200);
        }
        return response()->json(response_formatter(DEFAULT_204), 200);
    }


    /**
     * Show the specified resource.
     * @param Request $request
     * @param string $bookingId
     * @return JsonResponse
     */
    public function paymentStatusUpdate(Request $request, string $bookingId): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'payment_status' => 'required|in:paid,unpaid'
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $booking = $this->booking->where('id', $bookingId)->where(['serviceman_id' => $request->user()->serviceman->id])->first();
        if (isset($booking)) {
            $booking->is_paid = $request['payment_status'] == 'paid' ? 1 : 0;
            $booking->save();
            return response()->json(response_formatter(PAYMENT_STATUS_UPDATE_SUCCESS_200, $booking), 200);
        }

        return response()->json(response_formatter(DEFAULT_204), 200);
    }


    /**
     * Show the form for creating a new resource.
     * @param Request $request
     * @param string $id
     * @return JsonResponse
     */
    /**
     * Serviceman accept:
     *  - booking PENDING (kisi ne accept nahi kiya): current assigned serviceman
     *    accept kare to booking ACCEPTED hoti hai
     *  - auto-assignment me purane slots ya accepted booking par late accept reject hota hai
     */
    public function acceptBooking(Request $request, string $bookingId): JsonResponse
    {
        $serviceman = $request->user()->serviceman;
        $booking = $this->booking
            ->where('id', $bookingId)
            ->where('provider_id', $serviceman->provider_id)
            ->whereIn('booking_status', ['pending', 'accepted'])
            ->first();

        if (!$booking) {
            return response()->json(response_formatter(DEFAULT_204), 200);
        }

        $slot = \Modules\BookingModule\Entities\BookingServiceman::where('booking_id', $booking->id)
            ->where('serviceman_id', $serviceman->id)
            ->first();

        // ye serviceman ko is booking ki request gayi hi nahi
        // Pending request current assignee ya broadcast ke kisi pending slot
        // holder ko mil sakti hai. Purane rejected/expired slots valid nahi.
        $isCurrentAssignment = $booking->serviceman_id === $serviceman->id;
        $isProviderAssignedSlot = $booking->booking_status === 'pending'
            && $slot
            && $slot->status === \Modules\BookingModule\Entities\BookingServiceman::STATUS_PENDING;
        if ($booking->booking_status !== 'pending' || (!$isCurrentAssignment && !$isProviderAssignedSlot)) {
            return response()->json(response_formatter(DEFAULT_204), 200);
        }

        // pending booking par timer expire ho chuka to accept nahi
        // GRACE: current assignee ko expiry ke baad bhi 180s tak accept ka
        // mauka — notification click → app open → navigate me time lagta hai
        if ($booking->booking_status === 'pending') {
            $graceSeconds = 180;
            $expired = ($slot && $slot->expires_at && $slot->expires_at->isPast())
                || (!$slot && $booking->serviceman_assign_expires_at && $booking->serviceman_assign_expires_at->isPast());
            if ($expired) {
                $deadline = $slot && $slot->expires_at
                    ? $slot->expires_at
                    : ($booking->serviceman_assign_expires_at
                        ? (\Carbon\Carbon::parse($booking->serviceman_assign_expires_at))
                        : null);
                $withinGrace = $deadline
                    && $deadline->copy()->addSeconds($graceSeconds)->isFuture()
                    && $isCurrentAssignment;
                if (!$withinGrace) {
                    return response()->json(response_formatter(DEFAULT_400, null, [['error_code' => 'booking', 'message' => translate('booking_request_expired')]]), 400);
                }
            }
        }

        $isFirstAccept = $booking->booking_status === 'pending';

        $accepted = DB::transaction(function () use ($booking, $bookingId, $slot, $serviceman, $request, $isFirstAccept) {
            // SECURITY: booking row-lock + andar hi re-check — 2 parallel accepts me
            // sirf ek hi pehla accept (lead) banega, doosra "already accepted" ho jayega.
            $booking = \Modules\BookingModule\Entities\Booking::withoutGlobalScopes()
                ->where('id', $bookingId)
                ->lockForUpdate()
                ->first();

            if (!$booking
                || $booking->provider_id !== $serviceman->provider_id
                || !in_array($booking->booking_status, ['pending', 'accepted'], true)) {
                return false; // lock ke baad status badal chuka — kuch mat karo
            }

            // slot bhi lock karke dobara padho (parallel slot updates race band)
            $slot = \Modules\BookingModule\Entities\BookingServiceman::where('booking_id', $booking->id)
                ->where('serviceman_id', $serviceman->id)
                ->lockForUpdate()
                ->first();

            $isCurrentAssignment = $booking->serviceman_id === $serviceman->id;
            $isProviderAssignedSlot = $booking->booking_status === 'pending'
                && $slot
                && $slot->status === \Modules\BookingModule\Entities\BookingServiceman::STATUS_PENDING;
            if ($booking->booking_status !== 'pending' || (!$isCurrentAssignment && !$isProviderAssignedSlot)) {
                return false;
            }

            if ($slot && $slot->expires_at && $slot->expires_at->isPast()) {
                // GRACE: current assignee expiry ke baad bhi 180s tak accept
                // kar sakta hai (notification → app open → navigate me delay)
                $withinGrace = $isCurrentAssignment
                    && $slot->expires_at->copy()->addSeconds(180)->isFuture();
                if (!$withinGrace) {
                    return false;
                }
            }

            // LOCKED state se hi first-accept decide karo (bahar wale stale value par nahi)
            $isFirstAccept = $booking->booking_status === 'pending';

            if ($slot) {
                $slot->status = \Modules\BookingModule\Entities\BookingServiceman::STATUS_ACCEPTED;
                $slot->save();
            }

            if ($isFirstAccept) {
                // pehla accept = booking confirm (lead = ye serviceman)
                $booking->serviceman_id = $serviceman->id;
                $booking->booking_status = 'accepted';
                $booking->serviceman_assign_expires_at = null;
                $booking->save();

                $bookingStatusHistory = new $this->bookingStatusHistory;
                $bookingStatusHistory->booking_id = $booking->id;
                $bookingStatusHistory->changed_by = $request->user()->id;
                $bookingStatusHistory->booking_status = 'accepted';
                $bookingStatusHistory->save();

                // Provider-manual assignment me doosre logon ke pending slots
                // record reh sakte hain, lekin ab booking accepted hone ke baad
                // unke accept requests server reject karega.
                \Modules\BookingModule\Entities\BookingServiceman::where('booking_id', $booking->id)
                    ->where('status', \Modules\BookingModule\Entities\BookingServiceman::STATUS_PENDING)
                    ->update([
                        'status' => \Modules\BookingModule\Entities\BookingServiceman::STATUS_EXPIRED,
                        'expires_at' => now(),
                    ]);
            } elseif (!$slot) {
                return false;
            }

            return true;
        });

        if (!$accepted) {
            return response()->json(response_formatter(DEFAULT_204), 200);
        }

        // Provider ko push: model observer (serviceman_assign / booking_accepted job)
        // already bhej deta hai — direct push hataya taki provider ko 2-3 baar
        // same info na mile.

        return response()->json(response_formatter(BOOKING_STATUS_UPDATE_SUCCESS_200, $booking), 200);
    }

    /**
     * Serviceman reject:
     *  - booking PENDING: slot reject -> agla NEAREST serviceman (loop)
     *  - booking ACCEPTED (team): member team se nikla; lead chhoda to naya lead
     */
    public function rejectBooking(Request $request, string $bookingId): JsonResponse
    {
        $serviceman = $request->user()->serviceman;
        $booking = $this->booking
            ->where('id', $bookingId)
            ->where('provider_id', $serviceman->provider_id)
            ->whereIn('booking_status', ['pending', 'accepted'])
            ->first();

        if (!$booking) {
            return response()->json(response_formatter(DEFAULT_204), 200);
        }

        $slot = \Modules\BookingModule\Entities\BookingServiceman::where('booking_id', $booking->id)
            ->where('serviceman_id', $serviceman->id)
            ->first();

        if (!$slot && $booking->serviceman_id !== $serviceman->id) {
            return response()->json(response_formatter(DEFAULT_204), 200);
        }

        if ($booking->booking_status === 'pending') {
            $isProviderAssignedSlot = $booking->booking_status === 'pending'
                && $slot
                && $slot->status === \Modules\BookingModule\Entities\BookingServiceman::STATUS_PENDING;
            if ($booking->serviceman_id !== $serviceman->id && !$isProviderAssignedSlot) {
                return response()->json(response_formatter(DEFAULT_204), 200);
            }

            DB::transaction(function () use ($booking, $bookingId, $slot, $serviceman) {
                // SECURITY: row-lock + re-check (parallel reject/accept race band)
                $booking = \Modules\BookingModule\Entities\Booking::withoutGlobalScopes()
                    ->where('id', $bookingId)
                    ->lockForUpdate()
                    ->first();
                if (!$booking || $booking->booking_status !== 'pending') {
                    return;
                }
                $slot = \Modules\BookingModule\Entities\BookingServiceman::where('booking_id', $booking->id)
                    ->where('serviceman_id', $serviceman->id)
                    ->lockForUpdate()
                    ->first();

                if ($slot) {
                    $slot->status = \Modules\BookingModule\Entities\BookingServiceman::STATUS_REJECTED;
                    $slot->save();
                }
                if ($booking->serviceman_id === $serviceman->id) {
                    // Broadcast fallback me current lead decline kare to kisi
                    // remaining pending serviceman ko lead banao, taa ki expiry
                    // scheduler ek hi baar next cycle chala sake.
                    $nextPendingSlot = \Modules\BookingModule\Entities\BookingServiceman::where('booking_id', $booking->id)
                        ->where('status', \Modules\BookingModule\Entities\BookingServiceman::STATUS_PENDING)
                        ->where('expires_at', '>', now())
                        ->orderBy('expires_at')
                        ->first();
                    $booking->serviceman_id = $nextPendingSlot?->serviceman_id;
                    $booking->serviceman_assign_expires_at = $nextPendingSlot?->expires_at;
                    $booking->saveQuietly();
                }
            });

            // Broadcast fallback me baaki pending requests ko rehne do.
            $hasLiveSlot = \Modules\BookingModule\Entities\BookingServiceman::where('booking_id', $booking->id)
                ->where('status', \Modules\BookingModule\Entities\BookingServiceman::STATUS_PENDING)
                ->where('expires_at', '>', now())
                ->exists();

            if (!$hasLiveSlot) {
                dispatchNearestServicemanRequest($booking);
            }
        } else {
            // booking already accepted (team) — ye member exit kar raha hai
            DB::transaction(function () use ($booking, $bookingId, $slot, $serviceman) {
                // SECURITY: row-lock + re-check (parallel lead-exit race band)
                $booking = \Modules\BookingModule\Entities\Booking::withoutGlobalScopes()
                    ->where('id', $bookingId)
                    ->lockForUpdate()
                    ->first();
                if (!$booking || $booking->booking_status !== 'accepted') {
                    return;
                }
                $slot = \Modules\BookingModule\Entities\BookingServiceman::where('booking_id', $booking->id)
                    ->where('serviceman_id', $serviceman->id)
                    ->lockForUpdate()
                    ->first();

                if ($slot) {
                    $slot->status = \Modules\BookingModule\Entities\BookingServiceman::STATUS_REJECTED;
                    $slot->save();
                }
                if ($booking->serviceman_id === $serviceman->id) {
                    // lead chhod raha hai -> kisi accepted member ko naya lead banao
                    $newLead = \Modules\BookingModule\Entities\BookingServiceman::where('booking_id', $booking->id)
                        ->where('serviceman_id', '!=', $serviceman->id)
                        ->where('status', \Modules\BookingModule\Entities\BookingServiceman::STATUS_ACCEPTED)
                        ->first();
                    $booking->serviceman_id = $newLead?->serviceman_id;
                    $booking->save();
                }
            });
        }

        // NOTE: reject par provider ko direct push hataya — rotation automatic
        // hai, provider sirf update chahta hai (list poll / accepted par push).
        // Har reject par push notification spam tha.

        return response()->json(response_formatter(DEFAULT_200), 200);
    }

    /**
     * Assignment Tracker: booking ka complete auto-assign cycle history
     * Serviceman dekh sakta hai ki booking kitne servicemen ko assign hui
     * aur kaunse status me hai (pending, accepted, rejected, expired)
     */
    public function assignmentTracker(Request $request, string $bookingId): JsonResponse
    {
        $serviceman = $request->user()->serviceman;
        $booking = $this->booking
            ->where('id', $bookingId)
            ->where('provider_id', $serviceman->provider_id)
            ->first();

        if (!$booking) {
            return response()->json(response_formatter(DEFAULT_404), 404);
        }

        // Fetch all assignment history for this booking
        $assignmentHistory = \Modules\BookingModule\Entities\BookingServiceman::where('booking_id', $booking->id)
            ->with('serviceman:id,user_id')
            ->with('serviceman.user:id,first_name,last_name,profile_image')
            ->orderBy('created_at')
            ->get();

        $historyData = [];
        $sequence = 1;

        foreach ($assignmentHistory as $assignment) {
            $historyData[] = [
                'serviceman_id' => $assignment->serviceman_id,
                'serviceman_name' => $assignment->serviceman->user->first_name . ' ' . $assignment->serviceman->user->last_name,
                'serviceman_image' => $assignment->serviceman->user->profile_image,
                'status' => $assignment->status,
                'distance' => null, // Distance calculation requires live location - can be added later
                'assigned_at' => $assignment->created_at,
                'responded_at' => $assignment->updated_at,
                'sequence_order' => $sequence++,
            ];
        }

        // Check if booking is still cycling (no one accepted yet)
        $isStillCycling = $booking->booking_status === 'pending';

        $bookingDetails = \Modules\BookingModule\Entities\BookingDetail::where('booking_id', $booking->id)
            ->with('service:id,name,thumbnail')
            ->first();

        $data = [
            'booking_id' => $booking->id,
            'readable_id' => $booking->readable_id,
            'service_name' => $bookingDetails?->service?->name ?? '',
            'service_image' => $bookingDetails?->service?->thumbnail,
            'customer_location' => $booking->service_address_id ? \Modules\UserManagement\Entities\Address::find($booking->service_address_id)?->address ?? '' : '',
            'total_amount' => $booking->total_booking_amount,
            'service_schedule' => $booking->service_schedule,
            'assignment_history' => $historyData,
            'is_still_cycling' => $isStillCycling,
        ];

        return response()->json(response_formatter(DEFAULT_200, $data), 200);
    }

    /**
     * Final-cycle open requests for this serviceman only. The query is scoped
     * to their provider and to their own unexpired pending assignment slot.
     */
    public function zonePendingBookings(Request $request): JsonResponse
    {
        $serviceman = $request->user()->serviceman;
        $validator = Validator::make($request->all(), [
            'limit' => 'sometimes|numeric|min:1|max:100',
            'offset' => 'sometimes|numeric|min:1|max:100000',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $now = now();
        $graceCutoff = $now->copy()->subSeconds(180);

        // Serviceman ki assigned sub-categories
        $assignedSubCategoryIds = \Modules\ServicemanModule\Entities\ServicemanCategory::where('serviceman_id', $serviceman->id)
            ->pluck('sub_category_id')
            ->filter()
            ->toArray();

        $bookings = $this->booking
            ->with(['subCategory:id,name', 'detail.service'])
            ->where('provider_id', $serviceman->provider_id)
            ->where('booking_status', 'pending')
            ->where('assignment_mode', 'zone_pending')
            // Fail closed: an unconfigured serviceman must never see every
            // category's zone-pending work.
            ->whereIn('sub_category_id', $assignedSubCategoryIds)
            ->whereHas('servicemenAssignments', function ($query) use ($serviceman, $graceCutoff) {
                $query->where('serviceman_id', $serviceman->id)
                    ->where('status', \Modules\BookingModule\Entities\BookingServiceman::STATUS_PENDING)
                    ->where('expires_at', '>', $graceCutoff);
            })
            ->latest()
            ->paginate($request->input('limit', 20), ['*'], 'offset', $request->input('offset', 1))
            ->withPath('');

        foreach ($bookings as $booking) {
            $mySlot = \Modules\BookingModule\Entities\BookingServiceman::where('booking_id', $booking->id)
                ->where('serviceman_id', $serviceman->id)
                ->where('status', \Modules\BookingModule\Entities\BookingServiceman::STATUS_PENDING)
                ->first();
            $remaining = $mySlot?->expires_at
                ? max(0, $mySlot->expires_at->getTimestamp() - now()->getTimestamp())
                : 0;
            // GRACE: expiry ke baad bhi 180s tak accept_possible — app ko
            // grace remaining bhi countdown me dikhao
            if ($remaining <= 0 && $mySlot?->expires_at) {
                $remaining = max(0, $mySlot->expires_at->copy()->addSeconds(180)->getTimestamp() - now()->getTimestamp());
            }
            $booking->accept_remaining_seconds = $remaining;
        }

        return response()->json(response_formatter(DEFAULT_200, $bookings), 200);
    }

    /**
     * SPEC: serviceman customer ke ghar pahuncha (300m radius ke andar) to
     * "Reached" mark karega -> start OTP generate hoga jo customer app ke
     * booking details me dikhega (+ notification). Serviceman OTP verify
     * karke hi service start (ongoing) kar payega.
     */
    public function reachedBooking(Request $request, string $bookingId): JsonResponse
    {
        $servicemanId = $request->user()->serviceman->id;
        $booking = $this->booking
            ->where('id', $bookingId)
            ->where('serviceman_id', $servicemanId)
            ->whereIn('booking_status', ['accepted', 'ongoing'])
            ->first();
        $isRepeatBooking = false;

        if (!$booking) {
            $booking = $this->bookingRepeat
                ->with('booking.customer')
                ->where('id', $bookingId)
                ->where('serviceman_id', $servicemanId)
                ->whereIn('booking_status', ['accepted', 'ongoing'])
                ->first();
            $isRepeatBooking = $booking !== null;
        }

        if (!$booking) {
            return response()->json(response_formatter(DEFAULT_204), 200);
        }

        // Pehle se reached (OTP already hai) — dubara generate mat karo, par
        // customer ko OTP push DOBARA bhejo (agar pehli baar notification
        // fail hui ho to yahi "I Have Reached" click uska retry ban jayega).
        // Same OTP wapas jaata hai — user app ka START OTP card DB se hi
        // dikhta hai, push sirf instant alert hai.
        if (!is_null($booking->start_otp) && !is_null($booking->serviceman_reached_at)) {
            $this->sendStartOtpNotification($booking, $isRepeatBooking);
            return response()->json(response_formatter(BOOKING_STATUS_UPDATE_SUCCESS_200, $booking), 200);
        }

        // Serviceman ki current location (app regular location update bhejti hai)
        $servLat = $request->user()->current_lat;
        $servLng = $request->user()->current_lng;

        $locationBooking = $isRepeatBooking ? ($booking->booking ?? $booking) : $booking;
        [$bookingLat, $bookingLng] = getBookingCoordinates($locationBooking);

        $locationUpdatedAt = $request->user()->last_location_updated_at;
        if (!$locationUpdatedAt || \Carbon\Carbon::parse($locationUpdatedAt)->lt(now()->subMinutes(5))) {
            return response()->json(response_formatter(DEFAULT_400, null, [
                ['error_code' => 'location', 'message' => translate('Location is outdated. Turn on GPS and update your location first.')],
            ]), 400);
        }

        if (is_null($servLat) || is_null($servLng) || is_null($bookingLat) || is_null($bookingLng)) {
            return response()->json(response_formatter(DEFAULT_400, null, [
                ['error_code' => 'location', 'message' => translate('Location not available. Turn on GPS and update your location first.')],
            ]), 400);
        }

        $distanceKm = calculateDistance((float)$servLat, (float)$servLng, $bookingLat, $bookingLng);
        $radiusKm = 0.3; // 300 meter

        if ($distanceKm > $radiusKm) {
            return response()->json(response_formatter(DEFAULT_400, null, [
                ['error_code' => 'location', 'message' => translate('You are ') . round($distanceKm * 1000) . 'm ' . translate('away from the customer location. Get within 300m to start.')],
            ]), 400);
        }

        $booking->start_otp = (string) random_int(100000, 999999);
        $booking->start_otp_generated_at = now();
        $booking->serviceman_reached_at = now();
        $booking->save();

        // Customer ko OTP notification (user app booking details card + push)
        $this->sendStartOtpNotification($booking, $isRepeatBooking);

        return response()->json(response_formatter(BOOKING_STATUS_UPDATE_SUCCESS_200, $booking), 200);
    }

    /**
     * Customer ko start-OTP push. User app me booking details ka START OTP
     * card DB se hi dikhta hai — ye push sirf instant alert hai. Idempotent
     * hai: baar baar call kar sakte ho, same OTP wapas jaata hai.
     */
    private function sendStartOtpNotification($booking, bool $isRepeatBooking): void
    {
        try {
            $customer = $isRepeatBooking ? $booking->booking?->customer : $booking->customer;
            if ($customer?->fcm_token) {
                device_notification(
                    $customer->fcm_token,
                    translate('Your serviceman has arrived'),
                    translate('Share this OTP to start your service') . ': ' . $booking->start_otp,
                    null,
                    $booking->id,
                    'booking'
                );
            }
        } catch (\Throwable $e) {
        }
    }

    /**
     * SPEC: serviceman extra work ke liye apne provider ki subscribed
     * categories ki existing services select kar sakta hai (external) ya
     * manual add kar sakta hai. Ye endpoint provider ki services deta hai.
     */
    public function providerServices(Request $request): JsonResponse
    {
        $serviceman = $request->user()->serviceman;
        $provider = \Modules\ProviderManagement\Entities\Provider::where('id', $serviceman->provider_id)->first();

        if (!$provider) {
            return response()->json(response_formatter(DEFAULT_200, []), 200);
        }

        $subCategoryIds = \Modules\ProviderManagement\Entities\SubscribedService::where('provider_id', $provider->id)
            ->where('is_subscribed', 1)
            ->pluck('sub_category_id')
            ->toArray();

        if (empty($subCategoryIds)) {
            return response()->json(response_formatter(DEFAULT_200, []), 200);
        }

        $services = \Modules\ServiceManagement\Entities\Service::withoutGlobalScopes()
            ->whereIn('sub_category_id', $subCategoryIds)
            ->where('is_active', 1)
            ->with(['variations' => function ($query) {
                $query->select('id', 'service_id', 'variant_key', 'variant', 'price');
            }])
            ->get(['id', 'name', 'sub_category_id', 'zone_id'])
            ->map(function ($service) {
                $defaultVariant = $service->variations->firstWhere('variant_key', 'default') ?? $service->variations->first();
                return [
                    'id' => $service->id,
                    'name' => $service->name,
                    'price' => (float) ($defaultVariant?->price ?? 0),
                    'variant_key' => $defaultVariant?->variant_key ?? 'default',
                ];
            })
            ->values();

        return response()->json(response_formatter(DEFAULT_200, $services), 200);
    }

    /**
     * SPEC: serviceman on-site customer ki extra chije add karega — custom
     * name + custom price (external services bhi). Final bill/invoice me
     * include hoga (total_booking_amount update hota hai).
     */
    public function storeExtraService(Request $request, string $bookingId): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:120',
            'price' => 'required|numeric|min:0',
            'quantity' => 'required|integer|min:1|max:99',
            'type' => 'nullable|in:custom,external',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $booking = $this->booking
            ->where('id', $bookingId)
            ->where('serviceman_id', $request->user()->serviceman->id)
            ->where('booking_status', 'ongoing')
            ->first();

        if (!$booking) {
            return response()->json(response_formatter(DEFAULT_204), 200);
        }

        $amount = ((float)$request['price']) * ((int)$request['quantity']);

        $extra = new \Modules\BookingModule\Entities\BookingExtraService();
        $extra->booking_id = $booking->id;
        $extra->serviceman_id = $request->user()->serviceman->id;
        $extra->name = $request['name'];
        $extra->price = (float)$request['price'];
        $extra->quantity = (int)$request['quantity'];
        $extra->type = $request['type'] ?? 'custom';
        $extra->save();

        // Final bill update — total + additional_charge dono sync
        $booking->total_booking_amount += $amount;
        $booking->additional_charge += $amount;
        $booking->save();
        $this->notifyExtraServiceChanged($booking, $extra, true);

        return response()->json(response_formatter(DEFAULT_STORE_200, $booking->fresh(['extraServices'])), 200);
    }

    /** Increase one booked service by one unit while the serviceman is on site. */
    public function increaseServiceQuantity(Request $request, string $bookingId): JsonResponse
    {
        return $this->changeServiceQuantity($request, $bookingId, 1);
    }

    /** Decrease one booked service by one unit while the serviceman is on site. */
    public function decreaseServiceQuantity(Request $request, string $bookingId): JsonResponse
    {
        return $this->changeServiceQuantity($request, $bookingId, -1);
    }

    /**
     * Serviceman ke +/- quantity buttons ka shared handler.
     *
     * service_id/zone_id par uuid rule mat lagao — seeded data me service ids
     * "svc-0001-..." format ki hoti hain, uuid rule 400 return kar deta tha.
     * Ownership + zone match + detail lookup hi asli safety check hain.
     */
    private function changeServiceQuantity(Request $request, string $bookingId, int $delta): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'service_id' => 'required|string|max:191',
            'variant_key' => 'required|string|max:191',
            'zone_id' => 'required|string|max:191',
            'is_sub_booking' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $servicemanId = $request->user()->serviceman->id;
        $isSubBooking = $request->boolean('is_sub_booking');

        $result = DB::transaction(function () use ($request, $bookingId, $servicemanId, $isSubBooking, $delta) {
            if ($isSubBooking) {
                $booking = BookingRepeat::where('id', $bookingId)
                    ->where('serviceman_id', $servicemanId)
                    ->where('booking_status', 'ongoing')
                    ->lockForUpdate()
                    ->first();
                $detail = $booking ? $this->bookingRepeatDetail
                    ->where('booking_repeat_id', $bookingId)
                    ->where('service_id', $request['service_id'])
                    ->where('variant_key', $request['variant_key'])
                    ->lockForUpdate()
                    ->first() : null;
            } else {
                $booking = $this->booking
                    ->where('id', $bookingId)
                    ->where('serviceman_id', $servicemanId)
                    ->where('booking_status', 'ongoing')
                    ->lockForUpdate()
                    ->first();
                $detail = $booking ? $this->bookingDetail
                    ->where('booking_id', $bookingId)
                    ->where('service_id', $request['service_id'])
                    ->where('variant_key', $request['variant_key'])
                    ->lockForUpdate()
                    ->first() : null;
            }

            if (!$booking) {
                return ['error' => 'Only your ongoing booking can be changed.', 'status' => 403];
            }
            if ((string) $booking->zone_id !== (string) $request['zone_id']) {
                return ['error' => 'Service zone does not match this booking.', 'status' => 400];
            }
            if (!$detail) {
                return ['error' => 'Booked service was not found.', 'status' => 404];
            }

            $newQuantity = (int) $detail->quantity + $delta;
            if ($newQuantity > 99) {
                return ['error' => 'Maximum service quantity is 99.', 'status' => 400];
            }
            if ($newQuantity < 1) {
                return ['error' => 'Minimum service quantity is 1.', 'status' => 400];
            }

            $request->merge([
                'service_id' => $detail->service_id,
                'variant_key' => $detail->variant_key,
                'zone_id' => $booking->zone_id,
                'old_quantity' => (int) $detail->quantity,
                'new_quantity' => $newQuantity,
            ]);

            if ($isSubBooking) {
                $request->merge(['booking_repeat_id' => $bookingId]);
                if ($delta > 0) {
                    $this->increase_service_quantity_from_booking_repeat($request);
                } else {
                    $this->decrease_service_quantity_from_booking_repeat($request);
                }
            } else {
                $request->merge(['booking_id' => $bookingId]);
                if ($delta > 0) {
                    $this->increase_service_quantity_from_booking($request);
                } else {
                    $this->decrease_service_quantity_from_booking($request);
                }
            }

            return ['success' => true];
        });

        if (isset($result['error'])) {
            $responseCode = $result['status'] === 404 ? DEFAULT_404 : DEFAULT_400;
            return response()->json(
                response_formatter($responseCode, null, [['error_code' => 'booking', 'message' => $result['error']]]),
                $result['status']
            );
        }

        return response()->json(response_formatter(DEFAULT_UPDATE_200), 200);
    }

    /**
     * Extra service remove — total se amount wapas minus.
     */
    public function deleteExtraService(Request $request, string $bookingId, string $id): JsonResponse
    {
        $booking = $this->booking
            ->where('id', $bookingId)
            ->where('serviceman_id', $request->user()->serviceman->id)
            ->where('booking_status', 'ongoing')
            ->first();

        if (!$booking) {
            return response()->json(response_formatter(DEFAULT_204), 200);
        }

        $extra = \Modules\BookingModule\Entities\BookingExtraService::where('booking_id', $booking->id)
            ->where('id', $id)
            ->first();

        if (!$extra) {
            return response()->json(response_formatter(DEFAULT_204), 200);
        }

        $amount = ((float)$extra->price) * ((int)$extra->quantity);
        $extra->delete();

        $booking->total_booking_amount = max(0, $booking->total_booking_amount - $amount);
        $booking->additional_charge = max(0, $booking->additional_charge - $amount);
        $booking->save();
        $this->notifyExtraServiceChanged($booking, $extra, false);

        return response()->json(response_formatter(DEFAULT_200, $booking->fresh(['extraServices'])), 200);
    }

    private function notifyExtraServiceChanged(Booking $booking, $extra, bool $added): void
    {
        try {
            $booking->loadMissing(['customer', 'provider.owner']);
            $title = translate($added ? 'Extra service added to your booking' : 'Extra service removed from your booking');
            $description = trim((string) $extra->name) . ' x' . (int) $extra->quantity
                . ' — ' . number_format((float) $extra->price * (int) $extra->quantity, 2);
            $tokens = [
                $booking->customer?->fcm_token,
                $booking->provider?->owner?->fcm_token,
            ];

            foreach (array_unique(array_filter($tokens)) as $token) {
                device_notification($token, $title, $description, null, $booking->id, 'booking');
            }
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::warning('Extra-service notification failed: ' . $e->getMessage(), [
                'booking_id' => $booking->id,
            ]);
        }
    }
    public function bookingDetails(Request $request, string $id): JsonResponse
    {
        $booking = $this->booking->with([
            'detail.service', 'schedule_histories.user', 'status_histories.user', 'customer', 'provider', 'zone', 'serviceman.user', 'booking_partial_payments',
            'servicemenAssignments.serviceman.user', 'extraServices'
        ])->where(function ($query) use ($request) {
            return $query->where('serviceman_id', $request->user()->serviceman->id)
                ->orWhereHas('servicemenAssignments', function ($subQuery) use ($request) {
                    $subQuery->where('serviceman_id', $request->user()->serviceman->id)
                        ->whereIn('status', [
                            \Modules\BookingModule\Entities\BookingServiceman::STATUS_PENDING,
                            \Modules\BookingModule\Entities\BookingServiceman::STATUS_ACCEPTED,
                        ]);
                });
        })->where(['id' => $id])->first();

        if (isset($booking)) {
            $booking->service_address = $booking->service_address_location != null ? json_decode($booking->service_address_location) : $booking->service_address;

            if (isset($booking->provider)) {
                $booking->provider->callingEnabled = (bool)($booking->provider->calling_enabled ?? false);
            }

            $offlinePayment = $booking->booking_offline_payments?->first()?->customer_information;
            unset($booking->booking_offline_payments);

            if ($offlinePayment) {
                $booking->booking_offline_payment = collect($offlinePayment)->map(function ($value, $key) {
                    return ["key" => $key, "value" => $value];
                })->values()->all();
            }

            // AUTO-ASSIGN: mera accept deadline + team members
            $myId = $request->user()->serviceman->id;
            $mySlot = $booking->servicemenAssignments->firstWhere('serviceman_id', $myId);
            $isMyCurrentAssignment = (string) $booking->serviceman_id === (string) $myId;
            $isMyPendingSlot = $mySlot
                && $mySlot->status === \Modules\BookingModule\Entities\BookingServiceman::STATUS_PENDING;

            $acceptRemaining = 0;
            if ($booking->booking_status === 'pending' && $isMyPendingSlot && $mySlot->expires_at) {
                $acceptRemaining = max(0, $mySlot->expires_at->getTimestamp() - now()->getTimestamp());
            } elseif ($booking->booking_status === 'pending'
                && $isMyCurrentAssignment
                && !$mySlot
                && $booking->serviceman_assign_expires_at) {
                $assignExpires = $booking->serviceman_assign_expires_at instanceof \Carbon\Carbon
                    ? $booking->serviceman_assign_expires_at
                    : \Carbon\Carbon::parse($booking->serviceman_assign_expires_at);
                $acceptRemaining = max(0, $assignExpires->getTimestamp() - now()->getTimestamp());
            }

            // FALLBACK: agar slot ya expires_at null hai lekin booking pending
            // hai aur mujhe assign hui hai — provider ke wait_time se deadline banao
            // (taaki serviceman ko countdown popup mile, 0 par popup band na ho)
            if ($acceptRemaining <= 0
                && $booking->booking_status === 'pending'
                && $isMyCurrentAssignment
                && !$mySlot
                && !$booking->serviceman_assign_expires_at) {
                $waitTime = max(30, (int) ($booking->provider?->auto_assign_wait_time ?: 120));
                $acceptRemaining = $waitTime;
            }

            // GRACE: expiry ke baad bhi 180s tak current assignee accept kar
            // sakta hai — app me accept button dikhta rahe grace window me
            $inGraceWindow = false;
            if ($booking->booking_status === 'pending' && $acceptRemaining <= 0 && $isMyCurrentAssignment) {
                $deadline = $mySlot?->expires_at
                    ?? ($booking->serviceman_assign_expires_at
                        ? \Carbon\Carbon::parse($booking->serviceman_assign_expires_at)
                        : null);
                if ($deadline && $deadline->copy()->addSeconds(180)->isFuture()) {
                    $inGraceWindow = true;
                    $acceptRemaining = max(0, $deadline->copy()->addSeconds(180)->getTimestamp() - now()->getTimestamp());
                }
            }

            $canAcceptAssignment = $booking->booking_status === 'pending'
                && ($isMyPendingSlot || $isMyCurrentAssignment)
                && ($acceptRemaining > 0 || $inGraceWindow);

            $team = $booking->servicemenAssignments->map(function ($assignment) use ($myId) {
                return [
                    'serviceman_id' => $assignment->serviceman_id,
                    'name' => trim(($assignment->serviceman?->user?->first_name ?? '') . ' ' . ($assignment->serviceman?->user?->last_name ?? '')),
                    'image' => $assignment->serviceman?->user?->profile_image_full_path
                        ?? ($assignment->serviceman?->user?->profile_image ? asset('public/assets/provider-module/img/user2x.png') : null),
                    'status' => $assignment->status,
                    'is_me' => $assignment->serviceman_id === $myId,
                ];
            })->values();

            return response()->json(response_formatter(DEFAULT_200, [
                'booking' => $booking,
                'accept_remaining_seconds' => $acceptRemaining,
                'can_accept_assignment' => $canAcceptAssignment,
                'team' => $team,
                'provider_serviceman_can_cancel_booking' => (int)provider_config('provider_serviceman_can_cancel_booking', 'serviceman_config', $booking->provider_id)?->live_values,
                'provider_serviceman_can_edit_booking' => (int)provider_config('provider_serviceman_can_edit_booking', 'serviceman_config', $booking->provider_id)?->live_values,
            ]), 200);
        }
        return response()->json(response_formatter(DEFAULT_204), 200);
    }

    /**
     * Show the form for creating a new resource.
     * @param Request $request
     * @param string $id
     * @return JsonResponse
     */
    public function singleBookingDetails(Request $request, string $id): JsonResponse
    {
        $booking = $this->bookingRepeat->with([
            'detail.service', 'scheduleHistories.user', 'statusHistories.user', 'booking.service_address', 'booking.customer', 'booking.provider', 'serviceman.user'
        ])->where(function ($query) use ($request) {
            return $query->where('serviceman_id', $request->user()->serviceman->id);
        })->where(['id' => $id])->first();

        if (isset($booking)) {
            if (isset($booking->booking->provider)) {
                $booking->booking->provider->callingEnabled = (bool)($booking->booking->provider->calling_enabled ?? false);
            }

            return response()->json(response_formatter(DEFAULT_200, [
                'booking' => $booking,
                'provider_serviceman_can_cancel_booking' => (int)provider_config('provider_serviceman_can_cancel_booking', 'serviceman_config', $booking->provider_id)?->live_values,
                'provider_serviceman_can_edit_booking' => (int)provider_config('provider_serviceman_can_edit_booking', 'serviceman_config', $booking->provider_id)?->live_values,
            ]), 200);
        }
        return response()->json(response_formatter(DEFAULT_204), 200);
    }


    /**
     * Display a listing of the resource.
     * @param Request $request
     * @return JsonResponse
     */
    public function bookingList(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'limit' => 'required|numeric|min:1|max:200',
            'offset' => 'required|numeric|min:1|max:100000',
            'booking_status' => 'required|in:all,' . implode(',', array_column(BOOKING_STATUSES, 'key')),
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $servicemanId = auth('api')->user()->serviceman->id;

        // Serviceman ki assigned sub-categories
        $assignedSubCategoryIds = \Modules\ServicemanModule\Entities\ServicemanCategory::where('serviceman_id', $servicemanId)
            ->pluck('sub_category_id')
            ->filter()
            ->toArray();

        $bookings = $this->booking->with(['subCategory:id,name', 'repeat', 'servicemenAssignments'])
            ->where(function ($query) use ($servicemanId) {
                // Pending rotation request sirf current serviceman ko dikhni
                // chahiye; purane tried slots ko list se filter karo.
                $query->where('serviceman_id', $servicemanId)
                    ->orWhere(function ($manualAssignmentQuery) use ($servicemanId) {
                    $manualAssignmentQuery->where('booking_status', 'pending')
                        ->whereHas('servicemenAssignments', function ($subQuery) use ($servicemanId) {
                            $subQuery->where('serviceman_id', $servicemanId)
                                ->where('status', \Modules\BookingModule\Entities\BookingServiceman::STATUS_PENDING);
                        });
                    })
                    ->orWhere(function ($assignmentQuery) use ($servicemanId) {
                        $assignmentQuery->where('booking_status', '!=', 'pending')
                            ->whereHas('servicemenAssignments', function ($subQuery) use ($servicemanId) {
                                $subQuery->where('serviceman_id', $servicemanId)
                                    ->where('status', \Modules\BookingModule\Entities\BookingServiceman::STATUS_ACCEPTED);
                            });
                    })
                    ->orWhereHas('repeat', function ($subQuery) use ($servicemanId) {
                        $subQuery->where('serviceman_id', $servicemanId);
                    });
            })
            // Category filter: sirf usi category ki pending bookings jo serviceman ko assigned hain.
            // Agar koi category assign nahi to saari bookings (backward compat).
            // Already assigned (accepted/ongoing/completed) bookings filter mat karo.
            ->when(!empty($assignedSubCategoryIds), function ($q) use ($assignedSubCategoryIds) {
                $q->where(function ($inner) use ($assignedSubCategoryIds) {
                    $inner->whereNotIn('booking_status', ['pending'])
                          ->orWhere(function ($pendingQ) use ($assignedSubCategoryIds) {
                              $pendingQ->where('booking_status', 'pending')
                                       ->whereIn('sub_category_id', $assignedSubCategoryIds);
                          });
                });
            })
            ->when($request['booking_status'] != 'all', function ($query) use ($request) {
                $query->where(function ($subQuery) use ($request) {
                    $subQuery->where('booking_status', $request['booking_status'])
                        ->orWhereHas('repeat', function ($repeatQuery) use ($request) {
                            $repeatQuery->where('booking_status', $request['booking_status']);
                        });
                });
            })
            ->latest()
            ->paginate($request['limit'], ['*'], 'offset', $request['offset'])
            ->withPath('');

            foreach ($bookings as $booking) {
                if ($booking->repeat->isNotEmpty()) {
                    $filteredRepeats = $booking->repeat->where('serviceman_id', $servicemanId)->sortBy('readable_id');
                    $booking->repeats = $filteredRepeats->values()->toArray();
                }
                unset($booking->repeat);

                // AUTO-ASSIGN: mera accept deadline (pending slot ho toh)
                $mySlot = $booking->servicemenAssignments->firstWhere('serviceman_id', $servicemanId);
                $booking->accept_remaining_seconds = ($mySlot && $mySlot->status === \Modules\BookingModule\Entities\BookingServiceman::STATUS_PENDING && $mySlot->expires_at)
                    ? max(0, $mySlot->expires_at->getTimestamp() - now()->getTimestamp())
                    : 0;
            }

        return response()->json(response_formatter(DEFAULT_200, $bookings), 200);

    }

    /**
     * Show the specified resource.
     * @param Request $request
     * @return JsonResponse
     */
    public function notificationSend(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'booking_id' => 'required|uuid',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $booking = $this->booking
            ->with(['customer'])
            ->where('id', $request['booking_id'])
            ->where(function ($query) use ($request) {
                return $query->where('serviceman_id', $request->user()->serviceman->id);
            })
            ->first();

        $bookingRepeat = $this->bookingRepeat
            ->where('id', $request['booking_id'])
            ->where(function ($query) use ($request) {
                return $query->where('serviceman_id', $request->user()->serviceman->id);
            })
            ->first();

        if (!isset($booking)) {
            if ($bookingRepeat){
                $fcmToken = $bookingRepeat?->booking?->customer?->fcm_token;
                $title = get_push_notification_message('otp', 'customer_notification', $bookingRepeat?->booking?->customer?->current_language_key) . ' ' . $bookingRepeat->booking_otp;

                if ($fcmToken) {
                    device_notification($fcmToken, $title, null, null, $bookingRepeat->id, 'booking', null, $bookingRepeat?->booking?->customer?->id, null, null, 'repeat');
                    return response()->json(response_formatter(NOTIFICATION_SEND_SUCCESSFULLY_200), 200);

                } else {
                    return response()->json(response_formatter(NOTIFICATION_SEND_FAILED_200), 200);
                }
            }
            return response()->json(response_formatter(DEFAULT_404), 404);
        }

        $fcmToken = $booking?->customer?->fcm_token;
        $title = translate('Your booking verification OTP is') . ' ' . $booking->booking_otp;

        if ($fcmToken) {
            device_notification($fcmToken, $title, null, null, $booking->id, 'booking', null, $booking?->customer?->id);
            return response()->json(response_formatter(NOTIFICATION_SEND_SUCCESSFULLY_200), 200);

        } else {
            return response()->json(response_formatter(NOTIFICATION_SEND_FAILED_200), 200);
        }
    }

    /**
     * @param Request $request
     * @return JsonResponse
     */
    public function getServiceInfo(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'zone_id' => 'required|uuid',
            'service_info' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $data = [];
        $providerId = $request->user()->serviceman->provider_id;
        foreach (json_decode($request['service_info'], true) as $item) {
            $service = Service::active()
                ->where('id', $item['service_id'])
                ->with(['category.category_discount', 'category.campaign_discount', 'service_discount'])
                ->with(['variations' => fn($query) => $query->where('variant_key', $item['variant_key'])->where('zone_id', $request['zone_id'])])
                ->first();

            if (!isset($service)) return response()->json(response_formatter(DEFAULT_404, $data), 404);

            $quantity = $item['quantity'];
            $variationPrice = $service?->variations[0]?->price;

            $basicDiscount = basic_discount_calculation($service, $variationPrice * $quantity, $providerId);
            $campaignDiscount = campaign_discount_calculation($service, $variationPrice * $quantity);
            $subTotal = round($variationPrice * $quantity, 2);

            $applicableDiscount = ($campaignDiscount >= $basicDiscount) ? $campaignDiscount : $basicDiscount;

            $tax = round((($variationPrice * $quantity - $applicableDiscount) * $service['tax']) / 100, 2);

            $basicDiscount = $basicDiscount > $campaignDiscount ? $basicDiscount : 0;
            $campaignDiscount = $campaignDiscount >= $basicDiscount ? $campaignDiscount : 0;

            $data[] = collect([
                'service_id' => $service->id,
                'service_name' => $service->name,
                'variant_key' => $service?->variations[0]?->variant_key,
                'quantity' => $item['quantity'],
                'service_cost' => $variationPrice,
                'total_discount_amount' => $basicDiscount + $campaignDiscount,
                'coupon_code' => null,
                'tax_amount' => round($tax, 2),
                'total_cost' => round($subTotal - $basicDiscount - $campaignDiscount + $tax, 2),
                'zone_id' => $request['zone_id']
            ]);
        }

        return response()->json(response_formatter(DEFAULT_200, $data), 200);
    }

    /**
     * @param Request $request
     * @return JsonResponse
     */
    public function updateBooking(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'booking_id' => 'required|uuid',
            'service_info' => 'required',
            'payment_status' => 'nullable|in:0,1',
            'serviceman_id' => 'nullable',
            'booking_status' => 'nullable|in:' . implode(',', array_column(BOOKING_STATUSES, 'key')),
            'service_schedule' => 'nullable',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $booking = $this->booking
            ->with('detail')
            ->where('id', $request['booking_id'])
            ->where('serviceman_id', $request->user()->serviceman->id)
            ->first();

        if (!is_null($request['payment_status'])) $booking->is_paid = $request['payment_status'];
        if (!is_null($request['serviceman_id'])) $booking->serviceman_id = $request['serviceman_id'];
        if (!is_null($request['booking_status'])) $booking->booking_status = $request['booking_status'];
        if (!is_null($request['service_schedule'])) $booking->service_schedule = $request['service_schedule'];
        $booking->save();

        $editAccess = (boolean)provider_config('provider_serviceman_can_edit_booking', 'serviceman_config', $booking->provider_id)?->live_values;
        $request['service_info'] = collect(json_decode($request['service_info'], true));
        $serviceInfoValidated = $request['service_info']?->first()['quantity'] ?? null;

        if ($editAccess && $serviceInfoValidated) {
            $existingServices = $this->bookingDetail->where('booking_id', $request['booking_id'])->get();
            foreach ($existingServices as $item) {
                if (!$request['service_info']->where('service_id', $item->service_id)->where('variant_key', $item->variant_key)->first()) {
                    $request['service_info']->push([
                        'service_id' => $item->service_id,
                        'variant_key' => $item->variant_key,
                        'quantity' => 0,
                    ]);
                }
            }


            foreach ($request['service_info'] as $key => $item) {
                $existingService = $this->bookingDetail
                    ->where('booking_id', $request['booking_id'])
                    ->where('service_id', $item['service_id'])
                    ->where('variant_key', $item['variant_key'])
                    ->first();

                if (!$existingService) {
                    $request['service_id'] = $item['service_id'];
                    $request['variant_key'] = $item['variant_key'];
                    $request['quantity'] = $item['quantity'];
                    $this->addNewBookingService($request);

                } else if ($existingService && $item['quantity'] == 0) {
                    $request['service_id'] = $item['service_id'];
                    $request['variant_key'] = $item['variant_key'];
                    $request['quantity'] = $item['quantity'];

                    $this->remove_service_from_booking($request);

                } else if ($existingService && $existingService->quantity < $item['quantity']) {
                    $request['service_id'] = $item['service_id'];
                    $request['variant_key'] = $item['variant_key'];
                    $request['old_quantity'] = $existingService->quantity;
                    $request['new_quantity'] = (int)$item['quantity'];
                    $this->increase_service_quantity_from_booking($request);

                } else if ($existingService && $existingService->quantity > $item['quantity']) {
                    $request['service_id'] = $item['service_id'];
                    $request['variant_key'] = $item['variant_key'];
                    $request['old_quantity'] = $existingService->quantity;
                    $request['new_quantity'] = (int)$item['quantity'];

                    $this->decrease_service_quantity_from_booking($request);

                }
            }
        }

        return response()->json(response_formatter(DEFAULT_UPDATE_200), 200);
    }

    /**
     * @param Request $request
     * @return JsonResponse
     */
    public function updateBookingRepeat(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'booking_id' => 'required|uuid',
            'booking_repeat_id' => 'nullable',
            'service_info' => 'required',
            'payment_status' => 'nullable|in:0,1',
            'serviceman_id' => 'nullable',
            'booking_status' => 'nullable|in:' . implode(',', array_column(BOOKING_STATUSES, 'key')),
            'service_schedule' => 'nullable',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        if (empty($request->input('booking_repeat_id'))) {
            $findRepeatId = $this->booking->with('repeat')->where('id', $request->input('booking_id'))->first();

            if ($findRepeatId && $findRepeatId->repeat->isNotEmpty()) {
                $sortedRepeats = $findRepeatId->repeat->sortBy('readable_id');

                $repeatId = $sortedRepeats->firstWhere('booking_status', 'ongoing')?->id;

                if (!$repeatId) {
                    $repeatId = $sortedRepeats->firstWhere('booking_status', 'accepted')?->id;
                }

                $request->merge(['booking_repeat_id' => $repeatId]);
            }
        }

        $booking = $this->bookingRepeat
            ->with('detail')
            ->where('id', $request['booking_repeat_id'])
            ->where(function ($query) use ($request) {
                return $query->where('serviceman_id', $request->user()->serviceman->id);
            })->first();

        if (!is_null($request['payment_status'])) $booking->is_paid = $request['payment_status'];
        if (!is_null($request['serviceman_id'])) $booking->serviceman_id = $request['serviceman_id'];
        if (!is_null($request['booking_status'])) $booking->booking_status = $request['booking_status'];
        if (!is_null($request['service_schedule'])) $booking->service_schedule = $request['service_schedule'];
        $booking->save();

        $editAccess = (boolean)provider_config('provider_serviceman_can_edit_booking', 'serviceman_config', $booking->provider_id)?->live_values;
        $request['service_info'] = collect(json_decode($request['service_info'], true));
        $serviceInfoValidated = $request['service_info']?->first()['quantity'] ?? null;

        if ($editAccess && $serviceInfoValidated) {
            $totalOldQuantity = 0;
            $totalNewQuantity = 0;
            $updateQuantity = [];

            foreach ($request['service_info'] as $key => $item) {
                $existingService = $this->bookingRepeatDetail
                    ->where('booking_repeat_id', $request['booking_repeat_id'])
                    ->where('service_id', $item['service_id'])
                    ->where('variant_key', $item['variant_key'])
                    ->first();

                if ($existingService) {
                    $totalOldQuantity += $existingService->quantity;

                    if ($existingService->quantity < $item['quantity']) {
                        $request['service_id'] = $item['service_id'];
                        $request['variant_key'] = $item['variant_key'];
                        $request['old_quantity'] = $existingService->quantity;
                        $request['new_quantity'] = (int)$item['quantity'];

                        $this->increase_service_quantity_from_booking_repeat($request);
                    } else if ($existingService->quantity > $item['quantity']) {
                        $request['service_id'] = $item['service_id'];
                        $request['variant_key'] = $item['variant_key'];
                        $request['old_quantity'] = $existingService->quantity;
                        $request['new_quantity'] = (int)$item['quantity'];

                        $this->decrease_service_quantity_from_booking_repeat($request);
                    }

                    $totalNewQuantity += (int)$item['quantity'];
                    $updateQuantity[] = [
                        'service_id' => $item['service_id'],
                        'quantity' => (int)$item['quantity'],
                        'variant_key' => $item['variant_key'],
                        'service_name' => $existingService->service_name,
                        'service_cost' => $existingService->service_cost,
                    ];
                }
            }

            if ($request['next_all_booking_change'] == 1){
                $mainBooking = $this->booking->where('id', $request['booking_id'])->first();
                $sourceRepeatBooking = $this->bookingRepeat->where('id', $request['booking_repeat_id'])->first();

                $targetRepeatBookings = $this->bookingRepeat
                    ->where('booking_id', $request['booking_id'])
                    ->whereIn('booking_status', ['accepted', 'ongoing'])
                    ->where('id', '!=', $sourceRepeatBooking ? $sourceRepeatBooking->id : null)
                    ->orderBy('readable_id')
                    ->get();

                if ($sourceRepeatBooking) {

                    $sortedReadableIds = $targetRepeatBookings->pluck('readable_id')->sort()->values();
                    $minReadableId = $sortedReadableIds->first();
                    $maxReadableId = $sortedReadableIds->last();

                    if ($totalOldQuantity != $totalNewQuantity) {
                        foreach ($updateQuantity as $key => $update) {
                            $existService = $this->bookingRepeatDetail
                                ->where('booking_repeat_id', $request['booking_repeat_id'])
                                ->where('service_id', $update['service_id'])
                                ->first();

                            if ($existService) {
                                $updateQuantity[$key]['discount_amount'] = $existService->discount_amount;
                                $updateQuantity[$key]['tax_amount'] = $existService->tax_amount;
                                $updateQuantity[$key]['total_cost'] = $existService->total_cost;
                                $updateQuantity[$key]['repeat_details_id'] = $existService->id;
                            }
                        }
                        $bookingRepeatHistory = $this->bookingRepeatHistory;
                        $bookingRepeatHistory->booking_id = $request['booking_id'];
                        $bookingRepeatHistory->booking_repeat_id = $request['booking_repeat_id'];
                        $bookingRepeatHistory->old_quantity = $totalOldQuantity;
                        $bookingRepeatHistory->new_quantity = $totalNewQuantity;
                        $bookingRepeatHistory->is_multiple = $request['next_all_booking_change'] ? 1 : 0;
                        $bookingRepeatHistory->readable_id = "$minReadableId - $maxReadableId";
                        $bookingRepeatHistory->log_details = json_encode($updateQuantity);
                        $bookingRepeatHistory->total_booking_amount = $sourceRepeatBooking->total_booking_amount;
                        $bookingRepeatHistory->total_tax_amount = $sourceRepeatBooking->total_tax_amount;
                        $bookingRepeatHistory->total_discount_amount = $sourceRepeatBooking->total_discount_amount;
                        $bookingRepeatHistory->extra_fee = $sourceRepeatBooking->extra_fee;
                        $bookingRepeatHistory->save();
                    }

                    foreach ($targetRepeatBookings as $targetBooking) {
                        $targetBooking->total_booking_amount = $sourceRepeatBooking->total_booking_amount;
                        $targetBooking->total_tax_amount = $sourceRepeatBooking->total_tax_amount;
                        $targetBooking->total_discount_amount = $sourceRepeatBooking->total_discount_amount;
                        $targetBooking->total_campaign_discount_amount = $sourceRepeatBooking->total_campaign_discount_amount;
                        $targetBooking->save();
                    }

                    foreach ($sourceRepeatBooking->detail as $sourceDetail) {
                        foreach ($targetRepeatBookings as $targetBooking) {
                            foreach ($targetBooking->detail as $targetDetail) {
                                $targetDetail->quantity = $sourceDetail->quantity;
                                $targetDetail->tax_amount = $sourceDetail->tax_amount;
                                $targetDetail->total_cost = $sourceDetail->total_cost;
                                $targetDetail->discount_amount = $sourceDetail->discount_amount;
                                $targetDetail->campaign_discount_amount = $sourceDetail->campaign_discount_amount;
                                $targetDetail->overall_coupon_discount_amount = 0;
                                $targetDetail->save();
                            }
                        }
                    }

                    foreach ($sourceRepeatBooking->details_amounts as $sourceAmount) {
                        foreach ($targetRepeatBookings as $targetBooking) {
                            foreach ($targetBooking->details_amounts as $targetAmount) {
                                $targetAmount->service_quantity = $sourceAmount->service_quantity;
                                $targetAmount->service_tax = $sourceAmount->service_tax;
                                $targetAmount->coupon_discount_by_admin = 0;
                                $targetAmount->coupon_discount_by_provider = 0;
                                $targetAmount->discount_by_admin = $sourceAmount->discount_by_admin;
                                $targetAmount->discount_by_provider = $sourceAmount->discount_by_provider;
                                $targetAmount->campaign_discount_by_admin = $sourceAmount->campaign_discount_by_admin;
                                $targetAmount->campaign_discount_by_provider = $sourceAmount->campaign_discount_by_provider;
                                $targetAmount->save();
                            }
                        }
                    }
                }


                $mainBooking->total_booking_amount = $targetRepeatBookings->sum('total_booking_amount');
                $mainBooking->total_tax_amount = $targetRepeatBookings->sum('total_tax_amount');
                $mainBooking->total_discount_amount = $targetRepeatBookings->sum('total_discount_amount');
                $mainBooking->total_campaign_discount_amount = $targetRepeatBookings->sum('total_campaign_discount_amount');
                $mainBooking->save();

            }else{
                $mainBooking = $this->booking->where('id', $request['booking_id'])->first();
                $sourceRepeatBooking = $this->bookingRepeat->where('id', $request['booking_repeat_id'])->first();
                $repeatBooking = $this->bookingRepeat->where('booking_id', $request['booking_id'])->get();

                $mainBooking->total_booking_amount = $repeatBooking->sum('total_booking_amount');
                $mainBooking->total_tax_amount = $repeatBooking->sum('total_tax_amount');
                $mainBooking->total_discount_amount = $repeatBooking->sum('total_discount_amount');
                $mainBooking->total_campaign_discount_amount = $repeatBooking->sum('total_campaign_discount_amount');
                $mainBooking->save();

                if ($totalOldQuantity != $totalNewQuantity) {
                    foreach ($updateQuantity as $key => $update) {
                        $existService = $this->bookingRepeatDetail
                            ->where('booking_repeat_id', $request['booking_repeat_id'])
                            ->where('service_id', $update['service_id'])
                            ->first();

                        if ($existService) {
                            $updateQuantity[$key]['discount_amount'] = $existService->discount_amount;
                            $updateQuantity[$key]['tax_amount'] = $existService->tax_amount;
                            $updateQuantity[$key]['total_cost'] = $existService->total_cost;
                            $updateQuantity[$key]['repeat_details_id'] = $existService->id;
                        }
                    }

                    $bookingRepeatHistory = $this->bookingRepeatHistory;
                    $bookingRepeatHistory->booking_id = $request['booking_id'];
                    $bookingRepeatHistory->booking_repeat_id = $request['booking_repeat_id'];
                    $bookingRepeatHistory->old_quantity = $totalOldQuantity;
                    $bookingRepeatHistory->new_quantity = $totalNewQuantity;
                    $bookingRepeatHistory->is_multiple = $request['next_all_booking_change'] ? 1 : 0;
                    $bookingRepeatHistory->readable_id = $booking->readable_id;
                    $bookingRepeatHistory->log_details = json_encode($updateQuantity);
                    $bookingRepeatHistory->total_booking_amount = $sourceRepeatBooking->total_booking_amount;
                    $bookingRepeatHistory->total_tax_amount = $sourceRepeatBooking->total_tax_amount;
                    $bookingRepeatHistory->total_discount_amount = $sourceRepeatBooking->total_discount_amount;
                    $bookingRepeatHistory->extra_fee = $sourceRepeatBooking->extra_fee;
                    $bookingRepeatHistory->save();
                }
            }
        }
        return response()->json(response_formatter(DEFAULT_UPDATE_200), 200);
    }

    /**
     * @param Request $request
     * @return JsonResponse
     */
    public function removeService(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'booking_id' => 'required|uuid',
            'service_id' => 'required|uuid',
            'variant_key' => 'required',
            'zone_id' => 'required|uuid',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $booking = $this->booking->with('detail')
            ->where('id', $request['booking_id'])
            ->where(fn($query) => $query->where('serviceman_id', $request->user()->serviceman->id)->orWhereNull('serviceman_id'))
            ->first();

        if ($booking?->detail->count() < 2) {
            return response()->json(response_formatter(DEFAULT_400), 400);
        }

        $this->remove_service_from_booking($request);

        return response()->json(response_formatter(DEFAULT_UPDATE_200), 200);
    }
}
