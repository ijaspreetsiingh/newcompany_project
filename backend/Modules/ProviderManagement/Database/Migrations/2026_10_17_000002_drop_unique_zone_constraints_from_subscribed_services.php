<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    /**
     * Business rule: ek zone + same category me DO provider ho sakte hain,
     * par sirf ACTIVE wala reality me present hoga (dusra inactive rukega).
     * Isliye subscribed_services par lage unique (zone_id, sub_category_id)
     * aur (zone_id, category_id) constraints hata dein, warna naye (inactive)
     * provider ki assignment rows database reject kar dega.
     *
     * Exclusivity ab application level par enforce hogi: sirf ACTIVE provider
     * ek zone+category me allowed hai.
     *
     * @return void
     */
    public function up(): void
    {
        if (Schema::hasTable('subscribed_services') && Schema::hasIndex('subscribed_services', 'unique_zone_sub_category')) {
            Schema::table('subscribed_services', function (Blueprint $table) {
                $table->dropUnique('unique_zone_sub_category');
            });
        }

        if (Schema::hasTable('subscribed_services') && Schema::hasIndex('subscribed_services', 'unique_zone_category')) {
            Schema::table('subscribed_services', function (Blueprint $table) {
                $table->dropUnique('unique_zone_category');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('subscribed_services') && ! Schema::hasIndex('subscribed_services', 'unique_zone_sub_category')) {
            $hasDuplicates = \Illuminate\Support\Facades\DB::table('subscribed_services')
                ->select('zone_id', 'sub_category_id')
                ->groupBy('zone_id', 'sub_category_id')
                ->havingRaw('COUNT(*) > 1')
                ->exists();

            if (! $hasDuplicates) {
                Schema::table('subscribed_services', function (Blueprint $table) {
                    $table->unique(['zone_id', 'sub_category_id'], 'unique_zone_sub_category');
                });
            }
        }

        if (Schema::hasTable('subscribed_services') && ! Schema::hasIndex('subscribed_services', 'unique_zone_category')) {
            $hasDuplicates = \Illuminate\Support\Facades\DB::table('subscribed_services')
                ->select('zone_id', 'category_id')
                ->groupBy('zone_id', 'category_id')
                ->havingRaw('COUNT(*) > 1')
                ->exists();

            if (! $hasDuplicates) {
                Schema::table('subscribed_services', function (Blueprint $table) {
                    $table->unique(['zone_id', 'category_id'], 'unique_zone_category');
                });
            }
        }
    }
};
