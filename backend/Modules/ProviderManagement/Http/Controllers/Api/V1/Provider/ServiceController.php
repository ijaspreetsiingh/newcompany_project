<?php

namespace Modules\ProviderManagement\Http\Controllers\Api\V1\Provider;

use Carbon\Carbon;
use Illuminate\Contracts\Support\Renderable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Modules\BusinessSettingsModule\Entities\PackageSubscriber;
use Modules\BusinessSettingsModule\Entities\PackageSubscriberLimit;
use Modules\CategoryManagement\Entities\Category;
use Modules\ProviderManagement\Entities\SubscribedService;

class ServiceController extends Controller
{
    private $subscribedService, $category;
    private PackageSubscriber $packageSubscriber;
    private PackageSubscriberLimit $packageSubscriberLimit;

    public function __construct(SubscribedService $subscribedService, Category $category, PackageSubscriber $packageSubscriber, PackageSubscriberLimit $packageSubscriberLimit)
    {
        $this->subscribedService = $subscribedService;
        $this->packageSubscriber = $packageSubscriber;
        $this->packageSubscriberLimit = $packageSubscriberLimit;
        $this->category = $category;
    }

    /**
     * Update the specified resource in storage.
     * @param Request $request
     * @return JsonResponse
     */
    public function updateSubscription(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'sub_category_id' => 'required|array',
            'sub_category_id.*' => 'exists:categories,id',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $providerModel = $request->user()->provider;
        $providerId = $providerModel->id;
        $zoneId = $providerModel->zone_id;
        $subscriptionRequired = (int) ($providerModel->subscription_required ?? 1);

        $packageSubscriber = null;
        $limit = null;

        // Provider Subscribe OFF -> package limit queries skip (fast)
        if ($subscriptionRequired !== 0) {
            $packageSubscriber = $this->packageSubscriber->where('provider_id', $providerId)->first();
            $limit = $this->packageSubscriberLimit
                ->where('provider_id', $providerId)
                ->where('subscription_package_id', $packageSubscriber?->subscription_package_id)
                ->where('key', 'category')
                ->first();
        }

        $packageSubscriberLimit = $limit?->limit_count;
        $isLimit = $limit?->is_limited;
        $endDate = $packageSubscriber?->package_end_date;
        $packageEndDate = $endDate ? Carbon::parse($endDate)->endOfDay() : null;
        $isPackageEnded = $packageEndDate ? Carbon::now()->subDays()->diffInDays($packageEndDate, false) : null;

        foreach (array_unique($request['sub_category_id']) as $id) {
            $subCategory = $this->category->find($id);
            if (!$subCategory) {
                continue;
            }

            $existing = $this->subscribedService
                ->where('provider_id', $providerId)
                ->where('sub_category_id', $id)
                ->when($zoneId, function ($query) use ($zoneId) {
                    $query->where('zone_id', $zoneId);
                })
                ->first();

            // Already assigned -> toggle OFF (row delete, taaki unique index slot free ho)
            if ($existing) {
                $existing->delete();
                continue;
            }

            // Package limit (sirf jab subscription required ho)
            if ($subscriptionRequired !== 0 && $packageSubscriber && $isLimit && $isPackageEnded) {
                $categoryCount = $this->subscribedService
                    ->where('provider_id', $providerId)
                    ->where('is_subscribed', 1)
                    ->count();

                if ($packageSubscriberLimit <= $categoryCount) {
                    return response()->json(response_formatter(CATEGORY_LIMIT_END), 400);
                }
            }

            // Exclusivity: ek zone me ek sub-category sirf ek provider ko
            if ($zoneId) {
                $taken = $this->subscribedService
                    ->where('zone_id', $zoneId)
                    ->where('sub_category_id', $id)
                    ->where('provider_id', '!=', $providerId)
                    ->with('provider:id,company_name,contact_person_name', 'sub_category:id,name')
                    ->first();

                if ($taken) {
                    $owner = $taken->provider;
                    $ownerName = $owner?->contact_person_name ?: $owner?->company_name ?: translate('another provider');
                    $subName = $taken->sub_category?->name ?: '';
                    $message = translate('This sub-category is already assigned to')
                        . ' "' . $ownerName . '"'
                        . ($subName ? ' (' . $subName . ')' : '')
                        . ' ' . translate('in the same zone') . '.';

                    return response()->json([
                        'response_code' => DEFAULT_400['response_code'],
                        'message' => $message,
                        'content' => null,
                        'errors' => [['error_code' => 'sub_category_id', 'message' => $message]],
                    ], 400);
                }
            }

            $this->subscribedService->create([
                'provider_id' => $providerId,
                'sub_category_id' => $id,
                'category_id' => $subCategory->parent_id,
                'zone_id' => $zoneId,
                'assign_type' => 'specific',
                'is_subscribed' => 1,
            ]);
        }

        return response()->json(response_formatter(DEFAULT_200), 200);
    }
}
