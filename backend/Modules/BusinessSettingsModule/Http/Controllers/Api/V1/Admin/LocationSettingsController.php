<?php

namespace Modules\BusinessSettingsModule\Http\Controllers\Api\V1\Admin;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Modules\BusinessSettingsModule\Entities\BusinessSettings;

class LocationSettingsController extends Controller
{
    private BusinessSettings $businessSetting;

    public function __construct(BusinessSettings $businessSetting)
    {
        $this->businessSetting = $businessSetting;
    }

    /**
     * Get search radius settings for location-based service discovery.
     * @return JsonResponse
     */
    public function getSearchRadius(): JsonResponse
    {
        try {
            // Get all location-related settings
            $initialRadius = $this->businessSetting
                ->where('key_name', 'initial_search_radius')
                ->where('settings_type', 'location_search')
                ->first()?->live_values ?? 5;

            $maxRadius = $this->businessSetting
                ->where('key_name', 'max_search_radius')
                ->where('settings_type', 'location_search')
                ->first()?->live_values ?? 50;

            $radiusStep = $this->businessSetting
                ->where('key_name', 'radius_increment_step')
                ->where('settings_type', 'location_search')
                ->first()?->live_values ?? 5;

            $maxAttempts = $this->businessSetting
                ->where('key_name', 'max_search_attempts')
                ->where('settings_type', 'location_search')
                ->first()?->live_values ?? 5;

            return response()->json([
                'response_code' => 'default_200',
                'message' => 'Settings retrieved successfully',
                'content' => [
                    'initial_radius' => (float)$initialRadius,
                    'max_radius' => (float)$maxRadius,
                    'radius_increment_step' => (float)$radiusStep,
                    'max_search_attempts' => (int)$maxAttempts,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'response_code' => 'default_error',
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Update location search settings (Admin only).
     * @param Request $request
     * @return JsonResponse
     */
    public function updateSearchRadius(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'initial_radius' => 'required|numeric|min:1|max:100',
                'max_radius' => 'required|numeric|min:1|max:500',
                'radius_increment_step' => 'required|numeric|min:0.5|max:50',
                'max_search_attempts' => 'required|integer|min:1|max:20',
                'show_popup_on_location_change' => 'boolean',
                'show_zone_reminder' => 'boolean',
            ]);

            // Validate max_radius >= initial_radius
            if ($validated['max_radius'] < $validated['initial_radius']) {
                return response()->json([
                    'response_code' => 'validation_error',
                    'message' => 'Max radius must be greater than or equal to initial radius'
                ], 422);
            }

            // Save each setting
            $this->businessSetting->updateOrCreate(
                ['key_name' => 'initial_search_radius', 'settings_type' => 'location_search'],
                ['live_values' => $validated['initial_radius']]
            );

            $this->businessSetting->updateOrCreate(
                ['key_name' => 'max_search_radius', 'settings_type' => 'location_search'],
                ['live_values' => $validated['max_radius']]
            );

            $this->businessSetting->updateOrCreate(
                ['key_name' => 'radius_increment_step', 'settings_type' => 'location_search'],
                ['live_values' => $validated['radius_increment_step']]
            );

            $this->businessSetting->updateOrCreate(
                ['key_name' => 'max_search_attempts', 'settings_type' => 'location_search'],
                ['live_values' => $validated['max_search_attempts']]
            );

            $this->businessSetting->updateOrCreate(
                ['key_name' => 'show_popup_on_location_change', 'settings_type' => 'location_search'],
                ['live_values' => $request->has('show_popup_on_location_change') ? 1 : 0]
            );

            $this->businessSetting->updateOrCreate(
                ['key_name' => 'show_zone_reminder', 'settings_type' => 'location_search'],
                ['live_values' => $request->has('show_zone_reminder') ? 1 : 0]
            );

            return response()->json([
                'response_code' => 'default_200',
                'message' => 'Settings updated successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'response_code' => 'default_error',
                'message' => $e->getMessage()
            ], 400);
        }
    }
}
