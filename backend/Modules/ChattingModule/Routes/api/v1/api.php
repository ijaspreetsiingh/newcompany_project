<?php

use Illuminate\Support\Facades\Route;
use Modules\ChattingModule\Http\Controllers\Api\V1\Admin\ChattingController as AdminChattingController;
use Modules\ChattingModule\Http\Controllers\Api\V1\Customer\ChattingController as CustomerChattingController;
use Modules\ChattingModule\Http\Controllers\Api\V1\Provider\ChattingController as ProviderChattingController;
use Modules\ChattingModule\Http\Controllers\Api\V1\Serviceman\ChattingController as ServicemanChattingController;
use Modules\ChattingModule\Http\Controllers\Api\V1\GlobalChattingController;

Route::group(['prefix' => 'admin', 'as' => 'admin.', 'namespace' => 'Api\V1\Admin', 'middleware' => ['auth:api']], function () {
    Route::group(['prefix' => 'chat'], function () {
        Route::get('channel-list', [AdminChattingController::class, 'channelList']);
        Route::get('referenced-channel-list', [AdminChattingController::class, 'referencedChannelList']);
        Route::post('create-channel', [AdminChattingController::class, 'createChannel']);
        Route::post('send-message', [AdminChattingController::class, 'sendMessage']);
        Route::get('conversation', [AdminChattingController::class, 'conversation']);
    });
});

Route::group(['prefix' => 'client', 'as' => 'customer.', 'namespace' => 'Api\V1\Customer', 'middleware' => ['auth:api']], function () {
    Route::group(['prefix' => 'inbox'], function () {
        Route::get('thread-index', [CustomerChattingController::class, 'channelList']);
        Route::post('thread-lookup', [CustomerChattingController::class, 'channelListSearch']);
        Route::get('referenced-channel-list', [CustomerChattingController::class, 'referencedChannelList']);
        Route::post('open-thread', [CustomerChattingController::class, 'createChannel']);
        Route::post('transmit-note', [CustomerChattingController::class, 'sendMessage']);
        Route::get('thread', [CustomerChattingController::class, 'conversation']);
    });
});

Route::group(['prefix' => 'partner', 'as' => 'provider.', 'namespace' => 'Api\V1\Provider', 'middleware' => ['auth:api', 'actch:provider_app']], function () {
    Route::group(['prefix' => 'inbox'], function () {
        Route::get('thread-index', [ProviderChattingController::class, 'channelList']);
        Route::post('thread-lookup', [ProviderChattingController::class, 'channelListSearch']);
        Route::get('linked-thread-index', [ProviderChattingController::class, 'referencedChannelList']);
        Route::post('open-thread', [ProviderChattingController::class, 'createChannel']);
        Route::post('transmit-note', [ProviderChattingController::class, 'sendMessage']);
        Route::get('thread', [ProviderChattingController::class, 'conversation']);
    });
});

Route::group(['prefix' => 'technician', 'as' => 'serviceman.', 'namespace' => 'Api\V1\Serviceman', 'middleware' => ['auth:api', 'actch:serviceman_app']], function () {
    Route::group(['prefix' => 'inbox'], function () {
        Route::get('thread-index', [ServicemanChattingController::class, 'channelList']);
        Route::post('thread-lookup', [ServicemanChattingController::class, 'channelListSearch']);
        Route::get('linked-thread-index', [ServicemanChattingController::class, 'referencedChannelList']);
        Route::post('open-thread', [ServicemanChattingController::class, 'createChannel']);
        Route::post('transmit-note', [ServicemanChattingController::class, 'sendMessage']);
        Route::get('thread', [ServicemanChattingController::class, 'conversation']);
    });
});

Route::group(['namespace' => 'Api\V1', 'middleware' => ['auth:api']], function () {
    Route::group(['prefix' => 'chat'], function () {
        Route::get('channel-list', [GlobalChattingController::class, 'channelList']);
        Route::get('referenced-channel-list', [GlobalChattingController::class, 'referencedChannelList']);
        Route::post('create-channel', [GlobalChattingController::class, 'createChannel']);
        Route::post('send-message', [GlobalChattingController::class, 'sendMessage']);
        Route::get('conversation', [GlobalChattingController::class, 'conversation']);
        Route::get('unread-conversation', [GlobalChattingController::class, 'unreadConversationCount']);
    });
});
