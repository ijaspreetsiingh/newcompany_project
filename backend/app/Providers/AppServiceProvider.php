<?php

namespace App\Providers;

use App\Traits\ActivationClass;
use Illuminate\Foundation\AliasLoader;
use Illuminate\Http\Request;
use Illuminate\Pagination\Paginator;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Redirect;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Config;
use Laravel\Passport\Passport;
use Modules\AddonModule\Traits\AddonHelper;
use Modules\BusinessSettingsModule\Entities\BusinessSettings;

ini_set('memory_limit', '512M');

class AppServiceProvider extends ServiceProvider
{
    use ActivationClass, AddonHelper;

    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
    }

    /**
     * Bootstrap any application services.
     *
     */
    public function boot(Request $request)
    {
        if(env('FORCE_HTTPS', false) || env('RAILWAY_PUBLIC_DOMAIN')) {
            \URL::forceScheme('https');
        }

        // Directory scans over the Windows→Docker bind-mount are ~50x slower per file
        // (measured: Modules tree = 18s vs native vendor volume = 369ms). These two scan
        // the Modules tree on every request (~6.7s). Cache forever; cleared on cache:clear
        // (addon install/remove is rare — run `php artisan cache:clear` after changing addons).
        Config::set('addon_admin_routes', Cache::rememberForever(
            'addon_admin_routes',
            fn () => $this->get_addon_admin_routes()
        ));
        Config::set('get_payment_publish_status', Cache::rememberForever(
            'get_payment_publish_status',
            fn () => $this->get_payment_publish_status()
        ));

        try {
            Config::set('default_pagination', 25);
            Paginator::useBootstrap();
        } catch (\Exception $ex) {
            info($ex);
        }
    }

    protected function registerAliases(array $aliases): void
    {
        $loader = AliasLoader::getInstance();

        foreach ($aliases as $alias => $class) {
            if (class_exists($class)) {
                $loader->alias($alias, $class);
            }
        }
    }
}
