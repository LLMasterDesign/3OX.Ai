///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.124 // WORKBOOK :: RAVEN.SUITE.md ▞▞

```elixir
/// status:[ACTIVE] ver:[0.2.0] created:[26.05.04]
/// doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
/// Raven Suite — 3OX.Sidekik runtime, TPR-first integration, and roadmap
```

## Architectural correction (v0.2.0, 4 May 2026)

> **TPR (TelePromptR) is the only Telegram speaker. Everything else uses TelePromptR.** — Lucius

Previous drafts of this doc proposed adding a Telegram adapter under
`.vec3/dev/`. That was wrong. The runtime contract is:

- `teleprompter.service` (TPR) — Telegram gateway and per-topic router.
- `speaker-mesh.service`        — LLM inference + reply streaming.
- Agents (Sidekik, Money.Bagz, VSO.Agent…) **never** call the Telegram
  Bot API directly. They emit two JSON fragments — `TPR.SPEAKER.MESH.json`
  and `TPR.ROUTE.MAP.json` — and let TPR's `merge.sh` fold them into the
  master config on the VPS, then `systemctl restart speaker-mesh`.

Sidekik now follows that contract: `scripts/teleprompt.rb` writes the
fragments under `!0UT.SIDEKIK/tpr/`, and `dispatch.rb` writes a
`tpr.handoff` receipt under `!0UT.SIDEKIK/tpr/handoff/` for any intent
routing to a sub-agent. The deployment loop is the same shape as
Money.Bagz: `bash sync-vps.sh`.

# Raven Suite

The **Raven Suite** is the operator-facing runtime for **3OX.Sidekik** —
Lucius's daily-driver agent. It sits on top of the existing 3OX kernel
(`.3ox` + `.vec3`) and adds: an inbox/outbox/tape, a supervisor loop
(`raven.rb`), and a small CLI (`sidekik`).

## Layout

```
3OX Agents/Sidekik/
├── sidekik                       # bash CLI
├── raven.rb                      # supervisor loop
├── sync-vps.sh                   # rsync + TPR merge + speaker-mesh restart
├── .raven/
│   ├── inbox/                    # *.intent.json, written by triage
│   ├── outbox/                   # *.reply.json, written by dispatch
│   └── tape/tape.jsonl           # append-only event tape
├── !0UT.SIDEKIK/
│   └── tpr/                      # TPR fragments (merged on VPS)
│       ├── TPR.SPEAKER.MESH.json # speaker fragment, persona + system prompt
│       ├── TPR.ROUTE.MAP.json    # route fragment, topic ↔ intent map
│       ├── TPR.RECEIPT.json      # last emit receipt
│       └── handoff/              # *.handoff.json — sub-agent fan-outs
└── .3ox/
    ├── (1)Spark/sparkfile.md     # identity, glyph 🦅, slot E043
    ├── (2)Brains/brains.rs       # Sentinel brain + routing hints
    ├── (3)Rules/limits.toml      # narrow-only; defers to root Warden 12 laws
    ├── (4)Toolkit/tools.yml      # triage, dispatch, note, status, teleprompt
    ├── (5)Links/routes.json      # subagent map + tpr fragment dir
    ├── (6)Pulse/run.rb           # dispatcher into scripts/
    ├── _meta/
    │   ├── WHOAMI.md
    │   ├── SESSION.CHECKPOINT.toml
    │   ├── NAMING.CONTRACT.toml
    │   └── CHANGELOG.toml
    └── scripts/
        ├── triage.rb             # classify intent → write to inbox + tape
        ├── dispatch.rb           # drain inbox → outbox + TPR handoffs + tape
        ├── note.rb               # tape append (free text)
        ├── status.rb             # snapshot → (6)Pulse/runtime/status.json
        └── teleprompt.rb         # emit TPR speaker + route fragments
```

## Operator runbook (one screen)

```
cd "3OX Agents/Sidekik"

./sidekik say "pay the electric bill"   # → triage → dispatch → status
./sidekik note "remember to call dad"   # → tape append
./sidekik status                        # → fresh snapshot
./sidekik teleprompt                    # → regenerate TPR fragments
./sidekik sync                          # → rsync to VPS + TPR merge + restart speaker-mesh
./sidekik up                            # detach raven supervisor (interval=5s)
./sidekik down                          # stop supervisor
./sidekik tick                          # one cycle, no detach
./sidekik alive                         # local Box-aliveness verdict
```

Root kernel aliveness still owns the global verdict:

```
ruby .3ox/run.rb queue noop && ruby .3ox/run.rb once noop
ruby .vec3/rc/run.rb aliveness    # exit 0 ⇨ valid_box3 + authoritative
```

## Slot claim

- Hex chip: **`::0x02B::`**  (claimed in `.3ox/(5)Links/hex.index.json`)
- ξ slot: **`E043 SIDEKIK.RAVEN`**, route_key `sidekik.raven`
- Allowlist mirrored in root `(4)Toolkit/tools.yml` slots map

## Stability honesty (4 May 2026)

This is a working starter; some of the substrate around it is still
being assembled. Below is the honest verdict per layer.

| Layer | State | Notes |
|---|---|---|
| **Substrate (`.3ox` + `.vec3` kernel)** | ✅ stable | `ruby .vec3/rc/run.rb aliveness` returns exit 0 with `valid_box3` + `authoritative` true; encoder CI green on main. |
| **Encoder + hex codebook (4096)** | ✅ stable | `scripts/encoder_validate.py` passes. 36 entries claimed (post-Sidekik). Single-source-of-truth rule enforced. |
| **Warden twelve laws** | ✅ stable | PR #23 merged. `scripts/warden_laws_validate.py` enforces 12 laws, sequential ids, code set, field counts (27/216/243), hashing keys. |
| **Ring A/B/C specs** | ✅ stable | Specs `0x110–0x139` present, line-1 chip CI passing. |
| **Box aliveness contract** | ✅ stable | PR #13 merged. `aliveness` is binary, hashed, exit-coded. |
| **`.vec3` runtime contents (`bin/`, `dev/`, `ops/`)** | ⚠️ stub | Folders exist with `.gitkeep` only — and they should stay narrow. Telegram I/O lives in **TPR**, not here, so no `telegram_in.rb`/`telegram_out.rb` is needed under `.vec3/dev/`. |
| **Sidekik scripts** | ✅ MVP | `triage`, `dispatch`, `note`, `status`, `teleprompt` round-trip works locally (verified on this branch). |
| **TPR (TelePromptR) integration** | ✅ wired | `scripts/teleprompt.rb` emits `TPR.SPEAKER.MESH.json` + `TPR.ROUTE.MAP.json`. `sync-vps.sh` mirrors Money.Bagz pattern: rsync → `merge.sh` → `systemctl restart speaker-mesh`. Telegram chat/topic IDs in `(5)Links/routes.json` are blank until Lucius binds Sidekik to a topic. |
| **Sub-agent fan-out** | ✅ via TPR handoff | `dispatch.rb` writes a `tpr.handoff` receipt under `!0UT.SIDEKIK/tpr/handoff/` for each non-self route. TPR consumes the handoff and re-routes to the sub-agent's topic; speaker-mesh handles inference. No agent-to-agent shell-out. |
| **EXC boundary surfaces** | 🟡 research | `routes.json → exc_boundary` documents the contract; concrete `.exc/.kdl/.exs` files live under `.3ox/(3)Rules/exc/` for TPW + Ring A. Encoder validates line-1 chip; semantic round-trip is not yet enforced in CI. |
| **3OX.BUILDER (`brain.exe` compile path)** | ✅ green | PR #26 merged: cargo workspace builds + tests on stable rustc, CI workflow added. |

### What's missing to call this "production daily-driver"

1. **First-deploy config**: fill in `telegram.chat_id` + `allowed_topics` in `3OX Agents/Sidekik/.3ox/(5)Links/routes.json`, then `bash sync-vps.sh`. Same shape Money.Bagz uses.
2. **TPR-side awareness of the `tpr.handoff` shape**: TelePromptR's existing per-topic router already reads JSON fragments; document the `*.handoff.json` schema in `_meta/` and confirm the merge.sh on VPS picks up `handoff/` (or extend it if not).
3. **Receipt schema enforcement**: `_meta/ENCODER.RECEIPT.schema.json` is present but not wired into `dispatch.rb` / `teleprompt.rb`. Add CI that validates the emitted fragments against the schema.
4. **Sirius clock**: `3OX.BUILDER/sirius.clock.rb` exists; cube imprints use `⧗-YY.SSS` manually. A pre-commit hook or `_meta/CHANGELOG.toml` updater would close the loop.

## Verdict

The substrate **is** stable enough to host Sidekik today. The encoder and
hex codebook are settled. The Warden laws are enforced in CI. The Box
aliveness contract is binary and reproducible. The cargo workspace
builds clean on stable rustc. **TPR is the single Telegram speaker, and
Sidekik now plugs into it the same way Money.Bagz does.**

Next sensible PR after this one: receipt-schema CI for the TPR fragments,
and a small documentation pass on the `tpr.handoff` schema so other
agents (VSO.Agent, future sub-agents) follow the same handoff shape.

:: ∎
