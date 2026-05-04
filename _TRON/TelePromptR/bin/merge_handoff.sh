#!/usr/bin/env bash
# status:[ACTIVE] ver:[1.0.0] created:[26.05.04]
# doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
# merge_handoff.sh — drop-in for TelePromptR/<TPR_ZENS3N>/merge.sh.
#
# After the existing merge.sh folds the per-agent
#   TPR.SPEAKER.MESH.json + TPR.ROUTE.MAP.json
# fragments into the master TPR config, source this script (or call it
# at the tail) so any pending tpr.handoff records are processed too.
#
# Wiring (existing merge.sh):
#   # ... existing fragment merge ...
#   bash "$(dirname "$0")/merge_handoff.sh"
#
# Or from systemd timer / one-shot service (recommended):
#   ExecStart=/usr/bin/ruby /root/_TRON/TelePromptR/bin/tpr_handoff.rb
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TPR_HANDOFF_RB="${TPR_HANDOFF_RB:-$HERE/tpr_handoff.rb}"
TPR_AGENTS_REGISTRY="${TPR_AGENTS_REGISTRY:-/etc/tpr/agents.json}"

if [[ ! -f "$TPR_HANDOFF_RB" ]]; then
  echo "[merge_handoff] missing $TPR_HANDOFF_RB" >&2
  exit 2
fi

export TPR_AGENTS_REGISTRY
exec /usr/bin/ruby "$TPR_HANDOFF_RB"
