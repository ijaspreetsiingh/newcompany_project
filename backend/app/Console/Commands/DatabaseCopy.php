<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Throwable;

/**
 * Database copy: source connection -> target connection.
 *
 * Use case: production data Aiven (remote, slow ~1.3s/query) me hai aur hum
 * Railway ka apna MySQL (private network, ~1-5ms) pe shift karna hai.
 *
 *   php artisan db:copy --from=mysql --to=mysql_railway --chunk=500
 *
 * Safety:
 *  - Source (Aiven) READ ONLY hai — kuch bhi delete nahi hota
 *  - Target tables pehle se hain to wahi rows UPDATE hoti hain (upsert)
 *  - migrations table bhi copy hoti hai (taaki naye DB par migrations na chale)
 *  - Chunked copy (memory safe)
 *  - --dry-run sirf table list + row counts dikhata hai
 */
class DatabaseCopy extends Command
{
    protected $signature = 'db:copy
        {--from=mysql : Source connection name (config/database.php)}
        {--to=mysql_railway : Target connection name (config/database.php)}
        {--chunk=500 : Rows per insert batch}
        {--table=* : Sirf ye tables copy karo}
        {--dry-run : Sirf plan dikhao, copy mat karo}';

    protected $description = 'Copy all tables (with data) from one DB connection to another';

    public function handle(): int
    {
        $from = (string) $this->option('from');
        $to = (string) $this->option('to');
        $chunk = max(50, (int) $this->option('chunk'));
        $only = (array) $this->option('table');
        $dryRun = (bool) $this->option('dry-run');

        $this->info("Copy: {$from} -> {$to} (chunk {$chunk})");

        try {
            DB::connection($from)->getPdo();
            DB::connection($to)->getPdo();
        } catch (Throwable $e) {
            $this->error('Connection error: ' . $e->getMessage());
            return 1;
        }

        try {
            $tables = $this->listTables($from);
        } catch (Throwable $e) {
            $this->error('Table list error: ' . $e->getMessage());
            return 1;
        }

        if (!empty($only)) {
            $tables = array_values(array_intersect($tables, $only));
        }

        $this->info('Tables found: ' . count($tables));

        // FK checks off (target) — order me copy karenge
        try {
            DB::connection($to)->statement('SET FOREIGN_KEY_CHECKS=0');
        } catch (Throwable $e) {
            // kuch MySQL variants me fail hota hai — ignore
        }

        $copied = 0;
        $failed = [];

        foreach ($tables as $table) {
            try {
                $count = (int) DB::connection($from)->table($table)->count();
                $targetExists = Schema::connection($to)->hasTable($table);

                if (!$targetExists) {
                    $this->warn("  SKIP {$table} (target table missing)");
                    $failed[] = $table . ' (missing in target)';
                    continue;
                }

                if ($dryRun) {
                    $this->line("  PLAN {$table}: {$count} rows");
                    continue;
                }

                if ($count === 0) {
                    $this->line("  SKIP {$table} (0 rows)");
                    continue;
                }

                $done = 0;
                DB::connection($from)->table($table)->orderByRaw('1')->chunk($chunk, function ($rows) use ($from, $to, $table, &$done, $count) {
                    $data = [];
                    foreach ($rows as $row) {
                        $data[] = (array) $row;
                    }

                    if (empty($data)) {
                        return;
                    }

                    // Upsert (rows same primary key par replace)
                    $columns = array_keys($data[0]);
                    DB::connection($to)->table($table)->upsert($data, $this->primaryKeyOf($to, $table), $columns);

                    $done += count($data);
                });

                $copied++;
                $this->info("  OK   {$table}: {$done}/{$count} rows");
            } catch (Throwable $e) {
                $this->error("  FAIL {$table}: " . $e->getMessage());
                $failed[] = $table;
            }
        }

        try {
            DB::connection($to)->statement('SET FOREIGN_KEY_CHECKS=1');
        } catch (Throwable $e) {
            // ignore
        }

        $this->newLine();
        $this->info("Done. Tables copied: {$copied}, failed: " . count($failed));
        if (!empty($failed)) {
            $this->warn('Failed: ' . implode(', ', $failed));
        }

        if (!$dryRun) {
            $this->newLine();
            $this->comment('Next steps:');
            $this->comment(' 1) Row counts verify karo (php artisan db:copy --from=mysql_railway --to=mysql --dry-run)');
            $this->comment(' 2) App service env me DB_HOST/DB_PORT/DB_DATABASE/DB_USERNAME/DB_PASSWORD -> Railway MySQL set karo');
            $this->comment(' 3) MYSQL_ATTR_SSL_CA hatao (Railway private network par SSL CA nahi chahiye)');
            $this->comment(' 4) Redeploy + smoke test');
        }

        return empty($failed) ? 0 : 2;
    }

    /**
     * Source DB ki tables (views chhod kar).
     */
    private function listTables(string $connection): array
    {
        $database = DB::connection($connection)->getDatabaseName();
        $rows = DB::connection($connection)->select(
            'select table_name as t from information_schema.tables where table_schema = ? and table_type = ? order by table_name',
            [$database, 'BASE TABLE']
        );

        return array_map(fn ($r) => (string) $r->t, $rows);
    }

    /**
     * Table ka primary key (upsert ke liye) — nahi mila to first column use karo.
     */
    private function primaryKeyOf(string $connection, string $table): array
    {
        try {
            $rows = DB::connection($connection)->select(
                'select column_name as c from information_schema.key_column_usage
                 where table_schema = ? and table_name = ? and constraint_name = ?',
                [DB::connection($connection)->getDatabaseName(), $table, 'PRIMARY']
            );

            if (!empty($rows)) {
                return array_map(fn ($r) => (string) $r->c, $rows);
            }
        } catch (Throwable $e) {
            // ignore
        }

        try {
            $columns = Schema::connection($connection)->getColumnListing($table);
            return $columns ? [(string) $columns[0]] : [];
        } catch (Throwable $e) {
            return [];
        }
    }
}
