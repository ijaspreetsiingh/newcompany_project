# 🐳 DOCKER - CACHE & DATABASE CLEANUP COMMANDS

## When to Run These

After updating code/config, run these commands to make sure everything is fresh:

---

## 1️⃣ RESTART EVERYTHING (SAFEST)

```bash
# Stop all containers
docker-compose down

# Remove old volumes (optional - only if you want fresh DB)
# docker-compose down -v

# Restart all services
docker-compose up -d

# Wait 10 seconds for services to boot
sleep 10

# Check status
docker-compose ps
```

**Result**: 
- All containers restart
- Cache cleared
- Services fresh
- Database still has data (unless -v used)

---

## 2️⃣ JUST CLEAR APP CACHE (FAST)

```bash
# Enter app container
docker-compose exec app bash

# Inside container:
php artisan cache:clear
php artisan config:clear
php artisan view:clear
php artisan route:clear

# Exit
exit
```

**Result**:
- Laravel cache cleared
- Config reloaded
- Views recompiled
- Routes recached

---

## 3️⃣ CLEAR REDIS CACHE (IF ISSUES)

```bash
# Enter Redis container
docker-compose exec redis bash

# Inside container:
redis-cli FLUSHALL

# Exit
exit
```

**Result**:
- All Redis data cleared
- Fresh cache memory

---

## 4️⃣ DATABASE REFRESH (BE CAREFUL!)

```bash
# DO NOT RUN unless you want fresh DB!

docker-compose exec app bash

# Inside container:
php artisan migrate:refresh --seed

# Exit
exit
```

**⚠️ WARNING**: This resets database and seeds dummy data!

---

## 5️⃣ REBUILD DOCKER IMAGE (FULL RESET)

```bash
# If Dockerfile changed:
docker-compose down
docker-compose build --no-cache
docker-compose up -d
docker-compose ps
```

**Result**: 
- New image built from Dockerfile
- All containers recreated
- Fresh PHP extensions
- Everything updated

---

## 6️⃣ QUICK ALL-IN-ONE (RECOMMENDED AFTER CODE CHANGES)

```bash
# Stop
docker-compose down

# Start fresh
docker-compose up -d

# Wait for boot
sleep 10

# Clear Laravel cache
docker-compose exec app php artisan cache:clear

# Clear config
docker-compose exec app php artisan config:clear

# Check status
docker-compose ps

echo "✅ All done!"
```

---

## WHAT EACH DOES

| Command | Cache | DB | Config | Effect |
|---------|-------|----|---------| -------|
| cache:clear | ✅ | ❌ | ❌ | Clears Laravel cache |
| config:clear | ✅ | ❌ | ✅ | Reloads config |
| view:clear | ✅ | ❌ | ❌ | Recompiles views |
| route:clear | ✅ | ❌ | ✅ | Recaches routes |
| FLUSHALL | ✅ | ❌ | ❌ | Clears Redis |
| down -v | ✅ | ✅ | ✅ | Stops + deletes volumes |
| up -d | ✅ | ❌ | ✅ | Starts containers |
| build --no-cache | ✅ | ❌ | ✅ | Rebuilds image |

---

## QUICK REFERENCE

**After changing code:**
```bash
docker-compose down && docker-compose up -d && sleep 10 && docker-compose exec app php artisan cache:clear
```

**After changing .env:**
```bash
docker-compose exec app php artisan config:clear
```

**If things are weird:**
```bash
docker-compose down && docker-compose up -d
```

**If Redis issues:**
```bash
docker-compose exec redis redis-cli FLUSHALL
```

**Full reset (loses DB):**
```bash
docker-compose down -v && docker-compose up -d
```

---

## CHECK DOCKER STATUS

```bash
# See all containers running
docker-compose ps

# See logs of app
docker-compose logs app

# See logs of specific service
docker-compose logs redis
docker-compose logs db
docker-compose logs nginx

# Enter app container (bash)
docker-compose exec app bash

# Run PHP artisan commands
docker-compose exec app php artisan tinker
```

---

## COMMON DOCKER ISSUES & FIXES

### Issue: "Connection refused"
```bash
# Redis/DB not ready yet
docker-compose up -d
sleep 15  # Wait longer
docker-compose ps
```

### Issue: "Cache issues after code change"
```bash
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan config:clear
```

### Issue: "Database connection error"
```bash
docker-compose ps
# If db not running:
docker-compose up -d db
sleep 5
docker-compose up -d
```

### Issue: "Out of memory / weird errors"
```bash
docker-compose down
docker-compose up -d
```

---

## AFTER CODE UPDATE (RECOMMENDED FLOW)

```bash
# 1. Pull new code
git pull

# 2. Stop containers
docker-compose down

# 3. Start fresh
docker-compose up -d

# 4. Wait for boot
sleep 10

# 5. Clear Laravel cache
docker-compose exec app php artisan cache:clear

# 6. Clear config
docker-compose exec app php artisan config:clear

# 7. Verify
docker-compose ps

echo "✅ Ready to go!"
```

Save this as `docker-update.sh` and run when needed!

