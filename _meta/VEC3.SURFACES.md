///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.124 // WORKBOOK :: VEC3.SURFACES.md ▞▞

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[26.05.04]
/// doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
/// .vec3/ canon — seven runtime surfaces, place vs authority, L2/L3 split
```

# `.vec3/` — The Runtime Surfaces

`.vec3/` is the **runtime kernel**. It sits as a sibling of `.3ox/` at
every cube root. `.3ox/` declares the agent (six face files); `.vec3/`
runs it (seven surface folders).

The cube boundary is `_TRON ⊃ cube ⊃ {.3ox/, .vec3/}`. They are siblings,
not parent and child — runtime is not part of identity.

## The duality: Place vs Authority

Every surface in `.vec3/` is a **place** where state lives. Authority
over that state lives elsewhere — in `Core{Axis}` (data plane),
`Core{System}` (operational plane), or `_TRON/systemd/` (daemon law).

```
.vec3/var/receipts/  exists  →  but Tape (k01)        owns receipt writing
.vec3/rc/rules.ref   exists  →  but Warden (k00)      owns rule enforcement
.vec3/proc/workers/  exists  →  but Supervisor (k21)  owns lifecycle
```

The shortest one-liner:

> **`proc` is part of `vec3`, but `proc` is the process plane, not the lifecycle sovereign.**

Same shape for every surface. Place names where state lives; authority
names who is allowed to mutate it. Warden Law #5 (`SLOT_IDENTITY`)
forbids collapsing the two.

## The seven surfaces

```
.vec3/
├─ rc/      :: run control
├─ lib/     :: protected library logic
├─ dev/     :: devices, adapters, executors
├─ var/     :: live state, receipts, cursors, metrics
├─ proto/   :: protocol contracts and gRPC interfaces
├─ proc/    :: process plane, workers, queue, sub-agents, kernel
└─ mem/     :: awareness and memory surfaces
```

### `.vec3/rc/` — Run Control

The control spine. Immutable rules, mutable system config, and the
binaries the runtime is allowed to execute. Where the system declares
**what it is allowed to be and how it boots**.

| Holds | Purpose |
|---|---|
| `rules.ref` | Immutable security and invariants |
| `sys.ref` | Runtime config and feature flags |
| `boot.lock` | Crash recovery / boot coordination |
| `binaries` | Installed runtime artifacts |
| `policy.wasm` | (system-level) compiled global policy |

Authority: **Warden** (`k00`) reads and enforces.

### `.vec3/lib/` — Library

Protected, read-only reference logic. Never written at runtime.
**Packaged truth and reusable logic, but not live mutation.** If `rc/`
is law, `lib/` is canonized material.

| Holds | Purpose |
|---|---|
| `snips/` | Hot-reloadable shaping logic |
| `prompts/` | Versioned prompt assets |
| `static/` | Templates, assets, fixed support files |
| `*.ref` | Protected reference material |

Authority: read-only at runtime; mutated only by **`Core{System}.Patch`** (`k26`) under migration seal.

### `.vec3/dev/` — Devices

The executable bridge layer. **Where 3OX touches the outside world.**
This is the risky surface — Warden cares a lot about this folder
because side effects become possible here.

| Holds | Purpose |
|---|---|
| `io/` | Input and output bridge surfaces |
| `ops/` | Operational executors |
| `adapters/` | System integrations and capability wrappers |
| `drivers/` | Hardware/API interfaces |
| manifest | Adapter registration metadata |

Authority: capability enforcement gated by **Warden** (`k00`); execution by **`Core{System}.Cage`** (`k22`); registration by **`Core{Encode}.Authority`** (`k04`).

### `.vec3/var/` — Variable State

Live state and append-first evidence surface. **What is alive right
now and what just happened.** Mutates constantly.

| Holds | Purpose |
|---|---|
| `state/` | `status.ref` and current state |
| `receipts/YYYY/MM/DD/` | Local receipt mirror |
| `cursors/` | Stream/reader positions |
| `metrics/` | Telemetry exports |
| `pid` | Current process id (lighter agents) |
| `state.json` | Ephemeral state dump |
| `queue/` | Filesystem-backed queue (when used) |

Authority: **Tape** (`k01`) owns authoritative receipt writing — `var/receipts/` is a *mirror*, not the source of truth.

### `.vec3/proto/` — Protocols

The interface contract plane. **How services agree before they speak.**
Especially important for portable packs and the marketplace model
where machines need stable contracts, not vibes.

| Holds | Purpose |
|---|---|
| `*.proto` | gRPC service contracts |
| service contracts | Cross-language interface definitions |
| RPC type defs | Wire-level type law |

Authority: **`Core{Encode}.Seal`** (`k08`) for contract integrity; **`Core{Encode}.Route`** (`k06`) for binding contracts to routes.

### `.vec3/proc/` — Process Plane

Process and internal execution topology. **Where processes are
represented and coordinated inside the cube.** Note the duality:

> `proc` is the process surface.
> Supervisor is the lifecycle sovereign.

| Holds | Purpose |
|---|---|
| `workers/` | Sub-worker PIDs and status manifests |
| `queue/` | Durable local queue store |
| `agents/` | Recursive internal agents |
| `self/` | Self-process identity and local runtime control |
| `kernel/` | Internal process kernel for deeper agents |

Authority: **`Core{System}.Daemon`** (`k21`) — the Supervisor — owns starting, stopping, and restarting daemons one-for-one. `proc/` is where their state is *visible*, not where their continuity is *decided*.

### `.vec3/mem/` — Awareness

Memory and awareness layer. **What the system remembers, not what
it is currently doing.** This is the difference between a reactive
machine and a continuity-bearing one.

| Holds | Purpose |
|---|---|
| `hot/` | Short-lived fast memory dumps (Redis/ETS-style) |
| `deep/` | Vector indices and long semantic memory |
| `context/` | Session window snapshots and continuity slices |

Authority: **`Core{Encode}.Memory`** (`k07`) — Project Orion (PR #31) is the canonical retrieval/encode pipeline for `mem/deep` and `mem/context`. **Tape** (`k01`) still owns authoritative receipts; `mem/` does not duplicate that.

## `var` vs `mem` — the critical split

```
var = current operational state and evidence
mem = retained awareness and semantic continuity
```

More bluntly:

```
var remembers what just happened
mem remembers what matters across time
```

Examples that pin the difference:

```
.vec3/var/state/status.ref            :: system is ONLINE right now
.vec3/var/receipts/2026/05/04/...     :: this exact action happened
.vec3/mem/context/session-042.snapshot :: this conversation state was preserved
.vec3/mem/deep/job_finder.index       :: ranked semantic memory for job workflows
.vec3/mem/hot/current_user_focus.dump :: temporary active cognitive state
```

## L2 vs L3 — compressed vs full geometry

Not every cube needs the full seven-surface geometry. The canon allows
two scales of `.vec3/`.

### L2 (compressed base)

Six face files plus a lighter `.vec3/`:

```
.vec3/
├─ rc/      :: optional overrides
├─ var/     :: pid, state.json
└─ dev/     :: io buffers
```

Used for tiny flat agents that don't need a process plane, memory
graph, or formal protocol contracts.

### L3 (full agent)

The full seven-surface geometry opens:

```
.vec3/
├─ rc/
├─ lib/
├─ dev/
├─ var/
├─ proto/
├─ proc/
└─ mem/
```

Used for agents that supervise sub-workers, hold continuity across
sessions, expose RPC, or run an internal kernel.

## Two scales of `.vec3/` — the fractal coordinate

The same surface system repeats at machine scale:

```
agent vec3   :: inside a specific .3ox cube         (this doc)
system vec3  :: above the machine-wide daemon runtime
              under _TRON/systemd/vec3/
```

The system-level `_TRON/systemd/vec3/` is the **God View** of the
machine — the daemon set's own runtime kernel. It mirrors the same
surface names with system semantics:

```
_TRON/systemd/vec3/
├─ rc/
│   ├─ supervisor.pid
│   └─ boot.ledger
├─ var/
│   ├─ daemons/
│   │   ├─ warden.status
│   │   ├─ queue.stats
│   │   └─ pulse.heartbeat
│   └─ network/
│       └─ mesh.map
└─ lib/
    ├─ policy.wasm
    └─ registry.map
```

That is why 3OX feels fractal — the coordinate system repeats. An agent
has a `.vec3/` because it is a runtime; the machine has a `.vec3/`
because it too is a runtime, just one tier up.

## The shortest interpretation

```
rc    :: control      :: law and boot
lib   :: reference    :: protected logic and canon
dev   :: action       :: adapters, drivers, executable bridges
var   :: state        :: live state, receipts, cursors, metrics
proto :: agreement    :: service/interface contracts
proc  :: process      :: workers, queue, self, internal agents, kernel
mem   :: continuity   :: hot memory, deep semantic memory, context
```

## Ownership map

Each surface lives at a `.vec3/` *place*. Each surface is governed by
one or more authorities elsewhere in the system. The ownership map:

| Surface | Place owner (where state lives) | Authority (who is allowed to mutate it) | Slot |
|---|---|---|---|
| `rc/` | Warden | Warden enforces; `Core{System}.Patch` mutates under seal | `k00`, `k26` |
| `lib/` | Read-only canon | `Core{System}.Patch` under migration seal | `k26` |
| `dev/` | Adapter registry | Warden (gate) + `Core{System}.Cage` (sandbox) + `Core{Encode}.Authority` (registration) | `k00`, `k22`, `k04` |
| `var/` | Pulse heartbeat / mirror | **Tape** writes authoritative receipts; Pulse refreshes status | `k01`, `k02` |
| `proto/` | Contract registry | `Core{Encode}.Seal` (integrity) + `Core{Encode}.Route` (binding) | `k08`, `k06` |
| `proc/` | Process manifests | **Supervisor** (`Core{System}.Daemon`) owns lifecycle; Worker writes its own manifest | `k21` |
| `mem/` | Awareness store | `Core{Encode}.Memory` via Project Orion | `k07` |

**The split that must never collapse:**

- `proc/` is the **process plane**. Supervisor is the **lifecycle sovereign**.
- `var/receipts/` is a **mirror**. Tape is the **authoritative writer**.
- `rc/rules.ref` is a **file**. Warden is the **rule enforcer**.
- `dev/adapters/` is a **registry**. Warden gates **execution**.

Place ≠ authority. Warden Law #5 (`SLOT_IDENTITY`) makes this binding.

## Migration notes (open question, deferred)

The previous L3 row in `PLAN.md` (locked in PR #6, March) listed six
surfaces: `rc, lib, dev, var, bin, ops`. This canon supersedes that
with seven surfaces: `rc, lib, dev, var, proto, proc, mem`.

**`bin/` and `ops/` are not in the new canon.** Their content folds
into `.vec3/dev/` (executables and operational executors live alongside
adapters and drivers in the device-bridge layer).

For backwards compatibility this PR materializes `proto/`, `proc/`,
and `mem/` under the root cube's `.vec3/` but leaves the existing
`bin/` and `ops/` directories in place pending a deliberate
deprecation pass. Path:

1. This PR locks the seven-surface canon and creates the three new
   surfaces.
2. A follow-up PR moves any actual content from `bin/` and `ops/`
   into `dev/{ops,...}` and removes the empty directories with a
   `_meta/CHANGELOG.toml` migration entry.

Until that follow-up lands, agents may safely reference paths under
the seven canon surfaces. Anything still referencing `.vec3/bin/` or
`.vec3/ops/` should be flagged for migration during review.

## See also

- `PLAN.md` — L2/L3 layout summary (authoritative cube structure)
- `_meta/BOX.ALIVENESS.equation` — Box₃ aliveness invariant
- `_meta/RAVEN.SUITE.md` — daily-driver runtime overview
- `_meta/NAMING.CONTRACT.toml` — `[core]` and `[core.rotor]` naming
- `.3ox/(5)Links/routes.json` — slot index (`k00`–`k26`, `E000`–`E215`)
- `.3ox/(3)Rules/exc/axis/3OX.SPIN.spec` — rotary encoder of `Core{Axis}`
- Project Orion (PR #31) — k07 ENCODE.MEMORY pipeline; the authority over `.vec3/mem/`

:: ∎
