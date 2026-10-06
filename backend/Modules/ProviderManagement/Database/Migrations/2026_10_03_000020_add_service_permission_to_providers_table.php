<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    /**
     * Admin provider wizard ke "Service Permission" step ke do toggle:
     * 1. Provider naya service bana sakta hai (sirf assigned categories, apne zone me)
     * 2. Provider admin ki service edit kar sakta hai (description/price/image) apne zone me
     *
     * @return void
     */
    public function up()
    {
        if (! Schema::hasColumn('providers', 'allow_service_create')) {
            Schema::table('providers', function (Blueprint $table) {
                $table->tinyInteger('allow_service_create')->default(1)->after('assigned_main_category_id');
            });
        }

        if (! Schema::hasColumn('providers', 'allow_service_edit')) {
            Schema::table('providers', function (Blueprint $table) {
                $table->tinyInteger('allow_service_edit')->default(1)->after('allow_service_create');
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
            $table->dropColumn(['allow_service_create', 'allow_service_edit']);
        });
    }
};
