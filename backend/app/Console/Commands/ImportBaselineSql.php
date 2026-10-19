<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class ImportBaselineSql extends Command
{
    protected $signature = 'db:import-baseline';

    protected $description = 'Fresh database hai to installation/backup/database.sql import karta hai';

    public function handle(): int
    {
        try {
            if (Schema::hasTable('users')) {
                $this->info('[SKIP] Database pehle se installed hai.');
                return self::SUCCESS;
            }

            $path = base_path('installation/backup/database.sql');
            if (!file_exists($path)) {
                $this->error('[FAIL] database.sql not found: ' . $path);
                return self::FAILURE;
            }

            DB::unprepared(file_get_contents($path));
            $this->info('[OK] Baseline SQL imported (114 tables).');
            return self::SUCCESS;
        } catch (\Throwable $e) {
            $this->error('[FAIL] ' . $e->getMessage());
            return self::FAILURE;
        }
    }
}
