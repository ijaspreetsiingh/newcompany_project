<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Login/lookup: WHERE email = ? ab tak full-table scan tha (sirf PRIMARY index)
        // Duplicate email rows (guests etc.) ho to unique migration fail hoti —
        // pehle check, warna plain index.
        $hasDupEmail = DB::selectOne(
            "SELECT COUNT(*) AS c FROM (SELECT email FROM users WHERE email IS NOT NULL AND email != '' GROUP BY email HAVING COUNT(*) > 1) d"
        );
        if ((int) ($hasDupEmail->c ?? 0) === 0) {
            try {
                Schema::table('users', function (Blueprint $table) {
                    $table->unique('email', 'users_email_unique_idx');
                });
            } catch (\Throwable $e) {
                Schema::table('users', function (Blueprint $table) {
                    $table->index('email', 'users_email_idx');
                });
            }
        } else {
            Schema::table('users', function (Blueprint $table) {
                $table->index('email', 'users_email_idx');
            });
        }

        // OTP / phone login lookup
        Schema::table('users', function (Blueprint $table) {
            $table->index('phone', 'users_phone_idx');
        });

        // W2.10 bounding-box geo filter (findNearestServicemen) — composite index
        Schema::table('users', function (Blueprint $table) {
            $table->index(['current_lat', 'current_lng'], 'users_latlng_idx');
        });

        // Booking list filters
        Schema::table('users', function (Blueprint $table) {
            $table->index(['user_type', 'is_active'], 'users_type_active_idx');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('users_email_unique_idx');
        });
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('users_email_idx');
        });
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('users_phone_idx');
        });
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('users_latlng_idx');
        });
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('users_type_active_idx');
        });
    }
};
