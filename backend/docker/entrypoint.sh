#!/bin/sh
set -e

export PORT="${PORT:-10000}"

envsubst '${PORT}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

cd /var/www/html

mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs
chown -R www-data:www-data storage bootstrap/cache
chmod -R u+rwX storage bootstrap/cache

if [ -z "$APP_URL" ] && [ -n "$RENDER_EXTERNAL_URL" ]; then
    export APP_URL="$RENDER_EXTERNAL_URL"
fi

echo "[entrypoint] APP_URL=$APP_URL PORT=$PORT"

echo "[diag] disk:"
df -h /var/www/html | tail -1
echo "[diag] storage ownership:"
ls -la /var/www/html/storage/framework/ | head -10
echo "[diag] cache dir:"
ls -la /var/www/html/storage/framework/cache/
echo "[diag] www-data write test:"
su -s /bin/sh www-data -c 'touch /var/www/html/storage/framework/cache/__wt && echo "[diag] WWWDATA_WRITE=OK" || echo "[diag] WWWDATA_WRITE=FAIL"' || true
rm -f /var/www/html/storage/framework/cache/__wt
echo "[diag] php-fpm pool user:"
grep -E "^user|^;" /usr/local/etc/php-fpm.d/www.conf | grep user || true

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
