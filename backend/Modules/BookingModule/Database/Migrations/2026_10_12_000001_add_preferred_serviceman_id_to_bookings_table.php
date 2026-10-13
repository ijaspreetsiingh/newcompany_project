<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class AddPreferredServicemanIdToBookingsTable extends Migration
{
    /**
     * "Book again with same serviceman" — customer previous booking ke
     * serviceman ko hi pehle chance deta hai. Decline/expire par normal
     * nearest flow age badhta hai (tried-list exclusion).
     *
     * @return void
     */
    public function up()
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->char('preferred_serviceman_id', 36)->nullable()->after('serviceman_id')
                ->comment('customer book-again: pehle isi serviceman ko request bhejni hai');
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
            $table->dropColumn('preferred_serviceman_id');
        });
    }
}
