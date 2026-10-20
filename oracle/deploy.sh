#!/bin/bash
# ===========================================================================
# Oracle Cloud (Always Free A1) — ONE-COMMAND DEPLOY
#
# Usage (on a fresh Ubuntu 24.04 ARM VM):
#   curl -fsSL https://raw.githubusercontent.com/ijaspreetsiingh/newcompany_project/main/oracle/deploy.sh | bash
#
# ya fir:
#   git clone https://github.com/ijaspreetsiingh/newcompany_project.git /opt/yovo
#   cd /opt/yovo
#   bash oracle/deploy.sh
#
# Ye script karega:
#   1. Docker + docker compose install (agar nahi hai)
#   2. .env.example -> .env (agar .env nahi hai)
#   3. docker build (ARM64) + docker compose up
#   4. migrate + seed + cache (entrypoint bhi karta hai, but yahan explicit)
# ===========================================================================
set -e

REPO_DIR="${REPO_DIR:-/opt/yovo}"
COMPOSE_FILE="docker-compose.prod.yml"

echo "=============================================="
echo "  YOVO Oracle Cloud Deploy"
echo "=============================================="

# ---- 1. Docker install ----
if ! command -v docker >/dev/null 2>&1; then
    echo "[1/6] Docker install kar raha hoon..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER"
    echo "[1/6] Docker installed. Logout/login karo group effect ke liye, phir script dobara chalao."
    exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
    echo "[1/6] docker compose plugin missing — install kar raha hoon..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq docker-compose-v2
fi

echo "[1/6] Docker OK: $(docker --version)"

# ---- 2. Repo ----
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "[2/6] Cloning repo..."
    sudo mkdir -p "$REPO_DIR"
    sudo chown "$USER:$USER" "$REPO_DIR"
    git clone https://github.com/ijaspreetsiingh/newcompany_project.git "$REPO_DIR"
fi
cd "$REPO_DIR"

# ---- 3. .env ----
if [ ! -f backend/.env ]; then
    echo "[3/6] backend/.env.example -> backend/.env"
    cp backend/.env.example backend/.env
    echo "  ⚠️  backend/.env me DB_PASSWORD, APP_KEY, APP_URL set karo!"
    echo "  APP_KEY generate:  php artisan key:generate --show"
    exit 1
fi

# ---- 4. Build ----
echo "[4/6] Building Docker image (ARM64, 8-15 min first time)..."
docker build -f Dockerfile.railway -t yovo-app:latest .

# ---- 5. Up ----
echo "[5/6] Starting services..."
docker compose -f "$COMPOSE_FILE" up -d

# ---- 6. Wait + verify ----
echo "[6/6] Waiting for app to be healthy (max 3 min)..."
for i in $(seq 1 36); do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost/ 2>/dev/null | grep -q "200\|302"; then
        echo "  app responding."
        break
    fi
    sleep 5
done

echo ""
echo "=============================================="
echo "  DEPLOYED ✅"
echo "=============================================="
echo "  Local:   http://localhost"
echo "  IP:      http://$(curl -s ifconfig.me 2>/dev/null || echo '<public-ip>')"
echo "  Logs:    docker compose -f $COMPOSE_FILE logs -f"
echo "  Shell:   docker compose -f $COMPOSE_FILE exec app bash"
echo "=============================================="
echo ""
echo "HTTPS ke liye: oracle/cloudflare-tunnel.sh chalao (free domain + auto HTTPS)"
