<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    /**
     * Admin provider edit wizard: "Unsatisfied (Re-service)" section me
     * set karta hai ki service done hone ke baad user app me "Not satisfied"
     * button kitne din tak active rahega. 0 = section hidden.
     *
     * @return void
     */
    public function up()
    {
        if (! Schema::hasColumn('providers', 'unsatisfied_window_days')) {
            Schema::table('providers', function (Blueprint $table) {
                $table->integer('unsatisfied_window_days')->default(7)->after('allow_service_edit')
                    ->comment('user app me unsatisfied section ka window (days), 0 = hidden');
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
        Schema::table('providers', function (Blueprint $table) {
            $table->dropColumn('unsatisfied_window_days');
        });
    }
};
