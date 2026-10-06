<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('services', function (Blueprint $table) {
            if (!Schema::hasColumn('services', 'provider_id')) {
                $table->uuid('provider_id')->nullable()->after('id')->index();
            }
            if (!Schema::hasColumn('services', 'zone_id')) {
                $table->uuid('zone_id')->nullable()->after('provider_id')->index();
            }
            if (!Schema::hasColumn('services', 'parent_service_id')) {
                $table->uuid('parent_service_id')->nullable()->after('zone_id')->index();
            }
            if (!Schema::hasColumn('services', 'approval_status')) {
                $table->string('approval_status', 20)->default('approved')->after('parent_service_id');
            }
        });

        DB::table('services')->update(['approval_status' => 'approved']);
    }

    public function down(): void
    {
        Schema::table('services', function (Blueprint $table) {
            foreach (['provider_id', 'zone_id', 'parent_service_id', 'approval_status'] as $column) {
                if (Schema::hasColumn('services', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
