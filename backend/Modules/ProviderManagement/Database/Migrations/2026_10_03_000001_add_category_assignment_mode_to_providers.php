<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class AddCategoryAssignmentModeToProviders extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('providers', function (Blueprint $table) {
            // Category assignment mode: 0 = sub_category_only, 1 = complete_main_category
            $table->tinyInteger('category_assignment_mode')->default(0)->after('platform_fee_label');
            // Assigned main category ID (only used when mode is complete_main_category)
            $table->foreignUuid('assigned_main_category_id')->nullable()->after('category_assignment_mode');
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
            $table->dropColumn(['category_assignment_mode', 'assigned_main_category_id']);
        });
    }
}
