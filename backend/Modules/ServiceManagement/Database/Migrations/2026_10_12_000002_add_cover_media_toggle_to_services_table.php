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
            // Cover media type toggle: 0=cover_image (default), 1=cover_images (slider), 2=cover_video
            $table->tinyInteger('cover_media_type')->default(0)->after('cover_video')->comment('0:cover_image, 1:cover_images, 2:cover_video');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('services', function (Blueprint $table) {
            $table->dropColumn('cover_media_type');
        });
    }
};
