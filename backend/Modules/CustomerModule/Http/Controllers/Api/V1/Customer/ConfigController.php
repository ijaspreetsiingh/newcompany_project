<?php

namespace Modules\CustomerModule\Http\Controllers\Api\V1\Customer;

use App\Traits\MaintenanceModeTrait;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Validator;
use MatanYadaev\EloquentSpatial\Objects\Point;
use Modules\BusinessSettingsModule\Entities\BusinessPageSetting;
use Modules\BusinessSettingsModule\Entities\DataSetting;
use Modules\BusinessSettingsModule\Entities\ErrorLog;
use Modules\BusinessSettingsModule\Entities\LoginSetup;
use Modules\PaymentModule\Entities\Setting;
use Modules\ServiceManagement\Entities\Service;
use Modules\UserManagement\Entities\User;
use Modules\ZoneManagement\Entities\Zone;

class ConfigController extends Controller
{
    use MaintenanceModeTrait;

    function __construct()
    {
    }

    /**
     * Display a listing of the resource.
     *
     * PERF: ye endpoint app ke START par call hota hai. Pehle yahan ~20 DB
     * queries chalti thi (har query ~2s on remote MySQL = 28s response!).
     * Ab poora payload 2 minute ke cache me hai → response ~0.1s.
     * Maintenance mode hamesha live rahega (admin toggle instant).
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function configuration(Request $request): JsonResponse
    {
        $payload = Cache::remember('customer_setup_config_v1', 120, function () {
            return $this->buildConfigurationPayload();
        });

        // Maintenance mode live (cache se nahi) — admin ka toggle instant kaam kare
        $payload['maintenance'] = $this->checkMaintenanceMode();

        return response()->json(response_formatter(DEFAULT_200, $payload), 200);
    }

    private function buildConfigurationPayload(): array
    {
        $playstore = business_config('app_url_playstore', 'landing_button_and_links');
        $appstore = business_config('app_url_appstore', 'landing_button_and_links');

        $socialMediaSettings = login_setup('social_media_for_login');
        $getValue = json_decode($socialMediaSettings['value'], true);
        $googleSocialLogin = $getValue['google'];
        $facebookSocialLogin = $getValue['facebook'];
        $appleSocialLogin = $getValue['apple'];

        $advancedBooking = [
            'advanced_booking_restriction_value' => (int)business_config('advanced_booking_restriction_value', 'booking_setup')?->live_values,
            'advanced_booking_restriction_type' => business_config('advanced_booking_restriction_type', 'booking_setup')?->live_values,
        ];

        //payment gateways
        $isPublished = 0;
        try {
            $full_data = include('Modules/Gateways/Addon/info.php');
            $isPublished = $full_data['is_published'] == 1 ? 1 : 0;
        } catch (\Exception $exception) {
        }

        $payment_gateways = collect($this->getPaymentMethods())
            ->filter(function ($query) use ($isPublished) {
                if (!$isPublished) {
                    return in_array($query['gateway'], array_column(PAYMENT_METHODS, 'key'));
                } else return $query;
            })->map(function ($query) {
                $query['label'] = ucwords(str_replace('_', ' ', $query['gateway_title']));
                return $query;
            })->values();

        $countryData = business_config('system_language', 'business_information')?->live_values;

        $country = [];

        foreach ($countryData as $item) {
            if ($item['status'] == 1) {
                $country[] = $item;
            }
        }

        // W4.25: config endpoint har request par poora error_logs table nahi
        // padhega — sirf redirect_url column, capped at 1000 rows.
        $errorLogs = ErrorLog::query()
            ->whereNotNull('redirect_url')
            ->select('id', 'url', 'redirect_url')
            ->limit(1000)
            ->get()
            ->map(function ($log) {
                $redirect = (string) $log->redirect_url;
                // Sirf safe http(s) redirects app tak bhejo (javascript: etc. block).
                $isSafe = preg_match('#^https?://#i', $redirect) === 1;

                return [
                    'url' => $log->url,
                    'redtrect_url' => $isSafe ? $redirect : null,
                ];
            })
            ->filter(fn ($log) => !empty($log['redtrect_url']))
            ->values();

        $loginOptionsValue = LoginSetup::where(['key' => 'login_options'])?->first()?->value;
        $loginOptions = json_decode($loginOptionsValue);

        $socialMediaLoginValue = LoginSetup::where(['key' => 'social_media_for_login'])?->first()?->value;
        $socialMediaLoginOptions = json_decode($socialMediaLoginValue);


        $customerLogin = [
            'login_option' => $loginOptions,
            'social_media_login_options' => $socialMediaLoginOptions
        ];

        $dataValues = Setting::where('settings_type', 'sms_config')->get();
        $count = 0;
        foreach ($dataValues as $gateway) {
            $status = $gateway?->live_values['status'] ?? 0;
            if ($status == 1) {
                $count = 1;
            }
        }

        $emailConfig = business_config('email_config_status', 'email_config')?->live_values;
        $firebaseOtpConfig = business_config('firebase_otp_verification', 'third_party');
        $firebaseOtpStatus = (int)$firebaseOtpConfig?->live_values['status'] ?? null;

        if ($firebaseOtpStatus == 1) {
            $count = 1;
        }

        $forgotPasswordVerificationMethod = [
            'phone' => $count,
            'email' => $emailConfig
        ];


        return [
            'default_location' => [
                'latitude' => (business_config('address_latitude', 'business_information'))->live_values ?? 23.811842872190,
                'longitude' => (business_config('address_longitude', 'business_information'))->live_values ?? 90.66504678008192
            ],
            'maintenance' => $this->checkMaintenanceMode(),
            'business_name' => (business_config('business_name', 'business_information'))->live_values ?? null,
            'logo_full_path' => getBusinessSettingsImageFullPath(key: 'business_logo', settingType: 'business_information', path: 'business/', defaultPath: 'public/assets/admin-module/img/media/banner-upload-file.png'),
            'favicon_full_path' => getBusinessSettingsImageFullPath(key: 'business_favicon', settingType: 'business_information', path: 'business/', defaultPath: 'public/assets/admin-module/img/media/upload-file.png'),
            'country_code' => (business_config('country_code', 'business_information'))->live_values ?? null,
            'business_address' => (business_config('business_address', 'business_information'))->live_values ?? null,
            'business_phone' => (business_config('business_phone', 'business_information'))->live_values ?? null,
            'business_email' => (business_config('business_email', 'business_information'))->live_values ?? null,
            'base_url' => rtrim(url('/'), '/') . '/api/v1/',
            'currency_decimal_point' => (business_config('currency_decimal_point', 'business_information'))->live_values ?? null,
            'currency_code' => (business_config('currency_code', 'business_information'))->live_values ?? null,
            'currency_symbol' => currency_symbol() ?? '',
            'currency_symbol_position' => (business_config('currency_symbol_position', 'business_information'))->live_values ?? null,
            'about_us' => route('about-us', ['app' => 'user']),
            'privacy_policy' => route('privacy-policy', ['app' => 'user']),
            'terms_and_conditions' =>  route('terms-and-conditions', ['app' => 'user']),
            'refund_policy' => DataSetting::where('key', 'refund_policy')->first()->is_active == '1' ? route('refund-policy', ['app' => 'user']) : "",
            'cancellation_policy' => DataSetting::where('key', 'cancellation_policy')->first()->is_active == '1' ? route('cancellation-policy', ['app' => 'user']) : "",
            'pagination_limit' => (int)pagination_limit(),
            'time_format' => (business_config('time_format', 'business_information'))->live_values ?? '24h',
            'payment_gateways' => $payment_gateways,
            'footer_text' => (business_config('footer_text', 'business_information'))->live_values ?? null,
            'cookies_text' => (business_config('cookies_text', 'business_information'))->live_values ?? null,
            // Chat/support ko sirf admin id chahiye; poora profile public na karo.
            'admin_details' => User::select('id')->where('user_type', ADMIN_USER_TYPES[0])->first(),
            'min_versions' => json_decode((business_config('customer_app_settings', 'app_settings'))->live_values ?? null),
            'banner_auto_slide_duration' => (int)(business_config('banner_slider_settings', 'app_settings')?->live_values['banner_auto_slide_duration'] ?? 5),
            'app_url_playstore' => $playstore->is_active ? $playstore->live_values : null,
            'app_url_appstore' => $appstore->is_active ? $appstore->live_values : null,
            'web_url' => (business_config('web_url', 'landing_button_and_links'))->is_active == '1' ? (business_config('web_url', 'landing_button_and_links'))->live_values : null,
            'google_social_login' => (int)($googleSocialLogin ?? 0),
            'facebook_social_login' => (int)($facebookSocialLogin ?? 0),
            'apple_social_login' => (int)($appleSocialLogin ?? 0),
            'phone_number_visibility_for_chatting' => (int)((business_config('phone_number_visibility_for_chatting', 'business_information'))->live_values ?? 0),
            'wallet_status' => (int)((business_config('customer_wallet', 'customer_config'))->live_values ?? 0),
            'add_to_fund_wallet' => (int)((business_config('add_to_fund_wallet', 'customer_config'))->live_values ?? 0),
            'loyalty_point_status' => (int)((business_config('customer_loyalty_point', 'customer_config'))->live_values ?? 0),
            'referral_earning_status' => (int)((business_config('customer_referral_earning', 'customer_config'))->live_values ?? 0),
            'direct_provider_booking' => (int)((business_config('direct_provider_booking', 'business_information'))->live_values ?? 0),
            'bidding_status' => (int)((business_config('bidding_status', 'bidding_system'))->live_values ?? 0),
            'phone_verification' => (((login_setup('phone_verification'))->value ?? 0 ) == 1 && $count == 1 ? 1 : 0),
            'email_verification' => (int)((login_setup('email_verification'))->value ?? 0),
            'cash_after_service' => (int)((business_config('cash_after_service', 'service_setup'))->live_values ?? 0),
            'digital_payment' => (int)((business_config('digital_payment', 'service_setup'))->live_values ?? 0),
            'wallet_payment' => (int)((business_config('wallet_payment', 'service_setup'))->live_values ?? 0),
            'social_media' => (business_config('social_media', 'landing_social_media'))->live_values ?? null,
            'otp_resend_time' => (int)(business_config('otp_resend_time', 'otp_login_setup'))?->live_values ?? null,
            'max_booking_amount' => (float)(business_config('max_booking_amount', 'booking_setup'))?->live_values ?? null,
            'min_booking_amount' => (float)(business_config('min_booking_amount', 'booking_setup'))?->live_values ?? null,
            'guest_checkout' => (int)(business_config('guest_checkout', 'service_setup'))?->live_values ?? null,
            'partial_payment' => (int)(business_config('partial_payment', 'service_setup'))?->live_values ?? null,
            'booking_additional_charge' => (int)(business_config('booking_additional_charge', 'booking_setup'))?->live_values ?? null,
            'additional_charge_label_name' => (string)(business_config('additional_charge_label_name', 'booking_setup'))?->live_values ?? null,
            'additional_charge_fee_amount' => (float)(business_config('additional_charge_fee_amount', 'booking_setup'))?->live_values ?? null,
            'offline_payment' => (int)(business_config('offline_payment', 'service_setup'))?->live_values ?? null,
            'partial_payment_combinator' => (string)(business_config('partial_payment_combinator', 'service_setup'))?->live_values ?? null,
            'provider_self_registration' => (int)business_config('provider_self_registration', 'provider_config')?->live_values,
            'confirm_otp_for_complete_service' => (int)business_config('booking_otp', 'booking_setup')?->live_values,
            'instant_booking' => (int)business_config('instant_booking', 'booking_setup')?->live_values,
            'schedule_booking' => (int)business_config('schedule_booking', 'booking_setup')?->live_values,
            'schedule_booking_time_restriction' => (int)business_config('schedule_booking_time_restriction', 'booking_setup')?->live_values,
            'advanced_booking' => $advancedBooking,
            'system_language' => $country,
            'login_setup' => $customerLogin,
            'firebase_otp_verification' => $firebaseOtpStatus,
            'forgot_password_verification_method' => $forgotPasswordVerificationMethod,
            'error_logs' => $errorLogs,
            // Demo flag apps ke liye; actual environment name leak mat karo.
            'app_environment' => env('APP_ENV') === 'demo' ? 'demo' : 'production',
            'repeat_booking' => (int)business_config('repeat_booking', 'booking_setup')?->live_values,
            'create_user_account_from_guest_info' => (int)(business_config('create_user_account_from_guest_info', 'business_information'))?->live_values ?? 0,
            'service_at_provider_place' => (int)((business_config('service_at_provider_place', 'provider_config'))->live_values ?? 0),
            'newsletter_title' => DataSetting::where('type', 'landing_text_setup')->where('key', 'newsletter_title')->first()->value ?? '',
            'newsletter_description' => DataSetting::where('type', 'landing_text_setup')->where('key', 'newsletter_description')->first()->value ?? '',
            'business_pages' => BusinessPageSetting::where('is_active', 1)->orderByDesc('is_default')->orderBy('created_at', 'ASC')->get()->map(function ($page){
                return [
                    'page_key'        => $page->page_key,
                    'title'           => $page->title,
                    'is_default'      => $page->is_default,
                    'image_full_path' => $page->image_full_path,
                ];
            }),
            'max_image_upload_size' => uploadMaxFileSize('image'),
            'max_video_upload_size' => uploadMaxFileSize('file'),
        ];
    }

    /**
     * Per-provider checkout payment config (user app payment step).
     * Independent mode ON -> allowed gateways + cash/wallet/offline toggles +
     * booking fee sirf us provider ke liye; OFF/empty -> global behaviour.
     */
    public function providerPaymentConfig(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'provider_id' => 'nullable|string|max:191',
            'guest_id' => 'nullable|string|max:191',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $provider = null;
        if (!empty($request['provider_id'])) {
            $provider = \Modules\ProviderManagement\Entities\Provider::find($request['provider_id']);
        }

        // Provider id na bheja ho (stale/local cart) to customer ke cart se
        // provider resolve karo — warna global (unfiltered) config chali jati hai.
        if (!$provider) {
            $authedCustomerId = null;
            try {
                $authedCustomerId = auth('api')->id();
            } catch (\Throwable $exception) {
                $authedCustomerId = null;
            }
            $cartCustomerId = $authedCustomerId ?: $request['guest_id'];
            if (!empty($cartCustomerId)) {
                $cartProviderId = \Modules\CartModule\Entities\Cart::where('customer_id', $cartCustomerId)
                    ->value('provider_id');
                if (!empty($cartProviderId)) {
                    $provider = \Modules\ProviderManagement\Entities\Provider::find($cartProviderId);
                }
            }
        }

        $isPublished = 0;
        try {
            $full_data = include('Modules/Gateways/Addon/info.php');
            $isPublished = $full_data['is_published'] == 1 ? 1 : 0;
        } catch (\Exception $exception) {
        }

        $payment_gateways = collect($this->getPaymentMethods())
            ->filter(function ($query) use ($isPublished) {
                if (!$isPublished) {
                    return in_array($query['gateway'], array_column(PAYMENT_METHODS, 'key'));
                } else return $query;
            })->map(function ($query) {
                $query['label'] = ucwords(str_replace('_', ' ', $query['gateway_title']));
                return $query;
            })->values()->all();

        $payment_gateways = filterPaymentGatewaysForProvider($payment_gateways, $provider);

        $cashAfterService = ((int) ((business_config('cash_after_service', 'service_setup'))->live_values ?? 0)
            && providerAllowsPaymentMethod($provider, 'cash_after_service')) ? 1 : 0;
        $walletPayment = ((int) ((business_config('wallet_payment', 'service_setup'))->live_values ?? 0)
            && providerAllowsPaymentMethod($provider, 'wallet_payment')) ? 1 : 0;
        $offlinePayment = ((int) ((business_config('offline_payment', 'service_setup'))->live_values ?? 0)
            && providerAllowsPaymentMethod($provider, 'offline_payment')) ? 1 : 0;
        $digitalPayment = ((int) ((business_config('digital_payment', 'service_setup'))->live_values ?? 0)
            && count($payment_gateways) > 0) ? 1 : 0;

        $providerFee = providerBookingFee($provider);
        $bookingAdditionalCharge = $providerFee !== null
            ? ($providerFee > 0 ? 1 : 0)
            : (int) (business_config('booking_additional_charge', 'booking_setup')?->live_values ?? 0);

        $providerTaxPercent = null;
        if (providerIsIndependent($provider)
            && $provider->tax_percent !== null
            && $provider->tax_percent !== '') {
            $providerTaxPercent = (float) $provider->tax_percent;
        }

        return response()->json(response_formatter(DEFAULT_200, [
            'provider_id' => $provider?->id,
            'independent_mode' => providerIsIndependent($provider) ? 1 : 0,
            'payment_gateways' => $payment_gateways,
            'cash_after_service' => $cashAfterService,
            'digital_payment' => $digitalPayment,
            'wallet_payment' => $walletPayment,
            'offline_payment' => $offlinePayment,
            'booking_additional_charge' => $bookingAdditionalCharge,
            'additional_charge_label_name' => providerBookingFeeLabel($provider)
                ?? (string) (business_config('additional_charge_label_name', 'booking_setup')?->live_values ?? ''),
            'additional_charge_fee_amount' => bookingExtraFee($provider),
            'provider_tax_percent' => $providerTaxPercent,
        ]), 200);
    }

    public function pages(): JsonResponse
    {
        // PERF: 6 alag DataSetting queries → 1 cached query
        $pages = Cache::remember('customer_pages_v1', 300, function () {
            return [
                'about_us' => DataSetting::where('type', 'pages_setup')->where('key', 'about_us')->first(),
                'terms_and_conditions' => DataSetting::where('type', 'pages_setup')->where('key', 'terms_and_conditions')->first(),
                'refund_policy' => DataSetting::where('type', 'pages_setup')->where('key', 'refund_policy')->first(),
                'return_policy' => DataSetting::where('type', 'pages_setup')->where('key', 'return_policy')->first(),
                'cancellation_policy' => DataSetting::where('type', 'pages_setup')->where('key', 'cancellation_policy')->first(),
                'privacy_policy' => DataSetting::where('type', 'pages_setup')->where('key', 'privacy_policy')->first(),
            ];
        });

        return response()->json(response_formatter(DEFAULT_200, $pages), 200);
    }

    public function pageDetails($key)
    {
        $page = BusinessPageSetting::where('page_key', $key)->first();
        return response()->json(response_formatter(DEFAULT_200, $page), 200);
    }


    public function getZone(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'lat' => 'required',
            'lng' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $point = new Point($request->lat, $request->lng);
        $zone = Zone::whereContains('coordinates', $point)->ofStatus(1)->latest()->first();

        if ($zone) {
            $zone['formatted_coordinates'] = formatCoordinates($zone->coordinates);

            $services = Service::withoutGlobalScope('zone_wise_data')->where('is_active', 1)->whereHas('category', function ($query) use ($zone) {
                $query->OfStatus(1)->withoutGlobalScope('zone_wise_data')->whereHas('zones', function ($query) use ($zone) {
                    $query->where('zone_id', $zone->id);
                });
            })->count();

            return response()->json(response_formatter(DEFAULT_200, [
                'zone' => $zone,
                'available_services_count' => $services,
            ]), 200);
        }

        return response()->json(response_formatter(ZONE_RESOURCE_404), 200);
    }

    public function placeApiAutocomplete(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'search_text' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $searchText = $request->input('search_text');
        $cacheKey = 'geo:autocomplete:' . md5(mb_strtolower(trim($searchText)));

        $results = Cache::get($cacheKey);
        if (!is_array($results)) {
            $url = 'https://nominatim.openstreetmap.org/search?q=' . urlencode($searchText) . '&format=json&limit=8&addressdetails=1';
            $response = Http::withHeaders([
                'User-Agent' => 'YOVOServiceApp/1.0 (support@yovoservice.app)',
                'Accept-Language' => 'en',
            ])->timeout(8)->get($url);

            $results = $response->successful() ? ($response->json() ?? []) : [];
            if (is_array($results) && !empty($results)) {
                Cache::put($cacheKey, $results, now()->addHours(12));
            }
        }
        $suggestions = [];

        foreach ($results as $item) {
            $osmType = strtoupper(substr($item['osm_type'] ?? 'node', 0, 1));
            $suggestions[] = [
                'placePrediction' => [
                    'placeId' => $osmType . ($item['osm_id'] ?? $item['place_id'] ?? ''),
                    'text' => [
                        'text' => $item['display_name'] ?? '',
                    ],
                    'types' => [$item['type'] ?? 'place'],
                ],
            ];
        }

        return response()->json(response_formatter(DEFAULT_200, [
            'suggestions' => $suggestions,
        ]), 200);
    }

    public function distanceApi(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'origin_lat' => 'required',
            'origin_lng' => 'required',
            'destination_lat' => 'required',
            'destination_lng' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $originLng = $request['origin_lng'];
        $originLat = $request['origin_lat'];
        $destLng = $request['destination_lng'];
        $destLat = $request['destination_lat'];

        // OSRM demo server fair-use: same route ko dobara call na karo.
        $cacheKey = 'geo:route:' . md5($originLng . ',' . $originLat . ';' . $destLng . ',' . $destLat);
        $data = Cache::get($cacheKey);

        if (!is_array($data)) {
            $url = "https://router.project-osrm.org/route/v1/driving/{$originLng},{$originLat};{$destLng},{$destLat}?overview=false";

            $response = Http::withHeaders([
                'User-Agent' => 'YOVOServiceApp/1.0 (support@yovoservice.app)',
            ])->timeout(8)->get($url);

            $data = $response->successful() ? ($response->json() ?? []) : [];
            if (isset($data['routes'][0])) {
                Cache::put($cacheKey, $data, now()->addHour());
            }
        }

        if (isset($data['routes'][0])) {
            $route = $data['routes'][0];
            $distanceMeters = round($route['distance']);
            $durationSeconds = round($route['duration']);

            if ($distanceMeters >= 1000) {
                $distanceText = round($distanceMeters / 1000, 1) . ' km';
            } else {
                $distanceText = $distanceMeters . ' m';
            }

            $durationMinutes = round($durationSeconds / 60);
            if ($durationMinutes >= 60) {
                $hours = floor($durationMinutes / 60);
                $mins = $durationMinutes % 60;
                $durationText = $hours . ' hr ' . $mins . ' min';
            } else {
                $durationText = $durationMinutes . ' min';
            }

            $content = [
                'rows' => [
                    [
                        'elements' => [
                            [
                                'distance' => [
                                    'text' => $distanceText,
                                    'value' => $distanceMeters,
                                ],
                                'duration' => [
                                    'text' => $durationText,
                                    'value' => $durationSeconds,
                                ],
                            ],
                        ],
                    ],
                ],
            ];
        } else {
            $content = [
                'rows' => [
                    [
                        'elements' => [
                            [
                                'distance' => ['text' => '', 'value' => 0],
                                'duration' => ['text' => '', 'value' => 0],
                            ],
                        ],
                    ],
                ],
            ];
        }

        return response()->json(response_formatter(DEFAULT_200, $content), 200);
    }

    public function placeApiDetails(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'placeid' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $placeId = $request['placeid'];
        $cacheKey = 'geo:place:' . md5((string) $placeId);
        $data = Cache::get($cacheKey);

        if (!is_array($data)) {
            $url = "https://nominatim.openstreetmap.org/lookup?osm_ids={$placeId}&format=json&addressdetails=1&extratags=1";
            $response = Http::withHeaders([
                'User-Agent' => 'YOVOServiceApp/1.0 (support@yovoservice.app)',
                'Accept-Language' => 'en',
            ])->timeout(8)->get($url);

            $results = $response->successful() ? ($response->json() ?? []) : [];
            $data = $results[0] ?? [];

            if (!empty($data)) {
                Cache::put($cacheKey, $data, now()->addDays(7));
            }
        }
        $data = !empty($data) ? $data : null;

        if ($data && !isset($data['error'])) {
            $address = $data['address'] ?? [];

            $addressComponents = [];
            if (isset($address['country'])) {
                $addressComponents[] = [
                    'long_name' => $address['country'],
                    'short_name' => strtoupper($address['country_code'] ?? ''),
                    'types' => ['country', 'political'],
                ];
            }
            if (isset($address['state'])) {
                $addressComponents[] = [
                    'long_name' => $address['state'],
                    'short_name' => $address['state'],
                    'types' => ['administrative_area_level_1', 'political'],
                ];
            }
            if (isset($address['city']) || isset($address['town']) || isset($address['village'])) {
                $cityName = $address['city'] ?? $address['town'] ?? $address['village'] ?? '';
                $addressComponents[] = [
                    'long_name' => $cityName,
                    'short_name' => $cityName,
                    'types' => ['locality', 'political'],
                ];
            }
            if (isset($address['road'])) {
                $addressComponents[] = [
                    'long_name' => $address['road'],
                    'short_name' => $address['road'],
                    'types' => ['route'],
                ];
            }
            if (isset($address['house_number'])) {
                $addressComponents[] = [
                    'long_name' => $address['house_number'],
                    'short_name' => $address['house_number'],
                    'types' => ['street_number'],
                ];
            }
            if (isset($address['postcode'])) {
                $addressComponents[] = [
                    'long_name' => $address['postcode'],
                    'short_name' => $address['postcode'],
                    'types' => ['postal_code'],
                ];
            }

            $content = [
                'id' => (string)($data['osm_id'] ?? $placeId),
                'name' => $data['localname'] ?? $data['display_name'] ?? '',
                'types' => [$data['type'] ?? 'place'],
                'formattedAddress' => $data['display_name'] ?? '',
                'location' => [
                    'latitude' => (float)($data['lat'] ?? 0),
                    'longitude' => (float)($data['lon'] ?? 0),
                ],
                'displayName' => [
                    'text' => $data['display_name'] ?? '',
                    'languageCode' => 'en',
                ],
                'address_components' => $addressComponents,
            ];
        } else {
            $content = [
                'id' => '',
                'name' => '',
                'types' => [],
                'formattedAddress' => '',
                'location' => ['latitude' => 0, 'longitude' => 0],
                'displayName' => ['text' => '', 'languageCode' => 'en'],
                'address_components' => [],
            ];
        }

        return response()->json(response_formatter(DEFAULT_200, $content), 200);
    }

    public function geocodeApi(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'lat' => 'required',
            'lng' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        // ~1m precision: map drag karne par same cell cache hit hota hai.
        $cacheLat = round((float) $request->lat, 5);
        $cacheLng = round((float) $request->lng, 5);
        $cacheKey = 'geo:reverse:' . $cacheLat . ',' . $cacheLng;
        $data = Cache::get($cacheKey);

        if (!is_array($data)) {
            $url = "https://nominatim.openstreetmap.org/reverse?lat={$cacheLat}&lon={$cacheLng}&format=json&addressdetails=1&zoom=18";
            $response = Http::withHeaders([
                'User-Agent' => 'YOVOServiceApp/1.0 (support@yovoservice.app)',
                'Accept-Language' => 'en',
            ])->timeout(8)->get($url);

            $data = $response->successful() ? ($response->json() ?? []) : [];
            if (isset($data['display_name'])) {
                Cache::put($cacheKey, $data, now()->addDays(7));
            }
        }

        if (isset($data['display_name'])) {
            $address = $data['address'] ?? [];

            $addressComponents = [];
            if (isset($address['country'])) {
                $addressComponents[] = [
                    'long_name' => $address['country'],
                    'short_name' => strtoupper($address['country_code'] ?? ''),
                    'types' => ['country', 'political'],
                ];
            }
            if (isset($address['state'])) {
                $addressComponents[] = [
                    'long_name' => $address['state'],
                    'short_name' => $address['state'],
                    'types' => ['administrative_area_level_1', 'political'],
                ];
            }
            if (isset($address['city']) || isset($address['town']) || isset($address['village'])) {
                $cityName = $address['city'] ?? $address['town'] ?? $address['village'] ?? '';
                $addressComponents[] = [
                    'long_name' => $cityName,
                    'short_name' => $cityName,
                    'types' => ['locality', 'political'],
                ];
            }
            if (isset($address['road'])) {
                $addressComponents[] = [
                    'long_name' => $address['road'],
                    'short_name' => $address['road'],
                    'types' => ['route'],
                ];
            }
            if (isset($address['house_number'])) {
                $addressComponents[] = [
                    'long_name' => $address['house_number'],
                    'short_name' => $address['house_number'],
                    'types' => ['street_number'],
                ];
            }
            if (isset($address['postcode'])) {
                $addressComponents[] = [
                    'long_name' => $address['postcode'],
                    'short_name' => $address['postcode'],
                    'types' => ['postal_code'],
                ];
            }

            $content = [
                'status' => 'OK',
                'results' => [
                    [
                        'formatted_address' => $data['display_name'],
                        'types' => [$data['type'] ?? 'street_address'],
                        'address_components' => $addressComponents,
                    ],
                ],
            ];
        } else {
            $content = [
                'status' => 'ZERO_RESULTS',
                'results' => [],
            ];
        }

        return response()->json(response_formatter(DEFAULT_200, $content), 200);
    }

    private function getPaymentMethods(): array
    {
        // PERF: har call pe Schema::hasTable() = information_schema query
        // (remote MySQL par ~2s). Ab table existence + poora result cached hai.
        return Cache::remember('customer_payment_methods_v1', 300, function () {
            if (!Schema::hasTable('addon_settings')) {
                return [];
            }

            $methods = DB::table('addon_settings')
                ->where('settings_type', 'payment_config')
                ->whereIn('key_name', array_column(DIGITAL_PAYMENT_METHODS, 'key'))
                ->get();
            $env = env('APP_ENV') == 'live' ? 'live' : 'test';
            $credentials = $env . '_values';

            $data = [];
            foreach ($methods as $method) {
                $gateway_image = getPaymentGatewayImageFullPath(key: $method->key_name, settingsType: $method->settings_type, defaultPath: null);
                $credentialsData = json_decode($method->$credentials);
                $additional_data = json_decode($method->additional_data);
                if (($credentialsData->status ?? 0) == 1) {
                    $data[] = [
                        'gateway' => $method->key_name,
                        'gateway_image_full_path' => $gateway_image,
                        'gateway_title' => $additional_data->gateway_title ?? $method->key_name,
                    ];
                }
            }
            return $data;
        });
    }

}


