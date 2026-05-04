///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.124 // WORKBOOK :: TelePromptR README ▞▞

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[26.05.04]
/// doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
/// TPR handoff consumer — agent → TPR fan-out, ships into /root/!CMD.VPS/TelePromptR
```

# `_TRON/TelePromptR/` — TPR-side handoff consumer

TelePromptR (TPR) is the only Telegram speaker. Agents emit
`tpr.handoff` JSON records under `<agent>/!0UT.<AGENT>/tpr/handoff/`.
This directory provides the **TPR-side** code that:

1. Validates each handoff against the canonical schema.
2. Resolves a topic for the sub-agent (override map, classified key, hint, fallback).
3. Enqueues a topic record into TPR's existing queue dir for speaker-mesh to pick up.
4. Writes an ack receipt next to the source and moves the source to `.processed/`.
5. Idempotent by `id`; stale records (default >72 h) are moved to `.expired/`.

## Why these files live here

The TPR runtime currently lives only on `CMD.VPS` at
`/root/!CMD.VPS/TelePromptR/` — there is **no TelePromptR git repo on
the LLMasterDesign org** that we can open a PR against. So this
directory is the **canon source**: the schema, validator, consumer, and
tests are reviewed inside `3OX.Ai`, then deployed to the VPS via
ordinary rsync (or git checkout) into `/root/_TRON/TelePromptR/`.

## Layout

```
_TRON/TelePromptR/
├── README.md
├── agents.example.json          # registry template (copy to /etc/tpr/agents.json)
├── route.map.example.json       # optional override map
├── bin/
│   ├── tpr_handoff.rb           # main entry point
│   └── merge_handoff.sh         # drop-in tail for existing TelePromptR/<TPR_ZENS3N>/merge.sh
├── docs/
│   ├── HANDOFF.SCHEMA.md        # canonical doc
│   └── handoff.schema.json      # JSON Schema (draft-2020-12)
├── lib/
│   ├── tpr_handoff_schema.rb    # validator (no gems)
│   └── tpr_handoff_consumer.rb  # consumer (no gems)
├── fixtures/handoff/            # 2 valid + 2 invalid fixtures
└── test/
    ├── test_schema.rb           # schema validator tests
    └── test_consumer.rb         # consumer tests (Dir.mktmpdir)

_TRON/systemd/
├── tpr-handoff.service          # oneshot, ExecStart=ruby bin/tpr_handoff.rb
└── tpr-handoff.timer            # OnUnitActiveSec=5s
```

## VPS install (one time)

```bash
# 1. Sync this directory onto the VPS.
rsync -avz _TRON/TelePromptR/ root@VPS:/root/_TRON/TelePromptR/

# 2. Drop the agent registry.
sudo install -m 0644 /root/_TRON/TelePromptR/agents.example.json /etc/tpr/agents.json
sudoedit /etc/tpr/agents.json   # set runtime_root + per-agent handoff_dir

# 3. Pick one of the two integration paths.

# 3a. Tail the existing merge.sh (cheapest, runs every sync):
echo 'bash /root/_TRON/TelePromptR/bin/merge_handoff.sh' >> /root/!CMD.VPS/TelePromptR/<TPR_ZENS3N>/merge.sh

# 3b. Periodic timer (runs every 5s independent of agent syncs):
sudo cp _TRON/systemd/tpr-handoff.{service,timer} /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now tpr-handoff.timer
```

## Local verification (no VPS needed)

```
$ cd _TRON/TelePromptR
$ ruby test/test_schema.rb         # schema tests
$ ruby test/test_consumer.rb       # consumer tests against tmpdirs
```

## Topic resolution order

1. `route_map.to_agent[<to_agent>]`
2. `route_map.classified_key[<classified_key>]`
3. `topics_hint[0]`
4. `to_agent` (fallback)

## Outputs (per handoff)

| Sink | Path | When |
|---|---|---|
| `topic.enqueue` line | `<runtime_root>/queue/<topic>.jsonl` | always on ack |
| ack receipt | `<handoff_dir>/.acks/<id>.ack.json` | on ack |
| processed source | `<handoff_dir>/.processed/<id>.handoff.json` | on ack |
| reject error | `<handoff_dir>/.rejected/<id>.error.json` | on schema fail |
| expired source | `<handoff_dir>/.expired/<id>.handoff.json` | when `now - created_at > stale_after_hours` |

## What this does NOT do

- Does not send Telegram messages (existing TelePromptR speaker handles that).
- Does not run inference (speaker-mesh handles that).
- Does not modify `TPR.SPEAKER.MESH.json` / `TPR.ROUTE.MAP.json` (existing `merge.sh` handles those).

:: ∎
