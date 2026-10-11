<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    private function indexExists(string $table, string $index): bool
    {
        $row = DB::selectOne(
            "SELECT COUNT(*) AS c FROM information_schema.statistics
             WHERE table_schema = DATABASE() AND table_name = ? AND index_name = ?",
            [$table, $index]
        );
        return (int) ($row->c ?? 0) > 0;
    }

    private function addIndex(string $table, string $index, array $columns): void
    {
        if ($this->indexExists($table, $index)) {
            return;
        }
        $cols = implode(', ', $columns);
        DB::statement("ALTER TABLE `{$table}` ADD INDEX `{$index}` ({$cols})");
    }

    public function up(): void
    {
        $this->addIndex('bookings', 'bookings_customer_id_index', ['customer_id']);
        $this->addIndex('bookings', 'bookings_provider_id_index', ['provider_id']);
        $this->addIndex('bookings', 'bookings_serviceman_id_index', ['serviceman_id']);
        $this->addIndex('bookings', 'bookings_booking_status_index', ['booking_status']);
        $this->addIndex('bookings', 'bookings_zone_sub_category_index', ['zone_id', 'sub_category_id']);
        $this->addIndex('bookings', 'bookings_readable_id_index', ['readable_id']);
        $this->addIndex('bookings', 'bookings_transaction_id_index', ['transaction_id']);
        $this->addIndex('bookings', 'bookings_created_at_index', ['created_at']);

        $this->addIndex('booking_details', 'booking_details_booking_id_index', ['booking_id']);
        $this->addIndex('booking_details', 'booking_details_service_id_index', ['service_id']);

        $this->addIndex('booking_status_histories', 'booking_status_histories_booking_id_index', ['booking_id']);

        $this->addIndex('booking_rechecks', 'booking_rechecks_booking_id_index', ['booking_id']);
        $this->addIndex('booking_rechecks', 'booking_rechecks_serviceman_id_index', ['serviceman_id']);
        $this->addIndex('booking_rechecks', 'booking_rechecks_provider_id_index', ['provider_id']);

        $this->addIndex('booking_extra_services', 'booking_extra_services_booking_id_index', ['booking_id']);
        $this->addIndex('booking_extra_services', 'booking_extra_services_serviceman_id_index', ['serviceman_id']);

        $this->addIndex('booking_ignores', 'booking_ignores_booking_id_index', ['booking_id']);
        $this->addIndex('booking_ignores', 'booking_ignores_provider_id_index', ['provider_id']);

        $this->addIndex('servicemen', 'servicemen_provider_id_index', ['provider_id']);
    }

    public function down(): void
    {
        $indexes = [
            'bookings' => [
                'bookings_customer_id_index', 'bookings_provider_id_index', 'bookings_serviceman_id_index',
                'bookings_booking_status_index', 'bookings_zone_sub_category_index', 'bookings_readable_id_index',
                'bookings_transaction_id_index', 'bookings_created_at_index',
            ],
            'booking_details' => ['booking_details_booking_id_index', 'booking_details_service_id_index'],
            'booking_status_histories' => ['booking_status_histories_booking_id_index'],
            'booking_rechecks' => ['booking_rechecks_booking_id_index', 'booking_rechecks_serviceman_id_index', 'booking_rechecks_provider_id_index'],
            'booking_extra_services' => ['booking_extra_services_booking_id_index', 'booking_extra_services_serviceman_id_index'],
            'booking_ignores' => ['booking_ignores_booking_id_index', 'booking_ignores_provider_id_index'],
            'servicemen' => ['servicemen_provider_id_index'],
        ];
        foreach ($indexes as $table => $list) {
            foreach ($list as $index) {
                if ($this->indexExists($table, $index)) {
                    DB::statement("ALTER TABLE `{$table}` DROP INDEX `{$index}`");
                }
            }
        }
    }
};
