<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * HIGH TRAFFIC — DB indexes.
 *
 * Ye tables har API request me query hoti hain (booking list, assignment,
 * payment, wallet). Index na hone par MySQL full table scan karta hai ->
 * data badhte hi API slow.
 *
 * Note: index add karne se ek baar table lock hoti hai — busy hours me
 * nahi, off-peak me chalana best hai.
 */
class AddPerformanceIndexes extends Migration
{
    /**
     * @return array<string, array<int, string>>
     */
    private function indexMap(): array
    {
        return [
            'bookings' => [
                'idx_bookings_status_provider' => ['booking_status', 'provider_id'],
                'idx_bookings_customer_status' => ['customer_id', 'booking_status'],
                'idx_bookings_zone_subcat' => ['zone_id', 'sub_category_id'],
                'idx_bookings_paid_status' => ['is_paid', 'booking_status'],
                'idx_bookings_assignment_mode' => ['assignment_mode'],
                'idx_bookings_serviceman_status' => ['serviceman_id', 'booking_status'],
                'idx_bookings_created_at' => ['created_at'],
            ],
            'booking_servicemen' => [
                'idx_booking_servicemen_booking_status' => ['booking_id', 'status'],
                'idx_booking_servicemen_serviceman_status' => ['serviceman_id', 'status'],
                'idx_booking_servicemen_expires_at' => ['expires_at'],
            ],
            'payment_requests' => [
                'idx_payment_requests_transaction' => ['transaction_id'],
                'idx_payment_requests_paid' => ['is_paid'],
                'idx_payment_requests_method' => ['payment_method'],
            ],
            'booking_partial_payments' => [
                'idx_partial_payments_booking' => ['booking_id'],
            ],
            'booking_details' => [
                'idx_booking_details_booking' => ['booking_id'],
            ],
            'booking_details_amounts' => [
                'idx_booking_details_amounts_booking' => ['booking_id'],
            ],
            'booking_offline_payments' => [
                'idx_offline_payments_booking' => ['booking_id'],
            ],
            'transactions' => [
                'idx_transactions_booking' => ['booking_id'],
                'idx_transactions_type' => ['trx_type'],
                'idx_transactions_to_user' => ['to_user_id'],
                'idx_transactions_from_user' => ['from_user_id'],
                'idx_transactions_created_at' => ['created_at'],
            ],
            'accounts' => [
                'idx_accounts_user' => ['user_id'],
            ],
            'subscribed_services' => [
                'idx_subscribed_zone_subcat' => ['zone_id', 'sub_category_id'],
                'idx_subscribed_provider' => ['provider_id'],
            ],
            'serviceman_categories' => [
                'idx_serviceman_categories_serviceman' => ['serviceman_id'],
                'idx_serviceman_categories_subcat' => ['sub_category_id'],
            ],
            'users' => [
                'idx_users_user_type' => ['user_type'],
                'idx_users_wallet' => ['wallet_balance'],
            ],
            'reviews' => [
                'idx_reviews_serviceman' => ['serviceman_id'],
            ],
            'provider_bookings_timers' => [
                'idx_provider_timers_booking' => ['booking_id'],
                'idx_provider_timers_status' => ['status'],
            ],
        ];
    }

    public function up(): void
    {
        foreach ($this->indexMap() as $table => $indexes) {
            if (!Schema::hasTable($table)) {
                continue;
            }

            foreach ($indexes as $name => $columns) {
                $exists = false;
                try {
                    $exists = Schema::hasIndex($table, $name);
                } catch (\Throwable $e) {
                    $exists = false;
                }

                if ($exists) {
                    continue;
                }

                try {
                    Schema::table($table, function (Blueprint $table) use ($name, $columns) {
                        $table->index($columns, $name);
                    });
                } catch (\Throwable $e) {
                    // Index already exist (different name) ya duplicate column —
                    // ignore, baaki indexes bante rahenge.
                }
            }
        }
    }

    public function down(): void
    {
        foreach ($this->indexMap() as $table => $indexes) {
            if (!Schema::hasTable($table)) {
                continue;
            }

            foreach (array_keys($indexes) as $name) {
                try {
                    Schema::table($table, function (Blueprint $table) use ($name) {
                        $table->dropIndex($name);
                    });
                } catch (\Throwable $e) {
                    // ignore
                }
            }
        }
    }
}
