<?php

namespace Modules\ServicemanModule\Http\Controllers\Api\V1\Provider;

use App\Traits\UploadSizeHelperTrait;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Modules\BookingModule\Entities\Booking;
use Modules\CategoryManagement\Entities\Category;
use Modules\ServicemanModule\Entities\ServicemanCategory;
use Modules\ProviderManagement\Entities\SubscribedService;
use Modules\UserManagement\Entities\Serviceman;
use Modules\UserManagement\Entities\User;

class ServicemanController extends Controller
{
    use UploadSizeHelperTrait;
    private User $employee;
    private Serviceman $serviceman;
    private Booking $booking;

    public function __construct(Serviceman $serviceman, User $employee, Booking $booking)
    {
        $this->serviceman = $serviceman;
        $this->employee = $employee;
        $this->booking = $booking;
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

        $serviceman = $this->employee->with(['serviceman.servicemanCategories.subCategory', 'serviceman.servicemanCategories.mainCategory'])
            ->when($request->has('string'), function ($query) use ($request) {
                $query->where(function ($query) use ($request) {
                    $keys = explode(' ', base64_decode($request['string']));
                    foreach ($keys as $key) {
                        $query->orWhere('first_name', 'LIKE', '%' . $key . '%')
                            ->orWhere('last_name', 'LIKE', '%' . $key . '%')
                            ->orWhere('email', 'LIKE', '%' . $key . '%')
                            ->orWhere('identification_number', 'LIKE', '%' . $key . '%')
                            ->orWhere('phone', 'LIKE', '%' . $key . '%');
                    }
                });
            })
            ->when($request['status'] != 'all', function ($query) use ($request) {
                $query->ofStatus(($request['status'] == 'active') ? 1 : 0);
            })
            ->whereHas('serviceman', function ($query) use ($request) {
                $query->where('provider_id', $request->user()->provider->id);
            })->latest()->where(['user_type' => 'provider-serviceman'])
            ->paginate($request['limit'], ['*'], 'offset', $request['offset'])->withPath('');

        return response()->json(response_formatter(DEFAULT_200, $serviceman), 200);
    }

    /**
     * Store a newly created resource in storage.
     * @param Request $request
     * @return JsonResponse
     */
    public function store(Request $request): JsonResponse
    {
        $check = $this->validateUploadedFile($request, ['profile_image']);
        if ($check !== true) {
            return $check;
        }

        $validator = Validator::make($request->all(), [
            'first_name' => 'required',
            'last_name' => 'required',
            'phone' => 'required',
            'email' => 'required|email',
            'password' => 'required|min:8',
            'confirm_password' => 'required|same:password',
            'profile_image' => 'required|image|max:'. uploadMaxFileSizeInKB('image') .'|mimes:' . implode(',', array_column(IMAGEEXTENSION, 'key')),
            'identity_type' => 'required|in:passport,driving_license,company_id,nid,trade_license',
            'identity_number' => 'required',
            'identity_images' => 'required|array',
            'identity_images.*' => 'image|max:'. uploadMaxFileSizeInKB('image') .'|mimes:' . implode(',', array_column(IMAGEEXTENSION, 'key')),
            'sub_category_ids' => 'required|array|min:1',
            // Validate against actual category records. Some existing category
            // IDs are non-UUID strings, so a UUID-format check rejects valid IDs.
            'sub_category_ids.*' => 'exists:categories,id',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        if (!$this->validProviderSubCategories($request, $request->input('sub_category_ids', []))) {
            return response()->json(response_formatter(DEFAULT_400, null, [['error_code' => 'sub_category_ids', 'message' => translate('Select categories assigned to your provider')]]), 400);
        }

        if (User::where('email', $request['email'])->exists()) {
            return response()->json(response_formatter(DEFAULT_400, null, [['error_code' => 'email', 'message' =>translate('Email already taken')]]), 400);
        }
        if (User::where('phone', $request['phone'])->exists()) {
            return response()->json(response_formatter(DEFAULT_400, null, [['error_code' => 'phone', 'message' =>translate('Phone already taken')]]), 400);
        }

        $identityImages = [];
        foreach ($request->identity_images as $image) {
            $imageName = file_uploader('serviceman/identity/', APPLICATION_IMAGE_FORMAT, $image);
            $identityImages[] = ['image'=>$imageName, 'storage'=> getDisk()];
        }

        $subCategoryIds = $request->input('sub_category_ids', []);

        DB::transaction(function () use ($request, $identityImages, $subCategoryIds) {
            $employee = $this->employee;
            $employee->first_name = $request->first_name;
            $employee->last_name = $request->last_name;
            $employee->email = $request->email;
            $employee->phone = $request->phone;
            $employee->profile_image = file_uploader('serviceman/profile/', APPLICATION_IMAGE_FORMAT, $request->file('profile_image'));
            $employee->identification_number = $request->identity_number;
            $employee->identification_type = $request->identity_type;
            $employee->identification_image = $identityImages;
            $employee->password = bcrypt($request->password);
            $employee->user_type = 'provider-serviceman';
            $employee->is_active = 1;
            $employee->save();

            $serviceman = $this->serviceman;
            $serviceman->provider_id = $request->user()->provider->id;
            $serviceman->user_id = $employee->id;
            $serviceman->save();

            $this->syncServicemanCategories($serviceman->id, $subCategoryIds);
        });

        return response()->json(response_formatter(DEFAULT_STORE_200), 200);
    }

    /**
     * Show the specified resource.
     * @param string $id
     * @return JsonResponse
     */
    public function show(Request $request, string $id): JsonResponse
    {
        $bookings = $this->booking->where('serviceman_id', $id)
            ->select('booking_status', DB::raw('count(*) as total_booking'))
            ->groupBy('booking_status')
            ->get();

        $bookingCount = ['ongoing'=>0,'completed'=>0,'canceled'=>0];
        foreach ($bookings as $booking) {
            if ($booking->booking_status == 'ongoing')
                $bookingCount['ongoing'] = $booking->total_booking ?? 0;
            if ($booking->booking_status == 'completed')
                $bookingCount['completed'] = $booking->total_booking ?? 0;
            if ($booking->booking_status == 'canceled')
                $bookingCount['canceled'] = $booking->total_booking ?? 0;
        }

        $serviceman = $this->serviceman::with([
            'user',
            'servicemanCategories.subCategory',
            'servicemanCategories.mainCategory',
        ])->where('id', $id)
            ->where('provider_id', $request->user()->provider->id)
            ->first();

        if (!isset($serviceman)) {
            return response()->json(response_formatter(DEFAULT_204), 204);
        }

        $serviceman->bookings_count = $bookingCount;

        return response()->json(response_formatter(DEFAULT_200, $serviceman), 200);
    }

    /**
     * Show the specified resource.
     * @param string $id
     * @return JsonResponse
     */
    public function edit(Request $request, string $id): JsonResponse
    {
        $serviceman = $this->serviceman::with(['users'])
            ->where('id', $id)
            ->where('provider_id', $request->user()->provider->id)
            ->first();

        if (!isset($serviceman)) {
            return response()->json(response_formatter(DEFAULT_204), 204);
        }
        return response()->json(response_formatter(DEFAULT_200, $serviceman), 200);
    }

    /**
     * Update the specified resource in storage.
     * @param Request $request
     * @param string $id
     * @return JsonResponse
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $check = $this->validateUploadedFile($request, ['profile_image']);
        if ($check !== true) {
            return $check;
        }

        $employee = $this->employee::whereHas('serviceman', function ($query) use ($id, $request) {
            $query->where('id', $id)
                ->where('provider_id', $request->user()->provider->id);
        })->first();

        if (!isset($employee)) {
            return response()->json(response_formatter(DEFAULT_204), 204);
        }

        $validator = Validator::make($request->all(), [
            'first_name' => 'required',
            'last_name' => 'required',
            'phone' => 'required',
            'email' => 'required|email',
            'password' => 'min:8',
            'profile_image' => 'image|max:'. uploadMaxFileSizeInKB('image') .'|mimes:' . implode(',', array_column(IMAGEEXTENSION, 'key')),
            'identity_type' => 'in:passport,driving_license,company_id,nid,trade_license',
            'identity_number' => 'required',
            'identity_images' => 'array',
            'identity_images.*' => 'image|max:'. uploadMaxFileSizeInKB('image') .'|mimes:' . implode(',', array_column(IMAGEEXTENSION, 'key')),
            'sub_category_ids' => 'required|array|min:1',
            'sub_category_ids.*' => 'exists:categories,id',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        if (!$this->validProviderSubCategories($request, $request->input('sub_category_ids', []))) {
            return response()->json(response_formatter(DEFAULT_400, null, [['error_code' => 'sub_category_ids', 'message' => translate('Select categories assigned to your provider')]]), 400);
        }

        if (User::where('email', $request['email'])->where('id', '!=', $employee->id)->exists()) {
            return response()->json(response_formatter(DEFAULT_400, null, [['error_code' => 'email', 'message' =>translate('Email already taken')]]), 400);
        }
        if (User::where('phone', $request['phone'])->where('id', '!=', $employee->id)->exists()) {
            return response()->json(response_formatter(DEFAULT_400, null, [['error_code' => 'phone', 'message' =>translate('Phone already taken')]]), 400);
        }

        $identityImages = [];
        if ($request->has('identity_images')) {
            foreach ($request['identity_images'] as $image) {
                $imageName = file_uploader('serviceman/identity/', APPLICATION_IMAGE_FORMAT, $image);
                $identityImages[] = ['image'=>$imageName, 'storage'=> getDisk()];
            }
        }

        DB::transaction(function () use ($request, $identityImages, $employee) {
            $employee->first_name = $request->first_name;
            $employee->last_name = $request->last_name;
            $employee->email = $request->email;
            $employee->phone = $request->phone;
            if ($request->has('profile_image')) {
                $employee->profile_image = file_uploader('serviceman/profile/', APPLICATION_IMAGE_FORMAT, $request->file('profile_image'));
            }
            $employee->identification_number = $request->identity_number;
            $employee->identification_type = $request->identity_type;
            if(count($identityImages) > 0) {
                $employee->identification_image = $identityImages;
            }
            if ($request->has('password')) {
                $employee->password = bcrypt($request->password);
            }
            $employee->user_type = 'provider-serviceman';
            $employee->save();

            // Provider ne sub-categories bheji hain to sync karo
            if ($request->has('sub_category_ids')) {
                $this->syncServicemanCategories($employee->serviceman->id, $request->input('sub_category_ids', []));
            }
        });

        return response()->json(response_formatter(DEFAULT_UPDATE_200), 200);
    }

    /**
     * Remove the specified resource from storage.
     * @param Request $request
     * @return JsonResponse
     */
    public function destroy(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'serviceman_id' => 'required|array',
            'serviceman_id.*' => 'uuid',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }
        $servicemanIds = $this->serviceman
            ->whereIn('id', $request->serviceman_id)
            ->pluck('user_id')
            ->toArray();
            if (count($servicemanIds) < 1) {
                return response()->json(response_formatter(DEFAULT_204), 200);
            }
            $this->serviceman->whereIn('id', $request->serviceman_id)->delete();

            $employees = $this->employee->whereIn('id', $servicemanIds);
            if ($employees->count() > 0) {
                foreach ($employees->get() as $employee) {
                    file_remover('serviceman/profile/', $employee->profile_image);
                    foreach ($employee->identification_image as $image) {
                        file_remover('serviceman/identity/', $image);
                    }
                    $employee->delete();
                }
                return response()->json(response_formatter(DEFAULT_DELETE_200), 200);
            }
        return response()->json(response_formatter(DEFAULT_204), 200);
    }

    /**
     * * Bulk status update
     * @param Request $request
     * @return JsonResponse
     */
    public function changeActiveStatus(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'serviceman_id' => 'required|array',
            'serviceman_id.*' => 'uuid',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $servicemanIds = $this->serviceman->whereIn('id', $request->serviceman_id)->pluck('user_id')->toArray();
        if (count($servicemanIds) < 1) {
            return response()->json(response_formatter(DEFAULT_204), 200);
        }

        $employees = $this->employee->whereIn('id', $servicemanIds)->get();

        foreach ($employees as $employee) {
            if(isset($employee)) {
                $employee->is_active = !$employee->is_active;
                $employee->save();
            }
        }

        return response()->json(response_formatter(DEFAULT_200), 200);
    }

    /**
     * Serviceman ki category assignments clean replace karo.
     * sub_category_id se parent category_id auto-resolve hoti hai.
     * Category selection required hai; empty assignment allowed nahi hai.
     */
    private function syncServicemanCategories(string $servicemanId, array $subCategoryIds): void
    {
        ServicemanCategory::where('serviceman_id', $servicemanId)->delete();

        if (empty($subCategoryIds)) {
            return;
        }

        $categories = Category::whereIn('id', $subCategoryIds)
            ->select('id', 'parent_id')
            ->get()
            ->keyBy('id');

        $rows = [];
        $now  = now();
        foreach ($subCategoryIds as $subCatId) {
            $cat = $categories->get($subCatId);
            if (!$cat) continue;
            $rows[] = [
                'serviceman_id'   => $servicemanId,
                'category_id'     => $cat->parent_id ?? $cat->id,
                'sub_category_id' => $subCatId,
                'created_at'      => $now,
                'updated_at'      => $now,
            ];
        }

        if (!empty($rows)) {
            ServicemanCategory::insert($rows);
        }
    }

    private function validProviderSubCategories(Request $request, array $subCategoryIds): bool
    {
        $subCategoryIds = array_values(array_unique(array_filter($subCategoryIds)));
        if (empty($subCategoryIds)) {
            return false;
        }

        $provider = $request->user()->provider;
        $assignedIds = SubscribedService::query()
            ->where('provider_id', $provider->id)
            ->where('zone_id', $provider->zone_id)
            ->where('is_subscribed', 1)
            ->whereIn('sub_category_id', $subCategoryIds)
            ->pluck('sub_category_id')
            ->map(fn($id) => (string) $id)
            ->unique()
            ->values()
            ->all();

        return count($assignedIds) === count($subCategoryIds);
    }
}
