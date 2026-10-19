<?php

namespace Modules\ProviderManagement\Http\Controllers\Web\Admin;

use Brian2694\Toastr\Facades\Toastr;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Contracts\Support\Renderable;
use Illuminate\Contracts\View\Factory;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\DB;
use Modules\CategoryManagement\Entities\Category;
use Modules\ProviderManagement\Entities\Provider;
use Modules\ProviderManagement\Entities\ProviderRegistrationRequest;
use Modules\ProviderManagement\Entities\ProviderSetting;
use Modules\ProviderManagement\Entities\SubscribedService;
use Modules\UserManagement\Entities\Serviceman;
use Modules\UserManagement\Entities\User;
use \Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class ProviderRegistrationRequestController extends Controller
{
    protected ProviderRegistrationRequest $registrationRequest;
    protected Provider $provider;
    protected User $owner;
    protected SubscribedService $subscribedService;
    protected Category $category;
    protected Serviceman $serviceman;

    use AuthorizesRequests;

    public function __construct(
        ProviderRegistrationRequest $registrationRequest,
        Provider $provider,
        User $owner,
        SubscribedService $subscribedService,
        Category $category,
        Serviceman $serviceman
    )
    {
        $this->registrationRequest = $registrationRequest;
        $this->provider = $provider;
        $this->owner = $owner;
        $this->subscribedService = $subscribedService;
        $this->category = $category;
        $this->serviceman = $serviceman;
    }

    /**
     * Landing page se aayi provider registration requests ki list.
     * Review modal (popup) ke liye har pending request ka conflict data
     * pehle se compute karte hain: us zone+category me koi ACTIVE provider
     * already hai to uska naam / total services / total profiles (servicemen) /
     * status popup me dikhega.
     */
    public function index(Request $request): Renderable
    {
        $this->authorize('provider_view');

        $request->validate([
            'status' => 'nullable|in:' . implode(',', array_keys(ProviderRegistrationRequest::STATUSES)) . ',all',
            'search' => 'nullable|string',
        ]);

        $status  = $request->filled('status') ? $request['status'] : 'all';
        $search  = $request->has('search') ? $request['search'] : '';
        $queryParam = ['status' => $status, 'search' => $search];

        $requests = $this->registrationRequest
            ->with(['zone:id,name', 'mainCategory:id,name', 'createdProvider:id,company_name,is_active'])
            ->when($status != 'all', fn ($query) => $query->ofStatus($status))
            ->when($request->filled('search'), function ($query) use ($request) {
                $keys = explode(' ', $request['search']);
                return $query->where(function ($query) use ($keys) {
                    foreach ($keys as $key) {
                        $query->orWhere('company_name', 'LIKE', '%' . $key . '%')
                            ->orWhere('contact_person_name', 'LIKE', '%' . $key . '%')
                            ->orWhere('account_email', 'LIKE', '%' . $key . '%')
                            ->orWhere('contact_person_phone', 'LIKE', '%' . $key . '%');
                    }
                });
            })
            ->latest()
            ->paginate(pagination_limit())
            ->appends($queryParam);

        // sirf current page ki pending requests ke liye conflict check (N+1 controlled)
        $conflictMap = [];
        foreach ($requests->where('status', 'pending') as $registrationRequest) {
            $conflictMap[$registrationRequest->id] = $this->activeConflictingProviders($registrationRequest);
        }

        $statusCounts = [
            'all'      => $this->registrationRequest->count(),
            'pending'  => $this->registrationRequest->ofStatus('pending')->count(),
            'approved' => $this->registrationRequest->ofStatus('approved')->count(),
            'approved_inactive'  => $this->registrationRequest->ofStatus('approved_inactive')->count(),
            'accepted_existing'  => $this->registrationRequest->ofStatus('accepted_existing')->count(),
            'declined' => $this->registrationRequest->ofStatus('declined')->count(),
        ];

        return view('providermanagement::admin.provider.registration-requests',
            compact('requests', 'status', 'search', 'statusCounts', 'conflictMap'));
    }

    /**
     * Approve (koi conflict nahi ho to): provider ki ID ban jaegi aur ACTIVE hogi.
     */
    public function approve($id): RedirectResponse
    {
        $this->authorize('provider_add');

        $registrationRequest = $this->registrationRequest->find($id);
        if (!$registrationRequest) {
            Toastr::error(translate('Request not found'));
            return back();
        }
        if ($registrationRequest->status != 'pending') {
            Toastr::error(translate('This request has already been processed'));
            return back();
        }

        $conflicts = $this->activeConflictingProviders($registrationRequest);

        if ($conflicts->isNotEmpty()) {
            // popup par decision expected: Accept (old activate) ya Cancel (naya inactive)
            Toastr::error(translate('Another active provider already exists in this zone and category. Please choose Accept (activate old provider) or Cancel (create new without activation).'));
            return back();
        }

        DB::beginTransaction();
        try {
            $provider = $this->createProviderFromRequest($registrationRequest, true);
            $registrationRequest->update([
                'status'              => 'approved',
                'created_provider_id' => $provider->id,
            ]);
            DB::commit();
            Toastr::success(translate('Provider ID created and activated successfully'));
        } catch (\Exception $exception) {
            DB::rollBack();
            Toastr::error(translate('something_went_wrong'));
        }

        return back();
    }

    /**
     * Conflict popup par CANCEL: naye provider ki ID BAN JAEGI par
     * ACTIVE NAHI hogi (old active provider wavelengthwise apna kaam karta rahega).
     */
    public function approveInactive(Request $request, $id): RedirectResponse
    {
        $this->authorize('provider_add');

        $registrationRequest = $this->registrationRequest->find($id);
        if (!$registrationRequest) {
            Toastr::error(translate('Request not found'));
            return back();
        }
        if ($registrationRequest->status != 'pending') {
            Toastr::error(translate('This request has already been processed'));
            return back();
        }

        DB::beginTransaction();
        try {
            $provider = $this->createProviderFromRequest($registrationRequest, false);
            $registrationRequest->update([
                'status'              => 'approved_inactive',
                'created_provider_id' => $provider->id,
                'admin_note'          => $request['admin_note'] ?? null,
            ]);
            DB::commit();
            Toastr::success(translate('Provider ID created but is inactive. Activate it manually from the provider list when needed.'));
        } catch (\Exception $exception) {
            DB::rollBack();
            Toastr::error(translate('something_went_wrong'));
        }

        return back();
    }

    /**
     * Conflict popup par ACCEPT: old (already existing) provider ka
     * ID num active ho jaega; is request ke liye naya account NAHI banega.
     */
    public function acceptExisting(Request $request, $id): RedirectResponse
    {
        $this->authorize('provider_add');

        $registrationRequest = $this->registrationRequest->find($id);
        if (!$registrationRequest) {
            Toastr::error(translate('Request not found'));
            return back();
        }
        if ($registrationRequest->status != 'pending') {
            Toastr::error(translate('This request has already been processed'));
            return back();
        }

        $conflicts = $this->activeConflictingProviders($registrationRequest);

        DB::beginTransaction();
        try {
            if ($conflicts->isNotEmpty()) {
                foreach ($conflicts as $conflict) {
                    $existingProvider = $conflict->provider;
                    $existingProvider->is_active = 1;
                    $existingProvider->save();

                    $owner = $existingProvider->owner;
                    if ($owner) {
                        $owner->is_active = 1;
                        $owner->save();
                    }
                }
            } else {
                // tab tak conflict clear ho gaya: simple approve jaisa treat karo
                $provider = $this->createProviderFromRequest($registrationRequest, true);
                $registrationRequest->created_provider_id = $provider->id;
            }

            $registrationRequest->update([
                'status'     => 'accepted_existing',
                'admin_note' => $request['admin_note'] ?? null,
            ]);
            DB::commit();
            Toastr::success(translate('Existing provider has been activated instead'));
        } catch (\Exception $exception) {
            DB::rollBack();
            Toastr::error(translate('something_went_wrong'));
        }

        return back();
    }

    /**
     * Simple reject: koi account nahi banega.
     */
    public function decline(Request $request, $id): RedirectResponse
    {
        $this->authorize('provider_add');

        $registrationRequest = $this->registrationRequest->find($id);
        if (!$registrationRequest) {
            Toastr::error(translate('Request not found'));
            return back();
        }
        if ($registrationRequest->status != 'pending') {
            Toastr::error(translate('This request has already been processed'));
            return back();
        }

        $registrationRequest->update([
            'status'     => 'declined',
            'admin_note' => $request['admin_note'] ?? null,
        ]);

        Toastr::success(translate('Registration request declined'));
        return back();
    }

    /**
     * Us zone + usi category ke andar jo ACTIVE providers pehle se hain —
     * conflict popup ke liye stats ke saath: naam, total services,
     * total profiles (servicemen), status.
     */
    private function activeConflictingProviders(ProviderRegistrationRequest $registrationRequest): \Illuminate\Support\Collection
    {
        $zoneId = $registrationRequest->zone_id;
        $mainId = $registrationRequest->main_category_id;
        $subIds = $registrationRequest->effectiveSubCategoryIds();

        if (!$zoneId || !$mainId) {
            return collect();
        }

        return $this->subscribedService
            ->where('zone_id', $zoneId)
            ->where(function ($query) use ($mainId, $subIds) {
                $query->where('category_id', $mainId);
                if (!empty($subIds)) {
                    $query->orWhereIn('sub_category_id', $subIds);
                }
            })
            ->with(['provider:id,company_name,contact_person_name,is_active,user_id,zone_id', 'sub_category:id,name'])
            ->get()
            ->pluck('provider')
            ->filter(fn ($provider) => $provider && $provider->is_active == 1)
            ->unique('id')
            ->values()
            ->map(function ($provider) {
                // NOTE: model pe dynamic attributes set karke stats mat lagana —
                // save() unhe UPDATE SQL me daal deta hai (Unknown column error).
                // Isliye provider + stats ko plain wrapper me return karo.
                return (object) [
                    'provider'         => $provider,
                    'services_total'   => DB::table('services')->where('provider_id', $provider->id)->count(),
                    'servicemen_total' => DB::table('servicemen')->where('provider_id', $provider->id)->count(),
                    'subscribed_total' => $this->subscribedService->where('provider_id', $provider->id)->count(),
                ];
            });
    }

    /**
     * Registration request ka data lekar actual User (owner) + Provider + category
     * assignment bana deta hai. is_active par depend karta hai:
     *  true  -> admin approve (new provider, ACTIVE)
     *  false -> cancel decision (created but INACTIVE)
     */
    private function createProviderFromRequest(ProviderRegistrationRequest $registrationRequest, bool $active): Provider
    {
        // race guard: isi email/phone pe user ban chuka ho to fail karo
        if ($this->owner->where('email', $registrationRequest->account_email)->exists()) {
            throw new \Exception('Account with this email already exists');
        }
        if ($this->owner->where('phone', $registrationRequest->account_phone)->exists()) {
            throw new \Exception('Account with this phone already exists');
        }

        $nameParts = preg_split('/\s+/', trim($registrationRequest->contact_person_name), 2);

        $owner = new User();
        $owner->first_name            = trim($nameParts[0] ?? '') !== '' ? trim($nameParts[0]) : $registrationRequest->contact_person_name;
        $owner->last_name             = trim($nameParts[1] ?? '') !== '' ? trim($nameParts[1]) : null;
        $owner->email                 = $registrationRequest->account_email;
        $owner->phone                 = $registrationRequest->account_phone;
        $owner->identification_number = $registrationRequest->identity_number;
        $owner->identification_type   = $registrationRequest->identity_type;
        // users.identification_image column is NOT NULL -> always a (possibly empty) array
        $owner->identification_image  = $registrationRequest->identity_images ?? [];
        $owner->password              = $registrationRequest->password; // already bcrypt at submit
        $owner->is_active             = $active ? 1 : 0;
        $owner->user_type             = 'provider-admin';
        $owner->save();

        $provider = new Provider();
        $provider->company_name    = $registrationRequest->company_name;
        $provider->company_phone   = $registrationRequest->company_phone;
        $provider->company_email   = $registrationRequest->company_email;
        $provider->company_address = $registrationRequest->company_address;
        $provider->logo            = $registrationRequest->logo;

        $provider->contact_person_name  = $registrationRequest->contact_person_name;
        $provider->contact_person_phone = $registrationRequest->contact_person_phone;
        $provider->contact_person_email = $registrationRequest->contact_person_email;

        $provider->is_approved = 1;
        $provider->is_active   = $active ? 1 : 0;

        $provider->independent_mode            = 0;
        $provider->admin_commission_percent    = 0;
        $provider->provider_commission_percent = 0;
        $provider->platform_fee_amount         = 0;
        $provider->booking_fee                 = 0;
        $provider->custom_fees_enabled         = 0;
        $provider->calling_enabled             = 0;

        $provider->zone_id      = $registrationRequest->zone_id;
        $provider->coordinates  = ['latitude' => $registrationRequest->latitude, 'longitude' => $registrationRequest->longitude];

        $provider->user_id = $owner->id;
        $provider->save();

        $owner->zones()->sync($registrationRequest->zone_id);

        // provider default config: customer ko location-wise service render kare
        $serviceLocation = ['customer'];
        ProviderSetting::create([
            'provider_id'   => $provider->id,
            'key_name'      => 'service_location',
            'live_values'   => json_encode($serviceLocation),
            'test_values'   => json_encode($serviceLocation),
            'settings_type' => 'provider_config',
            'mode'          => 'live',
            'is_active'     => 1,
        ]);

        $this->saveCategoryAssignment($registrationRequest, $provider);

        // backward-compat columns
        $provider->category_assignment_mode = 1;
        $provider->assigned_main_category_id = $registrationRequest->main_category_id;
        $provider->save();

        return $provider;
    }

    /**
     * Landing request ke hisaab se assigned categories/services:
     *  - specific sub select hue to unki rows
     *  - sirf main category aayi thi to main ke saare children (assign_type='complete')
     */
    private function saveCategoryAssignment(ProviderRegistrationRequest $registrationRequest, Provider $provider): void
    {
        $subIds = $registrationRequest->effectiveSubCategoryIds();

        if (empty($subIds)) {
            // complete main category : main ke saare children
            foreach ($this->category->where('parent_id', $registrationRequest->main_category_id)->pluck('id') as $childId) {
                $this->subscribedService->create([
                    'provider_id'     => $provider->id,
                    'sub_category_id' => $childId,
                    'category_id'     => $registrationRequest->main_category_id,
                    'zone_id'         => $registrationRequest->zone_id,
                    'assign_type'     => 'complete',
                    'is_subscribed'   => 1,
                ]);
            }

            return;
        }

        foreach ($subIds as $subCategoryId) {
            $subCategory = $this->category->find($subCategoryId);
            if (!$subCategory) {
                continue;
            }

            $this->subscribedService->create([
                'provider_id'     => $provider->id,
                'sub_category_id' => $subCategoryId,
                'category_id'     => $subCategory->parent_id,
                'zone_id'         => $registrationRequest->zone_id,
                'assign_type'     => 'specific',
                'is_subscribed'   => 1,
            ]);
        }
    }
}
