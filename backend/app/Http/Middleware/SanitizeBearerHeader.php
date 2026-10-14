<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

/**
 * Flutter/Dart apps guest mode me token null hone par literal "Bearer null"
 * (ya JS-style "Bearer undefined") header bhej dete hain — auth guard usko
 * real token samajh kar crash karta tha aur poori guest journey 500 ho jaati
 * thi (basket/place/transmit). Garbage bearer ko absent treat karo.
 */
class SanitizeBearerHeader
{
    public function handle(Request $request, Closure $next)
    {
        $auth = $request->header('Authorization', '');
        if ($auth !== '') {
            $normalized = strtolower(trim(preg_replace('/\s+/', ' ', $auth)));
            if (in_array($normalized, ['bearer null', 'bearer undefined', 'bearer'], true)) {
                $request->headers->remove('Authorization');
            }
        }

        return $next($request);
    }
}
