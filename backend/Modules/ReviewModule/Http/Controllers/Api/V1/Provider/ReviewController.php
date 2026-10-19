<?php

namespace Modules\ReviewModule\Http\Controllers\Api\V1\Provider;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Modules\ReviewModule\Entities\Review;
use Modules\UserManagement\Entities\Serviceman;

class ReviewController extends Controller
{
    private $review;

    public function __construct(Review $review)
    {
        $this->review = $review;
    }

    /**
     * Display a listing of the resource.
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'limit' => 'required|numeric|min:1|max:200',
            'offset' => 'required|numeric|min:1|max:100000',
            'status' => 'required|in:active,inactive,all'
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $reviews = $this->review->where('provider_id', $request->user()->provider->id)
            ->with(['booking.detail', 'provider', 'customer', 'reviewReply', 'service', 'serviceman.user'])
            ->when($request->has('status') && $request['status'] != 'all', function ($query) use ($request) {
                return $query->ofStatus(($request['status'] == 'active') ? 1 : 0);
            })->latest()->paginate($request['limit'], ['*'], 'offset', $request['offset'])->withPath('');

        $ratingGroupCount = DB::table('reviews')->where('provider_id', $request->user()->provider->id)
            ->select('review_rating', DB::raw('count(*) as total'))
            ->groupBy('review_rating')
            ->get();

        $ratingInfo = [
            'rating_count' => $request->user()->provider['rating_count'],
            'average_rating' => $request->user()->provider['avg_rating'],
            'rating_group_count' => $ratingGroupCount,
        ];

        if ($reviews->count() > 0) {
            return response()->json(response_formatter(DEFAULT_200, ['reviews' => $reviews, 'rating' => $ratingInfo]), 200);
        }

        return response()->json(response_formatter(DEFAULT_404), 200);
    }

    /**
     * Show the specified resource.
     * @param Request $request
     * @return JsonResponse
     */
    public function search(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'string' => 'required',
            'limit' => 'required|numeric|min:1|max:200',
            'offset' => 'required|numeric|min:1|max:100000',
            'status' => 'required|in:all,active,inactive'
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $keys = explode(' ', base64_decode($request['string']));
        $reviews = $this->review->where('provider_id', $request->user()->provider->id)
            ->where(function ($query) use ($keys) {
                foreach ($keys as $key) {
                    $query->orWhere('booking_id', 'LIKE', '%' . $key . '%')
                        ->orWhere('provider_id', 'LIKE', '%' . $key . '%');
                }
            })->when($request['status'] != 'all', function ($query) use ($request) {
                return $query->ofStatus(($request['status'] == 'active') ? 1 : 0);
            })->paginate($request['limit'], ['*'], 'offset', $request['offset'])->withPath('');

        if ($reviews->count() > 0) {
            return response()->json(response_formatter(DEFAULT_200, $reviews), 200);
        }
        return response()->json(response_formatter(DEFAULT_204, $reviews), 200);
    }

    /**
     * Ek booking ke liye provider ke saare reviews (booking details -> reviews tab)
     *
     * @param Request $request
     * @param string $bookingId
     * @return JsonResponse
     */
    public function booking(Request $request, string $bookingId): JsonResponse
    {
        $validator = Validator::make(['booking_id' => $bookingId], [
            'booking_id' => 'required|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $provider = $request->user()->provider ?? null;
        if (!isset($provider)) {
            return response()->json(response_formatter(DEFAULT_403), 403);
        }

        $reviews = $this->review
            ->where('provider_id', $provider->id)
            ->where('booking_id', $bookingId)
            ->with(['booking.detail', 'provider', 'customer', 'reviewReply', 'service', 'serviceman.user'])
            ->latest()
            ->get();

        return response()->json(response_formatter(DEFAULT_200, ['reviews' => $reviews]), 200);
    }

    /**
     * Provider ke servicemen-wise rating breakdown:
     * har serviceman ka avg rating + review count, top & lowest serviceman,
     * saare reviews aur overall rating summary (nayi "serviceman reviews" screen ke liye)
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function servicemanRatings(Request $request): JsonResponse
    {
        $provider = $request->user()->provider ?? null;
        if (!isset($provider)) {
            return response()->json(response_formatter(DEFAULT_403), 403);
        }

        $reviews = $this->review
            ->where('provider_id', $provider->id)
            ->where('is_active', 1)
            ->with(['booking.detail', 'provider', 'customer', 'reviewReply', 'service', 'serviceman.user'])
            ->latest()
            ->limit(500)
            ->get();

        $groupedReviews = $reviews->whereNotNull('serviceman_id')->groupBy('serviceman_id');

        $servicemen = Serviceman::with('user')
            ->where('provider_id', $provider->id)
            ->get()
            ->map(function ($serviceman) use ($groupedReviews) {
                $list = $groupedReviews->get($serviceman->id, collect());
                $ratingCount = $list->count();
                $reviewCount = $list->filter(fn ($review) => !is_null($review->review_comment))->count();

                return [
                    'id' => $serviceman->id,
                    'name' => trim(($serviceman->user->first_name ?? '') . ' ' . ($serviceman->user->last_name ?? '')),
                    'profile_image' => $serviceman->user->profile_image_full_path ?? null,
                    'is_active' => (int) ($serviceman->is_active ?? 1),
                    'rating_count' => $ratingCount,
                    'review_count' => $reviewCount,
                    'average_rating' => $ratingCount > 0 ? round($list->avg('review_rating'), 2) : 0,
                ];
            })
            ->sortByDesc('average_rating')
            ->values();

        $ratedServicemen = $servicemen->filter(fn ($serviceman) => $serviceman['rating_count'] > 0)->values();

        $topServiceman = $ratedServicemen->count() > 0 ? $ratedServicemen->first() : null;
        $lowestServiceman = $ratedServicemen->count() > 1 ? $ratedServicemen->last() : null;

        $ratingGroupCount = DB::table('reviews')
            ->where('provider_id', $provider->id)
            ->where('is_active', 1)
            ->select('review_rating', DB::raw('count(*) as total'))
            ->groupBy('review_rating')
            ->get();

        $ratingCount = 0;
        $totalRating = 0;
        foreach ($ratingGroupCount as $count) {
            $ratingCount += $count->total;
            $totalRating += round($count->review_rating * $count->total, 2);
        }

        $ratingInfo = [
            'rating_count' => $ratingCount,
            'review_count' => $reviews->filter(fn ($review) => !is_null($review->review_comment))->count(),
            'average_rating' => $ratingCount > 0 ? round($totalRating / $ratingCount, 2) : 0,
            'rating_group_count' => $ratingGroupCount,
        ];

        return response()->json(response_formatter(DEFAULT_200, [
            'servicemen' => $servicemen,
            'top_serviceman' => $topServiceman,
            'lowest_serviceman' => $lowestServiceman,
            'reviews' => $reviews,
            'rating' => $ratingInfo,
        ]), 200);
    }

}
