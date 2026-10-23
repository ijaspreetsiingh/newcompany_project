# Zone + Category + Provider Assignment Guide

## Issue Fixed ✅

**Problem**: `/admin/category/create` and `/admin/sub-category/create` endpoints were failing.

**Cause**: Routes were **commented out** in `Modules/CategoryManagement/Routes/api/v1/api.php`.

**Solution**: Uncommented all necessary routes:
- `POST /api/v1/admin/category/store` - Create main category
- `GET /api/v1/admin/category/edit/{id}` - Edit main category
- `PUT /api/v1/admin/category/update/{id}` - Update main category
- `POST /api/v1/admin/sub-category/store` - Create sub-category
- `GET /api/v1/admin/sub-category/edit/{id}` - Edit sub-category
- `PUT /api/v1/admin/sub-category/update/{id}` - Update sub-category

---

## Complete Zone-Category-Provider Workflow

### Step 1: Create Main Categories (Admin)
**Frontend**: `http://127.0.0.1:8000/admin/category/create`
**API**: `POST /api/v1/admin/category/store`

**Required Fields**:
- `name` - Category name (unique)
- `zone_ids[]` - Array of zone IDs (which zones this category is available in)
- `image` - Category image file

**Example Request**:
```json
{
  "name": "Plumbing",
  "zone_ids": ["zone-id-delhi", "zone-id-mumbai"],
  "image": "<file>"
}
```

**Database Result**: 
- Saves in `categories` table with `parent_id = 0`, `position = 1`
- Links zones in `category_zone` table

---

### Step 2: Create Sub-Categories (Admin)
**Frontend**: `http://127.0.0.1:8000/admin/sub-category/create`
**API**: `POST /api/v1/admin/sub-category/store`

**Required Fields**:
- `name` - Sub-category name (unique)
- `parent_id` - Main category ID
- `short_description` - Description
- `image` - Sub-category image file

**Example Request**:
```json
{
  "name": "Pipe Repair",
  "parent_id": "category-plumbing-uuid",
  "short_description": "Fix broken pipes and leaks",
  "image": "<file>"
}
```

**Database Result**:
- Saves in `categories` table with `position = 2`
- Parent ID links to main category

---

### Step 3: Assign Provider to Zone (Already Exists)
When creating/editing a provider, admin assigns the provider to ONE zone.

**Database**: 
- `providers.zone_id` stores single zone

---

### Step 4: Assign Sub-Categories to Provider (Zone-Aware)
**Frontend**: `http://127.0.0.1:8000/admin/provider/edit/{provider_id}`
**API**: `PUT /api/v1/admin/provider/{provider_id}/update-subscription`

When a provider subscribes to a sub-category, system automatically stores:

**What Gets Saved** (`subscribed_services` table):
```
{
  provider_id: "provider-uuid",
  zone_id: "provider.zone_id",  ← Auto-filled from provider's zone
  category_id: "main-category-uuid",
  sub_category_id: "sub-category-uuid",
  is_subscribed: 1
}
```

**Unique Constraint**: `unique_zone_sub_category`
- **Meaning**: One provider per zone per sub-category
- **Example**:
  - **Delhi + Pipe Repair** = Only ONE provider can have this
  - **Mumbai + Pipe Repair** = Different provider can have this
  - **Delhi + Drain Cleaning** = Different provider can have this

---

## Visual Flow Chart

```
┌─────────────────────────────────────────────────────────────┐
│ ADMIN PANEL                                                  │
└─────────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: Create Main Category                                │
│ - Name: "Plumbing"                                          │
│ - Zones: [Delhi, Mumbai]                                    │
│ → categories table (parent_id=0)                            │
└─────────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: Create Sub-Categories                               │
│ - "Pipe Repair" → Parent: Plumbing                          │
│ - "Drain Cleaning" → Parent: Plumbing                       │
│ → categories table (parent_id=plumbing_id)                  │
└─────────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 3: Assign Provider to Zone                             │
│ - Provider: "Rahul Services"                                │
│ - Zone: Delhi                                               │
│ → providers.zone_id = delhi_id                              │
└─────────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 4: Provider Subscribe to Sub-Categories                │
│ - Select: Pipe Repair + Drain Cleaning                      │
│ → subscribed_services (multiple rows)                       │
│   - zone_id: Delhi                                          │
│   - sub_category_id: Pipe Repair                            │
│   - provider_id: Rahul Services                             │
│                                                              │
│   - zone_id: Delhi                                          │
│   - sub_category_id: Drain Cleaning                         │
│   - provider_id: Rahul Services                             │
└─────────────────────────────────────────────────────────────┘
              ↓
        [BOOKING FLOW]
              ↓
    Customer books in Delhi for Pipe Repair
              ↓
    System checks: Delhi + Pipe Repair → Rahul Services
              ↓
    Booking assigned to Rahul ✅
```

---

## Database Schema

### Categories Table
```sql
categories {
  id: UUID,
  name: string,
  parent_id: UUID (0 = main category),
  position: int (1 = main, 2 = sub),
  image: string,
  description: nullable string,
  is_active: boolean
}
```

### Category_Zone Table
```sql
category_zone {
  id: auto_increment,
  category_id: UUID,
  zone_id: UUID
}
```

### Subscribed_Services Table
```sql
subscribed_services {
  id: auto_increment,
  provider_id: UUID,
  zone_id: UUID,  ← NEW FIELD (copied from provider.zone_id)
  category_id: UUID,
  sub_category_id: UUID,
  is_subscribed: boolean,
  unique_zone_sub_category: UNIQUE(zone_id, sub_category_id)
}
```

### Providers Table
```sql
providers {
  id: UUID,
  zone_id: UUID,  ← ONE zone per provider
  company_name: string,
  company_email: string,
  company_phone: string,
  ...
}
```

---

## Key Points ⚠️

1. **One Provider Per Zone Per Sub-Category**
   - If Rahul is assigned "Pipe Repair" in Delhi, no other provider can be assigned "Pipe Repair" in Delhi
   - A different provider CAN be assigned "Pipe Repair" in Mumbai

2. **Automatic Zone Assignment**
   - When provider subscribes to sub-category, `zone_id` is automatically filled from `provider.zone_id`
   - Admin doesn't need to manually select zone

3. **Booking Assignment Logic** (`app/Lib/Helpers.php`)
   ```php
   // First check assigned provider (zone + sub-category)
   $provider = Provider::query()
     ->where('zone_id', $zoneId)
     ->whereHas('subscribed_services', function ($q) use ($zoneId, $subCategoryId) {
       $q->where('zone_id', $zoneId)
         ->where('sub_category_id', $subCategoryId)
         ->where('is_subscribed', 1);
     })
     ->first();
   
   // If no assigned provider, fallback to nearest eligible providers
   ```

4. **Admin Toggle** (Independent of Zone Assignment)
   - `provider.auto_assign_mode = 1`: Admin approval required before serviceman dispatch
   - `provider.auto_assign_mode = 0`: Auto-dispatch nearest serviceman

---

## Migration Check

Run this to verify migration is applied:
```bash
php artisan migrate --path=Modules/ProviderManagement/Database/Migrations/2026_10_02_000003_add_zone_to_subscribed_services_table.php
```

If you get a migration error, check:
1. Redis is configured in `.env` OR
2. Change cache driver to `file` in `config/cache.php`

---

## Testing Workflow

### Test Case 1: Zone-Specific Assignment
```
1. Create Category: "Plumbing" (Delhi + Mumbai)
2. Create Sub-Category: "Pipe Repair" (Parent: Plumbing)
3. Create Provider 1: "Rahul" → Zone: Delhi
4. Create Provider 2: "Simran" → Zone: Mumbai
5. Provider 1 subscribes: Pipe Repair
   → subscribed_services: (zone=Delhi, sub_cat=Pipe Repair, provider=Rahul)
6. Provider 2 subscribes: Pipe Repair
   → subscribed_services: (zone=Mumbai, sub_cat=Pipe Repair, provider=Simran)
7. Customer books in Delhi → Rahul gets booking ✅
8. Customer books in Mumbai → Simran gets booking ✅
```

### Test Case 2: Duplicate Prevention
```
1. Rahul (Delhi) subscribed to "Pipe Repair"
2. Try to assign another provider (Delhi) to "Pipe Repair"
   → Should fail with unique constraint error ✅
```

---

## API Endpoints Summary

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/v1/admin/category/index` | List main categories |
| POST | `/api/v1/admin/category/store` | Create main category |
| GET | `/api/v1/admin/category/edit/{id}` | Get category for editing |
| PUT | `/api/v1/admin/category/update/{id}` | Update category |
| DELETE | `/api/v1/admin/category/delete` | Delete categories |
| GET | `/api/v1/admin/sub-category/index` | List sub-categories |
| POST | `/api/v1/admin/sub-category/store` | Create sub-category |
| GET | `/api/v1/admin/sub-category/edit/{id}` | Get sub-category for editing |
| PUT | `/api/v1/admin/sub-category/update/{id}` | Update sub-category |
| DELETE | `/api/v1/admin/sub-category/delete` | Delete sub-categories |

---

## Troubleshooting

### "404 Not Found" on `/admin/category/create`
**Solution**: Routes were commented out. File `Modules/CategoryManagement/Routes/api/v1/api.php` has been fixed.

### "unique_zone_sub_category Violation"
**Meaning**: Another provider in same zone already has this sub-category.
**Solution**: Assign different sub-category or use different zone.

### "zone_id is NULL" in subscribed_services
**Cause**: Old subscriptions before migration.
**Solution**: Run migration + update script to backfill zone_id.

---

## Next Steps

1. ✅ Test category creation
2. ✅ Test sub-category creation
3. ✅ Test provider assignment
4. ✅ Create test bookings
5. Verify zone-specific booking distribution
