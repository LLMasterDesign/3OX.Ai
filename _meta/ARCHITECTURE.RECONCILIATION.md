///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.124 // _META :: ARCHITECTURE.RECONCILIATION ▞▞

```elixir
/// status:[DRAFT] ver:[0.1.0] created:[26.05.04]
/// doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
/// Reconciliation between ARCHITECTURE.SPEC.md and existing canon (κ27, Warden 12, .vec3 7-surfaces, edge-only, Box₃, 3OX.SPIN)
```

# Reconciliation: Architecture Freeze ↔ Existing Canon

`_meta/ARCHITECTURE.SPEC.md` (ver 1.0.0, 26.05.04) is captured verbatim
from Lucius's dictation. This file dissects it section-by-section
against everything already locked into the repo, so nothing is
silently overwritten.

## Existing canon this PR is reconciled against

| Canon | Source | Status |
|---|---|---|
| `Core{}` 27-slot chamber (κ27) | `_meta/NAMING.CONTRACT.toml [core]`, `routes.json slot_index k00..k26` | locked PR #21, #30 |
| Warden's twelve laws | `.3ox/(3)Rules/limits.toml [[warden.law]]`, `scripts/warden_laws_validate.py` | locked PR #23 |
| `.vec3/` seven surfaces | `_meta/VEC3.SURFACES.md` | locked PR #34 |
| 3OX.SPIN rotor (Core{Axis}) | `.3ox/(3)Rules/exc/axis/3OX.SPIN.spec` (hex 0x003 / k00) | locked PR #32 |
| Edge-only, no clocks | PR #29 | locked |
| Box₃ aliveness | `.3ox/_meta/BOX.ALIVENESS.equation` | locked PR #12 |
| Hex codebook (4096) + Ring A/B/C specs | `.3ox/(5)Links/hex.index.json`, `.3ox/(3)Rules/exc/ring-{a,b,c}/` | locked PR #15, #18, #21, #22 |
| 3OX.SPIN canon | `_meta/NAMING.CONTRACT.toml [core.rotor]` | locked PR #30, #32 |

## Verdict table (per spec section)

| § | Title | Status |
|---|---|---|
| 1 | IDENTITY | ✅ aligns (kernel-OS framing, README) |
| 2 | TOP LEVEL STACK | 🟡 new concepts (`!CMD.BRIDGE`, `!CMD.HUB`, `CITADEL.BASE`) |
| 3 | 6 DAEMONS | ⚠️ **CONFLICT 1** — see below |
| 4 | PRISM+ | ✅ new layer, no conflict |
| 5 | ARC MODE | ✅ new lens, complements `Core{System}.Daemon` (k21) |
| 6 | EVENT LAW | ✅ aligns with PR #29 edge-only; ⚠️ Scheduler ambiguity (Conflict 1) |
| 7 | VEC3 GEOMETRY | ✅ **exact match** with `_meta/VEC3.SURFACES.md` (PR #34) |
| 8 | L1/L2/L3 | 🟡 minor: `brain.rs` (doc) vs `brains.rs` (repo) — Conflict 3 |
| 9 | FOLDER OWNERSHIP | ✅ aligns with `(1)Spark/...(6)Pulse/` |
| 10 | LANGUAGE OWNERSHIP | ⚠️ **CONFLICT 2** — see below |
| 11 | UNIVERSAL ENVELOPE | ✅ matches Ring.C.C0 (k03 ENCODE.INTENT, hex 0x130/0x131) |
| 12 | ROUTER/MAP/POINTER | ✅ aligns with Ring.C.C2/C6 (k05 ENCODE.STATE) |
| 13 | RECEIPT LAW | ✅ aligns with k01 Tape + Warden Law #9 TAPE_INTEGRITY |
| 14 | BOOT SEQUENCE | ✅ aligns with Box₃ aliveness contract |
| 15 | GOLDEN PATH | ✅ aligns with edge-only flow |
| 16 | PACK LAW | 🟡 new but compatible with Warden Law #4 DECLARED_CAPABILITY |
| 17 | OWNER SUMMARY | ✅ aligns (modulo Conflict 1) |
| 18 | HARD LINES | ✅ aligns; ⚠️ "only Scheduler may emit CLOCK_EVENT" but §3 lists 6 daemons without Scheduler — see Conflict 1 |

**Score:** 14 align cleanly, 3 are net-new with no conflict, 3 are real conflicts that need a ruling.

---

## Open conflicts (awaiting Lucius ruling)

### Conflict 1 — "6 daemons" vs κ27 + missing Scheduler

**The problem.** §3 lists six daemons: Supervisor, Warden, Queue, Worker, Tape, Pulse. But:
- Warden (k00), Tape (k01), Pulse (k02) are `Core{Axis}` slots — not `Core{System}` daemons.
- Supervisor maps cleanly to `Core{System}.Daemon` (k21).
- **Queue and Worker aren't in κ27 at all.**
- §6 + §18 reference a Scheduler that's *not* in §3.

So either κ27 is wrong, or "daemon" means something different from "slot."

**Proposed reading (consistent with PR #34 place-vs-authority duality):**

> Daemons are **runtime process classes**. Slots are **identity authorities**. They are different planes.

Daemons live at `.vec3/proc/{workers,queue,kernel,…}` (place). Slots in κ27 *govern* what daemons may do (authority). Mapping:

| Daemon (process class) | Lives at (`.vec3/proc/`) | κ27 authority |
|---|---|---|
| Supervisor | `proc/self/`, `proc/kernel/` | `Core{System}.Daemon` (k21) |
| Warden | (in-process gate, no proc dir) | `Core{Axis}.Warden` (k00) |
| Queue | `proc/queue/` | `Core{Ring}.Intake` (k09) + `Core{Ring}.Route` (k12) |
| Worker | `proc/workers/` | `Core{Ring}.Execute` (k13) |
| Tape | (writer, no proc dir) | `Core{Axis}.Tape` (k01) |
| Pulse | (observer, no proc dir) | `Core{Axis}.Pulse` (k02) |
| **Scheduler** | (system-level, `_TRON/systemd/`) | `Core{Axis}.Pulse` (k02) — emits the rotor's CLOCK_EVENT |

Under this reading: §3's "6 daemons" is correct as a *cube-runtime* count, and Scheduler is a 7th process class living one tier up at `_TRON/systemd/` (since it's machine-scale, not cube-scale). §3 should be amended to read "6 cube daemons + Scheduler at system tier" so §6/§18 don't read as orphans.

**Alternatives:**
- (b) Promote Queue and Worker into κ27 as new System slots (would expand to k27/k28, breaking the locked 27-slot chamber — **not viable**).
- (c) Fold Scheduler into Supervisor (cleanest if no 7th daemon, but then §18 hard-line "only Scheduler may emit CLOCK_EVENT" needs a rewrite).

**Status:** OPEN — awaiting Lucius ruling. Recommendation: (a).

---

### Conflict 2 — Language triad

**The problem.** Two of Lucius's messages give different language assignments for `Core{Axis}`:

| Slot | 3OX.Core{} Research Note (earlier dictation) | Architecture Freeze §10 (this spec) |
|---|---|---|
| Warden (k00) | Rust | Rust ✓ same |
| Tape (k01) | **Lisp** | **Elixir** |
| Pulse (k02) | Elixir | (not assigned; doc treats Pulse as JSONL stream surface) |
| (cognition surface) | — | **Lisp** (Raven / entity cores, Supervisor-resident, Worker-invoked) |

The earlier triad was "one language per Axis seat." The Freeze repositions Lisp from a runtime language for k01 Tape into a *cognition* surface owned by Supervisor (continuity) and Worker (invocation), and gives Tape to Elixir along with PRISM+.

**Proposed reading (because it's actually internally consistent):**

Elixir/BEAM is genuinely good at high-concurrency append-first streams (Tape) *and* hot transformation pipelines (PRISM+). Lisp's strengths — symbolic reasoning, hot-loadable forms — are wasted on receipt-writing but ideal for `.vec3/proc/agents/` entity cores. So the Freeze isn't a contradiction; it's a *promotion* of Lisp out of the data plane and into the cognition plane:

```
Warden  (k00) ← Rust          (compiled strict guards)
Tape    (k01) ← Elixir        (BEAM append-first concurrency)
Pulse   (k02) ← JSONL/Elixir  (telemetry stream surface)
PRISM+        ← Elixir        (output shaping, snips at .vec3/lib/snips/)
Raven cores   ← Lisp          (symbolic cognition; lives at .vec3/proc/agents/)
```

If accepted, this gets recorded explicitly in `_meta/NAMING.CONTRACT.toml [core.deprecated]` so the supersession is auditable.

**Status:** OPEN — awaiting Lucius ruling. Recommendation: accept the Freeze.

---

### Conflict 3 — `brain.rs` vs `brains.rs`

§8.2 L2 lists `brain.rs` (singular). Repo uses `brains.rs` (plural, locked in PR #6 since March):

```
.3ox/(2)Brains/brains.rs
Money.Bagz/.3ox/(2)Brains/brains.rs
3OX Agents/Sidekik/.3ox/(2)Brains/brains.rs
```

**Proposed reading:** doc typo. Keep repo as `brains.rs`.

**Status:** OPEN — awaiting Lucius ruling. Recommendation: doc edit, not repo rename.

---

## New concepts in the spec (no conflict — need homes)

These are clean additions that don't fight anything in canon. Each gets a follow-up PR once the conflicts are ruled.

| # | Concept | Spec § | Proposed home | Status |
|---|---|---|---|---|
| N1 | `!CMD.BRIDGE`, `!CMD.HUB`, `CITADEL.BASE` | §2 | `_TRON/_TRON.CONTRACT.toml [paths]` | propose |
| N2 | PRISM+ output shaping layer (Elixir/BEAM, Worker→Station) | §4 | new `_meta/PRISM.PLUS.md` | propose |
| N3 | ARC MODE (9 states + 3 vectors, ETERNAL only for system) | §5 | new `_meta/ARC.MODE.md` | propose |
| N4 | Five event sources (FS, QUEUE, RPC, RECEIPT, CLOCK) | §6 | new `_meta/EVENT.SOURCES.md` or `.3ox/(5)Links/events.kdl` | propose |
| N5 | Universal Envelope (12 fields in/out, strict laws) | §11 | upgrade `Ring.C.C0` spec; add `scripts/envelope_validate.py` | propose |
| N6 | Map → Pointer (file slice, line range, hash, version) | §12 | upgrade `Ring.C.C2` spec; expand `.3ox/(5)Links/map.toml` | propose |
| N7 | Pack law (capabilities, adapters, scopes, golden tests, sign) | §16 | new `_meta/PACK.CONTRACT.md` + `pack.toml` schema; binds to Warden Law #4 | propose |
| N8 | L1 LITE tier (sparkfile + vec3 only, services/stations) | §8.1 | extend `_meta/VEC3.SURFACES.md` L2/L3 split; add to `PLAN.md` | propose |

---

## Strong alignments (recorded for posterity)

These sections of the spec confirm and reinforce existing canon. No PR needed — they're already in the repo, just newly tied to the spec language.

- **§7 VEC3 :: FULL GEOMETRY** is an exact match for `_meta/VEC3.SURFACES.md` (PR #34). Same seven surfaces, same place-vs-authority, same sub-folder topology. The spec slightly extends some surfaces with extra `contains` items (`policy.wasm` at system scale for `rc/`, `*.ref` explicit in `lib/`, `pid` + `state.json` in `var/`) — all compatible additions, none contradictory.
- **§13 RECEIPT LAW** matches Tape's authority over `.vec3/var/receipts/` (mirror) vs `_TRON/receipts/` (authoritative), and binds to Warden Law #9 TAPE_INTEGRITY (append-only, no overwrite, corrections via compensating receipts).
- **§18 HARD LINES** are direct restatements of Warden laws + 3OX.SPIN rotor + edge-only. "no per-agent timer spam" = PR #29. "Warden fail-closed" = Warden Law #12 FAIL_CLOSED. "logs do not outrank receipts" = Warden Law #9.
- **§14 BOOT SEQUENCE** mirrors the Box₃ aliveness flow (PR #12, #13) — register, start, emit heartbeat, mark ready only after proof.

---

## Process going forward

1. **This PR (#TBD): DRAFT.** Captures the spec verbatim + this reconciliation. Does not alter any other repo file. Does not promote the spec to ACTIVE.
2. **Lucius rules on Conflicts 1, 2, 3.**
3. **Resolution PR:** edit `ARCHITECTURE.SPEC.md` to the resolved form, lift DRAFT mark, apply resolutions where they touch other files (e.g. update `NAMING.CONTRACT.toml [core.deprecated]` for Lisp triad change, formalize the daemon-vs-slot duality in `VEC3.SURFACES.md`). Merge.
4. **Eight follow-up PRs** (one per row in "New concepts" table) — small, scoped, each can be reviewed independently.

The spec stays DRAFT until step 3.

:: ∎
