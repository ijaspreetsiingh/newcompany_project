#!/bin/sh
# ---------------------------------------------------------------------------
# Railway: SINGLE container me nginx + php-fpm + queue worker + scheduler
#
# Start command: sh /var/www/docker/start-all.sh
# ---------------------------------------------------------------------------
cd /var/www || exit 1

echo "[yovo] Railway deploy — starting all services"

# --- Storage link ---
php artisan storage:link 2>/dev/null || true

# --- Config/Route/View cache ---
php artisan config:cache 2>/dev/null || true
php artisan route:cache 2>/dev/null || true
php artisan view:cache 2>/dev/null || true

# --- Run pending migrations ---
php artisan migrate --force 2>/dev/null || true

# --- Queue worker (background, restart loop) ---
(
    while true; do
        php artisan queue:work --tries=3 --max-time=3600 --sleep=1 --no-interaction
        echo "[yovo] queue worker exited - restarting in 5s"
        sleep 5
    done
) &

# --- Scheduler (background, restart loop) ---
(
    while true; do
        php artisan schedule:work
        echo "[yovo] scheduler exited - restarting in 5s"
        sleep 5
    done
) &

# --- Start php-fpm in background ---
php-fpm -D

echo "[yovo] php-fpm started, launching nginx on port ${PORT:-80}"

# --- Nginx uses PORT env variable from Railway ---
# Replace ${PORT} placeholder in nginx config
if [ -n "$PORT" ]; then
    sed -i "s/\${PORT:-80}/$PORT/g" /etc/nginx/sites-available/default
else
    sed -i "s/\${PORT:-80}/80/g" /etc/nginx/sites-available/default
fi

# --- Start nginx (foreground - keeps container alive) ---
exec nginx -g 'daemon off;'
