///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.053 // WORKBOOK :: ENCODER.RULES ▞▞

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[26.05.03]
/// doc:[PARTIAL] auth:[3OX.AI]
/// Normative rules — encoder completion gates
```

# Encoder — Rules

Rules use **MUST** / **SHOULD** / **MAY** (RFC 2119 sense). Violations block **merge** or **release** per the gate column.

## Z. Agent conduct (Cursor / human implementers)

| ID | Rule | Gate |
|----|------|------|
| Z1 | Before **running code or shell commands**, the agent **MUST** show **preview** (what + why), **example** (expected command shape or sample I/O), then **run**, then **validate** (exit code / output / file check). | Review |
| Z2 | Read-only inspection **SHOULD** state intent in one line before the tool call. | Review |

**Example (validate hex index + fixture doc):**

```bash
python3 scripts/encoder_validate.py
python3 scripts/encoder_validate.py --doc scripts/encoder_fixtures/valid_line1.md
```

**Expected:** `ok: .3ox/(5)Links/hex.index.json — …` and `ok: doc scripts/encoder_fixtures/valid_line1.md — chip 0x0A4 …`; exit code **0**.

## A. Hex & line 1 (Gensing chip)

| ID | Rule | Gate |
|----|------|------|
| H1 | Line 1 **MUST** contain the agreed glyph spine prefix and **exactly** one chip **`::0xHHH::`** where `HHH` are three hex digits (`0-9A-Fa-f`). | CI / lint |
| H2 | Chip **MUST NOT** contain non-hex letters (e.g. G, H, K) inside the numeric span. | CI / lint |
| H3 | Long packed IDs **MUST NOT** replace the chip on line 1; full precision lives in `hex.index.json` or registry rows. | Review |
| H4 | If a document **claims** a code, **`hex.index.json`** `entries` **MUST** contain that key with at least `code` and `owner`. | CI |
| H5 | Silent overwrite of an existing `entries[key]` **MUST NOT** occur without owner handoff or explicit merge policy. | Review |

## B. Encoder layers 0–9

| ID | Rule | Gate |
|----|------|------|
| L0 | **RAW** **MUST NOT** be trusted for MAP or RECEIPT without passing SPARK orientation. | Design review |
| L1 | **SPARK** **MUST** set interpretive frame (role, intent, limits) before PHENO for automated runs. | Script |
| L2 | **PHENO** **MUST** be satisfiable as ρ φ τ (order preserved) when EXC or encoder profile requires it. | EXC validator |
| L3 | **PiCO** **MUST** map to ⊢ ⇨ ⟿ ▷ steps for bounded execution units that declare PiCO. | EXC validator |
| L4 | **PRISM** **MUST** equal literal `PRISM` where EXC v1 applies; presentation rules **SHOULD** be declared before emit. | EXC validator |
| L5 | **MAP** **SHOULD** resolve via `hex.index.json` + `routes.json` before emitting grounded claims. | CI optional |
| L6 | Every completed **encoded run** **SHOULD** emit one **RECEIPT** artifact. | Integration |
| L7 | **TAPE** **SHOULD** append receipts in deterministic order (append-only). | Integration |
| L8 | **PULSE** **MUST** update `status.json` `updated_at` when the station heartbeats (existing `.3ox/run.rb` behavior). | Aliveness |
| L9 | **LOOP** **SHOULD** read last receipt (or equivalent) before scheduling a follow-up run; unbounded self-queue **MUST** be blocked by policy. | Integration |

## C. WARDEN / limits

| ID | Rule | Gate |
|----|------|------|
| W1 | All writes **MUST** respect `.3ox/(3)Rules/limits.toml` `write_policy` and `scope`. | Warden |
| W2 | External receipts **SHOULD** record **sha256**; internal hot paths **MAY** use **xxh128** per `limits.toml`. | Review |

## D. EXC (when present)

| ID | Rule | Gate |
|----|------|------|
| E1 | **`.exc` wins** over `.kdl` and `.exs` on semantic conflict. | Review |
| E2 | `.kdl` **SHOULD** be mechanically generated from `.exc` or proven equivalent. | CI optional |
| E3 | Outcomes **PASS** / **FALLBACK** / **FAIL** **MUST** match definitions in `routes.json` `exc_boundary.validation_outcomes`. | EXC tests |
| E4 | `π` **MAY** be absent in v1; absence **MUST NOT** invalidate the unit. | EXC tests |

## E. GlyphBit / HIRO / .ME

| ID | Rule | Gate |
|----|------|------|
| G1 | ClassicMD `.bit` files **SHOULD** declare `INDEX_REF` to HIRO + PRISM (+ GEM) per their blueprint. | Manual |
| G2 | One hex cluster **MAY** reference many files; **SHOULD** list cluster in `hex.index.json` when stable. | Review |

## F. Completion checklist (release)

- [ ] `ENCODER.PRD.md` goals G1–G6 satisfied or explicitly waived with version note.
- [ ] `ENCODER.PLAN.md` Phase 1 exit criteria met (validate shell).
- [ ] `ENCODER.ARCHITECTURE.md` diagram matches implemented paths.
- [ ] This **RULES** file gates H1, H4, H8 green in CI where automation exists.

---

## Related files

- `_meta/ENCODER.PRD.md` — requirements
- `_meta/ENCODER.PLAN.md` — phases
- `_meta/ENCODER.ARCHITECTURE.md` — diagrams + component map
- `_meta/ENCODER.RECEIPT.schema.json` — RECEIPT v1 JSON Schema
- `scripts/exc_fixtures/encoder_minimal.exc` — minimal normative EXC v1 (DRAKON-inspired bodies)
- `scripts/exc_validate.py` — boundary check for `.exc`
- `.3ox/(5)Links/routes.json`, `hex.index.json`
- `.3ox/(3)Rules/limits.toml`

---

:: ∎
