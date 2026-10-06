<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * assign_type:
     *  - 'complete'  = puri main category di gayi (uske saare sub-category rows)
     *  - 'specific'  = sirf selected sub-category
     *
     * Row EXISTENCE hi assignment hai (unique_zone_sub_category ke saath),
     * isliye is_subscribed=0 wali rows delete kar di jaati hain taaki slot free rahe.
     */
    public function up(): void
    {
        Schema::table('subscribed_services', function (Blueprint $table) {
            if (!Schema::hasColumn('subscribed_services', 'assign_type')) {
                $table->string('assign_type', 16)->default('specific')->after('zone_id');
            }
        });

        // Slot free karo: non-subscribed rows unique index ko block karti rahengi
        DB::table('subscribed_services')->where('is_subscribed', 0)->delete();
    }

    public function down(): void
    {
        Schema::table('subscribed_services', function (Blueprint $table) {
            if (Schema::hasColumn('subscribed_services', 'assign_type')) {
                $table->dropColumn('assign_type');
            }
        });
    }
};
