<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Queue ke liye jobs table.
 *
 * Railway par Redis available nahi hua to QUEUE_CONNECTION=database fallback
 * chalta hai — uske liye ye table zaroori hai ( warna queue worker error
 * karega aur emails/notifications ruk jayenge).
 */
class CreateJobsTableForQueue extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('jobs')) {
            Schema::create('jobs', function (Blueprint $table) {
                $table->id();
                $table->string('queue')->index();
                $table->longText('payload');
                $table->unsignedTinyInteger('attempts');
                $table->unsignedInteger('reserved_at')->nullable();
                $table->unsignedInteger('available_at');
                $table->unsignedInteger('created_at');
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('jobs');
    }
}
