<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            // SPAM-FIX: provider ko "serviceman_assign" sirf pehli baar notify
            // karne ke liye (customer ke serviceman_assign_customer_notified ki
            // tarah). Rotation me har naye serviceman par provider ko dubara
            // push nahi jaana chahiye.
            if (!Schema::hasColumn('bookings', 'serviceman_assign_provider_notified')) {
                $table->tinyInteger('serviceman_assign_provider_notified')->default(0)->after('serviceman_assign_customer_notified');
            }
        });
    }

    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            if (Schema::hasColumn('bookings', 'serviceman_assign_provider_notified')) {
                $table->dropColumn('serviceman_assign_provider_notified');
            }
        });
    }
};
