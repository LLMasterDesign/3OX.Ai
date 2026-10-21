# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.202 // WORKBOOK :: GlyphBit root API ▞▞

defmodule GlyphBit do
  @moduledoc """
  Flat GlyphBit runtime — post-responder only.

  Proves `3OX ⊨ ∀ λ ∈ Λᴳ_post, ∃! τ ∈ T_post : R(λ, τ)` under BEAM Pulse.
  """

  @doc "Post-only entry: evaluate chat-after context and return unique τ."
  def after_chat(context) when is_map(context) do
    GlyphBit.Storm.after_chat(context)
  end

  @doc "Reset turn uniqueness counter (new primary turn)."
  def reset_turn do
    GlyphBit.Storm.reset_turn()
  end

  @doc "Heartbeat / aliveness snapshot."
  def heartbeat do
    GlyphBit.Storm.heartbeat()
  end
end
