#!/usr/bin/env bash
# status:[ACTIVE] ver:[0.1.0] created:[26.05.04]
# doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
# Sync 3OX.Sidekik to VPS, regenerate TPR fragments, merge into TelePromptR,
# then `systemctl restart speaker-mesh`. Mirrors Money.Bagz/.3ox/sync-vps.sh.
#
# TPR (TelePromptR) is the only component that talks to Telegram.
# Sidekik never calls the Bot API — it hands off through TPR.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIDEKIK_ROOT="$SCRIPT_DIR"
VPS="${SIDEKIK_VPS:-root@5.78.109.54}"
VPS_SIDEKIK="${SIDEKIK_VPS_PATH:-/root/_TRON/Agents/Sidekik}"
TPR_REPO="${SIDEKIK_TPR_REPO:-/root/!CMD.VPS}"
SSH_KEY="${SIDEKIK_SSH_KEY:-$HOME/.ssh/id_zens3n_vps}"

[[ -f "$SSH_KEY" ]] && SSH_OPTS=(-i "$SSH_KEY") || SSH_OPTS=()

echo "▛▞ SYNC SIDEKIK → VPS"
rsync -avz --delete \
  "${SSH_OPTS[@]}" \
  --exclude '.git' \
  --exclude '.raven/inbox/*' --exclude '.raven/outbox/*' --exclude '.raven/tape/*' \
  --exclude '.3ox/(6)Pulse/runtime/*' \
  --exclude '!0UT.SIDEKIK/' \
  "$SIDEKIK_ROOT/" "$VPS:$VPS_SIDEKIK/"

echo ""
echo "▛▞ REFRESH SIDEKIK (teleprompt + update TPR config)"
ssh "${SSH_OPTS[@]}" "$VPS" \
  "cd $VPS_SIDEKIK && ruby .3ox/'(6)Pulse'/run.rb teleprompt && cd !0UT.SIDEKIK/tpr && TPR_ZENS3N=$TPR_REPO bash merge.sh"

echo ""
echo "▛▞ RESTART speaker-mesh"
ssh "${SSH_OPTS[@]}" "$VPS" 'systemctl restart speaker-mesh'

echo ""
echo "✓ Done"
