///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.062 // WORKBOOK :: PLAN.md ▞▞

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[26.03.03]
/// doc:[PARTIAL] modified:[26.03.03] auth:[ZEN.PRO]
/// 3OX.Ai launch plan — substrates, branches, agents, Telegram
```

# 3OX.Ai — Launch Plan

## GOAL

A running 3OX system where agents communicate via Telegram.
ZEN.PRO builds it. CMD owns the runtime. _TRON orchestrates it.

────────────────────────────────────────────────
## BRANCH LAYOUT
────────────────────────────────────────────────

```
main                          ← stable releases only
│
├── substrate/elixir-frontmatter  ← frontmatter spec + conversions (DONE)
│
├── tron/systemd              ← _TRON runtime: systemd units, lifecycle
│   ├── speaker-mesh.service
│   ├── teleprompter.service
│   ├── _TRON.CONTRACT.toml   ← per-device contract (VPS, WSL, Mac)
│   └── lifecycle/
│       └── whoami.watch.service
│
├── meta/logging              ← _meta contracts, session checkpoints
│   ├── _meta/
│   │   ├── WHOAMI.md
│   │   ├── NAMING.CONTRACT.toml
│   │   ├── SESSION.CHECKPOINT.toml
│   │   └── CHANGELOG.toml
│   └── receipts/
│
├── structure/3ox-core        ← L2 + L3 canonical layout
│   ├── .3ox/                 ← L2: 6 core files (cube faces)
│   │   ├── (1)Spark/         sparkfile.md
│   │   ├── (2)Brains/        brains.rs
│   │   ├── (3)Rules/         limits.toml
│   │   ├── (4)Toolkit/       tools.yml
│   │   ├── (5)Links/         routes.json
│   │   └── (6)Pulse/         run.rb, receipts
│   │
│   └── .vec3/                ← L3: 7 surfaces (runtime kernel)
│       ├── rc/               run control, lifecycle, boot
│       ├── lib/              protected references, snips, prompts
│       ├── dev/              device bridges, adapters, drivers, ops
│       ├── var/              live state, receipts mirror, cursors, metrics
│       ├── proto/            gRPC contracts, interface definitions
│       ├── proc/             workers, queue, agents, self, kernel
│       └── mem/              hot, deep, context (Project Orion at k07)
│
└── agents/live               ← deployed agent cubes
    ├── Money.Bagz/
    │   ├── .3ox/             (L2 files)
    │   └── sync-vps.sh
    ├── VSO.Agent/
    │   ├── .3ox/             (L2 files + vec3)
    │   └── sync-vps.sh
    └── [future agents]/
```

────────────────────────────────────────────────
## 3OX.Core{} — 27 SLOT EXECUTION CHAMBER
────────────────────────────────────────────────

`3OX` is written with the triadic B-glyph and spoken as `BOX`.
The protected execution chamber is `3OX.Core{}`; members are addressed
inside that chamber, e.g. `3OX.Core{Axis}`, not `3OX.Axis`.

```
3OX.Core{} = Axis[3] + Encode[6] + Ring[9] + System[9]
```

| Group | Slots | Purpose |
|-------|-------|---------|
| `Axis` | 3 | Execution authorities: Warden, Tape, Pulse |
| `Encode` | 6 | Operation encoding gates |
| `Ring` | 9 | Ordered sequence for every operation |
| `System` | 9 | Protected system requirements |

### Axis[3]

| Slot | Duty | Language Anchor |
|------|------|-----------------|
| Warden | validation, permissions, boundaries | Rust |
| Tape | memory, encoding, digest trail | Lisp |
| Pulse | liveness, daemon state, execution flow | Elixir |

#### Rotor: `3OX.SPIN`

The rotary encoder of `Core{Axis}` is **`3OX.SPIN`**. One spin = one
walk of `Warden → Tape → Pulse`. It is the system's only clock —
edges arrive on spin, never on a wall-clock tick.

| Field | Value |
|-------|-------|
| Spec | `.3ox/(3)Rules/exc/axis/3OX.SPIN.spec` |
| Hex | `0x003` |
| Slot | `k00` |
| Bundle title | `3OX.SPIN.bundle` (in `hex.index.json`) |
| Edge sources | operator CLI · systemd `path` units · TPR `merge.sh` tail |

`3OX.SPIN` was previously labelled `TPW.SPIN` and lived under
`.3ox/(3)Rules/exc/tpw/`. Renamed to match the canonical `Core{Axis}`
hierarchy in this PR's sibling `3ox-spin-rename` PR.

### Encode[6]

| Slot | Duty |
|------|------|
| Intent | what wants to happen |
| Authority | who or what may do it |
| State | what state is touched |
| Route | where it must travel |
| Memory | what must be recorded |
| Seal | how it is closed and proven |

### Ring[9]

1. Intake
2. Validate
3. Encode
4. Route
5. Execute
6. Observe
7. Digest
8. Commit
9. Recover

### System[9]

`System[9]` uses a 2-4-3 grouping:

| Group | Slots | Members |
|-------|-------|---------|
| Anchor | 2 | Meta, Tron |
| Control | 4 | Chmod, Daemon, Cage, Route |
| Seal | 3 | Hash, Vault, Patch |

Hash policy:

| Scope | Hash |
|-------|------|
| Internal frame integrity | xxh3 |
| External durable proof | sha-256 |

Core laws:

- Axis authorizes.
- Encode transforms.
- Ring sequences.
- System protects.
- Nothing leaves Core{} unencoded.
- No operation bypasses Axis.

────────────────────────────────────────────────
## L2 — 6 CORE FILES (per .3ox cube)
────────────────────────────────────────────────

Every agent, station, and service has a `.3ox/` directory
containing exactly 6 faces:

| Face | File | Purpose |
|------|------|---------|
| (1) Spark | `sparkfile.md` | Identity, origin, PHENO chain |
| (2) Brains | `brains.rs` | Personality, rules, brain type |
| (3) Rules | `limits.toml` | Constraints, write policy |
| (4) Toolkit | `tools.yml` | Available tools and capabilities |
| (5) Links | `routes.json` | Routing, connections, topics |
| (6) Pulse | `run.rb` | Entry point, receipts, lifecycle |

────────────────────────────────────────────────
## L3 — 7 SURFACES (per .vec3 kernel)
────────────────────────────────────────────────

Runtime kernel — sits alongside `.3ox/` as `.vec3/`. Full canon:
`_meta/VEC3.SURFACES.md`.

| Surface | Role | Purpose |
|---|---|---|
| `rc/` | control | Law and boot — `rules.ref`, `sys.ref`, `boot.lock`, binaries |
| `lib/` | reference | Protected logic and canon — `snips/`, `prompts/`, `static/`, `*.ref` |
| `dev/` | action | Adapters, drivers, executable bridges, ops — outside-world surface |
| `var/` | state | Live state, receipts mirror, cursors, metrics |
| `proto/` | agreement | gRPC service contracts, interface definitions |
| `proc/` | process | `workers/`, `queue/`, `agents/`, `self/`, `kernel/` (Supervisor owns lifecycle) |
| `mem/` | continuity | `hot/`, `deep/`, `context/` — owned by `Core{Encode}.Memory` (k07, Project Orion) |

Place ≠ authority. See `_meta/VEC3.SURFACES.md` §Ownership map.

────────────────────────────────────────────────
## _META CONTRACT (per cube)
────────────────────────────────────────────────

Every `.3ox/` must have `_meta/` with:

| File | Purpose |
|------|---------|
| `WHOAMI.md` | Identity, TRON path, lifecycle service |
| `NAMING.CONTRACT.toml` | Naming rules, extensions, staging |
| `SESSION.CHECKPOINT.toml` | Resume state, truth paths, drift |
| `CHANGELOG.toml` | Change feed |

────────────────────────────────────────────────
## _TRON CONTRACT (per device)
────────────────────────────────────────────────

Each device running 3OX has a `_TRON.CONTRACT.toml`:

```toml
[device]
name = "CMD.VPS"
host = "5.78.109.54"
role = "runtime"           # runtime | build | mobile

[paths]
tron_root   = "/root/_TRON"
cmd_root    = "/root/!CMD.VPS"
tpr_root    = "/root/!CMD.VPS/TelePromptR"

[services]
speaker_mesh   = "active"
teleprompter   = "active"

[agents]
money_bagz     = "/root/!CMD.VPS/BudgetR"
```

Devices:
- **CMD.VPS** — runtime (Telegram agents live here)
- **ZEN.PRO** — build (Mac, Cursor, manufacturer)
- **ZENS3N.CMD** — WSL (full _TRON, 5TRATA)

────────────────────────────────────────────────
## WHAT EXISTS (working right now)
────────────────────────────────────────────────

✓ Money.Bagz agent responds via Telegram
✓ TelePromptR routes messages to agents by topic
✓ speaker-mesh handles LLM inference + streaming
✓ sync-vps.sh deploys Budget updates to VPS
✓ systemd manages speaker-mesh + teleprompter
✓ Elixir frontmatter spec locked (3ox.clip)
✓ All repo substrates converted to new format

────────────────────────────────────────────────
## WHAT NEEDS TO HAPPEN (priority order)
────────────────────────────────────────────────

### Phase 1 — Lock the Structure (this session)
1. Create branch `structure/3ox-core` with canonical L2 + L3 layout
2. Create branch `tron/systemd` with service files + _TRON.CONTRACT
3. Create branch `meta/logging` with _meta template
4. Create branch `agents/live` with Money.Bagz cube
5. Push all branches

### Phase 2 — Second Agent
6. Stand up VSO.Agent or another agent on VPS
7. Add Telegram topic routing for new agent
8. Verify multi-agent switching via TelePromptR

### Phase 3 — Domain + Hosting
9. 3ox.ai domain → GitHub Pages or docs site
10. README as landing page for the framework
11. INSTALL guide for spinning up a new 3OX system

### Phase 4 — Future Self Maintenance
12. Version tags on branches (v0.1.0, etc.)
13. CHANGELOG per branch
14. sync script per agent (pattern from Budget)

────────────────────────────────────────────────
## DEPLOYMENT FLOW (how an agent goes live)
────────────────────────────────────────────────

```
ZEN.PRO (Mac/Cursor)
  │
  │  1. Build agent cube (.3ox/ with 6 files)
  │  2. Write sync-vps.sh
  │  3. Run: bash .3ox/sync-vps.sh
  │
  ▼
CMD.VPS (Hetzner)
  │
  │  4. rsync receives agent files
  │  5. ruby .3ox/run.rb teleprompt → generates TPR config
  │  6. merge.sh → merges into TelePromptR CyberDeck
  │  7. systemctl restart speaker-mesh
  │
  ▼
Telegram
  │
  │  8. User sends message in agent topic
  │  9. teleprompter.rb routes to agent
  │ 10. speaker-mesh processes via LLM
  │ 11. Response streams back to chat
  │
  ▼
Working Agent ✓
```

:: ∎
