<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Guard: only add unique index on subscribed_services if it does not exist yet.
        if (Schema::hasTable('subscribed_services') && ! Schema::hasIndex('subscribed_services', 'unique_zone_sub_category')) {
            Schema::table('subscribed_services', function (Blueprint $table) {
                $table->unique(['zone_id', 'sub_category_id'], 'unique_zone_sub_category');
            });
        }

        // Guard: unique (zone_id, category_id) only if the existing data has no duplicate groups.
        if (Schema::hasTable('subscribed_services') && ! Schema::hasIndex('subscribed_services', 'unique_zone_category')) {
            $hasDuplicates = DB::table('subscribed_services')
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

    public function down(): void
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
};
