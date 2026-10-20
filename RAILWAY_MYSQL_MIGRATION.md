# Railway MySQL Migration Guide (Aiven → Railway MySQL)

> Kyun: Aiven (remote) par **har query ~1.3s** le rahi hai → app slow.
> Railway ka apna MySQL **private network** par hota hai → **~1-5ms** (250x faster).

---

## STEP 1 — Railway me MySQL service banao

1. Railway dashboard → apna project → **`+ New`** → **Database** → **MySQL**
2. Name: `mysql` (koi bhi)
3. **Region**: wahi jo Aiven DB ka hai (ya app service se exactly same) — region match = low latency
4. Plan: storage/data size check karo (free tier storage chhoti hoti hai)

Railway tumhe ye variables dega:
```
MYSQLHOST, MYSQLPORT, MYSQLUSER, MYSQLPASSWORD, MYSQLDATABASE
```

---

## STEP 2 — App service me naye DB ke liye alag variables (Aiven ABHI AS IS)

**App service → Variables → New Variable Group / individual variables:**

```
RAILWAY_DB_HOST=<MYSQLHOST value>      # e.g. mysql.railway.internal
RAILWAY_DB_PORT=3306
RAILWAY_DB_DATABASE=<MYSQLDATABASE>
RAILWAY_DB_USERNAME=<MYSQLUSER>
RAILWAY_DB_PASSWORD=<MYSQLPASSWORD>
```

> Railway me har variable ke saath "Reference variable" toggle hai — usse MySQL service se auto-fill ho jayega.

**ABHI `DB_HOST` etc. CHHEDNA MAT** — app Aiven se chal raha hai (data wahi hai).

---

## STEP 3 — Deploy hone do

Variables change karte hi Railway redeploy karega. Build ~10-20 min lagta hai (PHP extensions compile).

---

## STEP 4 — Data copy (Aiven → Railway MySQL)

**Railway → App service → Shell (ya Logs me shell button):**

```sh
# 1) pehle plan dekho (kuch copy nahi hoga)
php artisan db:copy --from=mysql --to=mysql_railway --dry-run

# 2) actual copy
php artisan db:copy --from=mysql --to=mysql_railway --chunk=500
```

Output me har table ka row count dikhega. Source (Aiven) **read-only** rehta hai — kuch delete nahi hota.

Verify:
```sh
php artisan db:copy --from=mysql_railway --to=mysql --dry-run
```
(counts match hone chahiye)

---

## STEP 5 — App ko naye DB par point karo

**App service → Variables** me update karo:

```
DB_HOST=<MYSQLHOST>          # e.g. mysql.railway.internal
DB_PORT=3306
DB_DATABASE=<MYSQLDATABASE>
DB_USERNAME=<MYSQLUSER>
DB_PASSWORD=<MYSQLPASSWORD>
```

### ⚠️ ZAROORI: `MYSQL_ATTR_SSL_CA` DELETE karo
Aiven ka certificate Railway MySQL ke saath kaam nahi karega → connection fail hoga.
`Variables` me `MYSQL_ATTR_SSL_CA` **delete** kar do (private network par SSL ki zarurat nahi).

### `DATABASE_URL` bhi set hai?
Agar `DATABASE_URL` variable set hai, to wo **override** karta hai — use bhi update/delete kar do
( warna purana Aiven URL hi use hoga).

---

## STEP 6 — Redeploy + smoke test

```sh
php artisan migrate --force
php artisan db:seed --class=AdminUserSeeder --force
```

Phir test:
- App login ✅
- Customer app config (`/api/v1/client/setup/`) — **ab < 1s aana chahiye** (pehle 28s)
- Provider/serviceman app login ✅
- Ek test booking + payment ✅

---

## STEP 7 — Backup

- **Aiven ko 1-2 hafte backup ke liye RAKHO** (delete mat karna)
- Wapas switch karna ho → `DB_*` variables revert + `MYSQL_ATTR_SSL_CA` wapas + redeploy
- Railway MySQL ka apna backup nahi hota → daily `php artisan database:backup` cron lagao
  (ya Aiven se nightly dump)

---

## Performance expectation

| | Aiven (ab) | Railway MySQL (baad me) |
|---|---|---|
| 1 query | ~1.3s | ~2-10ms |
| App startup config | 28s | **< 1s** |
| Booking list | 8-15s | **< 0.5s** |
| Booking create | 20s+ | **< 1s** |

---

## Troubleshooting

**"Connection refused"** → DB_HOST galat ya app service aur MySQL service alag region me hain.

**"certificate verify failed"** → `MYSQL_ATTR_SSL_CA` abhi set hai → delete karo.

**"Access denied for user"** → username/password mismatch (MySQL service ke variables exactly copy karo).

**Copy beech me ruk gaya** → `--chunk=200` chalao; command resumption safe hai (upsert).

**Table missing in target** → naye DB me schema nahi hai → STEP 3 ke baad app service me
`php artisan migrate --force` chalao (schema bana lega), phir copy dobara.
