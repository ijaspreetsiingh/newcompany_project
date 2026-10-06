<?php

namespace Modules\ServiceManagement\Http\Controllers\Api\V1\Provider;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Modules\CategoryManagement\Entities\Category;
use Modules\ProviderManagement\Entities\SubscribedService;
use Modules\ServiceManagement\Entities\Service;
use Modules\ServiceManagement\Entities\ProviderServiceRequest;
use Modules\ServiceManagement\Entities\Variation;

class ServiceManageController extends Controller
{
    private Service $service;
    private SubscribedService $subscribedService;

    public function __construct(Service $service, SubscribedService $subscribedService)
    {
        $this->service = $service;
        $this->subscribedService = $subscribedService;
    }

    /**
     * Custom message wala error response (app sirf `message` padhta hai).
     */
    private function errorResponse(int $status, string $message, string $code = 'default_400'): JsonResponse
    {
        return response()->json([
            'response_code' => $code,
            'message' => translate($message),
            'content' => null,
            'errors' => [],
        ], $status);
    }

    /**
     * Admin wizard (Step 6) ke do toggle — provider app inhi ke hisaab se
     * add / edit buttons dikhata hai.
     */
    private function permissions(object $provider): array
    {
        return [
            'can_create' => (bool) $provider->allow_service_create,
            'can_edit' => (bool) $provider->allow_service_edit,
            'approval_required' => (bool) $provider->service_approval_required,
            'pending_requests' => ProviderServiceRequest::where('provider_id', $provider->id)
                ->where('status', 'pending')
                ->count(),
        ];
    }

    /**
     * Provider ke assigned sub-category ids (sirf uski zone ke).
     */
    private function assignedSubCategoryIds(object $provider): array
    {
        return $this->subscribedService
            ->where('provider_id', $provider->id)
            ->where('is_subscribed', 1)
            ->when($provider->zone_id, function ($query) use ($provider) {
                $query->where('zone_id', $provider->zone_id);
            })
            ->pluck('sub_category_id')
            ->unique()
            ->values()
            ->all();
    }

    /**
     * Service ke variants (zone wise). Clone row ka apna variation hota hai,
     * base service ka original price dikhane ke liye bhi use hota hai.
     */
    private function zoneVariants(object $service, ?string $zoneId): array
    {
        $rows = Variation::where('service_id', $service->id)->get();

        $zoneRows = $zoneId ? $rows->where('zone_id', $zoneId)->values() : collect();
        if ($zoneRows->isEmpty()) {
            $zoneRows = $rows->values();
        }

        return $zoneRows->map(function ($row) {
            return [
                'variant_key' => $row->variant_key,
                'variant' => $row->variant,
                'price' => (float) $row->price,
            ];
        })->values()->all();
    }

    private function formatService(object $service, ?string $zoneId): array
    {
        $isOwned = !is_null($service->provider_id);

        return [
            'id' => $service->id,
            'parent_service_id' => $service->parent_service_id,
            'name' => $service->name,
            'short_description' => $service->short_description,
            'description' => $service->description,
            'cover_image' => $service->cover_image_full_path,
            'category_id' => $service->category_id,
            'sub_category_id' => $service->sub_category_id,
            'is_active' => (int) $service->is_active,
            'approval_status' => $service->approval_status,
            'is_owned' => $isOwned,
            'is_edited' => !is_null($service->parent_service_id),
            'is_pending' => $service->approval_status != 'approved',
            'variants' => $this->zoneVariants($service, $zoneId),
            'base_variants' => (!is_null($service->parent_service_id) && $service->parentService)
                ? $this->zoneVariants($service->parentService, $zoneId)
                : null,
            'created_via' => $isOwned ? 'provider' : 'admin',
        ];
    }

    /**
     * Ek hi call me: assigned categories -> sub-categories -> services.
     * GET api/v1/partner/services/manage
     */
    public function index(Request $request): JsonResponse
    {
        $provider = $request->user()->provider;
        if (!$provider) {
            return response()->json(response_formatter(DEFAULT_404), 404);
        }

        $zoneId = $provider->zone_id;
        $subCategoryIds = $this->assignedSubCategoryIds($provider);

        if (empty($subCategoryIds)) {
            return response()->json(response_formatter(DEFAULT_204), 204);
        }

        $services = $this->service
            ->with(['variations', 'parentService.variations', 'storage_cover_image'])
            ->whereIn('services.sub_category_id', $subCategoryIds)
            ->when($zoneId, function ($query) use ($zoneId) {
                $query->whereHas('category.zones', function ($zoneQuery) use ($zoneId) {
                    $zoneQuery->where('zone_id', $zoneId);
                });
            })
            ->get();

        $servicesBySubCategory = $services->groupBy('sub_category_id');

        $mainCategoryIds = Category::whereIn('id', $subCategoryIds)
            ->pluck('parent_id')
            ->filter()
            ->unique()
            ->values()
            ->all();

        $categories = Category::ofStatus(1)->ofType('main')->whereIn('id', $mainCategoryIds)
            ->with([
                'children' => function ($query) use ($subCategoryIds) {
                    $query->ofStatus(1)->whereIn('id', $subCategoryIds)->orderBy('name', 'asc');
                },
                'storage',
            ])
            ->orderBy('name', 'asc')
            ->get();

        $payload = [
            'categories' => $categories->map(function ($category) use ($servicesBySubCategory, $zoneId) {
                return [
                    'id' => $category->id,
                    'name' => $category->name,
                    'image' => $category->image_full_path,
                    'sub_categories' => $category->children->map(function ($subCategory) use ($servicesBySubCategory, $zoneId) {
                        return [
                            'id' => $subCategory->id,
                            'name' => $subCategory->name,
                            'image' => $subCategory->image_full_path,
                            'services' => ($servicesBySubCategory->get($subCategory->id) ?? collect())
                                ->map(fn ($service) => $this->formatService($service, $zoneId))
                                ->values()
                                ->all(),
                        ];
                    })->values()->all(),
                ];
            })->values()->all(),
            'assignable_sub_categories' => $categories->flatMap(function ($category) {
                return $category->children->map(fn ($subCategory) => [
                    'id' => $subCategory->id,
                    'name' => $subCategory->name,
                    'category_id' => $category->id,
                    'category_name' => $category->name,
                ]);
            })->values()->all(),
            'permissions' => $this->permissions($provider),
        ];

        return response()->json(response_formatter(DEFAULT_200, $payload), 200);
    }

    /**
     * Admin wali service ka clone banata hai (ya existing clone return karta hai).
     */
    private function makeClone(object $base, object $provider): Service
    {
        $clone = new Service();

        foreach (['name', 'short_description', 'description', 'category_id', 'sub_category_id', 'tax', 'thumbnail', 'gallery', 'min_bidding_price'] as $field) {
            $clone->{$field} = $base->{$field};
        }

        $clone->is_active = 1;
        $clone->order_count = 0;
        $clone->rating_count = 0;
        $clone->avg_rating = 0;
        $clone->is_single_provider = 0;
        $clone->single_provider_mode = null;
        $clone->single_provider_id = null;
        $clone->provider_id = $provider->id;
        $clone->zone_id = $provider->zone_id;
        $clone->parent_service_id = $base->id;
        $clone->approval_status = 'approved';
        $clone->slug = Service::generateUniqueSlug($base->name);
        $clone->save();

        return $clone;
    }

    /**
     * Clone ke liye apni zone ke variations banata hai + price apply karta hai.
     */
    private function syncCloneVariations(Service $clone, object $base, ?string $zoneId, array $prices): void
    {
        $existing = Variation::where('service_id', $clone->id)
            ->when($zoneId, fn ($query) => $query->where('zone_id', $zoneId))
            ->get();

        if ($existing->isEmpty()) {
            $baseRows = Variation::where('service_id', $base->id)->get();
            $seedRows = $zoneId ? $baseRows->where('zone_id', $zoneId)->values() : collect();
            if ($seedRows->isEmpty()) {
                $seedRows = $baseRows->values();
            }

            foreach ($seedRows as $row) {
                Variation::create([
                    'variant' => $row->variant,
                    'variant_key' => $row->variant_key,
                    'zone_id' => $zoneId,
                    'price' => $row->price,
                    'service_id' => $clone->id,
                ]);
            }

            $existing = Variation::where('service_id', $clone->id)
                ->when($zoneId, fn ($query) => $query->where('zone_id', $zoneId))
                ->get();
        }

        $keyed = $existing->keyBy('variant_key');

        foreach ($prices as $variantKey => $price) {
            $variation = $keyed->get($variantKey);
            if ($variation) {
                $variation->price = $price;
                $variation->save();
            }
        }
    }

    /**
     * Admin ki service edit -> clone banao / update karo.
     * PUT api/v1/partner/services/manage/{id}
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $provider = $request->user()->provider;
        if (!$provider) {
            return response()->json(response_formatter(DEFAULT_404), 404);
        }

        $validator = Validator::make($request->all(), [
            'price' => 'required|array|min:1',
            'price.*' => 'required|numeric|min:0|max:999999999',
            'short_description' => 'nullable|string|max:1000',
            'cover_image' => 'nullable|file|mimes:jpg,jpeg,png,webp|max:4096',
        ], [
            'price.required' => translate('Price is required'),
            'price.min' => translate('Price is required'),
            'price.*.numeric' => translate('Price must be a number'),
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $target = $this->service->find($id);
        if (!$target) {
            return response()->json(response_formatter(DEFAULT_404), 404);
        }

        $base = $target->parent_service_id ? $target->parentService : $target;

        if (!is_null($base->provider_id) && $base->provider_id != $provider->id) {
            return response()->json(response_formatter(DEFAULT_403), 403);
        }

        // Toggle gating: admin service edit = allow_service_edit, apni service = allow_service_create
        if (is_null($base->provider_id) && ! $provider->allow_service_edit) {
            return $this->errorResponse(403, 'Service editing is disabled for this provider');
        }
        if (!is_null($base->provider_id) && ! $provider->allow_service_create) {
            return $this->errorResponse(403, 'Service editing is disabled for this provider');
        }

        $assigned = $this->assignedSubCategoryIds($provider);
        if (!in_array($base->sub_category_id, $assigned)) {
            return $this->errorResponse(400, 'This service is not assigned to you');
        }

        $clone = Service::withoutGlobalScopes()
            ->where('parent_service_id', $base->id)
            ->where('provider_id', $provider->id)
            ->where('zone_id', $provider->zone_id)
            ->first();

        if (!$clone) {
            $clone = $this->makeClone($base, $provider);
        }

        // Step 6 toggle: admin service ki update approve queue me jati hai
        $isAdminService = is_null($base->provider_id);
        $requireApproval = $isAdminService && (bool) $provider->service_approval_required;

        $previousSnapshot = $this->previousSnapshot($clone, $provider->zone_id);

        if ($request->filled('short_description')) {
            $clone->short_description = $request->short_description;
        }

        if ($request->hasFile('cover_image')) {
            $clone->cover_image = file_uploader('service/', APPLICATION_IMAGE_FORMAT, $request->file('cover_image'));
        }

        $clone->save();

        $this->syncCloneVariations($clone, $base, $provider->zone_id, $request->price);

        if ($requireApproval) {
            $clone->approval_status = 'pending';
            $clone->save();
            $this->logServiceRequest($provider, $clone, 'update', $previousSnapshot);
        } elseif ($isAdminService) {
            $clone->approval_status = 'approved';
            $clone->save();
            // toggle OFF = approval ki zaroorat nahi -> purani pending request khud hi close
            ProviderServiceRequest::where('service_id', $clone->id)
                ->where('status', 'pending')
                ->update(['status' => 'approved', 'admin_note' => 'Auto approved (approval toggle is off)']);
        }

        $clone->load(['variations', 'parentService.variations', 'storage_cover_image']);

        return response()->json(response_formatter(DEFAULT_200, $this->formatService($clone, $provider->zone_id)), 200);
    }

    /**
     * Admin approval request ka snapshot: change se pehle wali state.
     */
    private function previousSnapshot($clone, ?string $zoneId): array
    {
        $pending = ProviderServiceRequest::where('service_id', $clone->id)
            ->where('status', 'pending')
            ->first();

        if ($pending && $pending->previous_values) {
            $decoded = json_decode($pending->previous_values, true);
            if (is_array($decoded)) {
                return $decoded;
            }
        }

        // pehli baar clone bana hai to uski variations abhi bani nahi hoti ->
        // "before" price asal base (admin) service se lete hain
        $priceServiceId = $clone->parent_service_id ?: $clone->id;

        $baseRows = Variation::where('service_id', $priceServiceId)->get();
        $zoneRows = $zoneId ? $baseRows->where('zone_id', $zoneId)->values() : collect();
        if ($zoneRows->isEmpty()) {
            $zoneRows = $baseRows;
        }

        return [
            'short_description' => $clone->short_description,
            'cover_image' => $clone->cover_image,
            'prices' => $zoneRows->pluck('price', 'variant_key')->toArray(),
        ];
    }

    /**
     * Create / Update request queue me likhta hai (admin ke 2 tabs).
     */
    private function logServiceRequest($provider, $service, string $type, ?array $previous): void
    {
        $pending = ProviderServiceRequest::where('service_id', $service->id)
            ->where('status', 'pending')
            ->first();

        $payload = [
            'provider_id' => $provider->id,
            'service_id' => $service->id,
            'zone_id' => $provider->zone_id,
            'request_type' => $type,
            'previous_values' => $previous === null
                ? null
                : ($pending ? $pending->previous_values : json_encode($previous)),
            'status' => 'pending',
        ];

        if ($pending) {
            $pending->update($payload);
            return;
        }

        ProviderServiceRequest::create($payload);
    }

    /**
     * Provider khud ka naya service banata hai -> admin approval ke liye pending.
     * POST api/v1/partner/services/manage
     */
    public function store(Request $request): JsonResponse
    {
        $provider = $request->user()->provider;
        if (!$provider) {
            return response()->json(response_formatter(DEFAULT_404), 404);
        }

        if (! $provider->allow_service_create) {
            return $this->errorResponse(403, 'Service creation is disabled for this provider');
        }

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:191',
            'sub_category_id' => 'required|exists:categories,id',
            'short_description' => 'required|string|max:1000',
            'description' => 'required|string',
            'cover_image' => 'required|file|mimes:jpg,jpeg,png,webp|max:4096',
            'price' => 'required|numeric|min:0|max:999999999',
        ], [
            'name.required' => translate('Service name is required'),
            'sub_category_id.required' => translate('Sub category is required'),
            'short_description.required' => translate('Short description is required'),
            'description.required' => translate('Description is required'),
            'cover_image.required' => translate('Service image is required'),
            'price.required' => translate('Price is required'),
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $assigned = $this->assignedSubCategoryIds($provider);
        if (!in_array($request->sub_category_id, $assigned)) {
            return $this->errorResponse(400, 'You are not assigned to this sub category');
        }

        $subCategory = Category::find($request->sub_category_id);
        if (!$subCategory) {
            return response()->json(response_formatter(DEFAULT_404), 404);
        }

        $requireApproval = (bool) $provider->service_approval_required;

        $service = new Service();
        $service->name = $request->name;
        $service->short_description = $request->short_description;
        $service->description = $request->description;
        $service->category_id = $subCategory->parent_id;
        $service->sub_category_id = $subCategory->id;
        $service->cover_image = file_uploader('service/', APPLICATION_IMAGE_FORMAT, $request->file('cover_image'));
        $service->tax = 0;
        $service->is_active = 1;
        $service->order_count = 0;
        $service->rating_count = 0;
        $service->avg_rating = 0;
        $service->min_bidding_price = 0;
        $service->is_single_provider = 0;
        $service->provider_id = $provider->id;
        $service->zone_id = $provider->zone_id;
        $service->parent_service_id = null;
        $service->approval_status = $requireApproval ? 'pending' : 'approved';
        $service->slug = Service::generateUniqueSlug($request->name);
        $service->save();

        if ($requireApproval) {
            $this->logServiceRequest($provider, $service, 'create', null);
        }

        $variantName = $request->input('variant_name') ?: 'Standard';
        Variation::create([
            'variant' => $variantName,
            'variant_key' => Str::slug($variantName),
            'zone_id' => $provider->zone_id,
            'price' => $request->price,
            'service_id' => $service->id,
        ]);

        $service->load(['variations', 'storage_cover_image']);

        return response()->json(response_formatter(SERVICE_STORE_200, $this->formatService($service, $provider->zone_id)), 200);
    }

    /**
     * Apni service delete / edit kiya hua clone discard (base wapas aa jata hai).
     * DELETE api/v1/partner/services/manage/{id}
     */
    public function destroy(Request $request, string $id): JsonResponse
    {
        $provider = $request->user()->provider;
        if (!$provider) {
            return response()->json(response_formatter(DEFAULT_404), 404);
        }

        $service = Service::withoutGlobalScopes()->find($id);
        if (!$service) {
            return response()->json(response_formatter(DEFAULT_404), 404);
        }

        if ($service->provider_id != $provider->id) {
            return response()->json(response_formatter(DEFAULT_403), 403);
        }

        // Clone discard = allow_service_edit, apni service delete = allow_service_create
        if (!is_null($service->parent_service_id) && ! $provider->allow_service_edit) {
            return $this->errorResponse(403, 'Service editing is disabled for this provider');
        }
        if (is_null($service->parent_service_id) && ! $provider->allow_service_create) {
            return $this->errorResponse(403, 'Service deletion is disabled for this provider');
        }

        $service->delete();

        return response()->json(response_formatter(DEFAULT_DELETE_200), 200);
    }
}
