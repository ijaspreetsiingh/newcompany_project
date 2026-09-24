<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
$s = Modules\ServiceManagement\Entities\Service::withoutGlobalScope('translate')->find('svc-0001-0001-0001-000000000001');
echo "Gallery data: " . json_encode($s->gallery) . "\n";
echo "Gallery full paths: " . json_encode($s->gallery_full_paths) . "\n";
echo "Gallery type: " . gettype($s->gallery) . "\n";
