<?php

namespace Modules\ServicemanModule\Http\Controllers\Web\Serviceman;

use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\DB;
use Modules\BookingModule\Entities\Booking;
use Modules\BookingModule\Entities\BookingDetailsAmount;
use Modules\TransactionModule\Entities\Transaction;
use Modules\UserManagement\Entities\Serviceman;
use Modules\UserManagement\Entities\User;

class ServicemanPanelController extends Controller
{
    protected $serviceman;
    protected $booking;
    protected $transaction;
    protected $bookingDetailsAmount;

    public function __construct(Serviceman $serviceman, Booking $booking, Transaction $transaction, BookingDetailsAmount $bookingDetailsAmount)
    {
        $this->serviceman = $serviceman;
        $this->booking = $booking;
        $this->transaction = $transaction;
        $this->bookingDetailsAmount = $bookingDetailsAmount;
    }

    public function dashboard(Request $request)
    {
        $servicemanId = $request->user()->serviceman->id;

        $myBookings = $this->booking->where('serviceman_id', $servicemanId)
            ->orWhereHas('repeat', function ($q) use ($servicemanId) {
                $q->where('serviceman_id', $servicemanId);
            })->get();

        $total_bookings = $myBookings->count();
        $pending_bookings = $myBookings->where('booking_status', 'pending')->count();
        $ongoing_bookings = $myBookings->where('booking_status', 'ongoing')->count();
        $completed_bookings = $myBookings->where('booking_status', 'completed')->count();
        $canceled_bookings = $myBookings->where('booking_status', 'canceled')->count();

        $recent_bookings = $this->booking->with(['detail.service' => function ($q) {
            $q->select('id', 'name', 'thumbnail');
        }])
            ->where('serviceman_id', $servicemanId)
            ->latest()
            ->take(5)
            ->get();

        $weekly_stats = $this->booking
            ->where('serviceman_id', $servicemanId)
            ->where('booking_status', 'completed')
            ->where('created_at', '>=', Carbon::now()->subWeek())
            ->select('booking_status', DB::raw('count(*) as total'))
            ->groupBy('booking_status')
            ->get();

        $provider = $request->user()->serviceman->provider;

        return view('servicemanmodule::dashboard.index', compact(
            'total_bookings', 'pending_bookings', 'ongoing_bookings',
            'completed_bookings', 'canceled_bookings', 'recent_bookings',
            'weekly_stats', 'provider'
        ));
    }

    public function bookingList(Request $request)
    {
        $servicemanId = $request->user()->serviceman->id;
        $status = $request->get('status', 'all');

        $bookings = $this->booking->with(['detail.service', 'customer', 'zone' => function ($q) {
            $q->withoutGlobalScope('translate');
        }])
            ->where(function ($q) use ($servicemanId) {
                $q->where('serviceman_id', $servicemanId)
                    ->orWhereHas('repeat', function ($sub) use ($servicemanId) {
                        $sub->where('serviceman_id', $servicemanId);
                    });
            })
            ->when($status !== 'all', function ($q) use ($status) {
                $q->where('booking_status', $status);
            })
            ->latest()
            ->paginate(10);

        return view('servicemanmodule::booking.list', compact('bookings', 'status'));
    }

    public function bookingDetails(Request $request, string $id)
    {
        $servicemanId = $request->user()->serviceman->id;

        $booking = $this->booking->with([
            'detail.service',
            'customer',
            'provider',
            'serviceman.user',
            'service_address',
            'zone' => function ($q) { $q->withoutGlobalScope('translate'); },
        ])
            ->where(function ($q) use ($servicemanId) {
                $q->where('serviceman_id', $servicemanId)
                    ->orWhereNull('provider_id');
            })
            ->where('id', $id)
            ->firstOrFail();

        $booking_amount = $this->bookingDetailsAmount->where('booking_id', $id)->first();

        return view('servicemanmodule::booking.details', compact('booking', 'booking_amount'));
    }

    public function statusUpdate(Request $request)
    {
        $request->validate([
            'booking_id' => 'required|uuid',
            'booking_status' => 'required|in:ongoing,completed,canceled',
        ]);

        $servicemanId = $request->user()->serviceman->id;
        $booking = $this->booking->where('id', $request->booking_id)
            ->where('serviceman_id', $servicemanId)
            ->firstOrFail();

        if ($request->booking_status === 'completed') {
            $otpVerify = business_config('confirm_otp_for_complete_service', 'booking_setup');
            if (isset($otpVerify) && $otpVerify->live_values == 1) {
                $request->validate([
                    'otp' => 'required|in:' . $booking->booking_otp,
                ]);
            }
        }

        $booking->booking_status = $request->booking_status;
        $booking->save();

        return back()->with('success', translate('booking_status_updated'));
    }

    public function profile(Request $request)
    {
        $user = $request->user();
        $serviceman = $user->serviceman;

        return view('servicemanmodule::profile.index', compact('user', 'serviceman'));
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'first_name' => 'required|string|max:255',
            'last_name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email,' . $user->id,
        ]);

        $user->first_name = $request->first_name;
        $user->last_name = $request->last_name;
        $user->email = $request->email;

        if ($request->hasFile('profile_image')) {
            $user->profile_image = file_uploader($request->file('profile_image'), 'profile');
        }

        $user->save();

        return back()->with('success', translate('profile_updated'));
    }

    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required',
            'password' => 'required|min:6|confirmed',
        ]);

        $user = $request->user();

        if (!\Hash::check($request->current_password, $user->password)) {
            return back()->with('error', translate('current_password_wrong'));
        }

        $user->password = \Hash::make($request->password);
        $user->save();

        return back()->with('success', translate('password_changed'));
    }

    public function updateLocation(Request $request)
    {
        $request->validate([
            'lat' => 'required|numeric|between:-90,90',
            'lng' => 'required|numeric|between:-180,180',
        ]);

        $user = $request->user();
        $user->current_lat = $request->lat;
        $user->current_lng = $request->lng;
        $user->last_location_updated_at = Carbon::now();
        $user->save();

        return response()->json(['success' => true]);
    }
}
