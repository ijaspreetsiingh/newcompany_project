<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Booking recheck (dubara inspection) ke liye table.
     *
     * Customer completed booking ke 15 din tak recheck raise kar sakta hai.
     * Recheck raise hote hi uska serviceman (jo kaam kar gaya tha) wapas
     * check karne jayega. Recheck state 15 din me auto-expire ho jayegi.
     *
     * status: requested | in_progress | completed | expired
     *
     * @return void
     */
    public function up()
    {
        Schema::create('booking_rechecks', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('booking_id');
            $table->uuid('customer_id');
            $table->uuid('provider_id')->nullable();
            $table->uuid('serviceman_id')->nullable()->comment('jo serviceman pehle kaam kar gaya tha');
            $table->string('status', 20)->default('requested');
            $table->text('reason')->nullable()->comment('customer ki problem');
            $table->text('serviceman_note')->nullable()->comment('recheck ke baad serviceman ki report');
            $table->timestamp('requested_at')->nullable();
            $table->timestamp('due_at')->nullable()->comment('15 din ka deadline');
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->index('booking_id');
            $table->index('customer_id');
            $table->index('provider_id');
            $table->index('serviceman_id');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('booking_rechecks');
    }
};
