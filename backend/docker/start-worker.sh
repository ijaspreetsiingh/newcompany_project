#!/bin/sh
# ---------------------------------------------------------------------------
# Railway service: QUEUE WORKER
#
# Isko Railway me ek alag service ki tarah use karo (same Dockerfile, sirf
# start command badlo):
#     sh /var/www/docker/start-worker.sh
#
# Kaam: emails, notifications, booking auto-approve/countdown, exports etc.
# (QUEUE_CONNECTION=redis hona zaroori hai)
# ---------------------------------------------------------------------------
cd /var/www || exit 1

echo "[yovo] queue worker start"

while true; do
    # --max-time=3600 : har ghante restart (memory leak se bachao)
    # --tries=3       : failed job 3 baar try
    php artisan queue:work \
        --tries=3 \
        --max-time=3600 \
        --sleep=1 \
        --no-interaction

    echo "[yovo] queue worker exited - restarting in 5s"
    sleep 5
done
