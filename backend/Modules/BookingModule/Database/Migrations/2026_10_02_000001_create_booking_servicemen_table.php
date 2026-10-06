<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateBookingServicemenTable extends Migration
{
    /**
     * Booking <-> serviceman (team) assignment ke liye pivot table.
     * Ek booking me 1 se zyada servicemen ho sakte hain (team).
     * status: pending | accepted | rejected | expired
     *
     * @return void
     */
    public function up()
    {
        Schema::create('booking_servicemen', function (Blueprint $table) {
            $table->id();
            $table->uuid('booking_id');
            $table->uuid('serviceman_id');
            $table->string('status', 20)->default('pending');
            $table->timestamp('expires_at')->nullable()->comment('is slot ki accept deadline');
            $table->timestamps();

            $table->index('booking_id');
            $table->index('serviceman_id');
            $table->unique(['booking_id', 'serviceman_id']);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('booking_servicemen');
    }
}
