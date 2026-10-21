# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.202 // WORKBOOK :: GlyphBit.Ontology ▞▞

defmodule GlyphBit.Ontology do
  @moduledoc """
  Embedded unique-binding ontology for GlyphBit post lane.

  Runtime surface of:
  3OX ⊨ ∀ λ ∈ Λᴳ_post, ∃! τ ∈ T_post : R(λ, τ)
  """

  @claim "3OX ⊨ ∀ λ ∈ Λᴳ_post, ∃! τ ∈ T_post : R(λ, τ)"
  @lambda_set ["post-output.storm"]
  @tau_set [:post_emit, :abstain_silence]
  @tau_wire %{"post.emit" => :post_emit, "abstain.silence" => :abstain_silence}

  @type tau :: :post_emit | :abstain_silence

  def claim, do: @claim
  def lambda_set, do: @lambda_set
  def tau_set, do: @tau_set

  def embed do
    %{
      claim: @claim,
      lambda_set: @lambda_set,
      tau_set: ["post.emit", "abstain.silence"],
      relation: "gate → emit|silence",
      uniqueness: %{
        max_posts_per_turn: 1,
        fail_closed: true,
        primary: false
      }
    }
  end

  @doc "Reject any τ outside T_post."
  def assert_tau!(tau) when tau in @tau_set, do: tau

  def assert_tau!(tau) do
    raise ArgumentError,
          "ontology violation: τ=#{inspect(tau)} ∉ T_post=#{inspect(@tau_set)}"
  end

  @doc "Parse wire string into typed τ."
  def parse_tau!("post.emit"), do: :post_emit
  def parse_tau!("abstain.silence"), do: :abstain_silence

  def parse_tau!(other) do
    raise ArgumentError, "unknown τ wire form: #{inspect(other)}"
  end

  def to_wire(:post_emit), do: "post.emit"
  def to_wire(:abstain_silence), do: "abstain.silence"

  @doc "Enforce ∃! — at most one post.emit per turn."
  def assert_unique_turn!(posts_this_turn) when is_integer(posts_this_turn) do
    if posts_this_turn >= 1 do
      :abstain_silence
    else
      :ok
    end
  end

  @doc "Primary must never be claimed by GlyphBit."
  def assert_post_only!(%{primary: true}) do
    raise ArgumentError, "ontology violation: GlyphBit cannot set primary=true"
  end

  def assert_post_only!(_harness), do: :ok

  def lambda, do: "post-output.storm"

  def known_wire?(s) when is_binary(s), do: Map.has_key?(@tau_wire, s)
end
