///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.202 // WORKBOOK :: GlyphBit README ▞▞

# GlyphBit.STORM — flat post-responder on BEAM

Smallest 3OX variant. One sparkfile → rated gate → ontology asserts → Elixir/BEAM GenServer.

Proves: `3OX ⊨ ∀ λ ∈ Λᴳ_post, ∃! τ ∈ T_post : R(λ, τ)`

## Quick proof

```bash
cd "3OX Agents/GlyphBit"
mix test
mix glyph.compile
```

## API

```elixir
GlyphBit.after_chat(%{primary_reply: "...", user_turn: "..."})
# => %{tau: :post_emit | :abstain_silence, line: nil | binary, rate: %{...}}

GlyphBit.reset_turn()
GlyphBit.heartbeat()
```

## Layout

| Path | Role |
|------|------|
| `STORM.sparkfile.md` | Flat six-lane source of truth |
| `lib/glyph_bit/rate.ex` | Pure rate gate |
| `lib/glyph_bit/ontology.ex` | Embedded Λᴳ / T / ∃! |
| `lib/glyph_bit/storm.ex` | Pulse GenServer |
| `lib/glyph_bit/compiler.ex` | Spark → digest artifact |
| `GLYPHBIT.BEAM.plan.md` | Full pipeline plan |

Post-only. Never owns the chat turn.
