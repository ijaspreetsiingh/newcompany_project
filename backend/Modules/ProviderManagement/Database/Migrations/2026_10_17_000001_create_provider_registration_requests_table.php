<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    /**
     * Landing page "Become a Provider" se aane wali registration requests.
     * Approval par hi User + Provider (ID) banate hain.
     *
     * @return void
     */
    public function up()
    {
        if (Schema::hasTable('provider_registration_requests')) {
            return;
        }

        Schema::create('provider_registration_requests', function (Blueprint $table) {
            $table->char('id', 36)->primary();

            // Contact + business details (provider ID banane ke liye jo jaisa chahiye)
            $table->string('contact_person_name', 191);
            $table->string('contact_person_phone', 25)->nullable();
            $table->string('contact_person_email', 191)->nullable();

            $table->string('company_name', 191);
            $table->string('company_phone', 25)->nullable();
            $table->string('company_email', 191)->nullable();
            $table->string('company_address', 255)->nullable();
            $table->string('logo', 191)->nullable();

            // Account login credentials (ID banane ke liye)
            $table->string('account_email', 191);
            $table->string('account_phone', 25);
            $table->string('password', 191); // bcrypt hashed (kabhi plain mat rakhna)

            // Identity verification details
            $table->string('identity_type', 50)->nullable();
            $table->string('identity_number', 191)->nullable();
            $table->text('identity_images')->nullable();

            $table->double('latitude')->nullable();
            $table->double('longitude')->nullable();

            // Where the provider wants to serve + what category/services
            $table->char('zone_id', 36)->nullable()->index();
            $table->char('main_category_id', 36)->nullable()->index();
            $table->text('sub_category_ids')->nullable(); // json array (optional; empty = pure main category)

            // Admin decision tracking
            $table->string('status', 32)->default('pending'); // pending | approved | approved_inactive | accepted_existing | declined
            $table->char('created_provider_id', 36)->nullable()->index();
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
        Schema::dropIfExists('provider_registration_requests');
    }
};
