<?php

namespace Modules\AdminModule\Http\Middleware;

use Brian2694\Toastr\Facades\Toastr;
use Closure;
use Illuminate\Http\Request;

class AdminMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Closure $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        $isApi = $request->is('api/*') || $request->expectsJson();

        if (auth()->check() && in_array(auth()->user()->user_type, ADMIN_USER_TYPES)) {

            $user = auth()->user();

            if ($user->user_type === 'admin-employee') {
                if ($user->is_active == 0) {
                    if ($isApi) {
                        return response()->json(response_formatter(ACCESS_DENIED), 403);
                    }
                    auth()->guard('web')->logout();
                    Toastr::warning(translate('Your account is inactive. Please contact the admin.'));
                    return redirect('admin/auth/login');
                }

                $role = $user->roles->first();
                if (!$role || $role->is_active == 0) {
                    if ($isApi) {
                        return response()->json(response_formatter(ACCESS_DENIED), 403);
                    }
                    auth()->guard('web')->logout();
                    Toastr::warning(translate('Your role is inactive or not assigned. Please contact the admin.'));
                    return redirect('admin/auth/login');
                }
            }

            return $next($request);
        }

        // SECURITY: API admin routes par JSON 403 (audit: koi bhi token se
        // payment secrets/user list access ho raha tha).
        if ($isApi) {
            return response()->json(response_formatter(ACCESS_DENIED), 403);
        }

        Toastr::info(ACCESS_DENIED['message']);
        return redirect('admin/auth/login');
    }
}
