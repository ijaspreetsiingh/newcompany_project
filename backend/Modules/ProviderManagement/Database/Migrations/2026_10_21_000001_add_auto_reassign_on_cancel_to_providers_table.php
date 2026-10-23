<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class AddAutoReassignOnCancelToProvidersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        if (!Schema::hasColumn('providers', 'auto_reassign_on_cancel')) {
            Schema::table('providers', function (Blueprint $table) {
                $table->tinyInteger('auto_reassign_on_cancel')->default(0)->after('auto_assign_wait_time')
                    ->comment('1 = auto reassign booking when serviceman cancels, 0 = manual');
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
        if (Schema::hasColumn('providers', 'auto_reassign_on_cancel')) {
            Schema::table('providers', function (Blueprint $table) {
                $table->dropColumn('auto_reassign_on_cancel');
            });
        }
    }
}