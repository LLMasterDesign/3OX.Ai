# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.202 // WORKBOOK :: GlyphBit mix project ▞▞

defmodule GlyphBit.MixProject do
  use Mix.Project

  def project do
    [
      app: :glyph_bit,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {GlyphBit.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Pure-Elixir BLAKE3 — internal GlyphBit digests (no Rust/NIF)
      {:b3, "~> 0.2"}
    ]
  end

  defp aliases do
    [
      "glyph.compile": ["run -e GlyphBit.Compiler.run!()"],
      proof: ["test --only proof"]
    ]
  end
end
