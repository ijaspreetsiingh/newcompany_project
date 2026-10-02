<?php

use Illuminate\Support\Facades\Route;
use Modules\CategoryManagement\Http\Controllers\Api\V1\Customer\CategoryController;
use Modules\CategoryManagement\Http\Controllers\Api\V1\Customer\SubCategoryController;
use Modules\CategoryManagement\Http\Controllers\Api\V1\Admin\CategoryController as AdminCategoryController;
use Modules\CategoryManagement\Http\Controllers\Api\V1\Admin\SubCategoryController as AdminSubCategoryController;
use Modules\CategoryManagement\Http\Controllers\Api\V1\Provider\CategoryController as ProviderCategoryController;

Route::group(['prefix' => 'admin', 'as'=>'admin.', 'namespace' => 'Api\V1\Admin', 'middleware'=>['auth:api']], function () {
//    Route::resource('category', 'CategoryController', ['only' => ['index', 'store', 'edit', 'update']]);
    Route::put('category/status/update', [AdminCategoryController::class, 'status_update']);
    Route::delete('category/delete', [AdminCategoryController::class, 'destroy']);
    Route::get('category/search', [AdminCategoryController::class, 'search']);
    Route::get('category/childes', [AdminCategoryController::class, 'childes']);

//    Route::resource('sub-category', 'SubCategoryController', ['only' => ['index', 'store', 'edit', 'update']]);
    Route::put('sub-category/status/update', [AdminSubCategoryController::class, 'status_update']);
    Route::delete('sub-category/delete', [AdminSubCategoryController::class, 'destroy']);
});


Route::group(['prefix' => 'partner', 'as'=>'provider.', 'namespace' => 'Api\V1\Provider', 'middleware' => ['auth:api', 'actch:provider_app']], function () {
    Route::get('child-groups', [ProviderCategoryController::class, 'subCategory']);
    Route::group(['prefix' => 'group', 'as'=>'category.'], function () {
        Route::get('/', [ProviderCategoryController::class, 'index']); // index
        Route::get('subgroups', [ProviderCategoryController::class, 'childes']);
    });
});


Route::group(['prefix' => 'client', 'as'=>'customer.', 'namespace' => 'Api\V1\Customer'], function () {
    Route::group(['prefix' => 'group', 'as'=>'category.'], function () {
        Route::get('/', [CategoryController::class, 'index']);
        Route::get('subgroups', [CategoryController::class, 'childes']);
    });
    Route::get('sub-categories', [SubCategoryController::class, 'index']);
    Route::get('spotlight-groups', [CategoryController::class, 'featured']);
});
