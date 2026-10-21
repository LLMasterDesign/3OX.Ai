# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.202 // WORKBOOK :: GlyphBit.Hash ▞▞

defmodule GlyphBit.Hash do
  @moduledoc """
  Hashing policy for GlyphBit.

  - **internal** — BLAKE3 (compile digests, tape imprint, hot verify)
  - **external** — SHA-256 (only if crossing a third-party boundary; unused in v0)

  Aligns with 3OX internal-vs-external split; GlyphBit chooses BLAKE3
  for the internal lane instead of xxh*.
  """

  @algo_internal :blake3
  @algo_external :sha256

  def algo_internal, do: @algo_internal
  def algo_external, do: @algo_external

  @doc "BLAKE3 hex digest (lowercase, 64 hex chars / 32 bytes)."
  def internal(data) when is_binary(data) do
    B3.hash(data, encoding: :hex)
  end

  @doc "BLAKE3 raw 32-byte digest."
  def internal_raw(data) when is_binary(data) do
    B3.hash(data)
  end

  @doc "SHA-256 hex — external boundary only."
  def external(data) when is_binary(data) do
    :crypto.hash(:sha256, data) |> Base.encode16(case: :lower)
  end

  @doc "Tag a digest with its algorithm for receipts."
  def tagged_internal(data) when is_binary(data) do
    %{algo: "blake3", digest: internal(data)}
  end
end
