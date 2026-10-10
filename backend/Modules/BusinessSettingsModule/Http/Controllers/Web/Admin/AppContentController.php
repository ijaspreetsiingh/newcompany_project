<?php

namespace Modules\BusinessSettingsModule\Http\Controllers\Web\Admin;

use Illuminate\Http\RedirectResponse;
use Illuminate\Routing\Controller;
use Illuminate\View\View;
use Modules\BusinessSettingsModule\Entities\BusinessSettings;

class AppContentController extends Controller
{
    private array $apps = ['user', 'provider', 'serviceman'];

    private array $pages = [
        'about_us',
        'privacy_policy',
        'terms_and_conditions',
        'refund_policy',
        'return_policy',
        'cancellation_policy',
    ];

    public function index(): View
    {
        $rows = BusinessSettings::where('settings_type', 'pages_setup')
            ->whereIn('key_name', $this->keys())
            ->get()
            ->keyBy('key_name');

        $content = [];
        foreach ($this->apps as $app) {
            foreach ($this->pages as $page) {
                $content[$app][$page] = $rows[$page . '_' . $app]?->live_values ?? '';
            }
        }

        return view('businesssettingsmodule::admin.app-content.index', [
            'apps' => $this->apps,
            'pages' => $this->pages,
            'content' => $content,
        ]);
    }

    public function update(): RedirectResponse
    {
        foreach ($this->apps as $app) {
            foreach ($this->pages as $page) {
                $key = $page . '_' . $app;
                $value = request()->input($key);

                BusinessSettings::updateOrCreate(
                    ['key_name' => $key, 'settings_type' => 'pages_setup'],
                    [
                        'live_values' => $value,
                        'test_values' => $value,
                        'mode' => 'live',
                        'is_active' => 1,
                    ]
                );
            }
        }

        return redirect()->back()->with('success', translate('successfully_updated'));
    }

    private function keys(): array
    {
        $keys = [];
        foreach ($this->apps as $app) {
            foreach ($this->pages as $page) {
                $keys[] = $page . '_' . $app;
            }
        }

        return $keys;
    }
}
