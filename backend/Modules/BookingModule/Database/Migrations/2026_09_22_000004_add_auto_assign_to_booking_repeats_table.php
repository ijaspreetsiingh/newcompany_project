<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class AddAutoAssignToBookingRepeatsTable extends Migration
{
    /**
     * bookings ki hi copy hai — repeat bookings ke liye same flow chahiye
     *
     * @return void
     */
    public function up()
    {
        Schema::table('booking_repeats', function (Blueprint $table) {
            $table->boolean('auto_assigned')->default(0);
            $table->timestamp('auto_assign_expires_at')->nullable();
            $table->uuid('assigned_provider_id')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('booking_repeats', function (Blueprint $table) {
            $table->dropColumn(['auto_assigned', 'auto_assign_expires_at', 'assigned_provider_id']);
        });
    }
}
