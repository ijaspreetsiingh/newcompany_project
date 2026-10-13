<?php
require "/var/www/vendor/autoload.php";
$app = require "/var/www/bootstrap/app.php";
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$user = Modules\UserManagement\Entities\User::where("user_type", "super-admin")->first();
auth("web")->loginUsingId($user->id);

$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$request = Illuminate\Http\Request::create("/admin/service/edit/99cc26c2-4dd3-4998-b6d5-884bb0f9bdd5", "GET");
$response = $kernel->handle($request);

echo "HTTP_STATUS: " . $response->getStatusCode() . PHP_EOL;
$content = $response->getContent() ?? "";
echo (strpos($content, "title-auto-fill") !== false ? "HAS_TITLE_AUTO_FILL" : "NO_TITLE_BTN") . PHP_EOL;
echo (strpos($content, "coverMediaInput") !== false ? "HAS_COVER_MEDIA" : "NO_COVER_MEDIA") . PHP_EOL;
echo (strpos($content, "cover_video") !== false ? "HAS_COVER_VIDEO" : "NO_COVER_VIDEO") . PHP_EOL;
echo (strpos($content, "serviceImageCropModal") !== false ? "HAS_CROP_MODAL" : "NO_CROP") . PHP_EOL;
echo (strpos($content, "analyzeImageBtn") !== false ? "HAS_AI_SIDEBAR" : "NO_AI_SIDEBAR") . PHP_EOL;
