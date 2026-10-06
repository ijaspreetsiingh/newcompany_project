<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    /**
     * Provider admin ko bhejta hai: apni assigned main category /
     * sub category ko replace / change / cancel karne ki request.
     * Admin approve karne par hi assignment badalta hai.
     *
     * @return void
     */
    public function up()
    {
        if (Schema::hasTable('provider_category_requests')) {
            return;
        }

        Schema::create('provider_category_requests', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('provider_id', 36)->index();
            $table->char('zone_id', 36)->nullable()->index();
            $table->string('request_type', 16)->default('replace'); // replace | cancel
            $table->text('current_main_category_ids')->nullable();
            $table->text('current_sub_category_ids')->nullable();
            $table->text('requested_sub_category_ids')->nullable();
            $table->text('note')->nullable();
            $table->string('status', 16)->default('pending'); // pending | approved | denied
            $table->text('admin_note')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('provider_category_requests');
    }
};
