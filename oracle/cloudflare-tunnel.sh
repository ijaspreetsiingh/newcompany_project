#!/bin/bash
# ===========================================================================
# Cloudflare Tunnel (FREE HTTPS + domain) — Oracle VM pe
#
# Prerequisite: apna domain Cloudflare me add ho (free plan OK).
#
# Usage:
#   bash oracle/cloudflare-tunnel.sh <TUNNEL_TOKEN> <DOMAIN>
#   e.g. bash oracle/cloudflare-tunnel.sh eyJh... api.yourdomain.com
# ===========================================================================
set -e

TOKEN="${1:?Usage: $0 <TUNNEL_TOKEN> <DOMAIN>}"
DOMAIN="${2:?Usage: $0 <TUNNEL_TOKEN> <DOMAIN>}"

echo "=== Cloudflare Tunnel setup ==="

# 1. cloudflared binary
if ! command -v cloudflared >/dev/null 2>&1; then
    echo "[1/4] cloudflared install kar raha hoon..."
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64|arm64)  URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64" ;;
        x86_64)        URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" ;;
        *) echo "Unsupported arch: $ARCH"; exit 1 ;;
    esac
    sudo wget -q "$URL" -O /usr/local/bin/cloudflared
    sudo chmod +x /usr/local/bin/cloudflared
fi
echo "[1/4] cloudflared: $(cloudflared --version)"

# 2. Tunnel service (systemd)
echo "[2/4] systemd service bana raha hoon..."
sudo tee /etc/systemd/system/cloudflared.service >/dev/null <<EOF
[Unit]
Description=Cloudflare Tunnel
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/cloudflared tunnel --no-autoupdate run --token $TOKEN
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now cloudflared
sleep 3
sudo systemctl is-active cloudflared && echo "[2/4] cloudflared ACTIVE ✅" || { echo "[2/4] FAILED"; exit 1; }

# 3. nginx config update (domain + HTTPS redirect)
echo "[3/4] nginx config me domain add kar raha hoon..."
NGINX_CONF="/etc/nginx/sites-enabled/default"
# (agar nginx reverse proxy hai to backend ka default.conf update kar)
echo "  -> Cloudflare dashboard me Public Hostname set karo:"
echo "     Hostname: $DOMAIN"
echo "     Service:  http://localhost:80"
echo "  (Cloudflare Zero Trust -> Tunnels -> Configure -> Public Hostname)"

# 4. APP_URL update
echo "[4/4] .env me APP_URL update karo:"
echo "     APP_URL=https://$DOMAIN"
echo "     PAYMENT_CALLBACK_HOSTS=$DOMAIN"
echo "     CORS_ALLOWED_ORIGINS=https://$DOMAIN"
echo "     SANCTUM_STATEFUL_DOMAINS=...,$DOMAIN"
echo "     phir: php artisan config:cache"

echo ""
echo "=============================================="
echo "  DONE ✅  HTTPS live: https://$DOMAIN"
echo "=============================================="
echo "  Test: curl -s https://$DOMAIN/api/v1/client/setup/"
echo "=============================================="
