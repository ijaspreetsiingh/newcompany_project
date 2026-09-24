<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$cat = DB::table('categories')->first();
$svc = DB::table('services')->where('id','svc-0001-0001-0001-000000000001')->first();

echo "Category ID: " . ($cat ? $cat->id : 'NULL') . "\n";
echo "Service category_id: " . ($svc ? $svc->category_id : 'NULL') . "\n";
echo "Service sub_category_id: " . ($svc ? $svc->sub_category_id : 'NULL') . "\n";

$catId = $cat->id ?? '';
echo "Is category UUID? " . (preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i', $catId) ? 'YES' : 'NO') . "\n";
echo "Category ID length: " . strlen($catId) . "\n";
