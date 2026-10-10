<?php

namespace Modules\CustomerModule\Http\Controllers;

use Illuminate\Contracts\Support\Renderable;
use Illuminate\Routing\Controller;

class PagesController extends Controller
{
    private function pageData(string $key)
    {
        $app = request()->query('app');
        if (in_array($app, ['user', 'provider', 'serviceman'], true)) {
            $override = business_config($key . '_' . $app, 'pages_setup');
            if ($override && !empty($override->live_values)) {
                return $override;
            }
        }

        return business_config($key, 'pages_setup');
    }

    /**
     * Display a listing of the resource.
     * @return Renderable
     */
    public function aboutUs(): Renderable
    {
        $page_data = $this->pageData('about_us');
        return view('customermodule::index', compact('page_data'));
    }

    /**
     * Display a listing of the resource.
     * @return Renderable
     */
    public function privacyPolicy(): Renderable
    {
        $page_data = $this->pageData('privacy_policy');
        return view('customermodule::index', compact('page_data'));
    }

    /**
     * Display a listing of the resource.
     * @return Renderable
     */
    public function termsAndConditions(): Renderable
    {
        $page_data = $this->pageData('terms_and_conditions');
        return view('customermodule::index', compact('page_data'));
    }

    /**
     * Display a listing of the resource.
     * @return Renderable
     */
    public function refundPolicy(): Renderable
    {
        $page_data = $this->pageData('refund_policy');
        return view('customermodule::index', compact('page_data'));
    }

    /**
     * Display a listing of the resource.
     * @return Renderable
     */
    public function returnPolicy(): Renderable
    {
        $page_data = $this->pageData('return_policy');
        return view('customermodule::index', compact('page_data'));
    }

    /**
     * Display a listing of the resource.
     * @return Renderable
     */
    public function cancellationPolicy(): Renderable
    {
        $page_data = $this->pageData('cancellation_policy');
        return view('customermodule::index', compact('page_data'));
    }
}
