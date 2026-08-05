#!/usr/bin/env bash
# status:[ACTIVE] ver:[1.0.0] created:[26.02.25]
# doc:[COMPLETE] auth:[ZEN.PRO]
# Sync 1n3ox-temp landing page to VPS for 3ox.store

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VPS="${STORE_VPS:-root@5.78.109.54}"
VPS_WEB="${STORE_VPS_PATH:-/var/www/3ox.store}"
SSH_KEY="${STORE_SSH_KEY:-$HOME/.ssh/id_zens3n_vps}"

[[ -f "$SSH_KEY" ]] && SSH_OPTS=(-i "$SSH_KEY") || SSH_OPTS=()

echo "▛▞ SYNC 3OX.STORE → VPS"
ssh "${SSH_OPTS[@]}" "$VPS" "mkdir -p $VPS_WEB"
rsync -avz --delete \
  "${SSH_OPTS[@]}" \
  --exclude '.git' \
  --exclude 'sync-3ox-store.sh' \
  --exclude 'index.v1.html' \
  --exclude 'watch-and-receipt.py' \
  "$SCRIPT_DIR/" "$VPS:$VPS_WEB/"

echo ""
echo "✓ 3ox.store deployed to $VPS:$VPS_WEB"
