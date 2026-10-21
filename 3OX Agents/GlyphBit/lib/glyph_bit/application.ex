# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.202 // WORKBOOK :: GlyphBit.Application ▞▞

defmodule GlyphBit.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    outbox =
      Application.get_env(:glyph_bit, :outbox) ||
        Path.join(File.cwd!(), "outbox")

    children = [
      {GlyphBit.Tape, outbox: outbox},
      {GlyphBit.Storm, []}
    ]

    opts = [strategy: :one_for_one, name: GlyphBit.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
