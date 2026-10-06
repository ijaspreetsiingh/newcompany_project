<?php

namespace Modules\BusinessSettingsModule\Http\Controllers\Web\Admin;

use Brian2694\Toastr\Facades\Toastr;
use Illuminate\Http\RedirectResponse;
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
     * Show location settings form page.
     */
    public function index()
    {
        $locationSettings = (object)[
            'initial_radius' => $this->businessSetting
                ->where('key_name', 'initial_search_radius')
                ->where('settings_type', 'location_search')
                ->first()?->live_values ?? 5,

            'max_radius' => $this->businessSetting
                ->where('key_name', 'max_search_radius')
                ->where('settings_type', 'location_search')
                ->first()?->live_values ?? 50,

            'radius_increment_step' => $this->businessSetting
                ->where('key_name', 'radius_increment_step')
                ->where('settings_type', 'location_search')
                ->first()?->live_values ?? 5,

            'max_search_attempts' => $this->businessSetting
                ->where('key_name', 'max_search_attempts')
                ->where('settings_type', 'location_search')
                ->first()?->live_values ?? 5,

            'show_popup_on_location_change' => (int)($this->businessSetting
                ->where('key_name', 'show_popup_on_location_change')
                ->where('settings_type', 'location_search')
                ->first()?->live_values ?? 1),

            'show_zone_reminder' => (int)($this->businessSetting
                ->where('key_name', 'show_zone_reminder')
                ->where('settings_type', 'location_search')
                ->first()?->live_values ?? 1),
        ];

        return view('businesssettingsmodule::admin.app-settings', [
            'webPage' => 'location_search',
            'locationSettings' => $locationSettings
        ]);
    }

    /**
     * Update location settings.
     */
    public function update(Request $request): RedirectResponse
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
                Toastr::error('Max radius must be >= initial radius');
                return back();
            }

            // Save settings
            $this->businessSetting->updateOrInsert(
                ['key_name' => 'initial_search_radius', 'settings_type' => 'location_search'],
                ['live_values' => $validated['initial_radius']]
            );

            $this->businessSetting->updateOrInsert(
                ['key_name' => 'max_search_radius', 'settings_type' => 'location_search'],
                ['live_values' => $validated['max_radius']]
            );

            $this->businessSetting->updateOrInsert(
                ['key_name' => 'radius_increment_step', 'settings_type' => 'location_search'],
                ['live_values' => $validated['radius_increment_step']]
            );

            $this->businessSetting->updateOrInsert(
                ['key_name' => 'max_search_attempts', 'settings_type' => 'location_search'],
                ['live_values' => $validated['max_search_attempts']]
            );

            $this->businessSetting->updateOrInsert(
                ['key_name' => 'show_popup_on_location_change', 'settings_type' => 'location_search'],
                ['live_values' => $request->has('show_popup_on_location_change') ? 1 : 0]
            );

            $this->businessSetting->updateOrInsert(
                ['key_name' => 'show_zone_reminder', 'settings_type' => 'location_search'],
                ['live_values' => $request->has('show_zone_reminder') ? 1 : 0]
            );

            Toastr::success('Location settings updated successfully!');
            return back();
        } catch (\Exception $e) {
            Toastr::error('Error updating settings: ' . $e->getMessage());
            return back();
        }
    }
}
