<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

/**
 * serviceman_categories pivot:
 * Provider app se jab serviceman create/edit hota hai to
 * provider ek ya multiple sub-categories assign karta hai.
 * findNearestServicemen() isi table se booking ki sub_category_id
 * ke against filter karta hai.
 */
class CreateServicemanCategoriesTable extends Migration
{
    public function up(): void
    {
        Schema::create('serviceman_categories', function (Blueprint $table) {
            $table->id();
            $table->foreignUuid('serviceman_id')
                  ->constrained('servicemen')
                  ->cascadeOnDelete();
            $table->uuid('category_id');
            $table->uuid('sub_category_id')->nullable();
            $table->timestamps();

            $table->unique(['serviceman_id', 'sub_category_id'], 'sm_sub_cat_unique');
            $table->index('serviceman_id');
            $table->index('sub_category_id');
            $table->index('category_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('serviceman_categories');
    }
}
