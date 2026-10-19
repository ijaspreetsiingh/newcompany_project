<?php

namespace Modules\ReviewModule\Http\Controllers\Api\V1\Serviceman;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Modules\ReviewModule\Entities\Review;

class ReviewController extends Controller
{
    private $review;

    public function __construct(Review $review)
    {
        $this->review = $review;
    }

    /**
     * Logged in serviceman ko mile saare reviews (rating summary ke saath)
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'limit' => 'required|numeric|min:1|max:200',
            'offset' => 'required|numeric|min:1|max:100000',
            'status' => 'nullable|in:active,inactive,all',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $serviceman = $request->user()->serviceman ?? null;
        if (!isset($serviceman)) {
            return response()->json(response_formatter(DEFAULT_403), 403);
        }

        $status = $request->has('status') ? $request['status'] : 'all';

        $reviews = $this->review
            ->where('serviceman_id', $serviceman->id)
            ->when($status != 'all', function ($query) use ($status) {
                return $query->ofStatus(($status == 'active') ? 1 : 0);
            })
            ->with(['booking.detail', 'provider', 'customer', 'reviewReply', 'service', 'serviceman.user'])
            ->latest()
            ->paginate($request['limit'], ['*'], 'offset', $request['offset'])->withPath('');

        $ratingGroupCount = DB::table('reviews')
            ->where('serviceman_id', $serviceman->id)
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

        $reviewCount = DB::table('reviews')
            ->where('serviceman_id', $serviceman->id)
            ->where('is_active', 1)
            ->whereNotNull('review_comment')
            ->count();

        $ratingInfo = [
            'rating_count' => $ratingCount,
            'review_count' => $reviewCount,
            'average_rating' => $ratingCount > 0 ? round($totalRating / $ratingCount, 2) : 0,
            'rating_group_count' => $ratingGroupCount,
        ];

        return response()->json(response_formatter(DEFAULT_200, ['reviews' => $reviews, 'rating' => $ratingInfo]), 200);
    }

    /**
     * Ek booking ke liye is serviceman ko mile reviews (booking details -> reviews tab)
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

        $serviceman = $request->user()->serviceman ?? null;
        if (!isset($serviceman)) {
            return response()->json(response_formatter(DEFAULT_403), 403);
        }

        $reviews = $this->review
            ->where('serviceman_id', $serviceman->id)
            ->where('booking_id', $bookingId)
            ->with(['booking.detail', 'provider', 'customer', 'reviewReply', 'service', 'serviceman.user'])
            ->latest()
            ->get();

        return response()->json(response_formatter(DEFAULT_200, ['reviews' => $reviews]), 200);
    }
}
