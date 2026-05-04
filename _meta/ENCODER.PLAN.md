///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.053 // WORKBOOK :: ENCODER.PLAN ▞▞

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[26.05.03]
/// doc:[PARTIAL] auth:[3OX.AI]
/// Phased delivery plan — encoder completion
```

# Encoder — Delivery Plan

## Phase 0 — Lock semantics (docs only)

- [x] **3OX.Core{}** — `routes.json` `core` + `slot_index` **k00..k26**; validate with **`python3 scripts/core_slots_validate.py`** (CI).
- [ ] Document **16 × 256** hex continent strategy (default seed: `0x0**` kernel/infra, `0x1**` GlyphBit, `0x2**` Genesis; reserve `0x3**`–`0xF**` in PLAN appendix).
- [ ] Align **HIRO / ME / core document** triad with `hex.index.json` optional fields (`exc_surfaces`, `files[]` when added).

**Exit:** All four `_meta/ENCODER.*` files reviewed; no open contradictions with `routes.json` / `hex.index.json`.

## Phase 1 — Validation shell

- [x] Implement **chip linter**: first line matches glyph spine + `::0xHHH::`; reject wrong length / non-hex. **Script:** `python3 scripts/encoder_validate.py --doc <path>` (chip-only on line 1).
- [x] Implement **index gate**: claimed codes exist in `hex.index.json`; `owner` present. **Script:** `python3 scripts/encoder_validate.py`.
- [x] Wire **CI** — `.github/workflows/encoder.yml` runs `python3 scripts/encoder_validate.py` and `--doc scripts/encoder_fixtures/valid_line1.md` on push/PR to `main`.

**Exit:** PR fails if sample corpus has invalid chips or missing index rows for claimed codes.

## Phase 2 — MAP + RECEIPT + TAPE

- [x] Define **RECEIPT** JSON shape — `_meta/ENCODER.RECEIPT.schema.json` (extends Pulse `job_id`, `completed_at`, `status`, `output_preview` + `encoder` MAP block).
- [x] **TAPE** — append-only **`.3ox/(6)Pulse/runtime/tape/tape.jsonl`** (NDJSON receipts); jobs queue stays `jobs.json`.
- [x] **MAP** — `routes.json` **`maps.hex`**, **`slot_index`**, `routes.*.slot`; resolver: **`scripts/encoder_dry_run.py`**.

**Exit:** **`python3 scripts/encoder_dry_run.py --code 0x02A`** writes **`runtime/logs/dry-run-*.json`**, **`runtime/logs/dry_run_pulse.json`**, appends **TAPE**; CI runs this step after encoder_validate.

## Phase 3 — EXC boundary (optional v1.1)

- [x] Minimal **`.exc` fixture** + **`scripts/exc_validate.py`** (PHENO, PiCO, PRISM, Ξ inner text, ν; optional `--canonical` for round-trip).
- [ ] Add `inst/proto/exc.v1.proto` or document-only until codegen.
- [ ] Deterministic `.kdl` emit from `.exc` (script or small lib).

**Exit:** Golden-file test: sample `.exc` → PASS; mutated → FALLBACK/FAIL per matrix in RULES.

## Phase 4 — LOOP + anti-recursion

- [ ] LOOP reads **last receipt** (and/or `hex.index` + session) before re-queueing.
- [ ] Policy: max depth or explicit “handoff required” flag in receipt.

**Exit:** Documented test: infinite re-prompt scenario **stops** with receipt reason code.

## Phase 5 — Inference & GlyphBit bridge

- [ ] Document **single-slot hydrate** contract for any LLM caller (from `tools.yml` / `routes.json`).
- [ ] Optional: **GlyphBit** `.ME` `index_ref` includes encoder version or `ENCODER.RULES` pointer.

**Exit:** One worked example: Noctua cluster hex + ClassicMD + index row.

---

## Dependencies

- `.3ox/(5)Links/` — `routes.json`, `hex.index.json`, `map.toml`, `slot.index.kdl`
- `.3ox/(3)Rules/limits.toml` — WARDEN
- `.3ox/run.rb` — PULSE / TAPE hooks for jobs

## Risks

| Risk | Mitigation |
|------|------------|
| Hex index merge conflicts | Owner + PR review; optional lock file per code in future |
| Layer blur in implementation | Each module owns one layer; ARCHITECTURE lists owners |
| Scope creep | PRD non-goals; phase gates |

---

:: ∎
