# Railway Deployment — Queue Worker + Scheduler (ZAROORI hai)

> Hindi me: Railway par **queue worker** aur **scheduler** dono chalne hi chahiye.
> Nahi chalne se — booking countdown expire, auto-reassign, provider manual queue,
> email notifications, daily backup — sab band rahega.

---

## 1. Abhi kya chal raha hai

| Service | Role | Status |
|---|---|---|
| `web` (nginx → php-fpm) | Website + API | ✅ chal raha hai |
| `db` (MySQL) | Database | ✅ |
| `redis` | Cache / Session / Queue | ✅ |
| `worker` | `php artisan queue:work` | ❌ **missing** |
| `scheduler` | `php artisan schedule:work` | ❌ **missing** |

---

## 2. Option A (RECOMMENDED) — 3 alag Railway services

Same image + same Dockerfile. Sirf **Start Command** alag hai.

### Service 2: `worker`
- **Start Command:**
  ```sh
  sh /var/www/docker/start-worker.sh
  ```
- Same env vars as `web` (ya "Reference variable / shared" use karo)

### Service 3: `scheduler`
- **Start Command:**
  ```sh
  sh /var/www/docker/start-scheduler.sh
  ```
- Same env vars as `web`

> Railway me service banane ke liye: Project → `+ New` → `Service` → apna existing
> **web** service select karo (`Copy`/`Same image` option) → sirf start command change karo.

---

## 3. Option B — ek hi service (sab ek container me)

Existing `web` service ka **Start Command** badal do:

```sh
sh /var/www/docker/start-all.sh
```

Ye script background me queue worker + scheduler chala deta hai aur foreground me
php-fpm (web). Sirf tab use karo jab 2 extra services nahi bana sakte.

---

## 4. Env variables checklist (har service me same)

```
APP_URL=https://newcompanyproject-production.up.railway.app
APP_ENV=live
APP_DEBUG=false

CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# Redis service ka host (Railway Redis service ka naam "redis" rakho)
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=<redis ka password>

# Security
SESSION_SECURE_COOKIE=true
SESSION_SAME_SITE=lax
CORS_ALLOWED_ORIGINS=https://newcompanyproject-production.up.railway.app
PAYMENT_CALLBACK_HOSTS=newcompanyproject-production.up.railway.app
```

> `REDIS_PASSWORD` Railway Redis service me `Service Variables` me milta hai.
> Agar Redis service ka naam alag hai to `REDIS_HOST` wahi rakho.

---

## 5. Deploy ke baad ek baar chalao (web service me)

```sh
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan storage:link
```

> `route:cache` ke baad **route file me naya route add karoge to dubara cache clear
> karna padega** (`php artisan route:clear && php artisan route:cache`).

---

## 6. Check karo sab chal raha hai

```sh
# Worker alive hai?
php artisan queue:monitor default:100

# Scheduler ka next run
php artisan schedule:list

# Logs
tail -f storage/logs/laravel.log
```

Railway logs me `worker` aur `scheduler` service dono me `[yovo] ... start` dikhna chahiye.

---

## 7. High-traffic ke liye (already configured hai)

- `php-fpm` pool: **100 children** (`php-fpm-pool.conf`)
- Redis: `volatile-lru` eviction
- Rate limiters: named (`payment`, `api`, `web`)
- Webhooks (Cashfree/Razorpay) throttle group ke **bahar** — gateway retries block nahi hote
- Queue worker `--max-time=3600` (hourly restart, memory leak se bachao)

---

## 8. Payment gateway webhook URLs (deploy ke baad set karo)

| Gateway | Webhook URL | Event |
|---|---|---|
| Cashfree | `https://newcompanyproject-production.up.railway.app/payment/cashfree/webhook` | `payment.settled` / order paid |
| Razorpay | `https://newcompanyproject-production.up.railway.app/payment/razor-pay/webhook` | `payment.captured` |

Razorpay ka **Webhook Secret** admin panel me
(Admin → Configuration → 3rd Party → Payment Method → Razorpay → "Webhook Secret")
paste karo — webhook signature verify hoga.
