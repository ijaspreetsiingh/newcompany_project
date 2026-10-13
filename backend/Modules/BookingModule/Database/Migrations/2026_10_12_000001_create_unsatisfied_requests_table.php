<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * UNSATISFIED (free re-service) flow:
     *
     * Customer completed booking ke admin-set window (providers.unsatisfied_window_days,
     * default 7 din) tak "Not satisfied with service" raise kar sakta hai.
     * Raise hote hi backend ORIGINAL booking ko clone karke ek FREE re-service
     * booking banata hai (amount 0, status accepted) — usi serviceman ke paas
     * jo pehle kaam karke gaya tha. bookings.is_re_service se apps highlight
     * karte hain.
     *
     * status: requested | completed | expired
     *
     * @return void
     */
    public function up()
    {
        Schema::create('unsatisfied_requests', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('booking_id');
            $table->uuid('customer_id');
            $table->uuid('provider_id')->nullable();
            $table->uuid('serviceman_id')->nullable()->comment('jo serviceman pehle kaam kar gaya tha');
            $table->uuid('reservice_booking_id')->nullable()->comment('auto-cloned free re-service booking');
            $table->string('status', 20)->default('requested');
            $table->text('reason')->nullable()->comment('customer ki problem');
            $table->timestamp('requested_at')->nullable();
            $table->timestamp('due_at')->nullable()->comment('window ka deadline');
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->index('booking_id');
            $table->index('customer_id');
            $table->index('provider_id');
            $table->index('serviceman_id');
            $table->index('status');
        });

        if (!Schema::hasColumn('bookings', 'is_re_service')) {
            Schema::table('bookings', function (Blueprint $table) {
                $table->tinyInteger('is_re_service')->default(0)->after('serviceman_reached_at')
                    ->comment('1 = unsatisfied flow se bani free re-service booking');
            });
        }

        if (!Schema::hasColumn('bookings', 're_service_of')) {
            Schema::table('bookings', function (Blueprint $table) {
                $table->uuid('re_service_of')->nullable()->after('is_re_service')
                    ->comment('original booking jisme customer unsatisfied hua');
            });
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropColumn(['is_re_service', 're_service_of']);
        });
        Schema::dropIfExists('unsatisfied_requests');
    }
};
