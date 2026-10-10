<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class AddIsOnDutyToServicemenTable extends Migration
{
    /**
     * On-duty toggle: serviceman app se "Available for jobs" ON/OFF.
     * Auto-assign sirf on-duty servicemen ko karta hai.
     * Default 1 — existing servicemen assignment milte rahein.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('servicemen', function (Blueprint $table) {
            $table->tinyInteger('is_on_duty')->default(1)->comment('1=ready for jobs, 0=offline');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('servicemen', function (Blueprint $table) {
            $table->dropColumn('is_on_duty');
        });
    }
}
