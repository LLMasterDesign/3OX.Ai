///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.053 // WORKBOOK :: ENCODER.PRD ▞▞

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[26.05.03]
/// doc:[PARTIAL] auth:[3OX.AI]
/// Product requirements — 3OX encoder (layers 0–9, hex, EXC, GlyphBit)
```

# Encoder — Product Requirements Document (PRD)

## 1. Purpose

Build a **complete, enforceable encoder** for 3OX that:

- Runs the **ten encoder layers** (0 RAW → 9 LOOP) as an explicit pipeline.
- Binds work to a **4096 code space** (`::0xHHH::`) with a **single merge target** (`hex.index.json`) so agents do not overwrite each other silently.
- Supports **EXC** as a non-executing boundary (`.exc` canonical, `.kdl` derived, `.exs` validates/executes).
- Coexists with **GlyphBit / HIRO / .ME (ClassicMD)** and **Gensing** (glyph line + context line) without merging dialects prematurely.
- Integrates **WARDEN** (limits), **TAPE** (ordered receipts), **PULSE** (live state), and **MAP** (Links) as already sketched in `.3ox`.

## 2. Goals

| ID | Goal | Measurable |
|----|------|--------------|
| G1 | Every encoded run can be traced | At least one **RECEIPT** artifact per run; optional append to **TAPE** |
| G2 | Hex claims are coordinated | `hex.index.json` is the only authoritative map for `0x000`–`0xFFF` claims |
| G3 | No silent cross-agent slot collision | Context line + `slot_index` + hex row disambiguate themed 3ox |
| G4 | Boundary validation without domain execution | EXC **PASS / FALLBACK / FAIL** per `routes.json` `exc_boundary` |
| G5 | Token-efficient inference | Single-slot hydrate; chip + index row before bulk body |
| G6 | Parser-safe first line | Line 1: glyph spine + `::0xHHH::` only; no long hex billboard |

## 3. Non-goals (v1)

- Full **gRPC** server + **excR** package in-repo (document contract; implement when scheduled).
- Replacing **ClassicMD** GlyphBits with Gensing-only (both dialects supported).
- 4096 **physical files** on disk (sparse index + many docs per code allowed).

## 4. Users & scenarios

- **Author (Lucius):** defines HIRO / `.ME` / `.bit`, assigns hex, updates `hex.index.json`.
- **Operator:** runs `.3ox/run.rb`, checks aliveness, inspects queue/status.
- **AI agent:** resolves chip → index → slot/tools → hydrates one scope; merges hex rows with owner rules.
- **Validator (CI or script):** checks chip format, index presence, EXC invariants when EXC paths present.

## 5. Encoder layers (requirements)

Each layer **MUST** have: name, input, output, owner component, failure mode documented in `ENCODER.ARCHITECTURE.md`. Order is normative:

0. **RAW** — untrusted ingress.  
1. **SPARK** — orientation (role, intent, tone, limits).  
2. **PHENO** — ρ φ τ skeleton.  
3. **PiCO** — ⊢ ⇨ ⟿ ▷ execution path.  
4. **PRISM** — output shape / drift caps.  
5. **MAP** — grounding (hex index, routes, file slices).  
6. **RECEIPT** — one run, one proof object.  
7. **TAPE** — ordered append-only chain of receipts.  
8. **PULSE** — observable state (heartbeat, status).  
9. **LOOP** — next-step decision from last receipt; anti-drift / anti-unbounded recursion.

## 6. Hex & identity

- **Chip:** `::0xHHH::` (three hex digits after `0x`, `0x000`–`0xFFF`).
- **Index:** `.3ox/(5)Links/hex.index.json` — sparse `entries`; minimal row includes `code`, `owner`; optional `exc_id`, `exc_surfaces`, `slot`, `route_key`, file cluster metadata.
- **Optional taxonomy:** first nibble = 16 module continents (256 codes each); document allocation in `ENCODER.PLAN.md`.

## 7. Success criteria (definition of done)

- [x] Architecture doc is the single diagram + component map for the encoder.
- [x] Rules file is referenced by CI or `make`/script for at least **chip + index** validation.
- [x] At least one **reference implementation path** (`scripts/encoder_dry_run.py`) runs **MAP → RECEIPT → TAPE** (dry run); full Pulse job integration optional.
- [ ] PRD and Plan stay in sync when scope changes (version bump in frontmatter).

## 7b. Artifacts

- **RECEIPT v1 schema:** `_meta/ENCODER.RECEIPT.schema.json`
- **Dry run:** `python3 scripts/encoder_dry_run.py --code 0x02A`

## 8. Out of scope ambiguities (track in Plan)

- Exact automation language (Ruby vs Python) for validators.
- Whether LOOP is always software or includes human checkpoint.

---

:: ∎
