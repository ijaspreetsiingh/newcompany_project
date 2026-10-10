<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class AddServicemanAssignCustomerNotifiedToBookingsTable extends Migration
{
    /**
     * customer ko "serviceman assigned" push sirf EK baar bhejne ke liye flag.
     * Auto-assign rotation me har naye serviceman par purani push dubara nahi jaati.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->tinyInteger('serviceman_assign_customer_notified')->default(0)->after('assignment_mode')->comment('0|1');
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
            $table->dropColumn('serviceman_assign_customer_notified');
        });
    }
}
