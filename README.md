# newcompany_project

Multi-provider on-demand service platform — Laravel backend + Flutter apps (User, Service Man, Provider).

## Structure

| Folder | Description |
|--------|-------------|
| `backend/` | Laravel 12 API + Admin panel (PHP 8.2+) |
| `user-app/` | Customer Flutter app (+ web) |
| `service-man-app/` | Service man Flutter app |
| `provider-app/` | Provider Flutter app |

## Prerequisites (other laptop)

- **PHP 8.2+** + Composer
- **MySQL 8** + Redis
- **Flutter SDK** (Dart ^3.9 for user/service-man, ^3.10 for provider)
- **Node.js 18+** (for any JS tooling / `backend/serviceman-app` if needed)

## Clone

```bash
git clone https://github.com/ijaspreetsiingh/newcompany_project.git
cd newcompany_project
```

## 1. Backend setup

```bash
cd backend
composer install
cp .env.example .env
# edit .env → DB_*, APP_URL, REDIS_*
php artisan key:generate
php artisan passport:keys
php artisan storage:link
php artisan migrate --seed
php artisan serve
```

Default URL: `http://127.0.0.1:8000`

## 2. Flutter apps

```bash
# User app
cd user-app && flutter pub get && flutter run

# Service man
cd ../service-man-app && flutter pub get && flutter run

# Provider
cd ../provider-app && flutter pub get && flutter run
```

Update each app's API base URL (usually in `lib/util/app_constants.dart` or similar) to point at your backend.

## Notes

- `.env`, keystores, and private keys are **not** in the repo — copy from `.env.example`.
- `vendor/`, `node_modules/`, `build/`, `.dart_tool/` are gitignored — install after clone.
- Firebase `google-services.json` / `GoogleService-Info.plist` are included for builds; replace with your own Firebase project if needed.
