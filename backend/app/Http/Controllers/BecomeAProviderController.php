<?php

namespace App\Http\Controllers;

use Brian2694\Toastr\Facades\Toastr;
use Illuminate\Contracts\View\Factory;
use Illuminate\Contracts\View\View;
use Illuminate\Foundation\Application;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Modules\BusinessSettingsModule\Entities\BusinessSettings;
use Modules\BusinessSettingsModule\Entities\DataSetting;
use Modules\ProviderManagement\Entities\ProviderRegistrationRequest;
use Modules\CategoryManagement\Entities\Category;
use Modules\ZoneManagement\Entities\Zone;

class BecomeAProviderController extends Controller
{
    private Zone $zone;
    private Category $category;
    private ProviderRegistrationRequest $registrationRequest;

    public function __construct(Zone $zone, Category $category, ProviderRegistrationRequest $registrationRequest)
    {
        $this->zone = $zone;
        $this->category = $category;
        $this->registrationRequest = $registrationRequest;
    }

    /**
     * Landing page "Become a Provider" form.
     */
    public function index(): Application|Factory|View
    {
        $zones = $this->zone->ofStatus(1)->get();
        $mainCategories = $this->category->ofType('main')->ofStatus(1)->orderBy('name')->get(['id', 'name', 'parent_id', 'position']);
        $subCategories = $this->category->ofType('sub')->ofStatus(1)->orderBy('name')->get(['id', 'name', 'parent_id', 'position']);

        // landing layout ($settings / $settingss) ke liye business data
        $settings = BusinessSettings::whereNotIn('settings_type', ['payment_config', 'third_party'])->get();
        $settingss = DataSetting::whereIn('type', ['landing_web_app', 'landing_text_setup'])->get();

        return view('become-a-provider', compact('zones', 'mainCategories', 'subCategories', 'settings', 'settingss'));
    }

    /**
     * Landing form submit: sab data request table me save karo (status=pending),
     * admin approve karega tabhi provider ki ID banegi.
     */
    public function submit(Request $request): RedirectResponse
    {
        $request->validate([
            'contact_person_name'  => 'required|string|max:191',
            'contact_person_phone' => 'required',
            'contact_person_email' => 'nullable|email',

            'company_name'    => 'required|string|max:191',
            'company_phone'   => 'required',
            'company_email'   => 'required|email',
            'company_address' => 'required|string|max:255',
            'logo'            => 'required|image|max:' . uploadMaxFileSizeInKB('image') . '|mimes:' . implode(',', array_column(IMAGEEXTENSION, 'key')),

            'account_email'    => 'required|email|unique:users,email',
            'account_phone'    => 'required|regex:/^([0-9\s\-\+\(\)]*)$/|min:8|unique:users,phone',
            'password'         => 'required|min:8',
            'confirm_password' => 'required|same:password',

            'identity_type'     => 'required|in:passport,driving_license,nid,trade_license,company_id',
            'identity_number'   => 'required|string|max:191',
            'identity_images.*' => 'nullable|image|max:' . uploadMaxFileSizeInKB('image') . '|mimes:' . implode(',', array_column(IMAGEEXTENSION, 'key')),

            'latitude'  => 'nullable|numeric',
            'longitude' => 'nullable|numeric',

            'zone_id'          => 'required|uuid|exists:zones,id',
            'main_category_id' => 'required|uuid|exists:categories,id',
            // optional: empty chosen => pure main category considered
            'sub_category_ids'   => 'nullable|array',
            'sub_category_ids.*' => 'exists:categories,id',
        ]);

        // request duplicate kyun na ban jaye: same account phone/email try karta?
        if ($this->registrationRequest->where('status', 'pending')->where('account_email', $request['account_email'])->exists()) {
            Toastr::error(translate('Your request is already pending for approval'));
            return back()->withInput();
        }

        $subCategoryIds = array_values(array_unique(array_filter((array) $request->input('sub_category_ids', []))));

        // selected sub categories main category ke children hi hone chahiye
        $validSubIds = $this->category->where('parent_id', $request['main_category_id'])->pluck('id')->all();
        if ($subCategoryIds && count(array_intersect($subCategoryIds, $validSubIds)) !== count($subCategoryIds)) {
            Toastr::error(translate('Selected services do not belong to the selected category'));
            return back()->withInput();
        }

        $identityImages = [];
        if ($request->has('identity_images')) {
            foreach ($request->file('identity_images', []) as $image) {
                $imageName = file_uploader('provider/identity/', APPLICATION_IMAGE_FORMAT, $image);
                $identityImages[] = ['image' => $imageName, 'storage' => getDisk()];
            }
        }

        DB::transaction(function () use ($request, $identityImages, $subCategoryIds) {
            $this->registrationRequest->create([
                'contact_person_name'  => $request['contact_person_name'],
                'contact_person_phone' => $request['contact_person_phone'],
                'contact_person_email' => $request['contact_person_email'],

                'company_name'    => $request['company_name'],
                'company_phone'   => $request['company_phone'],
                'company_email'   => $request['company_email'],
                'company_address' => $request['company_address'],
                'logo'            => file_uploader('provider/logo/', APPLICATION_IMAGE_FORMAT, $request->file('logo')),

                'account_email' => $request['account_email'],
                'account_phone' => $request['account_phone'],
                'password'      => bcrypt($request['password']), // hashed - approve pe user ka password banega

                'identity_type'   => $request['identity_type'],
                'identity_number' => $request['identity_number'],
                'identity_images' => $identityImages,

                'latitude'  => $request['latitude'],
                'longitude' => $request['longitude'],

                'zone_id'          => $request['zone_id'],
                'main_category_id' => $request['main_category_id'],
                'sub_category_ids' => $subCategoryIds,

                'status' => 'pending',
            ]);
        });

        Toastr::success(translate('Your provider registration request has been submitted. We will review it soon.'));
        return back();
    }
}
