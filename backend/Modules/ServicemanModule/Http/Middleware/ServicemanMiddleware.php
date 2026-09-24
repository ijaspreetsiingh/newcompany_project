<?php

namespace Modules\ServicemanModule\Http\Middleware;

use Brian2694\Toastr\Facades\Toastr;
use Closure;
use Illuminate\Http\Request;

class ServicemanMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        if (auth()->check() && auth()->user()->user_type === 'provider-serviceman') {
            return $next($request);
        }
        Toastr::info(translate(ACCESS_DENIED['message']));
        return redirect('serviceman/auth/login');
    }
}
