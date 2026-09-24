<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class AddAutoAssignToBookingsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->boolean('auto_assigned')->default(0)->comment('1 = booking is going through auto-assign flow');
            $table->timestamp('auto_assign_expires_at')->nullable()->comment('current provider timer deadline');
            $table->uuid('assigned_provider_id')->nullable()->comment('provider who finally accepted the auto-assigned booking');
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
            $table->dropColumn(['auto_assigned', 'auto_assign_expires_at', 'assigned_provider_id']);
        });
    }
}
