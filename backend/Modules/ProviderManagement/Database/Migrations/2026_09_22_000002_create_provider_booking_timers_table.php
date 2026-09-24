<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateProviderBookingTimersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('provider_booking_timers', function (Blueprint $table) {
            $table->id();
            $table->uuid('booking_id')->index();
            $table->uuid('provider_id')->index();
            $table->enum('status', ['pending', 'accepted', 'ignored', 'expired', 'auto_approved'])->default('pending');
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();

            $table->foreign('booking_id')->references('id')->on('bookings')->onDelete('cascade');
            $table->foreign('provider_id')->references('id')->on('providers')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('provider_booking_timers');
    }
}
