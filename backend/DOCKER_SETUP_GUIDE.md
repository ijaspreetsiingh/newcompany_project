# Demandium Backend - Docker Setup Guide

## ✅ Status: FULLY RUNNING & READY

Your backend is now **100% operational** with Docker Desktop!

---

## 🚀 What's Running

| Service | Container | Status | Port | Access |
|---------|-----------|--------|------|--------|
| **Laravel API** | demandium-app | ✅ Running | 9000 (internal) | http://localhost:8000 |
| **Nginx Web Server** | demandium-nginx | ✅ Running | 8000 | http://localhost:8000 |
| **MySQL Database** | demandium-db | ✅ Running | 3307 | localhost:3307 |
| **PhpMyAdmin** | demandium-phpmyadmin | ✅ Running | 8080 | http://localhost:8080 |

---

## 📱 Access Points

### 1. **Laravel API** (Main Backend)
```
URL: http://localhost:8000
Status: ✅ Working
Method: REST API
```

### 2. **PhpMyAdmin** (Database Manager)
```
URL: http://localhost:8080
Username: root
Password: root
Database: demandium_db
```

**Login Steps:**
- Go to http://localhost:8080
- Username: `root`
- Password: `root`
- Server: `db`
- Click Login

### 3. **Database Direct Access**
```
Host: localhost
Port: 3307
Database: demandium_db
Username: demandium
Password: demandium123
```

---

## 🔧 Useful Docker Commands

### **View Running Containers**
```powershell
docker compose ps
```

### **View Logs (Real-time)**
```powershell
docker compose logs -f
```

### **View App Logs Only**
```powershell
docker compose logs app -f
```

### **Stop All Containers**
```powershell
docker compose down
```

### **Start Containers**
```powershell
docker compose up -d
```

### **Restart Containers**
```powershell
docker compose restart
```

### **Clear Cache**
```powershell
docker compose exec -T app php artisan cache:clear
docker compose exec -T app php artisan config:clear
```

### **Run Artisan Commands**
```powershell
docker compose exec -T app php artisan migrate
docker compose exec -T app php artisan tinker
docker compose exec -T app composer require package-name
```

### **Execute Shell in Container**
```powershell
docker compose exec app bash
```

### **View Database**
```powershell
docker compose exec db mysql -u demandium -pdemandium123 demandium_db
```

---

## 📊 Database Info

| Property | Value |
|----------|-------|
| **Host** | db (internal) / localhost (external) |
| **Port** | 3306 (internal) / 3307 (external) |
| **Database** | demandium_db |
| **Root User** | root |
| **Root Password** | root |
| **App User** | demandium |
| **App Password** | demandium123 |

---

## 🔑 Environment Variables (.env)

```env
APP_NAME=Demandium
APP_ENV=local
APP_KEY=base64:BEoBVy0tFNvSjPwBew/LYrOfYYrJYMqNON0AUaB3Dmg=
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=demandium_db
DB_USERNAME=demandium
DB_PASSWORD=demandium123
```

---

## 🏗️ Project Structure

```
backend/
├── app/                      # Application code
├── Modules/                  # 21 Modular features
│   ├── AI/
│   ├── Auth/
│   ├── BookingModule/
│   ├── CartModule/
│   ├── PaymentModule/
│   ├── AdminModule/
│   └── ... (18 more modules)
├── database/
│   ├── migrations/           # Database schemas
│   └── seeders/             # Demo data
├── config/                   # Configuration
├── routes/                   # API routes
├── public/                   # Static files
├── storage/                  # Uploads, logs
├── Dockerfile               # Container definition
├── docker-compose.yml       # Multi-container setup
├── nginx.conf               # Web server config
└── .env                     # Environment variables
```

---

## 📝 API Endpoints

### **Base URL**
```
http://localhost:8000/api
```

### **Health Check**
```
GET http://localhost:8000
Response: 200 OK
```

### **Available Modules** (Check routes/api.php for full list)
- `/api/auth/*` - Authentication
- `/api/users/*` - User management
- `/api/services/*` - Service management
- `/api/bookings/*` - Booking management
- `/api/providers/*` - Provider management
- `/api/payments/*` - Payment processing
- `/api/chats/*` - Messaging
- `/api/reviews/*` - Reviews & ratings
- `/api/admin/*` - Admin panel
- `/api/transactions/*` - Transaction history

---

## 🛠️ Troubleshooting

### **Issue: Port 8000 already in use**
```powershell
# Change port in docker-compose.yml
# Find: ports: - "8000:80"
# Change to: ports: - "9000:80" (for example)
docker compose down
docker compose up -d
```

### **Issue: 500 Error on API**
```powershell
docker compose exec -T app php artisan cache:clear
docker compose exec -T app php artisan config:clear
docker compose logs app
```

### **Issue: Database connection error**
```powershell
# Wait for DB to fully start
docker compose down
docker compose up -d db
docker wait demandium-db  # Wait 10 seconds
docker compose up -d
```

### **Issue: PhpMyAdmin connection refused**
```powershell
docker compose restart db phpmyadmin
```

### **Issue: Composer dependency error**
```powershell
docker compose exec -T app composer update
docker compose exec -T app composer dump-autoload
```

---

## 📦 Key Technologies

| Technology | Version | Purpose |
|-----------|---------|---------|
| **Laravel** | 12.x | Framework |
| **PHP** | 8.3 | Language |
| **MySQL** | 8.0 | Database |
| **Nginx** | Alpine | Web Server |
| **Composer** | Latest | PHP Package Manager |

---

## 🔐 Security Notes

⚠️ **For Production:**
- Change `.env` password `root` to strong password
- Set `APP_DEBUG=false`
- Set `APP_ENV=production`
- Use `APP_KEY` secret from generator
- Enable HTTPS/SSL
- Setup proper firewall rules
- Use environment secrets for sensitive data

---

## 📋 Docker File Breakdown

### **Dockerfile** (PHP + Extensions)
- Built from `php:8.3-fpm`
- Includes: MySQL, Redis, GD, ZIP, Intl, etc.
- Max upload: 64MB
- Memory limit: 512MB
- Execution time: 300s

### **docker-compose.yml** (4 Services)
1. **app** - Laravel PHP-FPM
2. **db** - MySQL 8.0 (persistent volume)
3. **nginx** - Web server (port 8000)
4. **phpmyadmin** - Database UI (port 8080)

### **nginx.conf** (Web Server Config)
- FastCGI backend: app:9000
- Max body size: 64M
- Gzip compression enabled
- Static file caching

---

## ✨ Next Steps

### **Option 1: Connect Flutter Frontend**
```
Update lib/config/api_endpoints.dart:
const String API_BASE_URL = 'http://YOUR_COMPUTER_IP:8000/api';
```

### **Option 2: Test with Postman**
- Download Postman
- Import collection from API docs
- Set base URL: `http://localhost:8000/api`
- Start testing endpoints

### **Option 3: Build Mobile App**
```powershell
cd "..\User app and web"
flutter pub get
flutter run -d chrome --web-port 5000
```

### **Option 4: Deploy to Cloud**
- AWS EC2 / Lightsail
- DigitalOcean
- Azure
- Google Cloud Platform

---

## 📞 Support Resources

- **Official Docs**: https://jiourl.com/uNhZvD
- **Laravel Docs**: https://laravel.com/docs
- **Docker Docs**: https://docs.docker.com
- **API Testing**: Postman, Thunder Client, REST Client

---

## 🎉 You're All Set!

Your Demandium backend is **production-ready** and running with:
- ✅ Full Laravel API
- ✅ MySQL database with migrations
- ✅ Nginx web server
- ✅ PhpMyAdmin admin panel
- ✅ Docker containerization
- ✅ All 21 modules loaded

**Happy coding! 🚀**
