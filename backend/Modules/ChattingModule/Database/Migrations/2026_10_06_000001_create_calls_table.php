<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * In-app voice & video call history + live call state.
     *
     * status lifecycle:
     *   ringing    -> callee ke paas invite gaya (ring_expires_at tak)
     *   answered   -> callee ne accept kiya (answered_at, duration tick hota hai)
     *   ended      -> dono ne connected rehkar hang-up kiya (ended_at, duration)
     *   rejected   -> callee ne call kaat di (ringing ke dauran)
     *   cancelled  -> caller ne ring ke dauran hi call kaat di
     *   missed     -> ring timeout (45s) tak kisi ne respond nahi kiya
     *
     * @return void
     */
    public function up()
    {
        Schema::create('calls', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('caller_id');
            $table->uuid('callee_id');
            $table->uuid('channel_id')->nullable();
            $table->uuid('booking_id')->nullable();
            $table->string('call_type', 10)->default('voice');
            $table->string('status', 20)->default('ringing');
            $table->timestamp('ring_expires_at')->nullable();
            $table->timestamp('answered_at')->nullable();
            $table->timestamp('ended_at')->nullable();
            $table->unsignedInteger('duration')->default(0);
            $table->timestamps();

            $table->index('caller_id');
            $table->index('callee_id');
            $table->index('status');
            $table->index('booking_id');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('calls');
    }
};
