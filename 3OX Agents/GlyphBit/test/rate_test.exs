# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.202 // WORKBOOK :: rate_test ▞▞

defmodule GlyphBit.RateTest do
  use ExUnit.Case, async: true

  test "keywords produce fire" do
    r =
      GlyphBit.Rate.score(%{
        primary_reply: "ok",
        user_turn: "delay and stagnation"
      })

    assert r.verdict == :fire
    assert r.score >= 1.0
  end

  test "no primary forces hold" do
    r = GlyphBit.Rate.score(%{primary_reply: "", user_turn: "stuck in a loop"})
    assert r.verdict == :hold
  end
end
