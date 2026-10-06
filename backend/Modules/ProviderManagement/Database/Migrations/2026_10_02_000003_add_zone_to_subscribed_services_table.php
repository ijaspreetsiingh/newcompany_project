<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class AddZoneToSubscribedServicesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('subscribed_services', function (Blueprint $table) {
            // Add zone_id column
            $table->foreignUuid('zone_id')->nullable()->after('sub_category_id');
            // Note: Single provider per zone per category enforced at application level, not database constraint
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('subscribed_services', function (Blueprint $table) {
            $table->dropColumn('zone_id');
        });
    }
}
