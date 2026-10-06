# 🔄 COMPLETE PROJECT REBRAND - DEMANDIUM → YOVO

## ACTION PLAN (Non-Breaking Rename)

### Files to Change:
1. **Folder names** (top-level only, NOT module folders)
2. **Config files** (app name, database, etc.)
3. **Composer.json** (package name)
4. **ENV files** (.env, .env.example)
5. **README files**
6. **Comments in code** (non-critical files)
7. **Database name** (if needed)
8. **Docker files** (if using)

### Files to KEEP (Don't touch - production):
- ❌ Modules folder structure
- ❌ Database schema/migrations
- ❌ API routes
- ❌ Controllers
- ❌ Models
- ❌ Services/Business logic

---

## WHAT NEEDS CHANGING

### 1. App Name/Config
- `config/app.php` → Change 'name'
- `composer.json` → Change name/description
- `.env` → APP_NAME=YOVO
- `README.md` → Update title

### 2. Database Settings (Optional)
- `.env` → Change DB_DATABASE if you want
- If change → Need migration to rename DB

### 3. Folder Structure (Optional)
- `Demandium v3.7/1/` → Rename to `YOVO/` (optional)

### 4. Git/Version Control
- `.gitignore` → Already good
- Keep `.git` folder (don't delete)

### 5. Package Info
- `composer.json` → name: "yovo/booking-system"
- `package.json` → name: "yovo"

---

## STEP-BY-STEP PROCEDURE

### Step 1: Backup Everything
```bash
1. Create full backup of current directory
2. Create database backup
3. Store safely
```

### Step 2: Update Config Files
```php
// config/app.php
'name' => 'YOVO',  // Change from 'Demandium'
'url' => env('APP_URL', 'http://localhost:8000'),
```

### Step 3: Update .env File
```
APP_NAME=YOVO
APP_URL=http://127.0.0.1:8000
DB_DATABASE=yovo_db  (optional)
```

### Step 4: Update composer.json
```json
{
    "name": "yovo/booking-system",
    "description": "YOVO - Service Booking Platform",
    "type": "project",
    // ... rest stays same
}
```

### Step 5: Update package.json
```json
{
    "name": "yovo",
    "description": "YOVO - Service Booking Platform",
    // ... rest stays same
}
```

### Step 6: Clear Cache
```bash
php artisan config:clear
php artisan cache:clear
php artisan config:cache
```

---

## WHICH NAMES TO USE

Suggest:
- **Company Name**: YOVO
- **Database**: yovo_db (or keep demandium_db - doesn't matter)
- **User App**: YOVO (Customer booking app)
- **Provider App**: YOVO Pro / YOVO Partner
- **Serviceman App**: YOVO Worker / YOVO Service

---

## SAFE CHANGES (Won't break anything)

✅ Safe to change:
- `config/app.php` → 'name'
- `composer.json` → name, description
- `.env` → APP_NAME
- `README.md` → title
- `public/` → index files (update comments)
- Documentation files
- Folder names (top-level)

❌ DON'T CHANGE:
- Module folder names (critical)
- Database schema (unless running migrations)
- API routes
- Controller namespaces
- Model relationships
- Service/Business logic code

---

## VERIFICATION STEPS

After rename:
1. [ ] App boots without error
2. [ ] Admin panel loads
3. [ ] User API works
4. [ ] Provider API works
5. [ ] Serviceman API works
6. [ ] Booking creation works
7. [ ] Payment processes
8. [ ] Database connects

---

## ROLLBACK (If anything breaks)

```bash
# Restore backup
1. Delete current project
2. Restore from backup
3. Done!
```

---

## PROCEED?

Ready to do the rebrand? Say "GO" and I'll:
1. Change config files
2. Update .env
3. Update composer.json
4. Clear caches
5. Verify everything works

