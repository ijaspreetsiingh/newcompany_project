# Demandium Backend - Quick Reference Card

## 🎯 One-Line Quick Access

| Need | Command |
|------|---------|
| Start backend | `docker compose up -d` |
| Stop backend | `docker compose down` |
| View logs | `docker compose logs -f` |
| Access API | http://localhost:8000 |
| Database admin | http://localhost:8080 |
| Clear cache | `docker compose exec -T app php artisan cache:clear` |
| Run migrations | `docker compose exec -T app php artisan migrate` |
| Database shell | `docker compose exec db mysql -u demandium -pdemandium123 demandium_db` |

---

## 🔌 Database Connection (PhpMyAdmin)

```
URL: http://localhost:8080
Username: root
Password: root
Server: db
```

**Or Direct Connection:**
```
Host: localhost
Port: 3307
User: demandium
Pass: demandium123
Database: demandium_db
```

---

## 📡 API Base URL

```
http://localhost:8000/api
```

**Example Request:**
```bash
GET http://localhost:8000/api/health
GET http://localhost:8000/api/users
POST http://localhost:8000/api/auth/login
```

---

## 🐳 Docker Container Details

| Service | Image | Status | Port |
|---------|-------|--------|------|
| App | php:8.3-fpm | ✅ Running | 9000 |
| Nginx | nginx:alpine | ✅ Running | 8000 |
| MySQL | mysql:8.0 | ✅ Running | 3307 |
| PhpMyAdmin | phpmyadmin:latest | ✅ Running | 8080 |

---

## 🛠️ Common Commands

### **Inside Container**
```bash
# Run artisan command
docker compose exec -T app php artisan <command>

# Install package
docker compose exec -T app composer require package-name

# Open PHP shell
docker compose exec -T app php artisan tinker

# View logs
docker compose logs app -n 100
```

### **Container Management**
```bash
# List containers
docker compose ps

# Rebuild container
docker compose build app

# Fresh start
docker compose down -v && docker compose up -d

# Check resource usage
docker stats
```

---

## 📂 Important File Locations

```
/var/www/                    # App root in container
/var/www/.env                # Environment config
/var/www/storage/            # Uploads & logs
/var/www/public/             # Public files
/var/www/routes/api.php      # API endpoints
/var/www/Modules/*/Routes/   # Module routes
```

---

## 🔑 Environment Variables

```env
APP_URL=http://localhost:8000
DB_HOST=db
DB_PORT=3306
DB_USERNAME=demandium
DB_PASSWORD=demandium123
DB_DATABASE=demandium_db
```

---

## 📝 Logs Location

```
Docker Logs:
docker compose logs [service]

App Logs (inside container):
/var/www/storage/logs/

Error Log:
docker compose logs app | grep ERROR
```

---

## ✅ Health Checks

```bash
# Check if API is running
curl http://localhost:8000

# Check database connection
docker compose exec -T db mysql -u root -proot -e "SELECT 1;"

# Check PHP
docker compose exec -T app php -v

# Check Composer
docker compose exec -T app composer --version
```

---

## 🚨 Troubleshooting Checklist

- [ ] Docker Desktop is running
- [ ] Ports 8000, 8080, 3307 are not in use
- [ ] `docker compose ps` shows all 4 containers UP
- [ ] http://localhost:8000 returns 200 OK
- [ ] http://localhost:8080 is accessible
- [ ] Database credentials are correct
- [ ] .env file is configured
- [ ] Migrations have run successfully

---

## 📊 Database Tables

After migrations, you have:
```
- users
- posts
- post_bids
- oauth_clients
- oauth_tokens
- sessions
- cache
- jobs
- AI settings tables
```

---

## 🔗 Quick Links

- **API Base**: http://localhost:8000
- **PhpMyAdmin**: http://localhost:8080
- **Documentation**: Check DOCKER_SETUP_GUIDE.md
- **Laravel Docs**: https://laravel.com/docs/12
- **Docker Docs**: https://docs.docker.com

---

**Last Updated**: 2025-08-31  
**Status**: ✅ All Systems Operational
