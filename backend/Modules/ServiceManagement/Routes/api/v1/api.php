<?php

use Illuminate\Support\Facades\Route;
use Modules\ServiceManagement\Http\Controllers\Api\V1\Customer\FavoriteServiceController;
use Modules\ServiceManagement\Http\Controllers\Api\V1\Customer\ServiceController as CustomerServiceController;
use Modules\ServiceManagement\Http\Controllers\Api\V1\Provider\ServiceController as ProviderServiceController;
use Modules\ServiceManagement\Http\Controllers\Api\V1\Provider\FAQController as ProviderFAQController;
use Modules\ServiceManagement\Http\Controllers\Api\V1\Serviceman\ServiceController as ServicemanServiceController;
use Modules\ServiceManagement\Http\Controllers\Api\V1\Admin\ServiceController as AdminServiceController;
use Modules\ServiceManagement\Http\Controllers\Api\V1\Admin\FAQController as AdminFAQController;
use Modules\ServiceManagement\Http\Controllers\Api\V1\Provider\ServiceRequestController;


Route::group(['prefix' => 'admin', 'as' => 'admin.', 'namespace' => 'Api\V1\Admin', 'middleware' => ['auth:api']], function () {
//    Route::resource('service', 'ServiceController', ['only' => ['index', 'store', 'edit', 'update', 'show']]);
    Route::put('service/status/update', [AdminServiceController::class, 'statusUpdate']);
    Route::delete('service/delete', [AdminServiceController::class, 'destroy']);

//    Route::resource('faq', 'FAQController', ['only' => ['index', 'store', 'edit', 'update', 'show']]);
    Route::put('faq/status/update', [AdminFAQController::class, 'statusUpdate']);
    Route::delete('faq/delete', [AdminFAQController::class, 'destroy']);
});

Route::group(['prefix' => 'partner', 'as' => 'provider.', 'namespace' => 'Api\V1\Provider', 'middleware' => ['auth:api', 'actch:provider_app']], function () {
    Route::get('task', [ProviderServiceController::class, 'index']); // index
    Route::get('task/{id}', [ProviderServiceController::class, 'show']); // show
    Route::put('task/state/modify', [ProviderServiceController::class, 'statusUpdate']);
    Route::get('task/records/lookup', [ProviderServiceController::class, 'search']);
    Route::get('task/feedback/{service_id}', [ProviderServiceController::class, 'review']);
    Route::get('task/records/child-group-wise', [ProviderServiceController::class, 'servicesBySubcategory']);

    Route::get('task-submission', [ServiceRequestController::class, 'index']);
    Route::post('task-submission', [ServiceRequestController::class, 'makeRequest']);

    Route::post('feedback-response', [ProviderServiceController::class, 'reviewReply']);

    Route::get('questions', [ProviderFAQController::class, 'index']); // index
});

Route::group(['prefix' => 'technician', 'as' => 'serviceman.', 'namespace' => 'Api\V1\Service', 'middleware' => ['auth:api']], function () {
    Route::get('task/records/child-group-wise', [ServicemanServiceController::class, 'servicesBySubcategory']);

});

Route::group(['prefix' => 'client', 'as' => 'customer.', 'namespace' => 'Api\V1\Customer'], function () {

    Route::group(['prefix' => 'saved', 'as' => 'favorite.', 'middleware' => ['auth:api']], function () {
        Route::get('task-index', [FavoriteServiceController::class, 'list']);
        Route::post('task', [FavoriteServiceController::class, 'store']);
        Route::post('task-remove/{service_id}', [FavoriteServiceController::class, 'destroy']);
    });

    Route::group(['prefix' => 'task'], function () {
        Route::get('/', [CustomerServiceController::class, 'index']);
        Route::post('lookup', [CustomerServiceController::class, 'search']);
        Route::get('lookup-hints', [CustomerServiceController::class, 'searchSuggestions']);
        Route::get('lookup/suggested', [CustomerServiceController::class, 'searchRecommended']);
        Route::get('hot', [CustomerServiceController::class, 'popular']);
        Route::get('suggested', [CustomerServiceController::class, 'recommended']);
        Route::get('rising', [CustomerServiceController::class, 'trending']);
        Route::get('last-seen', [CustomerServiceController::class, 'recentlyViewed'])->middleware('auth:api');
        Route::get('deals', [CustomerServiceController::class, 'offers']);
        Route::get('info/{slug}', [CustomerServiceController::class, 'show']);
        Route::get('feedback/{service_id}', [CustomerServiceController::class, 'review']);
        //Route::get('child-group/{sub_category_id}', [CustomerServiceController::class, 'servicesBySubcategory']);
        Route::get('child-group/{slug}', [CustomerServiceController::class, 'servicesBySubcategory']);

        Route::post('zone-availability', [CustomerServiceController::class, 'serviceAreaAvailability']);

        Route::group(['prefix' => 'submission'], function () {
            Route::post('raise', [CustomerServiceController::class, 'makeRequest'])->middleware('auth:api');
            Route::get('index', [CustomerServiceController::class, 'requestList'])->middleware('auth:api');
        });
    });

    Route::get('latest-query-terms', [CustomerServiceController::class, 'recentlySearchedKeywords'])->middleware('auth:api');
    Route::get('drop-query-terms', [CustomerServiceController::class, 'removeSearchedKeywords'])->middleware('auth:api');
});
