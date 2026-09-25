# 🚀 Free Live Deployment Guide (Hinglish)

Project ko free me live karne ka complete plan:

| Kya | Kahan | Cost |
|-----|-------|------|
| Backend (Laravel API + Admin) | **Render** (Docker web service) | Free (750 hrs/month) |
| MySQL Database | **Aiven Free Tier** (always free, 1GB) | ₹0 |
| Redis | Nahi chahiye → file cache + sync queue | ₹0 |
| Flutter Apps | Local se APK build (baseUrl update karke) | ₹0 |
| Flutter Web (optional) | Vercel / Cloudflare Pages (drag & drop) | ₹0 |

> **Note:** MySQL ke liye Aiven ki jagah **TiDB Serverless** bhi le sakte ho (5GB free, no card) — end me alternative step hai.

---

## Step 1 — GitHub ✅ (ho chuka hai)

Repo: `https://github.com/ijaspreetsiingh/newcompany_project.git`

Isme `render.yaml` + `backend/Dockerfile.render` + `backend/docker/*` deploy files already hain.

---

## Step 2 — Aiven me free MySQL banao (5 min)

1. **https://www.aiven.io/free-tier** pe jao → sign up (email se, card NAHI lagta).
2. **Create service** → Database **MySQL** → Plan **Free** → region jo closest ho (e.g. `aws-eu-central-1` / `google-us-east1`).
3. ~2 min me service ban jayegi. **Overview / Connections** page pe ye note karo:
   - **Host** (e.g. `mysql-xxxx.aivencloud.com`)
   - **Port** (3306 NAHI hota — jaisa dashboard me dikhe wahi)
   - **Username** (`avnadmin`)
   - **Password** (reveal karo, copy karo)
   - **Database name** (usually `default`)
4. **CA certificate download** karo (Service → Settings → CA Certificate ya "Download CA" button).
   - File ko yahan rakho: **`backend/certs/aiven-ca.pem`**
   - Folder `backend/certs/` pehle se hai (ya bana lena).

---

## Step 3 — CA file commit + push (1 min)

```powershell
cd C:\Users\ijasp\OneDrive\Desktop\newcompany_project
git add backend/certs
git commit -m "add: Aiven CA certificate"
git push origin main
```

> CA file public certificate hai — commit karna safe hai. TiDB use kar rahe ho to TiDB ka CA lena (https://pki.tidbcloud.com).

---

## Step 4 — Render pe deploy (5 min)

1. **https://render.com** pe GitHub se sign up karo.
2. **New + Web Service** → GitHub repo `newcompany_project` connect karo.
3. Render `render.yaml` detect karega → **Apply** dabao (Blueprint flow).
4. Ye env vars prompt aayenge — Aiven wale values bharo:

   | Var | Kya daalna hai |
   |-----|----------------|
   | `DB_HOST` | Aiven host |
   | `DB_PORT` | Aiven port |
   | `DB_DATABASE` | `default` (ya jo naam dikhe) |
   | `DB_USERNAME` | `avnadmin` |
   | `DB_PASSWORD` | Aiven password |
   | `ADMIN_EMAIL` | Admin panel login email (yaad rakho) |
   | `ADMIN_PASSWORD` | Admin login password (strong rakho) |

5. **Apply / Deploy** → build ~5-10 min lega (composer + docker).
6. Deploy complete hone pe URL milega: **`https://xxxx.onrender.com`** 🎉

---

## Step 5 — Test karo

1. Browser me `https://xxxx.onrender.com` kholo → `/admin/auth/login` pe redirect hoga.
2. `ADMIN_EMAIL` / `ADMIN_PASSWORD` se login karo → Admin panel chal raha? ✅
3. API check: `https://xxxx.onrender.com/api/v1/customer/config` (ya koi bhi app route)
4. **Pehli request 30-50 sec** le sakti hai — free tier ka cold start hai (15 min idle ke baad service soti hai). Baad ki request fast.

### Agar DB error aaye (SSL wala issue)
Aiven TLS require karta hai. Fix:

1. Render dashboard → service → **Environment** → add var:
   ```
   MYSQL_ATTR_SSL_CA = /var/www/html/certs/aiven-ca.pem
   ```
2. **Manual Deploy → Clear build cache & deploy**.

### Logs dekhne ke liye
Render dashboard → **Logs** tab. Entrypoint har step ka output (import/migrate/seed) wahan dikhega.

---

## Step 6 — Flutter apps me baseUrl update

Deploy ke baad Render URL apne 3 apps me daalna hai:

| App | File | Kya badalna hai |
|-----|------|-----------------|
| User app | `user-app/lib/util/app_constants.dart` | `http://10.0.2.2:8000` → `https://xxxx.onrender.com` |
| Service man app | `service-man-app/lib/utils/app_constants.dart` | same |
| Provider app | `provider-app/lib/util/app_constants.dart` | same |

> URL milte hi bolo — **main teeno files edit karke push kar dunga.** Ya khud edit kar lo.

### APK build (apne PC pe):
```powershell
cd user-app
flutter pub get
flutter build apk --release
# APK: build\app\outputs\flutter-apk\app-release.apk
```

Debug (phone se test, USB ke bina):
```powershell
flutter build apk --debug
```

---

## Step 7 (optional) — Flutter Web live karo

```powershell
cd user-app
flutter build web --release
```

- `build/web` folder ko **https://vercel.com/new** pe **drag & drop** kar do (free, login GitHub se).
- Ya **Cloudflare Pages** → Create → Direct Upload → `build/web` folder.

---

## 🔧 Optional: Purana local data live karna

Abhi live DB **fresh** hai (schema + admin + default settings). Apna purana data (`demandium_db`) chahiye to bolo — dump export/import me help kar dunga. Rough flow:

```powershell
# local DB dump (Docker MySQL ke liye, port 3307)
docker exec -i <mysql-container> mysqldump -uroot -p1234 demandium_db > local-dump.sql
# phir Aiven me import (render/CLI se, SSL ke saath)
```

---

## ⚠️ Free tier ke limits (yaad rakho)

- **Render:** 512MB RAM, 15 min idle → sleep (cold start ~30-50s), 750 hrs/month. **DB pe import/migrate entrypoint khud karta hai.**
- **Storage ephemeral hai:** `storage/app` ke uploads redisploy pe delete hote hain. Images ke liye baad me **Cloudinary/S3** add kar sakte ho (bol dena).
- **Aiven:** 1GB storage, always free. Zarurat pade to TiDB Serverless (5GB) shift ho sakte ho.
- `APP_DEBUG=false` hai — production me error page pe details nahi dikhte, Render **Logs** me dekho.

---

## 📁 Deploy files kya hain

```
render.yaml                      ← Render blueprint (env vars + docker config)
backend/Dockerfile.render        ← nginx + php-fpm + supervisord image
backend/docker/entrypoint.sh     ← boot pe: passport keys, SQL import, migrate, seed, config:cache
backend/docker/nginx.conf.template ← $PORT pe listen (Render ko chahiye)
backend/docker/supervisord.conf  ← nginx + php-fpm + scheduler (artisan schedule:run har min)
backend/docker/uploads.ini       ← 64MB upload limit
backend/app/Console/Commands/ImportBaselineSql.php ← fresh DB pe database.sql import
backend/database/seeders/AdminUserSeeder.php       ← super-admin banata hai
```

Local Docker (`backend/Dockerfile` + `docker-compose.yml`) jaisa hai waisa hi chalega — `Dockerfile.render` sirf Render ke liye alag hai.
