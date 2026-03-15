///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.073 // WORKBOOK :: Boot.plan.md ▞▞

```elixir
/// status:[DRAFT] ver:[1.0.0] created:[26.03.14]
/// doc:[PARTIAL] modified:[26.03.14] auth:[3OX.AI]
/// Live bootstrap plan with minimal success contract for Box aliveness
```

# Boot Plan — Box Aliveness to Live

## 0) Primary Function (one sentence)

Make one **authoritative transition** from intent → execution → receipt such that Box₃ invariants evaluate true and the run is reproducible.

---

## 1) Success Contract (definition of “complete”)

A boot cycle is **COMPLETE** only when all checks below pass in the same run context:

1. **Pulse is valid**
   - `status.json` exists and has current `updated_at`, service map, and `last_completed_job`.
2. **Tape is valid**
   - queue/event artifacts exist and parse.
3. **Warden is valid**
   - rules/limits contract exists and is non-empty.
4. **Canon source is valid**
   - `.3ox` exists, `_meta/WHOAMI.md` exists, `_meta/SESSION.CHECKPOINT.toml` exists.
5. **Goal is reached**
   - at least one receipt-complete transition exists for the active intent.
6. **Authoritative is true**
   - `valid_box3=true` and canon source valid.

Operationally: `ruby .vec3/rc/run.rb aliveness` exits `0`.

---

## 2) What initiates “complete”

“Complete” is initiated by a **route-bound intent** that results in a terminal receipt.

Minimal trigger sequence:
1. Intent enters runtime (`queue`/route).
2. Runtime executes job.
3. Runtime emits completion artifact (`last_completed_job.status=completed` + receipt evidence).
4. RC aliveness check confirms authoritative state.

If any of the four steps fail, state is **not complete**.

---

## 3) Minimal Contract Needed to Work (MVP Contract)

You only need this to go live:

### Required files
- `.3ox/(3)Rules/limits.toml`
- `.3ox/_meta/WHOAMI.md`
- `.3ox/_meta/SESSION.CHECKPOINT.toml`
- `.vec3/rc/run.rb`
- `.3ox/run.rb` (delegation path for convenience)

### Required runtime artifacts
- `.3ox/(6)Pulse/runtime/status.json`
- `.3ox/(6)Pulse/runtime/queue/jobs.json`

### Required commands
- `ruby .3ox/run.rb queue noop`
- `ruby .3ox/run.rb once noop`
- `ruby .vec3/rc/run.rb aliveness`

### Required pass condition
- RC report returns:
  - `valid_box3=true`
  - `authoritative=true`
  - exit code `0`

That is the minimum viable live contract.

---

## 4) Boot Phases

## Phase A — Contract Lock
- Freeze meanings for: Pulse, Tape, Warden, Canon, Goal.
- Keep checks simple and binary (`true/false`) for launch.

Exit criterion:
- Team agrees “COMPLETE” means the 6 conditions in §1.

## Phase B — First Authoritative Transition
- Run noop path end-to-end once.
- Generate status + queue + completion artifacts.
- Confirm RC check returns success.

Exit criterion:
- One successful run captured with hashes and timestamps.

## Phase C — Repeatability
- Execute same flow 3 times.
- Confirm no structural drift in required fields.

Exit criterion:
- 3/3 successful authoritative runs.

## Phase D — Real Intent Cutover
- Replace noop with one real route intent (teleprompt or analyze).
- Verify same success contract holds.

Exit criterion:
- Real intent run exits authoritative and produces completion evidence.

---

## 5) Minimal Operator Runbook

1. `ruby .3ox/run.rb status`
2. `ruby .3ox/run.rb queue noop`
3. `ruby .3ox/run.rb once noop`
4. `ruby .vec3/rc/run.rb aliveness`

Interpretation:
- exit `0` → authoritative complete
- exit non-zero → inspect Pulse/Tape/Warden booleans and fix failing layer

---

## 6) Non-Goals for Launch (defer)

- Full merkle-chain proof validation.
- Full lineage and contract-hash route binding.
- Transition-id binding enforcement across all receipts.

These are hardening steps after live readiness.

---

## 7) Live Checklist

- [ ] Required files present
- [ ] Runtime artifacts generated
- [ ] First authoritative noop run passes
- [ ] Three repeat runs pass
- [ ] One real-intent run passes
- [ ] Team signs off on success contract

:: ∎
