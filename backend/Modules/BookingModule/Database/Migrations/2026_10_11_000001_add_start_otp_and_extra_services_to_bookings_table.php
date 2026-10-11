<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class AddStartOtpAndExtraServicesToBookingsTable extends Migration
{
    /**
     * 1) Serviceman reach OTP: serviceman customer ke 300m radius me aaye to
     *    start OTP generate hota hai (customer app me dikhta hai + notification).
     *    Serviceman ko OTP verify karke hi 'ongoing' karne ki permission milegi.
     *
     * 2) Extra services: serviceman on-site customer ki extra chije add karke
     *    custom price set kar sakta hai — final bill/invoice me include hogi.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->string('start_otp', 10)->nullable()->comment('serviceman arrival OTP (start ke liye)');
            $table->timestamp('start_otp_generated_at')->nullable();
            $table->timestamp('serviceman_reached_at')->nullable();
        });

        Schema::table('booking_repeats', function (Blueprint $table) {
            $table->string('start_otp', 10)->nullable();
            $table->timestamp('start_otp_generated_at')->nullable();
            $table->timestamp('serviceman_reached_at')->nullable();
        });

        Schema::create('booking_extra_services', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('booking_id');
            $table->uuid('serviceman_id')->nullable();
            $table->string('name', 120)->comment('custom/external work ka naam');
            $table->decimal('price', 12, 2)->default(0);
            $table->integer('quantity')->default(1);
            $table->string('type', 20)->default('custom')->comment('custom | external');
            $table->timestamps();

            $table->index('booking_id');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('booking_extra_services');

        Schema::table('bookings', function (Blueprint $table) {
            $table->dropColumn(['start_otp', 'start_otp_generated_at', 'serviceman_reached_at']);
        });

        Schema::table('booking_repeats', function (Blueprint $table) {
            $table->dropColumn(['start_otp', 'start_otp_generated_at', 'serviceman_reached_at']);
        });
    }
}
