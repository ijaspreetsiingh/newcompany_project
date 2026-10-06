# Service Gallery Images - Setup Status

## ✅ Ye sab ALREADY APPLIED ho chuka hai (backend folder me directly):

| # | File | Change |
|---|------|--------|
| 1 | `Modules/ServiceManagement/Database/Migrations/2026_09_17_000001_add_gallery_to_services_table.php` | **NAYI FILE** — `services` table me `gallery` (text, nullable) column |
| 2 | `Modules/ServiceManagement/Entities/Service.php` | `$casts` me `gallery => array`, `$appends` me `gallery_full_paths`, naya accessor `getGalleryFullPathsAttribute()` |
| 3 | `Modules/ServiceManagement/Http/Controllers/Web/Admin/ServiceController.php` | `store()` + `update()` me gallery save logic, validation me `gallery.*`, `existing_gallery[]` retain support |
| 4 | `Modules/ServiceManagement/Resources/views/admin/edit.blade.php` | **"Gallery Image" block** (multi-upload + preview grid + per-image remove) + preview JS |
| 5 | `resources/lang/en/lang.php` + `bn/lang.php` | `gallery_image` translation |

Sab PHP files `php -l` se verified — **no syntax errors**.

---

## ⚠️ SIRF EK KAAM BACHA HAI — tumhe manually karna hai:

### Migration run karo:

```bash
cd "C:\Users\ijasp\OneDrive\Desktop\booking apk\Demandium v3.7\codecanyon-40224772-demandium-multi-provider-on-demand-handyman-home-service-app-with-admin-panel\backend"
php artisan migrate
```

Ye `services` table me `gallery` column add kar dega.

---

## Kaise kaam karega:

**Admin panel me:**
1. Admin → Services → koi service **Edit** karo
2. Right column me thumbnail + cover image ke niche **"Gallery Image"** block dikhega
3. Multiple images select karo → preview grid me dikhengi → `×` se remove kar sakte ho
4. Save → images `storage/app/public/service/` me upload + `gallery` column me JSON array save

**API me:**
- `GET /api/v1/customer/service/detail/{slug}` response me `gallery_full_paths: [...]` array milega (S3/local dono support, existing `getSingleImageFullPath` helper use hota hai)

**Flutter app me:**
- Service details screen: hero slider (cover + gallery, auto-slide, dots), overlapping header card (name, rating, price, ADD+), "Photos & Videos" 2-col grid + See All full-screen viewer
- Gallery empty ho to bas cover image dikhega — crash nahi hoga

## Testing steps:
1. `php artisan migrate` chalao
2. Admin me service edit → gallery images upload → save
3. API test: service detail endpoint pe `gallery_full_paths` check karo
4. App me service details kholo — slider + gallery grid dikhenga
