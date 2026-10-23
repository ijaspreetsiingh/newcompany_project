<?php

namespace Modules\BusinessSettingsModule\Http\Controllers\Api\V1\Provider;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;
use Modules\ProviderManagement\Entities\ProviderSetting;

class BusinessInformationController extends Controller
{
    private ProviderSetting $providerSetting;

    public function __construct(ProviderSetting $providerSetting)
    {
        $this->providerSetting = $providerSetting;
    }

    /**
     * Display a listing of the resource.
     * @param Request $request
     * @return JsonResponse
     */
    public function businessSettingsGet(Request $request): JsonResponse
    {
        $request['key'] = ['provider_serviceman_can_cancel_booking', 'provider_serviceman_can_edit_booking', 'provider_serviceman_category_filter'];

        // Default rows bana do taaki provider app ka har switch hamesha render
        // ho — row missing hogi to app me switch UI me aayega hi nahi.
        // provider_serviceman_category_filter: 0 = zone pending me category
        // filter ACTIVE (default), 1 = filter IGNORE (sab service men ko sab
        // pending bookings — sirf zone pending screen ke liye).
        foreach ($request['key'] as $key) {
            $this->providerSetting->firstOrCreate(
                ['key_name' => $key, 'provider_id' => $request->user()->provider->id],
                ['key_name' => $key, 'live_values' => '0', 'test_values' => '0', 'settings_type' => 'serviceman_config', 'mode' => 'live', 'is_active' => 1]
            );
        }

        $dataValues = $this->providerSetting
            ->select('id', 'key_name', 'live_values', 'test_values', 'mode', 'created_at')
            ->when(!is_null($request['key']), fn($query) => $query->whereIn('key_name', $request['key'])->where('provider_id', $request->user()->provider->id))
            ->get();

        // firstOrCreate race se bani duplicate rows yahin self-heal karo:
        // har key_name sirf EK hi row response me aaye (warna provider app
        // me switch do baar render hota hai). Original (sabse pehli) row
        // rakhi jati hai, extras response se hatate hain aur DB se delete
        // kar dete hain — aage kabhi duplicate bana toh bhi UI single rahega.
        $duplicateGroups = $dataValues->groupBy('key_name')->filter(fn($group) => $group->count() > 1);
        foreach ($duplicateGroups as $group) {
            $keepId = $group->sortBy('created_at')->pluck('id')->first();
            $extraIds = $group->pluck('id')->reject(fn($id) => $id === $keepId)->values();
            if ($extraIds->isNotEmpty()) {
                $this->providerSetting->whereIn('id', $extraIds)->delete();
                $dataValues = $dataValues->reject(fn($row) => $extraIds->contains($row->id))->values();
            }
        }

        // Response shape pehle jaisa: sirf wahi 4 fields jo app parse karta hai
        $dataValues = $dataValues->map(fn($row) => $row->only('key_name', 'live_values', 'test_values', 'mode'));

        $serviceLocation = $this->providerSetting->where(['key_name' => 'service_location', 'provider_id' => $request->user()->provider->id, 'settings_type' => 'provider_config'])->first();
        $serviceLocations = $serviceLocation ? json_decode($serviceLocation->live_values, true) : [];

        $data = [
            'provider_serviceman_config' => $dataValues,
            'service_location' =>$serviceLocations
        ];

        return response()->json(response_formatter(DEFAULT_200, $data), 200);
    }

    /**
     * Display a listing of the resource.
     * @param Request $request
     * @return JsonResponse
     * @throws ValidationException
     */
    public function businessSettingsSet(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'data' => 'required',
            'data.*.key' => 'required|string',
            'data.*.value' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $customerLocationData = collect(json_decode($request->data, true))->firstWhere('key', 'customer_location');
        $providerLocationData = collect(json_decode($request->data, true))->firstWhere('key', 'provider_location');

        $customerLocation = $customerLocationData['value'] ?? '0';
        $providerLocation = $providerLocationData['value'] ?? '0';

        // Prevent both customer_location and provider_location from being inactive
        if ($customerLocation == '0' && $providerLocation == '0') {
            $error = [[
                    "error_code" => "data",
                    "message" => translate('At least one service location must be active')
                ]];
            return response()->json(response_formatter(DEFAULT_400, null, $error), 400);
        }

        $serviceLocation = [];

        foreach (collect(json_decode($request['data'], true)) as $key => $item) {
            $key = $item['key'];
            $value = $item['value'];

            $settingType = in_array($item['key'], ['provider_serviceman_can_edit_booking', 'provider_serviceman_can_cancel_booking', 'provider_serviceman_category_filter']) ? 'serviceman_config' : null;

            if (!is_null($settingType)) {
                $this->providerSetting->updateOrCreate(['key_name' => $item['key'], 'provider_id' => $request->user()->provider->id], [
                    'key_name' => $item['key'],
                    'live_values' => $item['value'],
                    'test_values' => $item['value'],
                    'settings_type' => $settingType,
                    'mode' => 'live',
                    'is_active' => 1,
                ]);
            }

            // Collect service location settings
            if ($key == 'customer_location' && $value == '1') {
                $serviceLocation[] = 'customer';
            }
            if ($key === 'provider_location' && $value == '1') {
                $serviceLocation[] = 'provider';
            }
        }

        $serviceAtProviderPlace = (int)((business_config('service_at_provider_place', 'provider_config'))->live_values ?? 0);

        if($serviceAtProviderPlace == 0){
            return response()->json(response_formatter(SERVICE_LOCATION_400), 200);
        }

        if (!empty($serviceLocation)) {
            $this->providerSetting->updateOrCreate(
                ['key_name' => 'service_location', 'provider_id' => $request->user()->provider->id, 'settings_type' => 'provider_config'],
                [
                    'key_name' => 'service_location',
                    'live_values' => json_encode($serviceLocation),
                    'test_values' => json_encode($serviceLocation),
                    'settings_type' => 'provider_config',
                    'mode' => 'live',
                    'is_active' => 1,
                ]
            );
        }

        return response()->json(response_formatter(DEFAULT_UPDATE_200), 200);
    }
}
