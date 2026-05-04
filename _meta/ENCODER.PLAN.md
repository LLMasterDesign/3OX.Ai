///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.053 // WORKBOOK :: ENCODER.PLAN ▞▞

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[26.05.03]
/// doc:[PARTIAL] auth:[3OX.AI]
/// Phased delivery plan — encoder completion
```

# Encoder — Delivery Plan

## Phase 0 — Lock semantics (docs only)

- [ ] Freeze **encoder layer** names 0–9 and one-line contracts (this repo: PRD + ARCHITECTURE + RULES).
- [ ] Document **16 × 256** hex continent strategy (default seed: `0x0**` kernel/infra, `0x1**` GlyphBit, `0x2**` Genesis; reserve `0x3**`–`0xF**` in PLAN appendix).
- [ ] Align **HIRO / ME / core document** triad with `hex.index.json` optional fields (`exc_surfaces`, `files[]` when added).

**Exit:** All four `_meta/ENCODER.*` files reviewed; no open contradictions with `routes.json` / `hex.index.json`.

## Phase 1 — Validation shell

- [ ] Implement **chip linter**: first line matches glyph spine + `::0xHHH::`; reject wrong length / non-hex. **Script:** `python3 scripts/encoder_validate.py --doc <path>` (chip-only on line 1).
- [ ] Implement **index gate**: claimed codes exist in `hex.index.json`; `owner` present. **Script:** `python3 scripts/encoder_validate.py`.
- [ ] Wire **one** CI step or `scripts/encoder_validate.sh` (language TBD) invoked from Makefile or `.github/workflows` if present.

**Exit:** PR fails if sample corpus has invalid chips or missing index rows for claimed codes.

## Phase 2 — MAP + RECEIPT + TAPE

- [ ] Define **RECEIPT** JSON shape (align with existing `runtime/logs/*.json` or extend).
- [ ] Define **append to TAPE** (queue file or dedicated `tape.jsonl` — choose one; document in ARCHITECTURE).
- [ ] MAP resolver: chip → `hex.index.json` → `routes.json` `slot_index` / `maps`.

**Exit:** One **end-to-end dry run** (noop or sample job) produces receipt + tape pointer + pulse status update.

## Phase 3 — EXC boundary (optional v1.1)

- [ ] Add `inst/proto/exc.v1.proto` or document-only until codegen.
- [ ] Minimal **Validate** path: canonical `.exc` text → check invariants from `routes.json` `exc_boundary`.
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
