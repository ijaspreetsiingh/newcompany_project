<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class AddLocationColumnsToUsersTable extends Migration
{
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('current_lat', 191)->nullable();
            $table->string('current_lng', 191)->nullable();
            $table->timestamp('last_location_updated_at')->nullable();
        });
    }

    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['current_lat', 'current_lng', 'last_location_updated_at']);
        });
    }
}
