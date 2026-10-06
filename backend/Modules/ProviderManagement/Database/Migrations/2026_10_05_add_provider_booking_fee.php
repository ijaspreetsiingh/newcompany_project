<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Per-provider payment settings (wizard Step 4 "Independent Commission"):
     *  - booking_fee: flat booking fee charged to customer (replaces global
     *    booking_additional_charge for this provider when independent mode ON)
     *  - tax_percent: flat tax % for this provider's services (overrides each
     *    service's own tax when set; NULL = keep per-service tax)
     *  - allowed_payment_methods: JSON array of payment method keys allowed at
     *    checkout for this provider (NULL/[] = all methods allowed)
     *
     * NOTE: legacy `commission_percentage` column is intentionally NOT renamed —
     * readers (Helpers::providerCommissionPercentage, Provider entity, admin
     * views) still use the old name.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('providers', function (Blueprint $table) {
            if (!Schema::hasColumn('providers', 'booking_fee')) {
                $table->decimal('booking_fee', 10, 2)->default(0)->comment('Booking fee charged to customer for this provider');
            }
            if (!Schema::hasColumn('providers', 'tax_percent')) {
                $table->decimal('tax_percent', 8, 4)->nullable()->comment('Tax % for this provider services; NULL = use service tax');
            }
            if (!Schema::hasColumn('providers', 'allowed_payment_methods')) {
                $table->text('allowed_payment_methods')->nullable()->comment('JSON array of allowed payment method keys; NULL = all');
            }
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('providers', function (Blueprint $table) {
            if (Schema::hasColumn('providers', 'allowed_payment_methods')) {
                $table->dropColumn('allowed_payment_methods');
            }
            if (Schema::hasColumn('providers', 'tax_percent')) {
                $table->dropColumn('tax_percent');
            }
            if (Schema::hasColumn('providers', 'booking_fee')) {
                $table->dropColumn('booking_fee');
            }
        });
    }
};
