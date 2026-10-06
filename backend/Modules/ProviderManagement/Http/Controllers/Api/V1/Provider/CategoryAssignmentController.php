<?php

namespace Modules\ProviderManagement\Http\Controllers\Api\V1\Provider;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Validator;
use Modules\CategoryManagement\Entities\Category;
use Modules\ProviderManagement\Entities\ProviderCategoryRequest;
use Modules\ProviderManagement\Entities\SubscribedService;

/**
 * Provider apni assigned main / sub category ko admin se replace,
 * change ya cancel karwa sakta hai. Admin approve karne par hi badalta hai.
 */
class CategoryAssignmentController extends Controller
{
    /**
     * App sirf top-level `message` padhta hai (custom error bhi wahin se aata hai).
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
     * Current assignment + poora category tree (assigned flag ke saath)
     * + agar koi request pending hai to woh bhi.
     * GET api/v1/partner/category-assignment
     */
    public function show(Request $request): JsonResponse
    {
        $provider = $request->user()->provider;
        if (!$provider) {
            return response()->json(response_formatter(DEFAULT_404), 404);
        }

        $assignedRows = SubscribedService::where('provider_id', $provider->id)
            ->where('is_subscribed', 1)
            ->when($provider->zone_id, function ($query) use ($provider) {
                $query->where('zone_id', $provider->zone_id);
            })
            ->get();

        $assignedSubIds = $assignedRows->pluck('sub_category_id')->unique()->values()->all();
        $assignedMainIds = $assignedRows->pluck('category_id')->unique()->values()->all();

        $categories = Category::query()
            ->ofType('main')
            ->ofStatus(1)
            ->when($provider->zone_id, function ($query) use ($provider) {
                $query->whereHas('zones', function ($zoneQuery) use ($provider) {
                    $zoneQuery->where('zone_id', $provider->zone_id);
                });
            })
            ->orderBy('position')
            ->with(['children' => function ($query) {
                $query->ofStatus(1)->orderBy('position');
            }])
            ->get();

        $tree = $categories->map(function ($category) use ($assignedSubIds, $assignedMainIds) {
            return [
                'id' => $category->id,
                'name' => $category->name,
                'is_assigned' => in_array($category->id, $assignedMainIds),
                'sub_categories' => $category->children->map(function ($subCategory) use ($assignedSubIds) {
                    return [
                        'id' => $subCategory->id,
                        'name' => $subCategory->name,
                        'description' => $subCategory->description,
                        'image' => $subCategory->image,
                        'is_assigned' => in_array($subCategory->id, $assignedSubIds),
                    ];
                })->values(),
            ];
        })->values();

        $pending = ProviderCategoryRequest::where('provider_id', $provider->id)
            ->where('status', 'pending')
            ->latest()
            ->first();

        return response()->json(response_formatter(DEFAULT_200, [
            'categories' => $tree,
            'current_main_category_ids' => $assignedMainIds,
            'current_sub_category_ids' => $assignedSubIds,
            'pending_request' => $pending ? [
                'id' => $pending->id,
                'request_type' => $pending->request_type,
                'requested_sub_category_ids' => $pending->requested_sub_category_ids ?? [],
                'note' => $pending->note,
                'created_at' => $pending->created_at,
            ] : null,
        ]), 200);
    }

    /**
     * Replace / change / cancel ki request admin ko bhejta hai.
     * POST api/v1/partner/category-assignment/request
     */
    public function store(Request $request): JsonResponse
    {
        $provider = $request->user()->provider;
        if (!$provider) {
            return response()->json(response_formatter(DEFAULT_404), 404);
        }

        $validator = Validator::make($request->all(), [
            'request_type' => 'required|in:replace,cancel',
            'sub_category_ids' => 'nullable|array',
            'sub_category_ids.*' => 'string',
            'note' => 'nullable|string|max:500',
        ], [
            'request_type.required' => translate('Request type is required'),
            'request_type.in' => translate('Invalid request type'),
            'sub_category_ids.array' => translate('Invalid sub category list'),
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $alreadyPending = ProviderCategoryRequest::where('provider_id', $provider->id)
            ->where('status', 'pending')
            ->exists();

        if ($alreadyPending) {
            return $this->errorResponse(400, 'You already have a pending category request', 'pending_request');
        }

        $currentRows = SubscribedService::where('provider_id', $provider->id)
            ->where('is_subscribed', 1)
            ->when($provider->zone_id, function ($query) use ($provider) {
                $query->where('zone_id', $provider->zone_id);
            })
            ->get();

        $currentSubIds = $currentRows->pluck('sub_category_id')->unique()->values()->all();
        $currentMainIds = $currentRows->pluck('category_id')->unique()->values()->all();

        $requestedSubIds = $request['request_type'] == 'cancel'
            ? []
            : array_values(array_unique(array_filter((array) ($request['sub_category_ids'] ?? []))));

        if ($request['request_type'] == 'replace') {
            if (empty($requestedSubIds)) {
                return $this->errorResponse(400, 'Select at least one sub category', 'sub_category_ids');
            }

            $validIds = Category::ofType('sub')->ofStatus(1)->whereIn('id', $requestedSubIds)->pluck('id')->all();
            if (count($validIds) != count($requestedSubIds)) {
                return $this->errorResponse(400, 'One or more selected sub categories are invalid', 'sub_category_ids');
            }

            // jis sub category par kisi aur provider ka haq hai woh bhejne se hi mat bhejo
            $taken = SubscribedService::whereIn('sub_category_id', $requestedSubIds)
                ->where('zone_id', $provider->zone_id)
                ->where('provider_id', '!=', $provider->id)
                ->with('provider:id,company_name,contact_person_name', 'sub_category:id,name')
                ->first();

            if ($taken) {
                $ownerName = $taken->provider?->contact_person_name ?: $taken->provider?->company_name ?: translate('another provider');
                return $this->errorResponse(400, 'This sub-category is already assigned to "' . $ownerName . '"', 'conflict');
            }
        }

        ProviderCategoryRequest::create([
            'provider_id' => $provider->id,
            'zone_id' => $provider->zone_id,
            'request_type' => $request['request_type'],
            'current_main_category_ids' => $currentMainIds,
            'current_sub_category_ids' => $currentSubIds,
            'requested_sub_category_ids' => $requestedSubIds,
            'note' => $request['note'] ?? null,
            'status' => 'pending',
        ]);

        return response()->json(response_formatter(DEFAULT_200, [
            'message' => translate('Request sent to admin for approval'),
        ]), 200);
    }
}
