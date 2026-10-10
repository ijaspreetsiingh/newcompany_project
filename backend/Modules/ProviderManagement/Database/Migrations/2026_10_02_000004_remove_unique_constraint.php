<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        if (Schema::hasTable('subscribed_services') && Schema::hasIndex('subscribed_services', 'unique_zone_sub_category')) {
            Schema::table('subscribed_services', function (Blueprint $table) {
                // Remove unique constraint - enforce single provider at application level instead
                $table->dropUnique('unique_zone_sub_category');
            });
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('subscribed_services', function (Blueprint $table) {
            // Add back unique constraint
            $table->unique(['zone_id', 'sub_category_id'], 'unique_zone_sub_category');
        });
    }
};
