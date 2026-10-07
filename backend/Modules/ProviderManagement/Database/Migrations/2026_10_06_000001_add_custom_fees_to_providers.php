<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Per-provider fee override (wizard Step 4, "Independent Commission" ke neeche):
     *  - custom_fees_enabled: 1 = is provider par sirf uske apne fee lagenge
     *    (booking_fee, chahe 0 ho = koi fee nahi). 0/null = global business
     *    settings wale fee apply honge (legacy behaviour).
     *  - booking_fee_label: customer checkout par dikhne wala fee label
     *    (NULL/empty = global additional_charge_label_name).
     *
     * Backfill: jinke booking_fee pehle se > 0 hai unke liye toggle ON rakha
     * jata hai taaki unka configured fee jaisa pehle chal raha tha waise hi chalta
     * rahe (behaviour change na ho).
     *
     * @return void
     */
    public function up()
    {
        Schema::table('providers', function (Blueprint $table) {
            if (!Schema::hasColumn('providers', 'custom_fees_enabled')) {
                $table->tinyInteger('custom_fees_enabled')->default(0)->after('booking_fee')
                    ->comment('1 = use this provider\'s own fees; 0 = global fees');
            }
            if (!Schema::hasColumn('providers', 'booking_fee_label')) {
                $table->string('booking_fee_label', 191)->nullable()->after('custom_fees_enabled')
                    ->comment('Customer facing fee label; NULL = global label');
            }
        });

        DB::table('providers')->where('booking_fee', '>', 0)->update(['custom_fees_enabled' => 1]);
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('providers', function (Blueprint $table) {
            if (Schema::hasColumn('providers', 'booking_fee_label')) {
                $table->dropColumn('booking_fee_label');
            }
            if (Schema::hasColumn('providers', 'custom_fees_enabled')) {
                $table->dropColumn('custom_fees_enabled');
            }
        });
    }
};
