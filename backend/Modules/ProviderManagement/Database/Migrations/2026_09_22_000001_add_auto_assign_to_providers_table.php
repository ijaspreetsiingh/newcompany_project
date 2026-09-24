<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class AddAutoAssignToProvidersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('providers', function (Blueprint $table) {
            $table->boolean('auto_assign_mode')->default(0)->comment('1 = all bookings directly sent to this provider, 0 = normal nearest-provider auto assign');
            $table->integer('auto_assign_wait_time')->default(120)->comment('seconds a provider gets to accept an auto-assigned booking');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('providers', function (Blueprint $table) {
            $table->dropColumn(['auto_assign_mode', 'auto_assign_wait_time']);
        });
    }
}
