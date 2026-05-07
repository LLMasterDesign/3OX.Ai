# Encoder — Warden laws (v1)

Authoritative source: **`.3ox/(3)Rules/limits.toml`** → **`[warden]`**, **`[warden.field]`**, **`[[warden.law]]`** (12 rows).

CI: `python3 scripts/warden_laws_validate.py`

| # | Code | Violation (summary) |
|---|------|------------------------|
| 1 | `SLOT_CAP` | Deny + violation receipt |
| 2 | `KERNEL_PROTECTION` | Deny |
| 3 | `WARDEN_FIRST` | Block execution |
| 4 | `DECLARED_CAPABILITY` | Deny by default |
| 5 | `SLOT_IDENTITY` | Reject registration |
| 6 | `ROUTE_DETERMINISM` | No execution |
| 7 | `NO_RAW_MUTATION` | Deny |
| 8 | `RECEIPT_COLLAPSE` | Degraded state |
| 9 | `TAPE_INTEGRITY` | Critical fault |
| 10 | `PULSE_VISIBILITY` | Degraded or restart |
| 11 | `MIGRATION_SEAL` | Reject upgrade |
| 12 | `FAIL_CLOSED` | Default (no violation class) |

Full `summary` and `violation` strings live in TOML only (single source of truth).

## Orion belt — engraved law (ο + Ω)

Cross-reference: **`_meta/canon/VEC3.SURFACES.md`** → **Orion's Belt (TRIAD)**.

**Engraved law:**

> **`ο{}` names a memory field; heat moves the field; the belt orders how a field may enter the graph; Ω proves what changed.**

:: ∎
