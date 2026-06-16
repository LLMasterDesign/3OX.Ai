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
`_meta/canon/VEC3.SURFACES.md`.

| Surface | Role | Purpose |
|---|---|---|
| `rc/` | control | Law and boot — `rules.ref`, `sys.ref`, `boot.lock`, binaries |
| `lib/` | reference | Protected logic and canon — `snips/`, `prompts/`, `static/`, `*.ref` |
| `dev/` | action | Adapters, drivers, executable bridges, ops — outside-world surface |
| `var/` | state | Live state, receipts mirror, cursors, metrics |
| `proto/` | agreement | gRPC service contracts, interface definitions |
| `proc/` | process | `workers/`, `queue/`, `agents/`, `self/`, `kernel/` (Supervisor owns lifecycle) |
| `mem/` | continuity | `hot/`, `deep/`, `context/` — owned by `Core{Encode}.Memory` (k07, Project Orion) |

Place ≠ authority. See `_meta/canon/VEC3.SURFACES.md` §Ownership map.

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
## ONBOARDING & CRITICAL FILES
────────────────────────────────────────────────

### Boot Chain — what gets read on startup

Sparkfile is the core entry point — like `.cursorrules` for Cursor.
Everything chains from it:

```
sparkfile.md          ← READ FIRST — identity, config, contract
  ├── soul.md         ← "read soul" — mission, values, why we persist
  ├── brains.rs       ← "read brain" — personality, rules, brain type
  ├── tools.yml       ← available capabilities
  ├── routes.json     ← where output goes
  ├── limits.toml     ← what's allowed, constraints
  └── run.rb          ← entry point, executes on boot → writes 3ox.log
```

### Critical Files Users Should Know

| File | Face | Touched On | Purpose |
|------|------|------------|---------|
| `sparkfile.md` | (1) Spark | First boot | Identity, origin, contract. THE config file. |
| `soul.md` | (1) Spark | First boot | Mission, values, ongoing identity. Why we persist. |
| `brains.rs` | (2) Brains | First boot | Personality type, rules, compiled to brain.exe |
| `3ox.log` | (6) Pulse | Every run | Append-only operation log. Created on first run.rb execution. |
| `skills.md` | (4) Toolkit | Agent setup | Available skills, onboarding guide for new capabilities |
| `merkle.root` | _meta | Integrity check | Hash tree root for change verification |

### Sparkfile as Embedded Loader

Sparkfile works like a run-loader. On boot it reads:
1. **soul.md** — loads the agent's purpose and identity anchor
2. **brains.rs** — loads personality, rules, brain type
3. **tools.yml + routes.json** — loads capabilities and routing
4. **limits.toml** — loads constraints before any execution

This is the same pattern from ChatGPT custom instructions:
instruction slot → run-loader with snips → full markdown of what to do.
Sparkfile IS the run-loader. Soul, brain, tools are the snips.

### Arc Persona Files (separate from L2)

`.spark` files and `.arc` files are Arc territory — persona presets:

| Extension | Purpose | Loaded By |
|-----------|---------|-----------|
| `.spark` | Persona presets (tone, style, triggers) | Arc at runtime |
| `.arc` | Full archetype definitions (upgraded glyph.bits) | Arc at runtime |
| `.spec` | Personality specifications (Z3N.SPEC style) | Arc at boot |

These live in `lib/` (vec3 kernel) — they are knowledge refs, not L2 faces.
Arc loads them dynamically based on context and triggered trait modifiers.

### Installation & Dependencies

**Required:**
- Ruby >= 3.2.0 (Supervisor, Workers, run.rb)
- Rust stable 2021+ (Warden, Brains compilation)

**Recommended:**
- Bun >= 1.0.0 (build tooling, compile-run)
- Elixir/OTP >= 1.16 (Tape, Pulse, Arc services — when running full stack)

**Optional:**
- Node.js >= 18 (alternative to Bun)
- Protobuf compiler (gRPC cross-language contracts)

**Install approach:**
- Dependencies listed per-agent in `tools.yml` under a `deps:` key
- `run.rb` checks deps on first boot, warns on missing
- Full install script future: `3ox install` CLI or `bun run setup`
- Each agent is self-contained — no global install required

### Onboarding Flow (new agent, new user)

```
1. Clone or create agent directory
2. Run: ruby .3ox/Pulse/run.rb
   → Reads sparkfile.md (identity)
   → Reads soul.md (purpose)
   → Loads brains.rs (personality)
   → Checks tools.yml (capabilities)
   → Validates limits.toml (constraints)
   → Creates 3ox.log (first entry)
   → Ready.

3. Connect to Telegram (optional):
   → /teleprompter subkey signon AgentName
   → /topic add AgentName
   → Run sync-vps.sh to deploy
   → Agent is live.
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

────────────────────────────────────────────────
## BUSINESS VISION
────────────────────────────────────────────────

### The Pitch — 100-Year System Lifecycle

3OX.Ai is infrastructure for AI agents that outlasts any single model,
any single company, any single decade. Model-agnostic, language-diverse
(Rust/Elixir/Ruby), built on patterns that survived 50+ years
(Unix FHS, BEAM/OTP, process supervision).

- Unix is 55 and counting. Erlang/OTP is 38. These patterns endure.
- 3OX owns the substrate, not the model. Models change. Substrates persist.
- The 5-6-7-7-2 lattice is a fixed topology. Everything inside evolves.

**Roadmap:**
- v1: Substrate locked, agents running, Telegram as primary IO
- v2: Stable + profitable — multi-device orchestration, SDK, public API
- v3+: Federated agent networks, cross-instance communication

### 3OX.Store — Netflix for AI

**Free tier:** Build your own agents with sparkfile templates,
community substrates, open-source L2/L3 specs, self-hosted.

**Store:**
- Pre-built agents (community or 3OX branded) — purchase once
- Personality packs (.arc/.spark) — sold separately
- Wallet refills — pay-per-use for premium LLM inference
- Substrate chapters — released as community grows

**Revenue:**
```
Free (self-host) → Store (pre-built) → Rental (per-use) → Enterprise
     $0              $20-200            $5-50/session       Custom
```

### Investor Value

1. Infrastructure play — owns the runtime layer between humans and AI
2. Model-agnostic — works with any LLM, current or future
3. Self-sustaining — agents generate logs, receipts, proof of life
4. Community flywheel — users build agents → store grows → more users
5. 100-year horizon — built on patterns older than the internet
6. Existing traction — working agents on Telegram today

### Agent Queue — ZENS3N Repo

All agent work runs from `git@github.com:LLMasterDesign/ZENS3N.git`
to keep 3OX.Ai stable. See `AGENT.QUEUE.md` in ZENS3N for task dispatch.

────────────────────────────────────────────────
## PHASE 5+ — WHAT'S NEXT
────────────────────────────────────────────────

**Immediate:** All agents coherent via TPR, logs functional, 1n3ox.ai updated
**Short-term:** 3+ agents live, boot chain automated, investor pitch polished
**Medium-term (Q2):** 3OX.Store alpha, community guide, SDK, Arc personas
**Long-term (2027):** Multi-device _TRON, federated agents, v2 spec, revenue

:: ∎
