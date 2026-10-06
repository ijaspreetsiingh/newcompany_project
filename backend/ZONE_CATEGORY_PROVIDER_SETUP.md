# Zone + Category Based Single Provider Assignment

## Overview
Ab system me **ek zone + ek category ke liye SIRF EK provider** assign hoga.

### Example:
- **Delhi + Plumber** = Rahul (sirf Rahul ko saare plumber bookings Delhi me jayengi)
- **Mumbai + Plumber** = Simran (sirf Simran ko saare plumber bookings Mumbai me jayengi)

## Changes Made

### 1. Database Migration
**File**: `Modules/ProviderManagement/Database/Migrations/2026_10_02_000003_add_zone_to_subscribed_services_table.php`

- Added `zone_id` column to `subscribed_services` table
- Added unique constraint: `unique_zone_sub_category` (ensures one provider per zone per sub_category)

### 2. Entity Update
**File**: `Modules/ProviderManagement/Entities/SubscribedService.php`

- Added `zone_id` to `$fillable` array

### 3. Provider Assignment Logic
**File**: `app/Lib/Helpers.php` - `findNearestProviders()` function

**NEW LOGIC**:
1. First check: Zone + Sub Category ke liye assigned provider (single provider per zone per category)
2. Fallback: Agar assigned provider nahi hai to nearest eligible providers (backward compatibility)

```php
// First check: Zone + Sub Category ke liye assigned provider
$assignedProvider = Provider::query()
    ->where('zone_id', $zoneId)
    ->whereHas('subscribed_services', function ($query) use ($zoneId, $subCategoryId) {
        $query->where('zone_id', $zoneId)
            ->where('sub_category_id', $subCategoryId)
            ->where('is_subscribed', 1);
    })
    ->first();

if ($assignedProvider) {
    return collect([$assignedProvider]);
}
```

### 4. Provider Subscription Updates
**Files Updated**:
- `Modules/ServiceManagement/Http/Controllers/Web/Provider/ServiceController.php`
- `Modules/ServiceManagement/Http/Controllers/Api/V1/Provider/ServiceController.php`

- Added `zone_id` when provider subscribes to a category
- Zone automatically taken from provider's zone

### 5. AI Toggle Logic Verification

#### Toggle ON (auto_assign_mode = 1)
**File**: `app/Lib/Helpers.php` - `startProviderDecisionWindow()`

- Provider ko notification bhejta hai with countdown timer
- Notification message: "New Booking Request! AI-assigned - nearest serviceman available"
- Provider decide karega kaunsa serviceman assign karna hai
- Timer expire hone par system nearest serviceman ko auto-assign kar dega

#### Toggle OFF (auto_assign_mode = 0)
**File**: `app/Lib/Helpers.php` - `dispatchNearestServicemanRequest()`

- Provider ke sabse NEAREST serviceman ko request bhejta hai
- Accept nahi hua -> timer expiry pe agla nearest (loop)
- Sabne mana -> provider ko "manually assign karo" push notification

## How It Works

### Booking Flow:
1. Customer booking place karta hai
2. `autoAssignBooking()` function call hota hai
3. System zone + sub_category ke liye assigned provider dhundta hai
4. Provider mil gaya -> booking us provider par lock hoti hai
5. Provider ke toggle ke hisab se:
   - **ON**: Provider ko notification + timer (wo decide karega)
   - **OFF**: Nearest serviceman ko automatic request

### Admin Setup:
1. Admin provider ko zone me assign karta hai (already exists)
2. Provider category subscribe karta hai (Web/App)
3. System automatically `zone_id` save karta hai in `subscribed_services` table
4. Unique constraint ensures sirf ek provider per zone per category

## Next Steps

### 1. Run Migration
```bash
php artisan migrate --path=Modules/ProviderManagement/Database/Migrations/2026_10_02_000003_add_zone_to_subscribed_services_table.php
```

**Note**: Migration failed due to Redis not being configured. You need to:
- Configure Redis in `.env` file, OR
- Change cache driver to file/array in `config/cache.php`

### 2. Update Existing Data
After migration, run this script to update existing subscribed_services with zone_id:

```php
// In tinker or a custom command
$subscribedServices = \Modules\ProviderManagement\Entities\SubscribedService::whereNull('zone_id')->get();
foreach ($subscribedServices as $service) {
    $provider = \Modules\ProviderManagement\Entities\Provider::find($service->provider_id);
    if ($provider) {
        $service->zone_id = $provider->zone_id;
        $service->save();
    }
}
```

### 3. Test the Flow
1. Create 2 providers in different zones (Delhi, Mumbai)
2. Subscribe both to same category (Plumber)
3. Create booking from Delhi zone
4. Verify: Only Delhi provider gets the booking
5. Create booking from Mumbai zone
6. Verify: Only Mumbai provider gets the booking

## Important Notes

- **Unique Constraint**: Database level ensures no duplicate zone+sub_category assignments
- **Fallback Logic**: If no assigned provider found, system falls back to nearest eligible providers
- **AI Toggle**: Works independently of zone assignment - controls serviceman assignment within provider
- **Backward Compatible**: Existing subscriptions will work after zone_id update

## Files Modified

1. `Modules/ProviderManagement/Database/Migrations/2026_10_02_000003_add_zone_to_subscribed_services_table.php` (NEW)
2. `Modules/ProviderManagement/Entities/SubscribedService.php`
3. `app/Lib/Helpers.php`
4. `Modules/ServiceManagement/Http/Controllers/Web/Provider/ServiceController.php`
5. `Modules/ServiceManagement/Http/Controllers/Api/V1/Provider/ServiceController.php`
