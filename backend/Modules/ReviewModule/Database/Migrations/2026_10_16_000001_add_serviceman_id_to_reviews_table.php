<?php

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class AddServicemanIdToReviewsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('reviews', function (Blueprint $table) {
            if (!Schema::hasColumn('reviews', 'serviceman_id')) {
                $table->foreignUuid('serviceman_id')->nullable()->after('provider_id');
            }
        });

        // Purane reviews ko booking ke assigned serviceman se backfill karo
        try {
            if (Schema::hasColumn('reviews', 'serviceman_id') && Schema::hasColumn('bookings', 'serviceman_id')) {
                DB::statement('
                    UPDATE reviews
                    INNER JOIN bookings ON bookings.id = reviews.booking_id
                    SET reviews.serviceman_id = bookings.serviceman_id
                    WHERE reviews.serviceman_id IS NULL AND bookings.serviceman_id IS NOT NULL
                ');
            }
        } catch (\Exception $e) {
            // backfill fail hua to bhi migration pass honi chahiye (column already added)
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('reviews', function (Blueprint $table) {
            if (Schema::hasColumn('reviews', 'serviceman_id')) {
                $table->dropColumn('serviceman_id');
            }
        });
    }
}
