# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.202 // WORKBOOK :: GlyphBit proof fixtures ▞▞

defmodule GlyphBit.Fixtures do
  @moduledoc false

  def p1_fire do
    %{
      primary_reply: "We can revisit the migration next sprint.",
      user_turn: "I'm stuck waiting until tomorrow again.",
      seed: 0
    }
  end

  def p2_hold_clean do
    %{
      primary_reply: "Done. Files synced.",
      user_turn: "Thanks — looks good.",
      seed: 0
    }
  end

  def p3_no_primary do
    %{
      primary_reply: "",
      user_turn: "We are stuck in a delay loop.",
      seed: 0
    }
  end

  def p4_already_posted do
    Map.put(p1_fire(), :already_posted, true)
  end

  def p5_ambiguous do
    Map.merge(p1_fire(), %{ambiguous: true})
  end

  def p7_boundary do
    # Unknown signal weight 0.5 (< threshold) + boundary flag → FAIL_CLOSED silence
    %{
      primary_reply: "Noted.",
      user_turn: "ok",
      boundary: true,
      signals: ["soft"]
    }
  end
end
