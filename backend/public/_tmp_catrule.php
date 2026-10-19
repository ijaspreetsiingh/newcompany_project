<?php
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Http\Request;
use Modules\ProviderManagement\Http\Controllers\Web\Admin\ProviderController;

$zone = 'c00ed508-2bf3-43c3-b95c-8e880de67168';
$me   = 'prvd-0001-0001-0001-000000000001';

$ctrl = app(ProviderController::class);
$ref  = new ReflectionMethod(ProviderController::class, 'categoryAssignmentConflictError');
$ref->setAccessible(true);

function run($ref, $ctrl, $payload, $exclude) {
    $req = new Request();
    $req->merge($payload);
    return $ref->invoke($ctrl, $req, $exclude);
}

echo "TEST 1 : 3 main categories (Plumbing + AC Repair + Carpentry), no subs\n";
$r = run($ref, $ctrl, [
    'zone_id' => $zone,
    'complete_main_category_ids' => [
        'cat-0001-0001-0001-000000000002', // Plumbing
        'cat-0001-0001-0001-000000000008', // AC Repair
        'bc250cc5-990b-4864-aac1-c8dde7b63427', // Carpentry
    ],
    'sub_category_ids' => null,
], $me);
echo "   => ".var_export($r, true)."  ".($r === null ? "[PASS]" : "[FAIL]").PHP_EOL.PHP_EOL;

echo "TEST 2 : single main (Plumbing) only\n";
$r = run($ref, $ctrl, [
    'zone_id' => $zone,
    'complete_main_category_ids' => ['cat-0001-0001-0001-000000000002'],
], $me);
echo "   => ".var_export($r, true)."  ".($r === null ? "[PASS]" : "[FAIL]").PHP_EOL.PHP_EOL;

echo "TEST 3 : sub already owned by ANOTHER active provider -> must still block\n";
$r = run($ref, $ctrl, [
    'zone_id' => $zone,
    'complete_main_category_ids' => null,
    // Fan Installation + Switch & Socket belong to prvd-0001 (excluded), so
    // use them WITH another provider id as exclude to prove block works:
    'sub_category_ids' => ['cat-0002-0001-0001-000000000009'],
], 'prvd-0000-0000-0000-000000000099'); // pretend asker is someone else
echo "   => ".var_export($r, true)."  ".($r !== null ? "[PASS - blocked]" : "[FAIL - should block]").PHP_EOL.PHP_EOL;

echo "TEST 4 : nothing selected\n";
$r = run($ref, $ctrl, ['zone_id' => $zone], $me);
echo "   => ".var_export($r, true)."  ".($r === null ? "[PASS]" : "[FAIL]").PHP_EOL.PHP_EOL;

echo "DONE";
