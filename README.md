# 3OX.Ai

Kernel-style architecture for AI agents. Reliable, auditable, state-preserving.

## What This Is

3OX is a framework for building AI agents that operate with operating system-level reliability. Instead of fragile prompt chains that lose context, 3OX agents run on a kernel architecture with protected surfaces, immutable rules, and provable operations.

Think systemd for AI agents.

## Core Architecture

**vec3 Kernel** - Six protected surfaces for agent runtime:
- `rc/` - Immutable rules and configuration
- `lib/` - Protected reference libraries
- `dev/` - External adapters (I/O bridges)
- `var/` - Runtime data (receipts, events, state)
- `proc/` - Live introspection
- `sys/` - Control knobs

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
- Preserve state across sessions (vec3/var)
- Generate receipts for every action
- Enforce atomic operations with rollback
- Follow immutable rules (vec3/rc)

For teams building AI systems that need to be production-ready, auditable, and reliable.

## Components

### 3OX Agents

Pre-built agents with full vec3 setup:

- **[VSO Agent](3OX%20Agents/VSO%20Agent/)** - Veterans Service Officer for VA disability claims. Strategic questioning, DBQ reference, deadline tracking, evidence validation.

More agents coming: Education, Sysadmin, Research, Development.

### 3OX.BUILDER

Framework tooling and templates:
- Agent scaffolding
- Brain compilation tools
- vec3 structure generators
- Tier system (T1: basic, T2: simple vec3, T3: full kernel)

See [3OX.BUILDER](3OX.BUILDER/) for documentation.

### Capsules (Coming)

Portable AI workspaces. Package an agent, its data, and state into a single unit. Move it between environments. State travels with the agent.

## Technical Details

**Tier System:**
- **T1**: File inference only. No vec3. Basic agents.
- **T2**: Simple vec3 (6 core files + sparkfile). Brain compiles. Basic kernel.
- **T3**: Full vec3 setup. Adapters, receipts, event streams. Production-ready.

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
- Device drivers → Adapters in vec3/dev

If you trust your OS to manage state reliably, you can trust 3OX agents the same way.

## Status

**Active Development**  
Version: 1.0.0  
Last Updated: ⧗-25.133

## License

MIT License - See [LICENSE](LICENSE)

---

Built for systems that can't afford to lose context.
