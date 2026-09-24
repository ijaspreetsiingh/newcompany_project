<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class AddServicemanAutoAssignToBookingsTable extends Migration
{
    /**
     * Serviceman accept/reject flow ke liye columns
     *
     * @return void
     */
    public function up()
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->timestamp('serviceman_assign_expires_at')->nullable()->comment('current serviceman timer deadline');
        });

        Schema::table('booking_repeats', function (Blueprint $table) {
            $table->timestamp('serviceman_assign_expires_at')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropColumn('serviceman_assign_expires_at');
        });

        Schema::table('booking_repeats', function (Blueprint $table) {
            $table->dropColumn('serviceman_assign_expires_at');
        });
    }
}
