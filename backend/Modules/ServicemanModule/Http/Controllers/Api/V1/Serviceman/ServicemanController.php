<?php

namespace Modules\ServicemanModule\Http\Controllers\Api\V1\Serviceman;

use App\Traits\UploadSizeHelperTrait;
use Carbon\Carbon;
use Illuminate\Contracts\Support\Renderable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;
use Modules\BookingModule\Entities\Booking;
use Modules\BookingModule\Entities\BookingScheduleHistory;
use Modules\BookingModule\Entities\BookingStatusHistory;
use Modules\PromotionManagement\Entities\PushNotification;
use Modules\SMSModule\Lib\SMS_gateway;
use Modules\UserManagement\Entities\Serviceman;
use Modules\UserManagement\Entities\User;
use Modules\PaymentModule\Traits\SmsGateway;

class ServicemanController extends Controller
{
    use UploadSizeHelperTrait;
    private Booking $booking;
    private Serviceman $serviceman;
    private User $employee;
    private PushNotification $pushNotification;

    public function __construct(Booking $booking, Serviceman $serviceman, User $employee, PushNotification $pushNotification)
    {
        $this->booking = $booking;
        $this->serviceman = $serviceman;
        $this->employee = $employee;
        $this->pushNotification = $pushNotification;
    }

    /**
     * Display a listing of the resource.
     * @param Request $request
     * @return JsonResponse
     */
    public function dashboard(Request $request): JsonResponse
    {
        $request['sections'] = explode(',', $request['sections']);

        $validator = Validator::make($request->all(), [
            'sections' => 'required|array',
            'sections.*' => 'in:top_cards,recent_bookings,booking_stats',
            'year' => 'integer|min:2000|max:' . (date('Y') + 1),
            'month' => 'integer|min:1|max:12',
            'stats_type' => 'in:full_year,full_month'
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $data = [];
        if (in_array('top_cards', $request['sections'])) {
            $servicemanId = $request->user()->serviceman->id;

// Cache top‑cards aggregation for 60 seconds to avoid repeated heavy DB scans
            $cacheKey = "serviceman_top_cards_{$servicemanId}";
            $topCards = \Illuminate\Support\Facades\Cache::remember($cacheKey, 60, function () use ($servicemanId) {
                $bookingOverview = DB::table('bookings')
                    ->select('booking_status', DB::raw('count(*) as total'))
                    ->where('serviceman_id', $servicemanId)
                    ->groupBy('booking_status');

                $repeatOverview = DB::table('booking_repeats')
                    ->select('booking_status', DB::raw('count(*) as total'))
                    ->where('serviceman_id', $servicemanId)
                    ->groupBy('booking_status');

                $combined = collect($bookingOverview->unionAll($repeatOverview)->get());

                return [
                    'total_bookings' => $combined->sum('total') ?? 0,
                    'pending_bookings' => $combined->where('booking_status', 'pending')->sum('total') ?? 0,
                    'ongoing_bookings' => $combined->where('booking_status', 'ongoing')->sum('total') ?? 0,
                    'completed_bookings' => $combined->where('booking_status', 'completed')->sum('total') ?? 0,
                    'canceled_bookings' => $combined->where('booking_status', 'canceled')->sum('total') ?? 0,
                ];
            });

            $data[] = [
                'top_cards' => $topCards
            ];
        }


        if (in_array('booking_stats', $request['sections'])) {
            $servicemanId = $request->user()->serviceman->id;
            $period = $request->input('stats_type');

            if (in_array($period, ['full_year', 'full_month'], true)) {
                $groupColumns = $period === 'full_year' ? 'year, month' : 'year, month, day';
                $regular = DB::table('booking_details_amounts as amounts')
                    ->join('bookings as booking', 'amounts.booking_id', '=', 'booking.id')
                    ->whereNull('amounts.booking_repeat_id')
                    ->where('booking.serviceman_id', $servicemanId)
                    ->where('booking.booking_status', 'completed')
                    ->whereYear('booking.created_at', $request['year'])
                    ->when($period === 'full_month', fn ($query) => $query->whereMonth('booking.created_at', $request['month']))
                    ->selectRaw('SUM(amounts.serviceman_earning) as total, YEAR(booking.created_at) as year, MONTH(booking.created_at) as month' . ($period === 'full_month' ? ', DAY(booking.created_at) as day' : ''))
                    ->groupByRaw($groupColumns);

                $repeat = DB::table('booking_details_amounts as amounts')
                    ->join('booking_repeats as booking_repeat', 'amounts.booking_repeat_id', '=', 'booking_repeat.id')
                    ->where('booking_repeat.serviceman_id', $servicemanId)
                    ->where('booking_repeat.booking_status', 'completed')
                    ->whereYear('booking_repeat.created_at', $request['year'])
                    ->when($period === 'full_month', fn ($query) => $query->whereMonth('booking_repeat.created_at', $request['month']))
                    ->selectRaw('SUM(amounts.serviceman_earning) as total, YEAR(booking_repeat.created_at) as year, MONTH(booking_repeat.created_at) as month' . ($period === 'full_month' ? ', DAY(booking_repeat.created_at) as day' : ''))
                    ->groupByRaw($groupColumns);

                $allBookings = DB::query()->fromSub($regular->unionAll($repeat), 'earning_rows')
                    ->selectRaw('SUM(total) as total, year, month' . ($period === 'full_month' ? ', day' : ''))
                    ->groupByRaw($groupColumns)
                    ->get()->toArray();
            } else {
                $allBookings = [];
            }

            $data[] = ['booking_stats' => $allBookings];
        }
        $servicemanId = auth('api')->user()->serviceman->id;
        if (in_array('recent_bookings', $request['sections'])) {
            $bookings = $this->booking->with(['detail.service' => function ($query) {
                $query->select('id', 'name', 'thumbnail');
            },'repeat'])->where(function ($query) use ($servicemanId) {
                $query->where('serviceman_id', $servicemanId)
                    ->orWhereHas('repeat', function ($subQuery) use ($servicemanId) {
                        $subQuery->where('serviceman_id', $servicemanId);
                    });
            })->take(5)->latest()->get();

            foreach ($bookings as $booking) {
                if ($booking->repeat->isNotEmpty()) {
                    $filteredRepeats = $booking->repeat->where('serviceman_id', $servicemanId)->sortBy('readable_id');
                    $booking->repeats = $filteredRepeats->values()->toArray();
                }
                unset($booking->repeat);
            }
            $data[] = ['bookings' => $bookings];
        }

        return response()->json(response_formatter(DEFAULT_200, $data), 200);
    }

    public function bookingStatistics(Request $request): JsonResponse
    {
        $servicemanId = $request->user()->serviceman->id;
        $now = Carbon::now();

        // Week starts on Sunday, ends on Saturday
        $startOfWeek = $now->copy()->startOfWeek(Carbon::MONDAY);
        $endOfWeek   = $now->copy()->endOfWeek(Carbon::SUNDAY);

        $startOfMonth = $now->copy()->startOfMonth();
        $endOfMonth   = $now->copy()->endOfMonth();

        $startOfYear = $now->copy()->startOfYear();
        $endOfYear   = $now->copy()->endOfYear();

        // Previous periods
        $lastWeekStart = $startOfWeek->copy()->subWeek();
        $lastWeekEnd   = $endOfWeek->copy()->subWeek();

        $lastMonthStart = $startOfMonth->copy()->subMonth();
        $lastMonthEnd   = $endOfMonth->copy()->subMonth();

        $lastYearStart = $startOfYear->copy()->subYear();
        $lastYearEnd   = $endOfYear->copy()->subYear();

        // Sum actual serviceman share from completed bookings (including repeats).
        $sumEarnings = function ($start, $end) use ($servicemanId) {
            $bookingEarnings = DB::table('booking_details_amounts as amounts')
                ->join('bookings as booking', 'amounts.booking_id', '=', 'booking.id')
                ->whereNull('amounts.booking_repeat_id')
                ->where('booking.serviceman_id', $servicemanId)
                ->where('booking.booking_status', 'completed')
                ->whereBetween('booking.created_at', [$start, $end])
                ->sum('amounts.serviceman_earning');

            $repeatEarnings = DB::table('booking_details_amounts as amounts')
                ->join('booking_repeats as booking_repeat', 'amounts.booking_repeat_id', '=', 'booking_repeat.id')
                ->where('booking_repeat.serviceman_id', $servicemanId)
                ->where('booking_repeat.booking_status', 'completed')
                ->whereBetween('booking_repeat.created_at', [$start, $end])
                ->sum('amounts.serviceman_earning');

            return (float) $bookingEarnings + (float) $repeatEarnings;
        };

        $allTimeEarning = $sumEarnings(Carbon::create(2000, 1, 1), $now->copy()->endOfDay());

        $paidCompletedBookings = DB::table('bookings')->where('serviceman_id', $servicemanId)
            ->where('booking_status', 'completed')->where('is_paid', 1)->count();
        $unpaidCompletedBookings = DB::table('bookings')->where('serviceman_id', $servicemanId)
            ->where('booking_status', 'completed')->where('is_paid', 0)->count();
        $paidCompletedRepeats = DB::table('booking_repeats')->where('serviceman_id', $servicemanId)
            ->where('booking_status', 'completed')->where('is_paid', 1)->count();
        $unpaidCompletedRepeats = DB::table('booking_repeats')->where('serviceman_id', $servicemanId)
            ->where('booking_status', 'completed')->where('is_paid', 0)->count();

        // Current periods
        $thisWeek  = $sumEarnings($startOfWeek, $endOfWeek);
        $thisMonth = $sumEarnings($startOfMonth, $endOfMonth);
        $thisYear  = $sumEarnings($startOfYear, $endOfYear);

        // Previous periods
        $lastWeek  = $sumEarnings($lastWeekStart, $lastWeekEnd);
        $lastMonth = $sumEarnings($lastMonthStart, $lastMonthEnd);
        $lastYear  = $sumEarnings($lastYearStart, $lastYearEnd);

        // Calculate percentage change
        $weekChange  = $lastWeek  > 0 ? (($thisWeek  - $lastWeek)  / $lastWeek)  * 100 : 0;
        $monthChange = $lastMonth > 0 ? (($thisMonth - $lastMonth) / $lastMonth) * 100 : 0;
        $yearChange  = $lastYear  > 0 ? (($thisYear  - $lastYear)  / $lastYear)  * 100 : 0;

        // Response data
        $data = [
            'this_week' => [
                'total_earning' => round($thisWeek, 2),
                'change' => round($weekChange, 2),
            ],
            'this_month' => [
                'total_earning' => round($thisMonth, 2),
                'change' => round($monthChange, 2),
            ],
            'this_year' => [
                'total_earning' => round($thisYear, 2),
                'change' => round($yearChange, 2),
            ],
            'payment_summary' => [
                'total_earning' => round($allTimeEarning, 2),
                'paid_completed_bookings' => $paidCompletedBookings + $paidCompletedRepeats,
                'unpaid_completed_bookings' => $unpaidCompletedBookings + $unpaidCompletedRepeats,
            ],
        ];

        return response()->json(response_formatter(DEFAULT_200, $data), 200);
    }


    /**
     * Custom date range earnings and booking count for serviceman dashboard.
     * GET /api/v1/technician/overview/earnings-range?from_date=YYYY-MM-DD&to_date=YYYY-MM-DD
     */
    public function earningsRange(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'from_date' => 'required|date_format:Y-m-d',
            'to_date' => 'required|date_format:Y-m-d|after_or_equal:from_date',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $servicemanId = $request->user()->serviceman->id;
        $fromDate = $request->from_date . ' 00:00:00';
        $toDate = $request->to_date . ' 23:59:59';

        $totalEarning = 0.0;
        $totalBookings = 0;

        // Regular bookings
        $regularEarnings = DB::table('booking_details_amounts as amounts')
            ->join('bookings as booking', 'amounts.booking_id', '=', 'booking.id')
            ->whereNull('amounts.booking_repeat_id')
            ->where('booking.serviceman_id', $servicemanId)
            ->where('booking.booking_status', 'completed')
            ->whereBetween('booking.created_at', [$fromDate, $toDate])
            ->get();

        foreach ($regularEarnings as $row) {
            $totalEarning += (float) ($row->serviceman_earning ?? 0);
            $totalBookings++;
        }

        // Repeat bookings
        $repeatEarnings = DB::table('booking_details_amounts as amounts')
            ->join('booking_repeats as booking_repeat', 'amounts.booking_repeat_id', '=', 'booking_repeat.id')
            ->where('booking_repeat.serviceman_id', $servicemanId)
            ->where('booking_repeat.booking_status', 'completed')
            ->whereBetween('booking_repeat.created_at', [$fromDate, $toDate])
            ->get();

        foreach ($repeatEarnings as $row) {
            $totalEarning += (float) ($row->serviceman_earning ?? 0);
            $totalBookings++;
        }

        $data = [
            'from_date' => $request->from_date,
            'to_date' => $request->to_date,
            'total_earning' => round($totalEarning, 2),
            'total_bookings' => $totalBookings,
        ];

        return response()->json(response_formatter(DEFAULT_200, $data), 200);
    }

    public function changePassword(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'password' => 'required|min:8|max:50',
            'confirm_password' => 'required|same:password'
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $this->employee->where('id', $request->user()->id)->update(['password' => bcrypt($request->password)]);

        return response()->json(response_formatter(DEFAULT_UPDATE_200), 200);
    }

    public function profileInfo(Request $request): JsonResponse
    {
        $user = $request->user();

        // Serviceman ki assigned categories bhi return karo taaki app
        // category-based UI (chips, profile display) sahi se dikha sake.
        $serviceman = $this->serviceman
            ->where('user_id', $user->id)
            ->with(['servicemanCategories.subCategory:id,name', 'servicemanCategories.mainCategory:id,name'])
            ->first();

        $userData = $user->toArray();
        $userData['assigned_categories'] = $serviceman
            ? $serviceman->servicemanCategories->map(fn($c) => [
                'sub_category_id'   => $c->sub_category_id,
                'category_id'       => $c->category_id,
                'sub_category_name' => $c->subCategory?->name,
                'category_name'     => $c->mainCategory?->name,
            ])->values()->toArray()
            : [];

        return response()->json(response_formatter(DEFAULT_UPDATE_200, $userData), 200);
    }

    /**
     * Display a listing of the resource.
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $serviceman = $this->serviceman->where(['user_id' => auth('api')->user()->id])
            ->with(['user', 'provider:id,zone_id', 'servicemanCategories.subCategory:id,name', 'servicemanCategories.mainCategory:id,name'])
            ->withCount(['bookings', 'bookings as completed_bookings_count' => function ($query) {
                $query->where('booking_status', 'completed');
            }])->first();

        if ($request->user()->user_type == PROVIDER_USER_TYPES[2]) {
            // App user object se assigned_categories padhta hai (chips display)
            if ($serviceman && $serviceman->user) {
                $serviceman->user->assigned_categories = $serviceman->servicemanCategories
                    ->map(fn($c) => [
                        'sub_category_id'   => $c->sub_category_id,
                        'category_id'       => $c->category_id,
                        'sub_category_name' => $c->subCategory?->name,
                        'category_name'     => $c->mainCategory?->name,
                    ])->values()->toArray();

                // Zone-pending category filter flag (provider ka toggle, sirf
                // zone pending screen ke liye):
                //   1 = filter ACTIVE (default) — sirf assigned categories ki bookings
                //   0 = provider ne "show all" ON kiya — filter hata do
                $ignoreFilter = (int)(provider_config('provider_serviceman_category_filter', 'serviceman_config', $serviceman->provider_id)?->live_values ?? 0) === 1;
                $serviceman->user->category_filter_active = $ignoreFilter ? 0 : 1;
            }

            return response()->json(response_formatter(DEFAULT_200, $serviceman), 200);
        }

        return response()->json(response_formatter(DEFAULT_403), 401);
    }

    /**
     * Modify provider information
     * @param Request $request
     * @return JsonResponse
     */
    public function updateProfile(Request $request): JsonResponse
    {
        $check = $this->validateUploadedFile($request, ['profile_image']);
        if ($check !== true) {
            return $check;
        }

        $employee = $this->employee::find($request->user()->id);
        if (!isset($employee)) {
            return response()->json(response_formatter(DEFAULT_204), 204);
        }

        $validator = Validator::make($request->all(), [
            'first_name' => 'required',
            'last_name' => 'required',
            'email' => 'required|email',
            'password' => '',
            'profile_image' => 'image|max:'. uploadMaxFileSizeInKB('image') .'|mimes:' . implode(',', array_column(IMAGEEXTENSION, 'key')),
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        if (User::where('email', $request['email'])->where('id', '!=', $employee->id)->exists()) {
            return response()->json(response_formatter(DEFAULT_400, null, [['error_code' => 'email', 'message' =>translate('Email already taken')]]), 400);
        }

        $employee->first_name = $request->first_name;
        $employee->last_name = $request->last_name;
        $employee->email = $request->email;
        if ($request->has('profile_image')) {
            $employee->profile_image = file_uploader('serviceman/profile/', APPLICATION_IMAGE_FORMAT, $request->file('profile_image'), $employee->profile_image);;
        }
        if ($request->has('password')) {
            $employee->password = bcrypt($request->password);
        }
        $employee->save();

        return response()->json(response_formatter(DEFAULT_UPDATE_200), 200);
    }

    /**
     * Display a listing of the resource.
     * @param Request $request
     * @return JsonResponse
     */
    public function pushNotifications(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'limit' => 'required|numeric|min:1|max:200',
            'offset' => 'required|numeric|min:1|max:100000',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $pushNotification = $this->pushNotification->ofStatus(1)->whereJsonContains('to_users', PROVIDER_USER_TYPES[2])
            ->whereJsonContains('zone_ids', $request->user()->serviceman->provider->zone_id)
            ->latest()
            ->paginate($request['limit'], ['*'], 'offset', $request['offset'])->withPath('');

        return response()->json(response_formatter(DEFAULT_200, $pushNotification), 200);
    }

    /**
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function forgotPassword(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'phone_or_email' => 'required'
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        DB::table('password_resets')->where('phone', $request['phone_or_email'])->delete();
        $customer = $this->employee->where('user_type', PROVIDER_USER_TYPES[2])
            ->where(['phone' => $request['phone_or_email']])
            ->first();

        if (isset($customer)) {
            $token = env('APP_ENV') != 'live' ? '1234' : rand(1000, 9999);

            DB::table('password_resets')->insert([
                'phone' => $customer['phone'],
                'email' => $customer['email'],
                'token' => $token,
                'created_at' => now(),
                'expires_at' => now()->addMinutes(3),
            ]);

            $method = business_config('forget_password_verification_method', 'business_information')?->live_values;
            if ($method == 'phone') {
                $publishedStatus = 0;
                $paymentPublishedStatus = config('get_payment_publish_status');
                if (isset($paymentPublishedStatus[0]['is_published'])) {
                    $publishedStatus = $paymentPublishedStatus[0]['is_published'];
                }
                if($publishedStatus == 1){
                    $response = SmsGateway::send($customer->phone, $token);
                }else{
                    SMS_gateway::send($customer->phone, $token);
                }

            } elseif($method == 'email') {
                $emailStatus = business_config('email_config_status', 'email_config')->live_values;

                if ($emailStatus){
                    try {
                        Mail::to($customer['email'])->send(new \App\Mail\PasswordResetMail($token));
                    } catch (\Exception $exception) {}
                }

            }

            return response()->json(response_formatter(DEFAULT_SENT_OTP_200), 200);
        }
        return response()->json(response_formatter(DEFAULT_404), 200);
    }

    /**
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function otpVerification(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'phone_or_email' => 'required',
            'otp' => 'required'
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $data = DB::table('password_resets')
            ->where('phone', $request['phone_or_email'])
            ->where(['token' => $request['otp']])->first();

        if (isset($data)) {
            return response()->json(response_formatter(DEFAULT_VERIFIED_200), 200);
        }

        return response()->json(response_formatter(DEFAULT_404), 200);
    }

    /**
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function resetPassword(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'phone_or_email' => 'required',
            'otp' => 'required',
            'password' => 'required',
            'confirm_password' => 'required|same:confirm_password'
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $data = DB::table('password_resets')
            ->where('phone', $request['phone_or_email'])
            ->where(['token' => $request['otp']])
            ->where('expires_at', '>', now())
            ->first();

        if (isset($data)) {
            $this->employee->where('user_type', PROVIDER_USER_TYPES[2])
                ->where('phone', $request['phone_or_email'])
                ->update([
                    'password' => bcrypt(str_replace(' ', '', $request['password']))
                ]);
            DB::table('password_resets')
                ->where('phone', $request['phone_or_email'])
                ->where(['token' => $request['otp']])->delete();

        } else {
            return response()->json(response_formatter(DEFAULT_404), 200);
        }

        return response()->json(response_formatter(DEFAULT_PASSWORD_RESET_200), 200);
    }


    /**
     * Modify provider information
     * @param Request $request
     * @return JsonResponse
     */
    public function updateFcmToken(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'fcm_token' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $customer = $this->employee::find($request->user()->id);
        $customer->fcm_token = $request->fcm_token;
        $customer->save();

        return response()->json(response_formatter(DEFAULT_UPDATE_200), 200);
    }

    /**
     * On-duty toggle (serviceman app "Available for jobs" switch):
     * OFF karne par auto-assign is serviceman ko nahi karega.
     */
    public function updateWorkStatus(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'is_on_duty' => 'required|in:0,1',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $serviceman = $request->user()->serviceman;
        if (!$serviceman) {
            return response()->json(response_formatter(DEFAULT_204), 200);
        }

        $serviceman->is_on_duty = (int) $request->is_on_duty;
        $serviceman->save();

        return response()->json(response_formatter(DEFAULT_UPDATE_200), 200);
    }

    /**
     * Current duty status — app start par sync ke liye
     */
    public function getWorkStatus(Request $request): JsonResponse
    {
        $serviceman = $request->user()->serviceman;
        $isOnDuty = $serviceman ? (int) ($serviceman->is_on_duty ?? 1) : 1;

        return response()->json(response_formatter(DEFAULT_200, [
            'is_on_duty' => $isOnDuty,
        ]), 200);
    }

    /**
     * Update serviceman's current GPS location
     * @param Request $request
     * @return JsonResponse
     */
    public function updateLocation(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'lat' => 'required|numeric|between:-90,90',
            'lng' => 'required|numeric|between:-180,180',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $user = $this->employee::find($request->user()->id);
        if (!isset($user)) {
            return response()->json(response_formatter(DEFAULT_204), 204);
        }

        $user->current_lat = $request->lat;
        $user->current_lng = $request->lng;
        $user->last_location_updated_at = Carbon::now();
        $user->save();

        return response()->json(response_formatter(DEFAULT_UPDATE_200), 200);
    }

    /**
     * @param Request $request
     * @return JsonResponse
     */
    public function changeLanguage(Request $request): JsonResponse
    {
        if (auth('api')->user()){
            $serviceman = $this->employee::find(auth('api')->user()->id);
            $serviceman->current_language_key = $request->header('X-localization') ?? 'en';
            $serviceman->save();
            return response()->json(response_formatter(DEFAULT_200), 200);
        }
        return response()->json(response_formatter(DEFAULT_404), 200);
    }
}
