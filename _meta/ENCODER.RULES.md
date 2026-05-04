# Encoder — Warden laws (v1)

Authoritative source: **`.3ox/(3)Rules/limits.toml`** → **`[warden]`**, **`[warden.field]`**, **`[[warden.law]]`** (12 rows).

CI: `python3 scripts/warden_laws_validate.py` · `python3 scripts/core_slots_validate.py`

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

## Project Orion (memory loop)

- **Seat:** **ENCODE.MEMORY** → **`k07`** (same κ as Ring C **C4** event contract; Orion is an additional memory-pipeline lens).
- **Hex band:** **`0x140`** bundle · **`0x141`–`0x147`** seven slots (`O1`…`O7`).
- **Pipeline:** `RAW → TRIAD → GRAPH → RETRIEVE → RESPOND → RECEIPT → LOOP` — **TRIAD** = **core belt of 3 beacons** (compress after bind, before graph).
- **Specs:** `.3ox/(3)Rules/exc/orion/*.spec` · **Registry:** `routes.json` → `gensing.orion` (steps 1–9 folded into seven slots + bundle).
- **Law:** `slot.index.kdl` → **`orion.memory`**.

:: ∎
