# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.202 // WORKBOOK :: GlyphBit.Rate ▞▞

defmodule GlyphBit.Rate do
  @moduledoc """
  Pure rate gate for GlyphBit post-output.

  Returns `{score, verdict, reasons}` — never the post text.
  Ambiguity / hard hold → :hold (FAIL_CLOSED → abstain.silence upstream).
  """

  @keywords ~w(stagnation delay later tomorrow waiting stuck loop)
  @signal_weights %{
    "stagnation" => 1.0,
    "delay" => 1.0,
    "timeline.loop" => 1.0,
    "avoidance" => 0.9,
    "false.continuity" => 0.9
  }
  @fire_threshold 1.0

  @type verdict :: :fire | :hold
  @type result :: %{score: float(), verdict: verdict(), reasons: [String.t()]}

  @doc "Score a chat-after context map."
  def score(context) when is_map(context) do
    reasons = []
    {score, reasons} = apply_hard_holds(context, 0.0, reasons)

    if hard_held?(reasons) do
      %{score: score, verdict: :hold, reasons: Enum.reverse(reasons)}
    else
      {score, reasons} = apply_signals(context, score, reasons)
      {score, reasons} = apply_keywords(context, score, reasons)
      {score, reasons} = apply_ambiguity(context, score, reasons)

      verdict =
        cond do
          ambiguous?(reasons) -> :hold
          score >= @fire_threshold -> :fire
          true -> :hold
        end

      %{score: score, verdict: verdict, reasons: Enum.reverse(reasons)}
    end
  end

  defp apply_hard_holds(ctx, score, reasons) do
    reasons =
      cond do
        not primary_exists?(ctx) ->
          ["hold:no_primary" | reasons]

        true ->
          reasons
      end

    reasons =
      if Map.get(ctx, :already_posted, false) or Map.get(ctx, "already_posted", false) do
        ["hold:already_posted" | reasons]
      else
        reasons
      end

    reasons =
      if Map.get(ctx, :ask_explain, false) or Map.get(ctx, "ask_explain", false) do
        ["hold:ask_explain" | reasons]
      else
        reasons
      end

    reasons =
      if Map.get(ctx, :handoff, false) or Map.get(ctx, "handoff", false) do
        ["hold:handoff" | reasons]
      else
        reasons
      end

    # Forced dual-route / conflict flag → FAIL_CLOSED
    reasons =
      if Map.get(ctx, :ambiguous, false) or Map.get(ctx, "ambiguous", false) do
        ["hold:ambiguous" | reasons]
      else
        reasons
      end

    {score, reasons}
  end

  defp apply_signals(ctx, score, reasons) do
    signals = List.wrap(Map.get(ctx, :signals) || Map.get(ctx, "signals") || [])

    Enum.reduce(signals, {score, reasons}, fn sig, {s, r} ->
      key = to_string(sig)
      w = Map.get(@signal_weights, key, 0.5)
      {s + w, ["fire:signal:#{key}" | r]}
    end)
  end

  defp apply_keywords(ctx, score, reasons) do
    text =
      [
        Map.get(ctx, :user_turn) || Map.get(ctx, "user_turn") || "",
        Map.get(ctx, :primary_reply) || Map.get(ctx, "primary_reply") || ""
      ]
      |> Enum.join(" ")
      |> String.downcase()

    hits = Enum.filter(@keywords, &String.contains?(text, &1))

    Enum.reduce(hits, {score, reasons}, fn kw, {s, r} ->
      {s + 1.0, ["fire:keyword:#{kw}" | r]}
    end)
  end

  defp apply_ambiguity(ctx, score, reasons) do
    # Threshold boundary without clear signal → treat as ambiguous when flagged
    boundary = Map.get(ctx, :boundary, false) or Map.get(ctx, "boundary", false)

    if boundary and score > 0 and score < @fire_threshold do
      {score, ["hold:boundary" | reasons]}
    else
      {score, reasons}
    end
  end

  defp primary_exists?(ctx) do
    reply = Map.get(ctx, :primary_reply) || Map.get(ctx, "primary_reply")
    is_binary(reply) and String.trim(reply) != ""
  end

  defp hard_held?(reasons) do
    Enum.any?(reasons, &String.starts_with?(&1, "hold:"))
  end

  defp ambiguous?(reasons) do
    Enum.any?(reasons, &(&1 in ["hold:ambiguous", "hold:boundary"]))
  end

  def fire_threshold, do: @fire_threshold
  def keywords, do: @keywords
end
