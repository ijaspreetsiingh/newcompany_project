<?php
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "COLS: ".implode(', ', Schema::getColumnListing('subscribed_services')).PHP_EOL.PHP_EOL;

$p = DB::table('providers')->where('id','prvd-0001-0001-0001-000000000001')->first();
echo "provider zone: ".($p->zone_id ?? 'NULL').PHP_EOL;

echo "--- provider's current subscribed rows ---".PHP_EOL;
$rows = DB::table('subscribed_services')->where('provider_id',$p->id)->get();
foreach ($rows as $r) {
    $mc = DB::table('categories')->where('id',$r->category_id)->first();
    $sc = DB::table('categories')->where('id',$r->sub_category_id)->first();
    echo "  main=".($mc->name ?? 'NULL')." | sub=".($sc->name ?? 'NULL')." | type={$r->assign_type} | zone=".($r->zone_id ?? 'NULL').PHP_EOL;
}
if ($rows->isEmpty()) echo "  (none)".PHP_EOL;

echo PHP_EOL."--- all main categories (active) ---".PHP_EOL;
foreach (DB::table('categories')->where('type','main')->where('is_active',1)->get() as $c) {
    $kids = DB::table('categories')->where('parent_id',$c->id)->pluck('name');
    echo "  {$c->name} (".implode(', ', $kids).")".PHP_EOL;
}

echo PHP_EOL."--- who owns what in same zone ---".PHP_EOL;
$same = DB::table('subscribed_services')->where('zone_id',$p->zone_id)->get();
foreach ($same as $r) {
    $sc = DB::table('categories')->where('id',$r->sub_category_id)->first();
    echo "  provider={$r->provider_id} sub=".($sc->name ?? $r->sub_category_id).PHP_EOL;
}
if ($same->isEmpty()) echo "  (none)".PHP_EOL;
echo "DONE";
