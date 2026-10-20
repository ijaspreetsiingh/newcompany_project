<?php

namespace App\Http\Controllers;

use Illuminate\Http\RedirectResponse;

/**
 * Sabse pehle route:cache fail ho raha tha kyunki routes/web.php me
 * Route::fallback(closure) tha (Laravel closure route cache nahi kar sakta).
 * Is controller ke through fallback ab cacheable hai.
 */
class FallbackController extends Controller
{
    public function __invoke(): RedirectResponse
    {
        return redirect('admin/auth/login');
    }
}
