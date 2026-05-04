///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.124 // WORKBOOK :: RAVEN.SUITE.md ▞▞

```elixir
/// status:[ACTIVE] ver:[0.1.0] created:[26.05.04]
/// doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
/// Raven Suite — 3OX.Sidekik runtime, stability honesty, and roadmap
```

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
├── .raven/
│   ├── inbox/                    # *.intent.json, written by triage
│   ├── outbox/                   # *.reply.json, written by dispatch
│   └── tape/tape.jsonl           # append-only event tape
└── .3ox/
    ├── (1)Spark/sparkfile.md     # identity, glyph 🦅, slot E043
    ├── (2)Brains/brains.rs       # Sentinel brain + routing hints
    ├── (3)Rules/limits.toml      # narrow-only; defers to root Warden 12 laws
    ├── (4)Toolkit/tools.yml      # triage, dispatch, note, status, inference
    ├── (5)Links/routes.json      # subagent map (Money.Bagz, VSO.Agent…)
    ├── (6)Pulse/run.rb           # dispatcher into scripts/
    ├── _meta/
    │   ├── WHOAMI.md
    │   ├── SESSION.CHECKPOINT.toml
    │   ├── NAMING.CONTRACT.toml
    │   └── CHANGELOG.toml
    └── scripts/
        ├── triage.rb             # classify intent → write to inbox + tape
        ├── dispatch.rb           # drain inbox → outbox + receipts → tape
        ├── note.rb               # tape append (free text)
        └── status.rb             # snapshot → (6)Pulse/runtime/status.json
```

## Operator runbook (one screen)

```
cd "3OX Agents/Sidekik"

./sidekik say "pay the electric bill"   # → triage → dispatch → status
./sidekik note "remember to call dad"   # → tape append
./sidekik status                        # → fresh snapshot
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
| **`.vec3` runtime contents (`bin/`, `dev/`, `ops/`)** | ⚠️ stub | Folders exist with `.gitkeep` only. Adapters and ops are not yet wired. Sidekik works around this by keeping its event loop **inside the cube** (`raven.rb` + `.raven/`). |
| **Sidekik scripts** | ✅ MVP | `triage`, `dispatch`, `note`, `status` round-trip works (verified locally on this branch). |
| **Telegram + speaker-mesh integration** | ⚠️ external | Lives on CMD.VPS (per `_TRON/_TRON.CONTRACT.toml`); not in this repo. Sidekik's `routes.json` exposes the slots but the actual `TPR.SPEAKER.MESH.json` and topic id need to be filled in on first deploy. |
| **Sub-agent invocation (Money.Bagz, VSO.Agent)** | ⚠️ symbolic | `dispatch.rb` currently writes a *would-invoke* receipt. The real shell-out (e.g. `ruby Money.Bagz/.3ox/(6)Pulse/run.rb teleprompt`) is one line away — gated until Telegram/SSH config is supplied. |
| **EXC boundary surfaces** | 🟡 research | `routes.json → exc_boundary` documents the contract; concrete `.exc/.kdl/.exs` files live under `.3ox/(3)Rules/exc/` for TPW + Ring A. Encoder validates line-1 chip; semantic round-trip is not yet enforced in CI. |
| **3OX.BUILDER (`brain.exe` compile path)** | 🟡 partial | Cargo + boot/ exist; full Rust 1.85 build still has open work in PR #14 (CONFLICTING with main). Sidekik does **not** require it — `brains.rs` is descriptive. |

### What's missing to call this "production daily-driver"

1. **PR #14** (Dev environment Rust 1.85+ fixes) needs to be rebased on the merged Warden + hex stack. Right now it's `CONFLICTING`.
2. **Real adapter under `.vec3/dev/`**: at minimum a `telegram_in.rb` and `telegram_out.rb` (or a thin HTTP webhook receiver). Without it, intents enter only via the local `sidekik say` CLI.
3. **Sub-agent shell-out** in `dispatch.rb` (one block per route_to). Currently symbolic by design — the wire format is locked, the call isn't.
4. **Receipt schema enforcement**: `_meta/ENCODER.RECEIPT.schema.json` is in the encoder PR set but not yet wired into `dispatch.rb`. Sidekik writes receipts that *match* the shape; CI does not yet validate them.
5. **Sirius clock**: `3OX.BUILDER/sirius.clock.rb` exists; cube imprints use `⧗-YY.SSS` manually. A pre-commit hook or `_meta/CHANGELOG.toml` updater would close the loop.

## Verdict

The substrate **is** stable enough to host Sidekik today. The encoder and
hex codebook are settled. The Warden laws are enforced in CI. The Box
aliveness contract is binary and reproducible. What you've been missing
is **the agent itself** and a small, opinionated supervisor wrapped
around the cube — that's what the Raven Suite supplies in this branch.

Next sensible PR after this one: **revive PR #14** (rebase on main) so
the BUILDER cargo path compiles, then add a single Telegram adapter
under `.vec3/dev/` and flip `dispatch.rb` from symbolic to live.

:: ∎
