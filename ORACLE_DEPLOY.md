# Oracle Cloud (Always Free) — Backend Deploy Guide

> Target: **Ampere A1 — 4 OCPU / 24 GB RAM** (Always Free, ARM64)
> Result: App + MySQL + Redis ek hi box → DB query ~0ms (Aiven par ~1.3s tha)

---

## 1. VM banao (OCI Console)

**Compute → Instances → Create instance**

| Field | Value |
|---|---|
| Name | `yovo-app` |
| Shape | **Ampere A1** → `VM.Standard.A1.Flex` |
| OCPU | **4** (max free) |
| RAM | **24 GB** (max free) |
| Image | **Ubuntu 24.04 (aarch64)** (ya Oracle Linux 9 ARM) |
| Shape availability | ⚠️ "Out of capacity" → **1 OCPU/6GB** se start karo, VM banne ke baad **Edit → 4/24** karo |
| Networking | VCN + subnet + **Public IP ON** (ya Cloudflare Tunnel — niche dekho) |
| Boot volume | 50 GB (default) |
| Extra volume | **200 GB block volume** → MySQL data ke liye (free) |
| SSH | Apni key pair upload karo |

> 💳 Card details maangega (trial $300) — **Always Free resources trial khatam hone ke baad bhi free rehte hain** ✅

---

## 2. Server setup (SSH)

```bash
ssh -i ~/your-key.pem ubuntu@<INSTANCE_PUBLIC_IP>

sudo apt update && sudo apt install -y docker.io docker-compose-v2 git curl
sudo usermod -aG docker $USER && newgrp docker
sudo mkdir -p /opt/yovo && cd /opt/yovo
```

---

## 3. Code + build (ARM64)

```bash
git clone https://github.com/ijaspreetsiingh/newcompany_project.git
cd newcompany_project
cp backend/.env.example backend/.env    # settings ke liye (ya local .env copy karo)

# Build (ARM pe PHP extensions compile hote hain → 8-15 min)
docker build -f Dockerfile.railway -t yovo-app:latest .
```

> ⚠️ `.env` me ye set karo:
> ```
> APP_ENV=production
> APP_DEBUG=false
> APP_URL=https://<tumhara-domain>
> DB_DATABASE=yovo
> DB_USERNAME=yovo
> DB_PASSWORD=<strong-password>
> DB_ROOT_PASSWORD=<strong-root-password>
> CACHE_DRIVER=redis
> SESSION_DRIVER=redis
> QUEUE_CONNECTION=redis
> MYSQL_ATTR_SSL_CA=            # KHALI karo (Aiven ka cert local MySQL pe fail karega)
> SESSION_SECURE_COOKIE=true
> ```

---

## 4. Data migrate (Aiven/Railway → local MySQL)

Option A (repo ka command — Docker ke andar):
```bash
docker compose -f docker-compose.prod.yml up -d mysql
# phir app container me:
docker compose -f docker-compose.prod.yml run --rm app php artisan db:copy --from=mysql_remote --to=mysql --dry-run
```
> `mysql_remote` connection ke liye `config/database.php` me Aiven wale
> `RAILWAY_DB_*`/remote env vars use karo (already hai).

Option B (mysqldump — simple + fast):
```bash
# Aiven se dump (CA cert zaruri)
mysqldump --ssl-ca=backend/certs/aiven-ca.pem -h <aiven-host> -u <user> -p <db> \
  --single-transaction --routines --triggers --default-character-set=utf8mb4 db > dump.sql

# Local MySQL me import
docker compose -f docker-compose.prod.yml exec -T mysql \
  mysql -u root -p"$DB_ROOT_PASSWORD" yovo < dump.sql
```

> ⏱ Table count verify: `php artisan db:copy --from=mysql --to=mysql_remote --dry-run`

---

## 5. Start everything

```bash
docker compose -f docker-compose.prod.yml up -d
docker compose -f docker-compose.prod.yml logs -f app
```

Entrypoint automatically: `migrate --force` → seeds → `config:cache` → `route:cache` → `view:cache` → supervisord (nginx + php-fpm + **queue worker** + **scheduler**).

Check:
```bash
docker compose -f docker-compose.prod.yml ps
curl -s -o /dev/null -w "%{time_total}\n" http://localhost/api/v1/client/setup/   # < 1s hona chahiye
```

---

## 6. HTTPS (payment gateway ke liye MANDATORY)

Razorpay/Cashfree HTTPS maangte hain → plain IP se kaam nahi chalega.

### Option A: Cloudflare Tunnel (FREE + apna domain) — RECOMMENDED
```bash
# Cloudflare dashboard → Zero Trust → Tunnels → Create
# Ubuntu me:
mkdir -p ~/.cloudflared && cd ~/.cloudflared
# (tunnel token copy karke)
docker run -d --name cloudflared --restart unless-stopped \
  --network host cloudflare/cloudflared:latest \
  tunnel --no-autoupdate run --token <TUNNEL_TOKEN>

# DNS: api.yourdomain.com -> tunnel
```
> Tunnel TCP/HTTP ko public hostname se VM tak forward karta hai + **automatic HTTPS** ✅

### Option B: Free domain (sslip.io / nip.io) + Let's Encrypt
```bash
# sslip.io: <ip>.sslip.io free wildcard DNS deta hai
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d <ip>.sslip.io
```
> `APP_URL` me wahi host daalna hoga (apps ka baseUrl bhi).

### Option C: Apna domain + Caddy (simple, auto-HTTPS)
```
# Caddyfile
api.yourdomain.com {
    reverse_proxy 127.0.0.1:80
}
```

---

## 7. Firewall (Oracle VCN)

OCI Console → **Networking → Virtual Cloud Networks → Security Lists** me **ingress rule** add karo:
- Source `0.0.0.0/0`, TCP **80** (HTTP) + **443** (HTTPS, Cloudflare tunnel par zarurat nahi)
- SSH (22) apne IP se only

> ⚠️ **NSG vs Security List**: dono jagah rule chahiye ho sakta hai.

---

## 8. Apps ka baseUrl update

`user-app`, `provider-app`, `service-man-app` → `lib/util/app_constants.dart`:
```dart
static const String baseUrl = 'https://api.yourdomain.com';
```
→ phir `flutter build apk --release` (APKs bana ke users ko distribute karo).

---

## 9. Performance (Oracle par expected)

| | Aiven (ab) | Oracle A1 (same box) |
|---|---|---|
| 1 DB query | ~1.3s | **~0.2-1ms** |
| App startup config | 28s | **< 0.3s** |
| Booking list | 8-15s | **< 0.3s** |
| Booking create | 20s+ | **< 0.5s** |
| Concurrent users | 5 children | **50 php-fpm workers + MySQL** |

---

## 10. Free tier limits (dhyaan rakhna)

| Resource | Free limit | Humara use |
|---|---|---|
| A1 compute | 4 OCPU / 24 GB | 2-4 OCPU (peak) ✅ |
| Block volume | 200 GB | 50 boot + 100-150 MySQL ✅ |
| Outbound data | 10 TB/month | ~1-2 GB/month ✅ |
| MySQL (self-hosted) | box ke andar | RAM me, no extra cost ✅ |

⚠️ Oracle kabhi kabhi **idle Always Free instances reclaim** kar sakta hai (capacity ke liye). Isliye:
- Weekly `mysqldump` backup → local/off-site
- Uptime monitor (UptimeRobot free) → alerts

---

## 11. Railway wala setup?

**Free tier me rehne de** (revert easy hai):
- Railway app service → Variables wapas Aiven/Railway MySQL par
- Redeploy
- Data wahi hai (Aiven source of truth rakho 1-2 hafte)

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Build fail (ARM extension) | `docker build --progress=plain -f Dockerfile.railway .` → logs dekho; zaroorat ho to `--build-arg` |
| "Out of host capacity" | 1 OCPU/6GB se banao → phir Edit → 4 OCPU/24 GB |
| MySQL "Access denied" | compose `.env` ke DB_USER/PASSWORD aur container ke MYSQL_* same rakho |
| App 500 | `docker compose logs -f app` → storage permission? `chown -R www-data:www-data storage bootstrap/cache` |
| App slow | `docker stats` → MySQL buffer pool / RAM check |
| Cloudflare tunnel 502 | app container healthy hai? `docker compose ps` + `curl localhost/api/v1/client/setup/` |
