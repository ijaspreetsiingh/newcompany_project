#!/bin/sh
# ---------------------------------------------------------------------------
# Railway service: SCHEDULER
#
# Railway me ek alag service banao (same Dockerfile, start command):
#     sh /var/www/docker/start-scheduler.sh
#
# Ye routes/console.php ka schedule chalata hai:
#   - AutoApproveBookingJob (har 30 second) → serviceman accept countdown
#     expire, provider manual queue, booking expiry/re-assign
#   - daily: recheck expiry, subscription mails, backup, queue prune
#
# BINA scheduler ye sab band rehta hai.
# ---------------------------------------------------------------------------
cd /var/www || exit 1

echo "[yovo] scheduler start"

while true; do
    php artisan schedule:work

    echo "[yovo] scheduler exited - restarting in 5s"
    sleep 5
done
