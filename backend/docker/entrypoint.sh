#!/bin/sh
set -e

export PORT="${PORT:-10000}"

envsubst '${PORT}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

cd /var/www/html

mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs

if [ -z "$APP_URL" ] && [ -n "$RENDER_EXTERNAL_URL" ]; then
    export APP_URL="$RENDER_EXTERNAL_URL"
fi

echo "[entrypoint] APP_URL=$APP_URL PORT=$PORT"

if [ ! -f storage/oauth-private.key ]; then
    echo "[entrypoint] generating passport keys..."
    php artisan passport:keys || true
fi

php artisan storage:link || true

echo "[entrypoint] importing baseline SQL (if fresh DB)..."
php artisan db:import-baseline || true

echo "[entrypoint] running migrations..."
php artisan migrate --force || true

echo "[entrypoint] seeding..."
php artisan db:seed --class=LoginSetupSeeder --force || true
php artisan db:seed --class=AdminUserSeeder --force || true

echo "[entrypoint] caching config..."
php artisan config:cache || true
php artisan view:cache || true

echo "[entrypoint] starting supervisord..."
exec supervisord -c /etc/supervisord.conf
