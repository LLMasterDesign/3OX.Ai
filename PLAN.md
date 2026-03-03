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

────────────────────────────────────────────────
## ARCHITECTURE AUDIT
────────────────────────────────────────────────

### Progression: 5 — 6 — 7 — 7 — 2

```
5TRATA (containment)   →  L2 .3ox (cube faces)  →  L3 .vec3 (kernel)  →  3OX.Ai (services)  →  Anchors
       5                        6                        7                      7                   2
```

- **5TRATA**: CMD → Base → Station → Service → Agent
- **L2**: Spark, Brains, Rules, Toolkit, Links, Pulse
- **L3**: rc, lib, dev, var, bin, mem, proc
- **3OX.Ai**: Arc, Pulse, Queue, Supervisor, Tape, Warden, Worker
- **Anchors**: _meta (identity), _TRON (device runtime)

### 3OX.Ai — 7 Modules

| Module | Full Name | Role |
|--------|-----------|------|
| Arc | Archetype | Persona loading, personality traits, triggered scope shifts. `.arc` files + `.spec` presets. Makes agents sound human, not robotic. |
| Tape | Tape | Append-only event journal. Elixir streaming. What happened, when. |
| Warden | Warden | Policy enforcement, mutation control. Rust core. What's allowed. |
| Pulse | Pulse | Heartbeat, liveness detection, keepalive. Is it alive. |
| Supervisor | Supervisor | Process lifecycle management, Ruby script dispatch. Restart strategy. |
| Worker | Worker | GenServer task execution. Does the actual work. |
| Queue | Queue | Backpressure-aware work distribution, job scheduling. Who works next. |

### Language Ownership

| Language | Owns | Why |
|----------|------|-----|
| Rust | Warden, Brains | Security-critical policy + compiled identity. Must never fail. |
| Elixir | Tape, Pulse, Arc | Event streaming, heartbeat, persona state. BEAM fault tolerance. |
| Ruby | Supervisor, Worker | Orchestration glue, script dispatch. Flexible, rapid iteration. |
| gRPC/Protobuf | Wire between all | Language-agnostic contracts. Rust, Elixir, Ruby all speak Protobuf. |
| Markdown | Sparkfiles, contracts | Human-readable truth. No compilation, no parsing ambiguity. |

### vec3 ↔ 3OX.Ai Mirror (7 — 7)

| vec3 (inside cube) | 3OX.Ai (across cubes) | Relationship |
|--------------------|----------------------|--------------|
| rc/ — lifecycle | Supervisor | Both own startup, shutdown, restart |
| lib/ — knowledge refs | Arc | Both hold what-to-BE knowledge (personas, references) |
| dev/ — IO bridges | Queue | Both route work in/out (IO dispatch, job routing) |
| var/ — state, spool | Tape | Both hold what-happened state (events, receipts) |
| bin/ — executables | Worker | Both execute tasks (entry points, GenServer) |
| mem/ — active state | Warden | Both hold hot rules (runtime policy, cache) |
| proc/ — observation | Pulse | Both observe running state (process tracking, heartbeat) |

### Sources

**Arc / Archetype — persona systems for AI agents:**

1. **CoALA** — Cognitive Architectures for Language Agents (Princeton, 2023).
   Framework for language agent memory models and action spaces.
   Informs how Arc structures persona memory vs. episodic memory.

2. **Anthropic PSM** — "The Persona Selection Model" (2026).
   LLMs learn to simulate diverse personas during pre-training;
   post-training refines a specific persona. Validates Arc's approach
   of treating agent identity as character-like entity with adjustable
   personality traits, not rigid pattern matching.
   → https://alignment.anthropic.com/2026/psm

3. **Structured Personality Control** — arXiv:2601.10025 (Jan 2026).
   Uses Jungian psychological types with three mechanisms:
   dominant-auxiliary coordination for coherent expression,
   reinforcement-compensation for contextual adaptation,
   and reflection for long-term personality evolution.
   Directly validates Arc's triggered trait modifiers and scope-shift design.

**Queue / Large-Scale — backpressure and job distribution:**

1. **Elixir Broadway + GenStage** — demand-driven backpressure pipelines.
   Producer → ProducerConsumer → Consumer stages with demand flowing
   upstream. Used at scale by Discord and Change.org.
   GenStage's stage types map directly to Queue's role in 3OX.
   → https://elixir-broadway.org

2. **Uber uForwarder** — open-sourced Feb 2026.
   Push-based Kafka consumer proxy serving 1,000+ downstream
   microservices, processing trillions of messages daily across
   multiple petabytes. Uses gRPC job routing, context-aware message
   headers for region/tenant routing, and out-of-order offset commits
   to prevent partition stalls. This is what Queue looks like at 200+
   services scale.
   → https://www.uber.com/blog/introducing-ufowarder
   → https://github.com/uber/uForwarder

:: ∎
