<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Admin controlled in-app calling toggle (provider edit page, Basic info card):
     *  - calling_enabled: 1 = is provider ke customers uske service man /
     *    provider ko in-app voice & video call kar sakte hain (aur khud bhi
     *    call out kar sakte hain). 0 = calling disabled for the whole
     *    provider ecosystem.
     *
     * Default OFF = admin ko har provider ko explicitly allow karna hoga
     * (Business Settings > 3rd Party > Agora credentials ke saath).
     *
     * @return void
     */
    public function up()
    {
        Schema::table('providers', function (Blueprint $table) {
            if (!Schema::hasColumn('providers', 'calling_enabled')) {
                $table->tinyInteger('calling_enabled')->default(0)->after('booking_fee_label')
                    ->comment('1 = allow in-app voice/video calling for this provider & its service men');
            }
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
            if (Schema::hasColumn('providers', 'calling_enabled')) {
                $table->dropColumn('calling_enabled');
            }
        });
    }
};
