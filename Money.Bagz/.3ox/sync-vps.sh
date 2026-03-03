#!/usr/bin/env bash
# status:[ACTIVE] ver:[1.0.0] created:[26.01.02]
# doc:[COMPLETE] modified:[26.03.03] auth:[ZEN.PRO]
# Sync Money.Bagz (Budget) to VPS, refresh TPR config

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUDGET_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VPS="${BUDGET_VPS:-root@5.78.109.54}"
VPS_BUDGET="${BUDGET_VPS_PATH:-/root/!CMD.VPS/BudgetR}"
TPR_REPO="${BUDGET_TPR_REPO:-/root/!CMD.VPS}"
SSH_KEY="${BUDGET_SSH_KEY:-$HOME/.ssh/id_zens3n_vps}"

[[ -f "$SSH_KEY" ]] && SSH_OPTS=(-i "$SSH_KEY") || SSH_OPTS=()

echo "▛▞ SYNC BUDGET → VPS"
rsync -avz --delete \
  "${SSH_OPTS[@]}" \
  --exclude '.git' \
  --exclude '!0UT.BUDGET/reports' \
  --exclude '!0UT.BUDGET/alerts' \
  "$BUDGET_ROOT/" "$VPS:$VPS_BUDGET/"

echo ""
echo "▛▞ REFRESH MONEY.BAGZ (teleprompt + update TPR config)"
ssh "${SSH_OPTS[@]}" "$VPS" "cd $VPS_BUDGET && ruby .3ox/run.rb teleprompt && cd !0UT.BUDGET/tpr && TPR_ZENS3N=$TPR_REPO bash merge.sh"

echo ""
echo "▛▞ RESTART speaker-mesh"
ssh "${SSH_OPTS[@]}" "$VPS" 'systemctl restart speaker-mesh'

echo ""
echo "✓ Done"
