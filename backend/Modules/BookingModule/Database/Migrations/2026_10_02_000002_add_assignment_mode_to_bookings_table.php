<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class AddAssignmentModeToBookingsTable extends Migration
{
    /**
     * assignment_mode: 'auto' (system ne serviceman auto-assign kiye)
     *                  'provider_manual' (provider decide kar raha hai kaunsa serviceman)
     *
     * @return void
     */
    public function up()
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->string('assignment_mode', 20)->nullable()->after('serviceman_assign_expires_at')->comment('auto | provider_manual');
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
            $table->dropColumn('assignment_mode');
        });
    }
}
