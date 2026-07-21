# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.202 // WORKBOOK :: GlyphBit.Storm GenServer ▞▞

defmodule GlyphBit.Storm do
  @moduledoc """
  BEAM projection of GlyphBit.STORM — Pulse-shaped post-responder.

  API:
    after_chat(ctx) → %{tau: ..., line: nil | binary, rate: map}
    reset_turn/0
    heartbeat/0
  """
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def after_chat(context) when is_map(context) do
    GenServer.call(__MODULE__, {:after_chat, context})
  end

  def reset_turn, do: GenServer.call(__MODULE__, :reset_turn)
  def heartbeat, do: GenServer.call(__MODULE__, :heartbeat)

  @impl true
  def init(_opts) do
    GlyphBit.Storm.Harness.validate!()

    state = %{
      identity: GlyphBit.Storm.Harness.identity(),
      ontology: GlyphBit.Ontology.embed(),
      posts_this_turn: 0,
      last_tau: nil,
      last_rate: nil,
      started_at: DateTime.utc_now(),
      spins: 0
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:after_chat, context}, _from, state) do
    GlyphBit.Storm.Harness.validate!()
    {result, new_state} = relate(context, state)
    {:reply, result, %{new_state | spins: state.spins + 1}}
  end

  def handle_call(:reset_turn, _from, state) do
    {:reply, :ok, %{state | posts_this_turn: 0}}
  end

  def handle_call(:heartbeat, _from, state) do
    beat = %{
      alive: true,
      glyphbit_id: state.identity.glyphbit_id,
      primary: state.identity.primary,
      posts_this_turn: state.posts_this_turn,
      last_tau: state.last_tau && GlyphBit.Ontology.to_wire(state.last_tau),
      spins: state.spins,
      started_at: DateTime.to_iso8601(state.started_at),
      ontology_claim: state.ontology.claim
    }

    {:reply, beat, state}
  end

  defp relate(context, state) do
    # Uniqueness first — ∃!
    case GlyphBit.Ontology.assert_unique_turn!(state.posts_this_turn) do
      :abstain_silence ->
        finish(:abstain_silence, nil, %{verdict: :hold, score: 0.0, reasons: ["hold:already_posted"]}, state)

      :ok ->
        rate = GlyphBit.Rate.score(context)

        tau =
          case rate.verdict do
            :fire -> :post_emit
            :hold -> :abstain_silence
          end

        tau = GlyphBit.Ontology.assert_tau!(tau)

        {line, posts} =
          case tau do
            :post_emit ->
              call = GlyphBit.Storm.Harness.pick_rupture(Map.get(context, :seed, 0))
              {GlyphBit.Storm.Harness.format_line(call), state.posts_this_turn + 1}

            :abstain_silence ->
              {nil, state.posts_this_turn}
          end

        finish(tau, line, rate, %{state | posts_this_turn: posts})
    end
  end

  defp finish(tau, line, rate, state) do
    GlyphBit.Ontology.assert_tau!(tau)

    {:ok, _row} =
      GlyphBit.Tape.append(%{
        lambda: GlyphBit.Ontology.lambda(),
        gate: rate.verdict,
        score: rate.score,
        reasons: rate.reasons,
        tau: GlyphBit.Ontology.to_wire(tau),
        line: line,
        hash: receipt_hash(tau, line, rate)
      })

    result = %{
      tau: tau,
      tau_wire: GlyphBit.Ontology.to_wire(tau),
      line: line,
      rate: rate,
      lambda: GlyphBit.Ontology.lambda()
    }

    {result, %{state | last_tau: tau, last_rate: rate}}
  end

  defp receipt_hash(tau, line, rate) do
    payload =
      [
        GlyphBit.Ontology.to_wire(tau),
        line || "",
        to_string(rate.verdict),
        :erlang.float_to_binary(rate.score * 1.0, decimals: 4)
      ]
      |> Enum.join("|")

    GlyphBit.Hash.tagged_internal(payload)
  end
end
