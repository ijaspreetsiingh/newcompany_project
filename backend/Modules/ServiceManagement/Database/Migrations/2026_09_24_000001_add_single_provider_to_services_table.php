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
            $table->boolean('is_single_provider')->default(0)->after('is_active');
            $table->string('single_provider_mode', 20)->nullable()->after('is_single_provider'); // any_first | specific
            $table->foreignUuid('single_provider_id')->nullable()->after('single_provider_mode');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('services', function (Blueprint $table) {
            $table->dropConstrainedForeignId('single_provider_id');
            $table->dropColumn(['is_single_provider', 'single_provider_mode']);
        });
    }
};
