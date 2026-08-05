# 3OX.Ai

Kernel-style architecture for AI agents. Reliable, auditable, state-preserving.

## What This Is

3OX is a framework for building AI agents that operate with operating system-level reliability. Instead of fragile prompt chains that lose context, 3OX agents run on a kernel architecture with protected surfaces, immutable rules, and provable operations.

Think systemd for AI agents.

## Core Architecture

**6 Core Files + Sparkfile** - Every 3ox agent has 7 files:
1. `sparkfile.md` - Comprehensive agent specification (the "prompt")
2. `brain.rs` - Rust config (compiles to brain.exe)
3. `tools.yml` - Tool registry
4. `routes.json` - Operation routing
5. `limits.json` - Resource limits
6. `run.rb` - Ruby runtime
7. `3ox.log` - Activity log

All tiers (T1, T2, T3) include these 7 files.

**`.vec3/` Kernel** — Eight protected runtime surfaces, sibling of `.3ox/` at every cube root. `.3ox/` declares the agent (six face files); `.vec3/` runs it (eight surface folders). See [`_meta/canon/VEC3.SURFACES.md`](_meta/canon/VEC3.SURFACES.md) for the full canon.

| Surface | Role | One-line meaning |
|---|---|---|
| `.vec3/rc/` | control | Law and boot — immutable `rules.ref`, `sys.ref`, `boot.lock` |
| `.vec3/bin/` | executables | Scripts, compiled tools, CLI entry points — `/usr/bin` equivalent |
| `.vec3/lib/` | reference | Protected logic and canon — `snips/`, `prompts/`, `*.ref` |
| `.vec3/dev/` | action | Adapters, drivers, executable bridges — where 3OX touches the outside world |
| `.vec3/var/` | state | Live state, receipts, cursors, metrics, `var/ops/` — what is alive right now |
| `.vec3/index/` | addressing | Registration, entity lookup, vec3 address resolution |
| `.vec3/proc/` | process | Workers, queue, self, internal agents, kernel — process plane (Supervisor still owns lifecycle) |
| `.vec3/mem/` | continuity | `hot/`, `deep/`, `context/` — what the system remembers, not what it is currently doing |

Place ≠ authority. `.vec3/var/receipts/` is a mirror; **Tape** owns receipt writing. `.vec3/proc/workers/` holds manifests; **Supervisor** owns lifecycle. `.vec3/rc/rules.ref` is a file; **Warden** enforces. The full ownership map lives in `_meta/canon/VEC3.SURFACES.md`.

**Brain Compilation** - Agent configurations written in Rust, compiled to executables. Type-safe behavior rules, not prompt engineering.

**Receipts System** - Every operation writes a receipt: timestamp, actor, inputs hash, outputs, status. Independent of model output. Survives inference drift.

**Operational Loop** - Agents run systematic workflows: assess → plan → execute → verify → log. No lost context.

## Why This Matters

Current AI agents:
- Lose context between sessions
- Can't prove what they did
- Break state on errors
- Drift from original intent

3OX agents:
- Preserve state across sessions (`.vec3/var`, `.vec3/mem`)
- Generate receipts for every action
- Enforce atomic operations with rollback
- Follow immutable rules (`.vec3/rc`)

For teams building AI systems that need to be production-ready, auditable, and reliable.

## Kernel Specification

The full architecture is defined in [`_meta/canon/`](_meta/canon/):

| Document | Defines |
|---|---|
| [KERNEL.V1](_meta/canon/KERNEL.V1.md) | 243-field kernel: 3 rings × 9 slots + 216 entity encoder |
| [ZENOS.V1](_meta/canon/ZENOS.V1.md) | ZenOS execution substrate — tier model, lane definitions, pheno chain templates |
| [LINUX.SYSTEM.MAPPING](_meta/canon/LINUX.SYSTEM.MAPPING.md) | How 3OX folder structure maps to Linux filesystem conventions |
| [ARCHITECTURE.SPEC](_meta/canon/ARCHITECTURE.SPEC.md) | Full architecture freeze — 18-section dictation |
| [VEC3.SURFACES](_meta/canon/VEC3.SURFACES.md) | The 7 `.vec3/` surfaces — place vs authority |

Ring specs are expanded individually in [`.3ox/(3)Rules/exc/`](.3ox/(3)Rules/exc/) (Ring A: Pheno Grammar, Ring B: Daemon Services, Ring C: Contract Surfaces).

## Components

### Runtime Stack

3OX agents are orchestrated by an Elixir/OTP runtime (**ORION**) that handles dispatch, streaming, and multi-seat coordination:

- **ORION GenServer** — routes requests across model seats (local Ornith 35B warden, 9B governor, cloud fallback)
- **TPR (TelePrompter Relay)** — Elixir GenServer for streaming chunk pub/sub across surfaces
- **CISA chain** — Cognitive Instruction Set Architecture: Θ→Ξ→κ→Σ→Δ→λ→τ→Ω→χ (heading → decode → dispatch → bind → enforce → execute → receipt → commit → ack)
- **Receipts** — every operation writes a receipt (timestamp, actor, inputs hash, outputs, status)

### 3OX Agents

Agents ship as self-contained cubes with `.3ox/` identity + `.vec3/` runtime:

- **[VSO Agent](3OX%20Agents/VSO%20Agent/)** — Veterans Service Officer for VA disability claims
- **[Sidekik](3OX%20Agents/Sidekik/)** — TPR-connected assistant with RAVEN dispatch
- **[Money.Bagz](Money.Bagz/)** — Financial operations agent

### 3OX.BUILDER

Rust workspace for framework tooling:
- `3ox` CLI — agent scaffolding and management
- `vec3-boot` — TUI boot loader with animated splash
- `brains-3ox-core` — core library for brain compilation
- Tier system (T1: basic, T2: simple vec3, T3: full kernel)

See [3OX.BUILDER](3OX.BUILDER/) for documentation.

### TelePromptR

Agent-to-agent handoff system via Telegram relay. Routes messages to correct agent seats, streams responses back. Schema-validated handoffs with Ruby consumer + minitest suite.

See [_TRON/TelePromptR](_TRON/TelePromptR/) for documentation.

## Technical Details

**Tier System:**
- **T1**: 6 core files + sparkfile.md (7 files). No vec3. File inference only. Basic logging.
- **T2**: 7 files + basic vec3 (rc, lib, var). Brain compiles. Simple kernel.
- **T3**: 7 files + full vec3 (rc, lib, dev, var). Adapters, receipts, event streams. Production-ready.

**File Validation**: xxHash64 checksums on all operations.

**Logging**: Structured logs with Sirius time (custom calendar).

**Languages**: Ruby runtime, Rust brain configs, SXSL markup.

## Get Started

Clone an agent:
```bash
git clone https://github.com/LLMasterDesign/3OX.Ai.git
cd "3OX.Ai/3OX Agents/VSO Agent"
```

See agent-specific README and INSTALL guides.

Build your own:
```bash
cd 3OX.BUILDER
# Documentation and templates
```

## Architecture Philosophy

Borrowed from operating systems:
- Protected memory spaces → Protected vec3 surfaces
- Process isolation → Agent boundaries
- Audit logs → Receipt system
- Init systems → Operational loop
- Device drivers → Adapters in `.vec3/dev`

If you trust your OS to manage state reliably, you can trust 3OX agents the same way.

## CI

Three GitHub Actions workflows validate the codebase:
- **cargo** — Rust workspace build + test (3OX.BUILDER)
- **encoder** — Hex index + entity encoder validation
- **tpr** — TPR handoff schema + consumer tests

## Status

**Active Development**  
Version: 1.1.0  
Last Updated: ⧗-26.216

## License

Apache License 2.0 — See [LICENSE](LICENSE)

---

Built for systems that can't afford to lose context.
