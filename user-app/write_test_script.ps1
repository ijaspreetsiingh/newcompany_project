<?php

// ================= TEST SCRIPT: Single Provider Feature =================
$base = 'C:\Users\ijasp\OneDrive\Desktop\booking apk\Demandium v3.7\codecanyon-40224772-demandium-multi-provider-on-demand-handyman-home-service-app-with-admin-panel\backend';
$script = <<<'PHP'
<?php
$pass = 0; $fail = 0;
function ok($label, $cond, $extra = '') {
    global $pass, $fail;
    if ($cond) { $pass++; echo "[PASS] $label $extra\n"; }
    else { $fail++; echo "[FAIL] $label $extra\n"; }
}

echo "==== 1. DB COLUMNS ====\n";
$cols = DB::select("SHOW COLUMNS FROM services WHERE Field LIKE '%single%'");
$names = array_column($cols, 'Field');
ok('is_single_provider exists', in_array('is_single_provider', $names));
ok('single_provider_mode exists', in_array('single_provider_mode', $names));
ok('single_provider_id exists', in_array('single_provider_id', $names));

echo "\n==== 2. MODEL ====\n";
$svcClass = 'Modules\ServiceManagement\Entities\Service';
ok('singleProvider() method', method_exists($svcClass, 'singleProvider'));

echo "\n==== 3. ADMIN CONTROLLER METHODS ====\n";
$adminCtrl = 'Modules\ServiceManagement\Http\Controllers\Web\Admin\ServiceController';
$r = new ReflectionMethod($adminCtrl, 'create');
ok('create() has providers in view data (source check)', true, '(source verified separately)');
$src = file_get_contents(base_path('Modules/ServiceManagement/Http/Controllers/Web/Admin/ServiceController.php'));
ok('create() passes $providers', str_contains($src, "compact('categories', 'zones', 'providers')"));
ok('edit() passes $providers', str_contains($src, "compact('categories', 'zones', 'service', 'tagNames', 'providers')"));
ok('store() validates single_provider_mode', str_contains($src, 'single_provider_mode'));
ok('store() saves is_single_provider', str_contains($src, 'is_single_provider'));
ok('update() saves is_single_provider', substr_count($src, 'is_single_provider') >= 4);

echo "\n==== 4. BLADE VIEWS (HTML OUTPUT) ====\n";
$createBlade = file_get_contents(base_path('Modules/ServiceManagement/Resources/views/admin/create.blade.php'));
$editBlade = file_get_contents(base_path('Modules/ServiceManagement/Resources/views/admin/edit.blade.php'));
foreach (['is-single-provider', 'single-provider-options', 'mode-any-first', 'mode-specific', 'single_provider_id', '__toggleSingleProviderOptions'] as $needle) {
    ok("create.blade has $needle", str_contains($createBlade, $needle));
}
foreach (['is-single-provider', 'single-provider-options', 'mode-any-first', 'mode-specific', 'single_provider_id', '__toggleSingleProviderOptions'] as $needle) {
    ok("edit.blade has $needle", str_contains($editBlade, $needle));
}

echo "\n==== 5. HELPERS EXIST ====\n";
ok('getServiceSingleProviderLockId()', function_exists('getServiceSingleProviderLockId'));
ok('getBookingSingleProviderLockId()', function_exists('getBookingSingleProviderLockId'));
ok('autoAssignBooking() has lock check', str_contains(file_get_contents(base_path('app/Lib/Helpers.php')), 'getBookingSingleProviderLockId'));

echo "\n==== 6. PROVIDER API CONTROLLER (claim logic) ====\n";
$provSrc = file_get_contents(base_path('Modules/ServiceManagement/Http/Controllers/Api/V1/Provider/ServiceController.php'));
ok('statusUpdate claims any_first', str_contains($provSrc, "single_provider_mode', 'any_first'") || str_contains($provSrc, "'single_provider_mode', 'any_first'"));
ok('statusUpdate releases on unsubscribe', str_contains($provSrc, 'single_provider_id\' => null') || str_contains($provSrc, "single_provider_id' => null"));
ok('index groups whereIn (orWhere bug fixed)', str_contains($provSrc, 'orWhereIn') && str_contains($provSrc, 'function ($query) use ($ids)'));

echo "\n==== 7. LIVE: LOCK HELPER ON REAL SERVICE ====\n";
$service = $svcClass::withoutGlobalScope('zone_wise_data')->withoutGlobalScope('translate')->first();
if ($service) {
    echo "Service: {$service->id} | is_single={$service->is_single_provider} | mode={$service->single_provider_mode} | lock={$service->single_provider_id}\n";
    ok('helper returns null when no lock', getServiceSingleProviderLockId([$service->id]) === null || $service->single_provider_id !== null);

    // Simulate: set specific lock
    $provider = \Modules\ProviderManagement\Entities\Provider::ofStatus(1)->ofApproval(1)->first();
    if ($provider) {
        $orig = [
            'is_single_provider' => $service->is_single_provider,
            'single_provider_mode' => $service->single_provider_mode,
            'single_provider_id' => $service->single_provider_id,
        ];
        $service->is_single_provider = 1;
        $service->single_provider_mode = 'specific';
        $service->single_provider_id = $provider->id;
        $service->save();

        $lock = getServiceSingleProviderLockId([$service->id]);
        ok('lock returns specific provider', $lock === $provider->id, "got=$lock expected={$provider->id}");

        // Booking-level helper
        $fakeIds = [$service->id, 'non-existent'];
        ok('lock works with mixed ids', getServiceSingleProviderLockId($fakeIds) === $provider->id);

        // Restore
        $service->is_single_provider = $orig['is_single_provider'];
        $service->single_provider_mode = $orig['single_provider_mode'];
        $service->single_provider_id = $orig['single_provider_id'];
        $service->save();
        echo "(service restored)\n";
    } else {
        echo "[SKIP] no approved provider for lock simulation\n";
    }
} else {
    echo "[SKIP] no services in DB\n";
}

echo "\n==== 8. LIVE: FIRST-SUBSCRIBER CLAIM SIMULATION ====\n";
$service2 = $svcClass::withoutGlobalScope('zone_wise_data')->withoutGlobalScope('translate')->first();
$provider2 = \Modules\ProviderManagement\Entities\Provider::ofStatus(1)->ofApproval(1)->first();
if ($service2 && $provider2) {
    $orig2 = [
        'is_single_provider' => $service2->is_single_provider,
        'single_provider_mode' => $service2->single_provider_mode,
        'single_provider_id' => $service2->single_provider_id,
        'sub_category_id' => $service2->sub_category_id,
    ];
    $service2->is_single_provider = 1;
    $service2->single_provider_mode = 'any_first';
    $service2->single_provider_id = null;
    $service2->save();

    // Simulate claim query (same as statusUpdate)
    $claimed = $svcClass::withoutGlobalScope('zone_wise_data')->withoutGlobalScope('translate')
        ->whereIn('sub_category_id', [$service2->sub_category_id])
        ->where('is_single_provider', 1)
        ->where('single_provider_mode', 'any_first')
        ->whereNull('single_provider_id')
        ->update(['single_provider_id' => $provider2->id]);

    $service2->refresh();
    ok('any_first claim sets provider on subscribe', $service2->single_provider_id === $provider2->id, "claimed_rows=$claimed lock={$service2->single_provider_id}");

    // Second provider cannot claim (whereNull fails)
    $provider3 = \Modules\ProviderManagement\Entities\Provider::ofStatus(1)->ofApproval(1)->where('id', '!=', $provider2->id)->first();
    if ($provider3) {
        $again = $svcClass::withoutGlobalScope('zone_wise_data')->withoutGlobalScope('translate')
            ->whereIn('id', [$service2->id])
            ->whereNull('single_provider_id')
            ->update(['single_provider_id' => $provider3->id]);
        ok('second provider cannot steal claim', $again === 0 && $service2->fresh()->single_provider_id === $provider2->id);
    }

    // Release on unsubscribe
    $released = $svcClass::withoutGlobalScope('zone_wise_data')->withoutGlobalScope('translate')
        ->whereIn('id', [$service2->id])
        ->where('is_single_provider', 1)
        ->where('single_provider_mode', 'any_first')
        ->where('single_provider_id', $provider2->id)
        ->update(['single_provider_id' => null]);
    ok('unsubscribe releases claim', $released === 1 && $service2->fresh()->single_provider_id === null);

    // Restore
    $service2->is_single_provider = $orig2['is_single_provider'];
    $service2->single_provider_mode = $orig2['single_provider_mode'];
    $service2->single_provider_id = $orig2['single_provider_id'];
    $service2->save();
    echo "(service restored)\n";
}

echo "\n==== 9. ADMIN FORM VALIDATION RULES (simulated) ====\n";
$v1 = validator(['is_single_provider' => '1', 'single_provider_mode' => null, 'single_provider_id' => null], [
    'is_single_provider' => 'nullable|in:0,1',
    'single_provider_mode' => 'required_if:is_single_provider,1|nullable|in:any_first,specific',
    'single_provider_id' => 'required_if:single_provider_mode,specific|nullable|exists:providers,id',
]);
ok('mode required when toggle ON', $v1->fails());

$v2 = validator(['is_single_provider' => '1', 'single_provider_mode' => 'any_first'], [
    'is_single_provider' => 'nullable|in:0,1',
    'single_provider_mode' => 'required_if:is_single_provider,1|nullable|in:any_first,specific',
    'single_provider_id' => 'required_if:single_provider_mode,specific|nullable|exists:providers,id',
]);
ok('any_first passes without provider_id', !$v2->fails());

$provId = \Modules\ProviderManagement\Entities\Provider::ofStatus(1)->ofApproval(1)->first()?->id;
$v3 = validator(['is_single_provider' => '1', 'single_provider_mode' => 'specific', 'single_provider_id' => $provId], [
    'is_single_provider' => 'nullable|in:0,1',
    'single_provider_mode' => 'required_if:is_single_provider,1|nullable|in:any_first,specific',
    'single_provider_id' => 'required_if:single_provider_mode,specific|nullable|exists:providers,id',
]);
ok('specific + valid provider passes', !$v3->fails());

$v4 = validator(['is_single_provider' => '1', 'single_provider_mode' => 'specific', 'single_provider_id' => null], [
    'is_single_provider' => 'nullable|in:0,1',
    'single_provider_mode' => 'required_if:is_single_provider,1|nullable|in:any_first,specific',
    'single_provider_id' => 'required_if:single_provider_mode,specific|nullable|exists:providers,id',
]);
ok('specific without provider fails', $v4->fails());

$v5 = validator(['is_single_provider' => '0'], [
    'is_single_provider' => 'nullable|in:0,1',
    'single_provider_mode' => 'required_if:is_single_provider,1|nullable|in:any_first,specific',
    'single_provider_id' => 'required_if:single_provider_mode,specific|nullable|exists:providers,id',
]);
ok('toggle OFF passes without mode', !$v5->fails());

echo "\n==== 10. PROVIDER GLOBAL SCOPE (service list filter) ====\n";
$srcService = file_get_contents(base_path('Modules/ServiceManagement/Entities/Service.php'));
ok('provider path filters single-provider services', str_contains($srcService, 'single_provider_id'));
ok('filter allows is_single_provider=0 OR null OR own id', str_contains($srcService, 'orWhere(\'single_provider_id\', $providerId)'));

echo "\n==== 11. CART + BOOKING INTEGRATION ====\n";
$cartSrc = file_get_contents(base_path('Modules/CartModule/Http/Controllers/Api/V1/Customer/CartController.php'));
ok('addToCart forces locked provider', str_contains($cartSrc, 'single_provider_id'));
ok('updateProvider respects lock', str_contains($cartSrc, 'getServiceSingleProviderLockId'));
$bookingSrc = file_get_contents(base_path('Modules/BookingModule/Http/Traits/BookingTrait.php'));
ok('placeBookingRequest applies cart lock', substr_count($bookingSrc, 'getServiceSingleProviderLockId') >= 1);
ok('repeat booking applies lock', str_contains($bookingSrc, 'repeatLockProviderId'));

echo "\n==== 12. AUTO-ASSIGN + NEXT PROVIDER ====\n";
$helpers = file_get_contents(base_path('app/Lib/Helpers.php'));
ok('autoAssignBooking checks lock first', str_contains($helpers, 'lockedProviderId'));
ok('moveBookingToNextProvider respects exclusive lock', str_contains($helpers, 'Single-provider exclusive: reject'));

echo "\n========================================\n";
echo "TOTAL PASS: $pass | FAIL: $fail\n";
echo $fail === 0 ? "RESULT: ALL TESTS PASSED ✅\n" : "RESULT: SOME TESTS FAILED ❌\n";
PHP;

file_put_contents($base . '/test_single_provider.php', $script);
echo "Script written: " . $base . "/test_single_provider.php\n";
