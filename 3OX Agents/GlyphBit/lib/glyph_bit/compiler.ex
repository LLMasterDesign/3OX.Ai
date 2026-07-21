# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.202 // WORKBOOK :: GlyphBit.Compiler ▞▞

defmodule GlyphBit.Compiler do
  @moduledoc """
  Compile STORM.sparkfile.md → digest + validated artifact under compile/.

  Does not re-parse markdown at emit time; runtime uses GlyphBit.Storm.Harness.
  """

  @spark "STORM.sparkfile.md"
  @out_dir "compile"

  def run! do
    root = File.cwd!()
    spark_path = Path.join(root, @spark)
    body = File.read!(spark_path)

    invariants = validate_spark!(body)
    GlyphBit.Storm.Harness.validate!()

    digest = :crypto.hash(:sha256, body) |> Base.encode16(case: :lower)

    artifact = %{
      source: @spark,
      sha256: digest,
      compiled_at: DateTime.utc_now() |> DateTime.to_iso8601(),
      ontology: GlyphBit.Ontology.embed(),
      identity: GlyphBit.Storm.Harness.identity(),
      invariants: invariants,
      rupture_bank: GlyphBit.Storm.Harness.rupture_bank()
    }

    File.mkdir_p!(Path.join(root, @out_dir))
    out = Path.join(root, Path.join(@out_dir, "storm.glyphbit.artifact.exs"))
    File.write!(out, inspect(artifact, pretty: true, limit: :infinity))

    digest_path = Path.join(root, Path.join(@out_dir, "storm.sha256"))
    File.write!(digest_path, digest <> "\n")

    IO.puts("compiled #{@spark}")
    IO.puts("  sha256: #{digest}")
    IO.puts("  artifact: #{out}")
    {:ok, artifact}
  end

  defp validate_spark!(body) do
    checks = [
      {"primary = false", Regex.match?(~r/primary\s*=\s*false/, body)},
      {"tools = []", Regex.match?(~r/tools\s*=\s*\[\]/, body)},
      {"max_posts_per_turn = 1", Regex.match?(~r/max_posts_per_turn\s*=\s*1/, body)},
      {"protocol post-output", String.contains?(body, "post-output")},
      {"lambda post-output.storm", String.contains?(body, "post-output.storm")},
      {"tau set", String.contains?(body, "post.emit") and String.contains?(body, "abstain.silence")}
    ]

    bad = Enum.reject(checks, fn {_n, ok} -> ok end)

    if bad != [] do
      names = Enum.map_join(bad, ", ", fn {n, _} -> n end)
      raise "spark compile failed invariants: #{names}"
    end

    Enum.into(checks, %{}, fn {n, ok} -> {n, ok} end)
  end
end
