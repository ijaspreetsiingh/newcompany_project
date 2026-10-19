<?php

namespace Modules\BookingModule\Http\Controllers\Api\V1\Customer;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Modules\BookingModule\Entities\Booking;
use Modules\BookingModule\Entities\BookingServiceman;
use Modules\UserManagement\Entities\Serviceman;
use Modules\UserManagement\Entities\User;
use Modules\ProviderManagement\Entities\Provider;
use Modules\ProviderManagement\Entities\SubscribedService;
use Modules\CategoryManagement\Entities\Category;

class ServicemanSelectionController extends Controller
{
    /**
     * Get available servicemen for manual selection
     * POST /api/v1/customer/get-available-servicemen
     * 
     * IMPORTANT: Filters servicemen by:
     * - Provider
     * - Service's main category AND sub-category assignment
     * - Active status
     * - Zone
     */
    public function getAvailableServicemen(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'zone_id' => 'required|uuid',
            'provider_id' => 'nullable|string|max:36',
            'category_id' => 'required|string|max:36',
            'sub_category_id' => 'required|string|max:36',
            'customer_lat' => 'nullable|numeric',
            'customer_lon' => 'nullable|numeric',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        try {
            $zoneId = $request['zone_id'];
            $providerId = $request['provider_id'] ?? null;
            $categoryId = $request['category_id'];
            $subCategoryId = $request['sub_category_id'];
            $customerLat = $request['customer_lat'];
            $customerLon = $request['customer_lon'];

            // Category bookings can have no provider_id in the cart. Resolve
            // the assigned provider from this zone/category in that case.
            if (empty($providerId)) {
                $candidateProviderIds = SubscribedService::query()
                    ->where('is_subscribed', 1)
                    ->where(function ($query) use ($subCategoryId, $categoryId) {
                        $query->where('sub_category_id', $subCategoryId)
                            ->orWhere(function ($categoryQuery) use ($categoryId) {
                                $categoryQuery->where('category_id', $categoryId)
                                    ->where('assign_type', 'complete');
                            });
                    })
                    ->whereHas('provider', function ($query) use ($zoneId) {
                        $query->where('zone_id', $zoneId)
                            ->where('is_active', 1)
                            ->where('is_approved', 1)
                            ->where('is_suspended', 0);
                    })
                    ->pluck('provider_id')
                    ->unique();

                foreach ($candidateProviderIds as $candidateId) {
                    if (subcategory_has_serviceable_provider($subCategoryId, $categoryId, $zoneId, $candidateId)) {
                        $providerId = $candidateId;
                        break;
                    }
                }
            }

            // Get the provider
            $provider = $providerId ? Provider::find($providerId) : null;
            if (!$provider) {
                if (empty($providerId)) {
                    return response()->json(response_formatter(DEFAULT_200, [], 'No servicemen available for this service'), 200);
                }
                return response()->json(response_formatter(DEFAULT_400, null, ['error' => 'Provider not found']), 400);
            }

            // A manually selected serviceman must belong to the provider that
            // actually serves this sub-category in the selected zone.
            $subCategory = Category::find($subCategoryId);
            if (!$subCategory || $subCategory->parent_id !== $categoryId) {
                return response()->json(response_formatter(DEFAULT_400, null, ['error' => 'Category does not match sub-category']), 400);
            }

            if ((string) $provider->zone_id !== (string) $zoneId ||
                !subcategory_has_serviceable_provider($subCategoryId, $categoryId, $zoneId, $providerId)) {
                return response()->json(response_formatter(DEFAULT_200, [], 'No servicemen available for this service'), 200);
            }

            // Offer only servicemen who can receive an assignment right now.
            // CATEGORY FILTER: Serviceman must have this sub_category assigned
            $servicemen = Serviceman::with(['user:id,first_name,last_name,profile_image'])
                ->where('provider_id', $providerId)
                ->where('is_on_duty', 1)
                ->whereHas('user', fn($q) => $q->where('is_active', 1))
                // Only staff explicitly assigned to this provider category's
                // sub-category can be offered for the booking.
                ->whereHas('servicemanCategories', function ($q) use ($subCategoryId, $categoryId) {
                    $q->where('sub_category_id', $subCategoryId)
                      ->where('category_id', $categoryId);
                })
                ->get();

            if ($servicemen->isEmpty()) {
                return response()->json(response_formatter(DEFAULT_200, [], 'No servicemen available for this service'), 200);
            }

            $result = [];

            foreach ($servicemen as $serviceman) {
                // Get average rating from reviews
                $rating = DB::table('reviews')
                    ->where('serviceman_id', $serviceman->id)
                    ->whereNotNull('review_rating')
                    ->where('is_active', 1)
                    ->avg('review_rating');
                $rating = $rating ? round($rating, 1) : 0;

                // Get review count
                $reviewCount = DB::table('reviews')
                    ->where('serviceman_id', $serviceman->id)
                    ->whereNotNull('review_rating')
                    ->where('is_active', 1)
                    ->count();

                // Get completed bookings count
                $completedCount = DB::table('bookings')
                    ->where('serviceman_id', $serviceman->id)
                    ->where('booking_status', 'completed')
                    ->count();

                // Get active bookings count
                $activeCount = DB::table('bookings')
                    ->where('serviceman_id', $serviceman->id)
                    ->whereIn('booking_status', ['pending', 'accepted', 'ongoing'])
                    ->count();

                // Calculate distance if coordinates provided
                $distance = null;
                if ($customerLat && $customerLon && $serviceman->user && $serviceman->user->latitude && $serviceman->user->longitude) {
                    $distance = calculateDistance($customerLat, $customerLon, $serviceman->user->latitude, $serviceman->user->longitude);
                }

                $result[] = [
                    'id' => $serviceman->id,
                    'name' => trim(($serviceman->user->first_name ?? '') . ' ' . ($serviceman->user->last_name ?? '')) ?: 'Unknown',
                    'profile_image' => $serviceman->user->profile_image_full_path ?? null,
                    'rating' => $rating,
                    'avg_rating' => $rating,
                    'total_reviews' => $reviewCount,
                    'completed_bookings' => $completedCount,
                    'active_bookings' => $activeCount,
                    'distance_km' => $distance ? round($distance, 1) : null,
                ];
            }

            // Sort by rating first (highest), then by distance (nearest)
            usort($result, function ($a, $b) {
                if ($a['rating'] != $b['rating']) {
                    return $b['rating'] <=> $a['rating']; // Higher rating first
                }
                if ($a['distance_km'] && $b['distance_km']) {
                    return $a['distance_km'] <=> $b['distance_km']; // Nearer first
                }
                return 0;
            });

            // Limit to 20
            $result = array_slice($result, 0, 20);

            return response()->json(response_formatter(DEFAULT_200, $result), 200);

        } catch (\Throwable $e) {
            \Log::error('getAvailableServicemen error: ' . $e->getMessage());
            return response()->json(response_formatter(DEFAULT_500, null, ['error' => 'Server error']), 500);
        }
    }

    /**
     * Assign serviceman manually to booking
     * POST /api/v1/customer/assign-serviceman-manual
     */
    public function assignServicemanManual(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'booking_id' => 'required|uuid',
            'serviceman_id' => 'required|string|max:36',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        try {
            $bookingId = $request['booking_id'];
            $servicemanId = $request['serviceman_id'];

            // Lock the booking while checking ownership/status and creating its
            // assignment slot. This prevents two customers/requests racing to
            // attach different staff to the same booking.
            $result = DB::transaction(function () use ($request, $bookingId, $servicemanId) {
                $booking = Booking::where('id', $bookingId)->lockForUpdate()->first();
                if (!$booking || (string) $booking->customer_id !== (string) $request->user()->id) {
                    return ['error' => 'Booking not found', 'status' => 404];
                }
                if ($booking->booking_status !== 'pending') {
                    return ['error' => 'Booking is not in pending status', 'status' => 400];
                }
                if (empty($booking->provider_id)) {
                    return ['error' => 'Booking provider is not assigned', 'status' => 400];
                }

                $subCategory = Category::find($booking->sub_category_id);
                if (!$subCategory || empty($subCategory->parent_id) ||
                    !subcategory_has_serviceable_provider(
                        $booking->sub_category_id,
                        $subCategory->parent_id,
                        $booking->zone_id,
                        $booking->provider_id
                    )) {
                    return ['error' => 'Booking category is not assigned to its provider', 'status' => 400];
                }

                $serviceman = Serviceman::with('user')
                    ->where('id', $servicemanId)
                    ->where('provider_id', $booking->provider_id)
                    ->where('is_on_duty', 1)
                    ->whereHas('user', fn ($query) => $query->where('is_active', 1))
                    ->whereHas('servicemanCategories', function ($query) use ($booking, $subCategory) {
                        $query->where('sub_category_id', $booking->sub_category_id)
                            ->where('category_id', $subCategory->parent_id);
                    })
                    ->first();

                if (!$serviceman) {
                    return ['error' => 'Serviceman is unavailable or not assigned to this category', 'status' => 400];
                }

                $waitTime = max(30, (int) ($booking->provider?->auto_assign_wait_time ?: 120));
                $expiresAt = now()->addSeconds($waitTime);
                BookingServiceman::where('booking_id', $bookingId)
                    ->where('status', BookingServiceman::STATUS_PENDING)
                    ->delete();

                BookingServiceman::updateOrCreate(
                    ['booking_id' => $bookingId, 'serviceman_id' => $servicemanId],
                    [
                        'status' => BookingServiceman::STATUS_PENDING,
                        'expires_at' => $expiresAt,
                    ]
                );
                $booking->serviceman_id = $servicemanId;
                $booking->serviceman_assign_expires_at = $expiresAt;
                $booking->assignment_mode = 'auto';
                $booking->save();

                return ['booking' => $booking, 'serviceman' => $serviceman, 'expires_at' => $expiresAt];
            });

            if (isset($result['error'])) {
                $responseCode = $result['status'] === 404 ? DEFAULT_404 : DEFAULT_400;
                return response()->json(
                    response_formatter($responseCode, null, ['error' => $result['error']]),
                    $result['status']
                );
            }

            $booking = $result['booking'];
            $serviceman = $result['serviceman'];

            return response()->json(response_formatter(DEFAULT_200, [
                'booking_id' => $bookingId,
                'serviceman_id' => $servicemanId,
                'expires_in_seconds' => max(0, now()->diffInSeconds($result['expires_at'], false)),
                'message' => 'Booking request sent to serviceman'
            ]), 200);

        } catch (\Throwable $e) {
            \Log::error('assignServicemanManual error: ' . $e->getMessage());
            return response()->json(response_formatter(DEFAULT_500, null, ['error' => 'Server error']), 500);
        }
    }
}
