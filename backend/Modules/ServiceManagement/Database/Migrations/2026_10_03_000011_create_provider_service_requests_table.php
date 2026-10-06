<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    /**
     * Provider ki taraf se aayi "nayi service add" / "admin service update"
     * ki approval request. Admin 2 tabs me dekhta hai.
     *
     * @return void
     */
    public function up()
    {
        if (Schema::hasTable('provider_service_requests')) {
            return;
        }

        Schema::create('provider_service_requests', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('provider_id', 36)->index();
            $table->char('service_id', 36)->index();
            $table->char('zone_id', 36)->nullable();
            $table->string('request_type', 16); // create | update
            $table->text('previous_values')->nullable(); // snapshot before change
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
        Schema::dropIfExists('provider_service_requests');
    }
};
