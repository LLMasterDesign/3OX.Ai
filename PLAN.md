///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.062 // WORKBOOK :: PLAN.md ▞▞

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[26.03.03]
/// doc:[PARTIAL] modified:[26.05.04] auth:[ZEN.PRO]
/// BOX.Ai launch plan — substrates, branches, agents, Telegram
```

# BOX.Ai — Launch Plan

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
│   └── .vec3/                ← L3: 6 folders (runtime kernel)
│       ├── rc/               run control, lifecycle
│       ├── lib/              protected references
│       ├── dev/              device bridges, IO
│       ├── var/              state, spool, inflight
│       ├── bin/              executables
│       └── ops/              tool operations
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
## L3 — 6 FOLDERS (per .vec3 kernel)
────────────────────────────────────────────────

Runtime kernel — sits alongside `.3ox/` as `.vec3/`:

| Folder | Purpose |
|--------|---------|
| `rc/` | Run control — config, lifecycle scripts, services |
| `lib/` | Protected libraries, references (read-only) |
| `dev/` | IO bridges (Telegram, HTTP, MQ), device ops |
| `var/` | Variable state — spool, inflight, events, receipts |
| `bin/` | Executables — daemon, watcher, terminal |
| `ops/` | Tool operations — indexer, health check |

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
