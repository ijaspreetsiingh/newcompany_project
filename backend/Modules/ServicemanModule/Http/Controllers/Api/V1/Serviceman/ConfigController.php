<?php

namespace Modules\ServicemanModule\Http\Controllers\Api\V1\Serviceman;

use App\Traits\MaintenanceModeTrait;
use DateTimeZone;
use Grimzy\LaravelMysqlSpatial\Types\Point;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Validator;
use Modules\BusinessSettingsModule\Entities\BusinessPageSetting;
use Modules\PaymentModule\Entities\Setting;
use Modules\ZoneManagement\Entities\Zone;

class ConfigController extends Controller
{
    use MaintenanceModeTrait;
    function __construct()
    {
    }


    /**
     * Display a listing of the resource.
     * @param Request $request
     * @return JsonResponse
     */
    public function configuration(Request $request): JsonResponse
    {
        $advancedBooking =  [
            'advanced_booking_restriction_value' => (int) business_config('advanced_booking_restriction_value', 'booking_setup')?->live_values,
            'advanced_booking_restriction_type' => business_config('advanced_booking_restriction_type', 'booking_setup')?->live_values,
        ];

        $countryData = business_config('system_language', 'business_information')?->live_values;

        $country = [];

        foreach ($countryData as $item) {
            if ($item['status'] == 1) {
                $country[] = $item;
            }
        }

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
        $firebaseOtpStatus =(int) $firebaseOtpConfig?->live_values['status'] ?? null;

        if ($firebaseOtpStatus == 1){
            $count = 1;
        }

        $forgotPasswordVerificationMethod = [
            'phone' => $count,
            'email' => $emailConfig
        ];

        return response()->json(response_formatter(DEFAULT_200, [
            'maintenance' => $this->checkMaintenanceMode(),
            'currency_symbol_position' => (business_config('currency_symbol_position', 'business_information'))->live_values ?? null,
            'serviceman_can_cancel_booking' => (int)(business_config('serviceman_can_cancel_booking', 'serviceman_config'))?->live_values,
            'serviceman_can_edit_booking' => (int)(business_config('serviceman_can_edit_booking', 'serviceman_config'))?->live_values,
            'business_name' => (business_config('business_name', 'business_information'))->live_values ?? null,
            'logo_full_path' => getBusinessSettingsImageFullPath(key: 'business_logo', settingType: 'business_information', path: 'business/',  defaultPath : 'public/assets/admin-module/img/media/banner-upload-file.png'),
            'favicon_full_path' =>  getBusinessSettingsImageFullPath(key: 'business_favicon', settingType: 'business_information', path: 'business/',  defaultPath : 'public/assets/admin-module/img/media/upload-file.png'),
            'country_code' => (business_config('country_code', 'business_information'))->live_values ?? null,
            'business_address' => (business_config('business_address', 'business_information'))->live_values ?? null,
            'business_phone' => (business_config('business_phone', 'business_information'))->live_values ?? null,
            'business_email' => (business_config('business_email', 'business_information'))->live_values ?? null,
            'base_url' => rtrim(url('/'), '/') . '/api/v1/',
            'currency_decimal_point' => (business_config('currency_decimal_point', 'business_information'))->live_values ?? null,
            'currency_code' => (business_config('currency_code', 'business_information'))->live_values ?? null,
            'currency_symbol' => currency_symbol() ?? '',
            'about_us' => route('about-us'),
            'privacy_policy' => route('privacy-policy'),
            'terms_and_conditions' => (business_config('terms_and_conditions', 'pages_setup'))->is_active ? route('terms-and-conditions') : "",
            'refund_policy' => (business_config('refund_policy', 'pages_setup'))->is_active ? route('refund-policy') : "",
            'cancellation_policy' => (business_config('cancellation_policy', 'pages_setup'))->is_active ? route('cancellation-policy') : "",
            'default_location' => ['default' => [
                'lat' => (business_config('address_latitude', 'business_information'))->live_values ?? 23.811842872190,
                'lon' => (business_config('address_longitude', 'business_information'))->live_values ?? 90.66504678008192
            ]],
            'sms_verification' => (business_config('sms_verification', 'service_setup'))->live_values ?? null,
            'pagination_limit' => (int)pagination_limit(),
            'time_format' => (business_config('time_format', 'business_information'))->live_values ?? '24h',
            'footer_text' => (business_config('footer_text', 'business_information'))->live_values ?? null,
            'min_versions' => json_decode((business_config('serviceman_app_settings', 'app_settings'))->live_values ?? null),
            'phone_verification' => (((login_setup('phone_verification'))->value ?? 0 ) == 1 && $count == 1 ? 1 : 0),
            'email_verification' => (int)((login_setup('email_verification'))->value ?? 0),
            'otp_resend_time' => (int)(business_config('otp_resend_time', 'otp_login_setup'))?->live_values ?? null,
            'booking_otp_verification' => (int)(business_config('booking_otp', 'booking_setup'))->live_values ?? null,
            'service_complete_photo_evidence' => (int)(business_config('service_complete_photo_evidence', 'booking_setup'))?->live_values ?? null,
            'booking_additional_charge' => (int)(business_config('booking_additional_charge', 'booking_setup'))?->live_values ?? null,
            'additional_charge_label_name' => (string)(business_config('additional_charge_label_name', 'booking_setup'))?->live_values ?? null,
            'additional_charge_fee_amount' => (int)(business_config('additional_charge_fee_amount', 'booking_setup'))?->live_values ?? null,
            'system_language' => $country,
            'instant_booking' => (int) business_config('instant_booking', 'booking_setup')?->live_values,
            'schedule_booking' => (int) business_config('schedule_booking', 'booking_setup')?->live_values,
            'schedule_booking_time_restriction' => (int) business_config('schedule_booking_time_restriction', 'booking_setup')?->live_values,
            'advanced_booking' => $advancedBooking,
            'firebase_otp_verification' => $firebaseOtpStatus,
            'forgot_password_verification_method' => $forgotPasswordVerificationMethod,
            'app_environment' => env('APP_ENV'),
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
        ]), 200);
    }

    public function pageDetails($key)
    {
        $page = BusinessPageSetting::where('page_key', $key)->first();
        return response()->json(response_formatter(DEFAULT_200, $page), 200);
    }

    public function getZone(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'lat' => 'required',
            'lng' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $point = new Point($request->lat, $request->lng);
        $zone = Zone::contains('coordinates', $point)->ofStatus(1)->latest()->first();

        if ($zone) {
            return response()->json(response_formatter(DEFAULT_200, $zone), 200);
        }

        return response()->json(response_formatter(DEFAULT_204), 200);
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
        $url = 'https://nominatim.openstreetmap.org/search?q=' . urlencode($searchText) . '&format=json&limit=8&addressdetails=1';
        $response = Http::withHeaders([
            'User-Agent' => 'JassBookingServiceApp/1.0',
            'Accept-Language' => 'en',
        ])->get($url);

        $results = $response->json();
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

        $url = "https://router.project-osrm.org/route/v1/driving/{$originLng},{$originLat};{$destLng},{$destLat}?overview=false";

        $response = Http::withHeaders([
            'User-Agent' => 'JassBookingServiceApp/1.0',
        ])->get($url);

        $data = $response->json();

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
        $url = "https://nominatim.openstreetmap.org/lookup?osm_ids={$placeId}&format=json&addressdetails=1&extratags=1";
        $response = Http::withHeaders([
            'User-Agent' => 'JassBookingServiceApp/1.0',
            'Accept-Language' => 'en',
        ])->get($url);

        $results = $response->json();
        $data = $results[0] ?? null;

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

        $url = "https://nominatim.openstreetmap.org/reverse?lat={$request->lat}&lon={$request->lng}&format=json&addressdetails=1&zoom=18";
        $response = Http::withHeaders([
            'User-Agent' => 'JassBookingServiceApp/1.0',
            'Accept-Language' => 'en',
        ])->get($url);

        $data = $response->json();

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

    public function getRoutes(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'origin_latitude' => 'required',
            'origin_longitude' => 'required',
            'destination_latitude' => 'required',
            'destination_longitude' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $distance = get_distance(
            [$request['origin_latitude'], $request['origin_longitude']],
            [$request['destination_latitude'], $request['destination_longitude']]
        );
        $distance = ($distance) ? number_format($distance, 2) . ' km' : null;

        return response()->json(response_formatter(DEFAULT_200, $distance), 200);
    }
}
