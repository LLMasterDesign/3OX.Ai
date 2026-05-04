///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.124 // _META :: ARCHITECTURE.RECONCILIATION ▞▞

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[26.05.04]
/// doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
/// Reconciliation between ARCHITECTURE.SPEC.md and existing canon — all three conflicts resolved
```

# Reconciliation: Architecture Freeze ↔ Existing Canon

`_meta/canon/ARCHITECTURE.SPEC.md` (ver 1.0.0, 26.05.04) is captured verbatim
from Lucius's dictation. This file dissects it section-by-section
against everything already locked into the repo, so nothing is
silently overwritten.

## Existing canon this PR is reconciled against

| Canon | Source | Status |
|---|---|---|
| `Core{}` 27-slot chamber (κ27) | `_meta/NAMING.CONTRACT.toml [core]`, `routes.json slot_index k00..k26` | locked PR #21, #30 |
| Warden's twelve laws | `.3ox/(3)Rules/limits.toml [[warden.law]]`, `scripts/warden_laws_validate.py` | locked PR #23 |
| `.vec3/` seven surfaces | `_meta/canon/VEC3.SURFACES.md` | locked PR #34 |
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
| 7 | VEC3 GEOMETRY | ✅ **exact match** with `_meta/canon/VEC3.SURFACES.md` (PR #34) |
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

## Resolved conflicts

All three open conflicts ruled on by Lucius on 26.05.04. Each resolution is recorded below with quoted reasoning so the decision is auditable.

### Conflict 1 — "6 daemons" vs κ27 + missing Scheduler — RESOLVED ✅

> Lucius: *"Yes daemon are seperate. κ00–02 are the scripts for how TPW makes everything run. While their daemons keep it all functional at first. I believe they need daemons for aliveness even if the rotary is working… they were the first 3 daemons and Queue and Worker came next. Supervisor was Gatekeeper but we don't use that title anymore."*

**Ruling:** Daemons are **runtime process classes**. Slots in κ27 are **identity authorities**. They are different planes. The κ00–k02 slot specs are the *scripts* by which the rotor runs (3OX.SPIN walks Warden → Tape → Pulse). The daemons of the same name are how those slots stay alive *at boot, before the rotor turns*. The two are complementary: slot governs meaning, daemon supplies aliveness.

**History:** Warden, Tape, and Pulse were the first three daemons. Queue and Worker were added later. The Supervisor daemon was originally called **Gatekeeper** — that title is deprecated and recorded in `_meta/NAMING.CONTRACT.toml [core.deprecated]`.

**Authority mapping (resolved):**

| Daemon (process class) | Lives at (`.vec3/proc/`) | κ27 authority |
|---|---|---|
| Supervisor *(formerly Gatekeeper)* | `proc/self/`, `proc/kernel/` | `Core{System}.Daemon` (k21) |
| Warden | (in-process gate, no proc dir) | `Core{Axis}.Warden` (k00) |
| Queue | `proc/queue/` | `Core{Ring}.Intake` (k09) + `Core{Ring}.Route` (k12) |
| Worker | `proc/workers/` | `Core{Ring}.Execute` (k13) |
| Tape | (writer, no proc dir) | `Core{Axis}.Tape` (k01) |
| Pulse | (observer, no proc dir) | `Core{Axis}.Pulse` (k02) |

**Open / future work** (Lucius: *"I'm not sure how scheduler / worker / queue all work together yet"*):
- The Scheduler daemon mentioned in §6/§18 (the only emitter of `CLOCK_EVENT`) does **not yet** have a locked relationship to Queue and Worker. Its physical location, slot governance, and whether it lives at the cube tier or the system tier (`_TRON/systemd/`) are deferred until Lucius designs that interaction. This is not a bug in the spec — it is a deliberate "to be designed" surface.
- When that interaction is locked, a follow-up PR will: (a) add Scheduler to the daemon table above, (b) update `_meta/EVENT.SOURCES.md` (queued in the New Concepts list, item N4), (c) decide whether `CLOCK_EVENT` enters at `Core{Axis}.Pulse` (k02) or somewhere else.

---

### Conflict 2 — Language triad — RESOLVED ✅

> Lucius: *"BEAM is right for TAPe and lisp for Supervisor."*

**Ruling:** Architecture Freeze §10 supersedes the earlier "3OX.Core{} Research Note" triad. Final assignment:

```
Warden    (k00, daemon)    ← Rust          (compiled strict guards)
Tape      (k01, daemon)    ← Elixir/BEAM   (append-first concurrency)
Pulse     (k02, daemon)    ← Elixir/BEAM   (telemetry; JSONL on the wire, not authority)
PRISM+    (output layer)   ← Elixir/BEAM   (output shaping, snips at .vec3/lib/snips/)
Supervisor (k21 daemon)    ← Lisp          (continuity host; hot-loadable cognition forms)
Raven cores / entity cores ← Lisp          (symbolic substrate, lives at .vec3/proc/agents/)
Worker    (job execution)  ← Lisp invoker  (hot-loads forms into Supervisor's host)
```

This is a *promotion* of Lisp out of the data plane and into the cognition / continuity plane. Tape moves to Elixir alongside PRISM+ because BEAM is the right substrate for high-concurrency append-first streams.

**Recorded in:** `_meta/NAMING.CONTRACT.toml [core.deprecated]` — the earlier Lisp→Tape assignment is now an auditable deprecation entry.

---

### Conflict 3 — `brain.rs` vs `brains.rs` — RESOLVED ✅

> Lucius: *"Brains was correct my bad."*

**Ruling:** Repo wins. `brains.rs` (plural) stays. The Architecture Spec is edited to match the repo. No file moves required.

---

## Naming hygiene applied alongside the rulings

In the course of Q1, Lucius mentioned: *"Supervisor was Gatekeeper but we don't use that title anymore."* Recorded explicitly:

- `_meta/NAMING.CONTRACT.toml [core.deprecated]` gains `"Gatekeeper" = "renamed to Supervisor; lives at Core{System}.Daemon (k21)"` so future writers don't reach for the old title.

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
| N8 | L1 LITE tier (sparkfile + vec3 only, services/stations) | §8.1 | extend `_meta/canon/VEC3.SURFACES.md` L2/L3 split; add to `PLAN.md` | propose |

---

## Strong alignments (recorded for posterity)

These sections of the spec confirm and reinforce existing canon. No PR needed — they're already in the repo, just newly tied to the spec language.

- **§7 VEC3 :: FULL GEOMETRY** is an exact match for `_meta/canon/VEC3.SURFACES.md` (PR #34). Same seven surfaces, same place-vs-authority, same sub-folder topology. The spec slightly extends some surfaces with extra `contains` items (`policy.wasm` at system scale for `rc/`, `*.ref` explicit in `lib/`, `pid` + `state.json` in `var/`) — all compatible additions, none contradictory.
- **§13 RECEIPT LAW** matches Tape's authority over `.vec3/var/receipts/` (mirror) vs `_TRON/receipts/` (authoritative), and binds to Warden Law #9 TAPE_INTEGRITY (append-only, no overwrite, corrections via compensating receipts).
- **§18 HARD LINES** are direct restatements of Warden laws + 3OX.SPIN rotor + edge-only. "no per-agent timer spam" = PR #29. "Warden fail-closed" = Warden Law #12 FAIL_CLOSED. "logs do not outrank receipts" = Warden Law #9.
- **§14 BOOT SEQUENCE** mirrors the Box₃ aliveness flow (PR #12, #13) — register, start, emit heartbeat, mark ready only after proof.

---

## Process going forward

1. ~~Capture the spec verbatim + dissect.~~ ✅ done in PR #35.
2. ~~Lucius rules on Conflicts 1, 2, 3.~~ ✅ done 26.05.04. All three resolved above.
3. **This commit:** lifts the DRAFT mark on `ARCHITECTURE.SPEC.md`, records resolutions, applies the auditable supersessions in `_meta/NAMING.CONTRACT.toml [core.deprecated]` (Lisp→Tape and Gatekeeper→Supervisor).
4. **Eight follow-up PRs** (one per row in "New concepts" table) — small, scoped, each can be reviewed independently. Of these, **N4 (Event sources)** carries an explicit dependency on Lucius's future Scheduler/Queue/Worker design ruling, so it should land last in the sequence.

The spec is now `ACTIVE`. The Scheduler/Queue/Worker interaction model remains the only design surface explicitly marked "to be designed."

:: ∎
