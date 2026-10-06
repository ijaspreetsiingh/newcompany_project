<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('providers', function (Blueprint $table) {
            if (!Schema::hasColumn('providers', 'independent_mode')) {
                $table->tinyInteger('independent_mode')->default(0)->after('auto_assign_wait_time');
            }
            if (!Schema::hasColumn('providers', 'admin_commission_percent')) {
                $table->double('admin_commission_percent', 8, 4)->default(0)->after('independent_mode');
            }
            if (!Schema::hasColumn('providers', 'provider_commission_percent')) {
                $table->double('provider_commission_percent', 8, 4)->default(0)->after('admin_commission_percent');
            }
            if (!Schema::hasColumn('providers', 'platform_fee_amount')) {
                $table->decimal('platform_fee_amount', 24, 2)->default(0)->after('provider_commission_percent');
            }
            if (!Schema::hasColumn('providers', 'platform_fee_label')) {
                $table->string('platform_fee_label', 191)->nullable()->after('platform_fee_amount');
            }
        });

        Schema::table('booking_details_amounts', function (Blueprint $table) {
            if (!Schema::hasColumn('booking_details_amounts', 'provider_commission')) {
                $table->decimal('provider_commission', 24, 2)->default(0)->after('admin_commission');
            }
            if (!Schema::hasColumn('booking_details_amounts', 'serviceman_earning')) {
                $table->decimal('serviceman_earning', 24, 2)->default(0)->after('provider_earning');
            }
            if (!Schema::hasColumn('booking_details_amounts', 'platform_fee')) {
                $table->decimal('platform_fee', 24, 2)->default(0)->after('serviceman_earning');
            }
        });
    }

    public function down(): void
    {
        Schema::table('providers', function (Blueprint $table) {
            $table->dropColumn([
                'independent_mode', 'admin_commission_percent', 'provider_commission_percent',
                'platform_fee_amount', 'platform_fee_label',
            ]);
        });

        Schema::table('booking_details_amounts', function (Blueprint $table) {
            $table->dropColumn(['provider_commission', 'serviceman_earning', 'platform_fee']);
        });
    }
};
