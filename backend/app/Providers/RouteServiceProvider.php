<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Foundation\Support\Providers\RouteServiceProvider as ServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Facades\Route;

class RouteServiceProvider extends ServiceProvider
{
    /**
     * The path to the "home" route for your application.
     *
     * This is used by Laravel authentication to redirect users after login.
     *
     * @var string
     */
    public const HOME = '/home';

    /**
     * The controller namespace for the application.
     *
     * When present, controller route declarations will automatically be prefixed with this namespace.
     *
     * @var string|null
     */
    // protected $namespace = 'App\\Http\\Controllers';

    /**
     * Define your route model bindings, pattern filters, etc.
     *
     * @return void
     */
    public function boot()
    {
        $this->configureRateLimiting();

        $this->routes(function () {
            Route::prefix('api/v1')
                ->middleware('api')
                ->namespace($this->namespace)
                ->group(base_path('routes/api/v1/api.php'));

            Route::middleware('web')
                ->namespace($this->namespace)
                ->group(base_path('routes/web.php'));
        });
    }

    /**
     * Configure the rate limiters for the application.
     *
     * @return void
     */
    protected function configureRateLimiting()
    {
        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute(180)->by(optional($request->user())->id ?: $request->ip());
        });

        // Login endpoints: normal users ko block na kare, brute-force ko block kare.
        RateLimiter::for('login', function (Request $request) {
            $identifier = strtolower((string) ($request->input('email_or_phone')
                ?? $request->input('email')
                ?? $request->input('phone')
                ?? $request->input('phone_number')
                ?? ''));

            return [
                Limit::perMinute(5)->by('login-min:' . $request->ip() . ':' . $identifier),
                Limit::perHour(25)->by('login-hour:' . $request->ip() . ':' . $identifier),
            ];
        });

        // Public geocoding/routing proxies: Nominatim/OSRM fair-use protection.
        RateLimiter::for('geo', function (Request $request) {
            return [
                Limit::perMinute(30)->by('geo-min:' . $request->ip()),
                Limit::perDay(1000)->by('geo-day:' . $request->ip()),
            ];
        });

        // Payment startup / verification endpoints.
        RateLimiter::for('payment', function (Request $request) {
            return Limit::perMinute(20)->by('pay:' . $request->ip());
        });
    }
}
