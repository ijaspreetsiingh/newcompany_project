<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Add to business_settings table instead of creating new table
        // This follows existing YOVO pattern
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Data preserved in business_settings
    }
};
