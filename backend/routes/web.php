<?php

use App\Http\Controllers\LandingController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\InstallController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('lang/{locale}', [LandingController::class, 'lang'])->name('lang');
Route::get('/', [LandingController::class, 'home'])->name('home');
Route::get('page/contact-us', [LandingController::class, 'contactUs'])->name('page.contact-us');

Route::get('business-page/{slug}', [LandingController::class, 'dynamicPage'])->name('business.page.dynamic');

Route::get('maintenance-mode', [LandingController::class, 'maintenanceMode'])->name('maintenance-mode');
Route::post('subscribe-newsletter',[LandingController::class, 'subscribeNewsletter'])->name('subscribe-newsletter');

Route::fallback(function () {
    return redirect('admin/auth/login');
});

Route::get('test', function () {
    //
});



