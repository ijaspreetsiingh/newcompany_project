<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('services', function (Blueprint $table) {
            // Cover slider: multiple images (JSON array). Empty/null => single cover_image use hoga.
            $table->text('cover_images')->nullable()->after('gallery');
            // Cover video: single video file for a particular service (admin panel)
            $table->string('cover_video', 191)->nullable()->after('cover_images');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('services', function (Blueprint $table) {
            $table->dropColumn(['cover_images', 'cover_video']);
        });
    }
};
