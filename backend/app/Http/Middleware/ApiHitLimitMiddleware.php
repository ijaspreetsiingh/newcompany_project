<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\RateLimiter;

class ApiHitLimitMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param Request $request
     * @param Closure(Request): (Response|RedirectResponse) $next
     * @param string $attempt_type
     * @param int $hit_count
     * @return JsonResponse
     */
    public function handle(Request $request, Closure $next, string $attempt_type = "normal", int $hit_count = 10)
    {
        // Pehle ye Cache::has (default/redis) vs Cache::store('file') mismatch par
        // fail-open tha aur key bina prefix ke IP/user id thi (cross-key collision
        // ka risk). Ab same RateLimiter store + prefixed key.
        $userId = auth('api')->id();
        $key = 'api_hit:' . $attempt_type . ':' . ($userId ?: $request->ip());

        if (RateLimiter::tooManyAttempts($key, max(1, $hit_count))) {
            return response()->json(TOO_MANY_ATTEMPT_403, 429);
        }
        RateLimiter::hit($key, 10);

        return $next($request);
    }
}
