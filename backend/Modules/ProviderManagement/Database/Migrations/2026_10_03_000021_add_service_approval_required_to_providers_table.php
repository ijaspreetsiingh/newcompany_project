<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    /**
     * Step 6 ka teesra toggle: ON = nayi service aur admin service ki update
     * admin approval ke queue me jayegi. OFF = bina approve ke publish.
     *
     * @return void
     */
    public function up()
    {
        if (Schema::hasColumn('providers', 'service_approval_required')) {
            return;
        }

        Schema::table('providers', function (Blueprint $table) {
            $table->tinyInteger('service_approval_required')->default(0)->after('allow_service_edit');
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
            $table->dropColumn('service_approval_required');
        });
    }
};
