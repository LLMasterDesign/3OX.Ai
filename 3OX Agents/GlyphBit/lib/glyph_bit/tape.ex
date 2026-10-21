# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.202 // WORKBOOK :: GlyphBit.Tape ▞▞

defmodule GlyphBit.Tape do
  @moduledoc """
  Mini append-only receipt tape for GlyphBit proofs.

  On-disk format: one Base64 erlang-term per line (no Hex deps).
  """
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def append(receipt) when is_map(receipt) do
    GenServer.call(__MODULE__, {:append, receipt})
  end

  def entries, do: GenServer.call(__MODULE__, :entries)
  def path, do: GenServer.call(__MODULE__, :path)
  def reset_for_test, do: GenServer.call(__MODULE__, :reset)

  @impl true
  def init(opts) do
    outbox = Keyword.fetch!(opts, :outbox)
    File.mkdir_p!(outbox)
    path = Path.join(outbox, "tape.terms")
    {:ok, %{path: path, entries: load_entries(path)}}
  end

  @impl true
  def handle_call({:append, receipt}, _from, state) do
    row =
      receipt
      |> Map.put_new(:ts, DateTime.utc_now() |> DateTime.to_iso8601())
      |> Map.put_new(:glyphbit_id, "Storm")

    line = Base.encode64(:erlang.term_to_binary(row)) <> "\n"
    File.write!(state.path, line, [:append])
    {:reply, {:ok, row}, %{state | entries: state.entries ++ [row]}}
  end

  def handle_call(:entries, _from, state), do: {:reply, state.entries, state}
  def handle_call(:path, _from, state), do: {:reply, state.path, state}

  def handle_call(:reset, _from, state) do
    File.write!(state.path, "")
    {:reply, :ok, %{state | entries: []}}
  end

  defp load_entries(path) do
    case File.read(path) do
      {:ok, body} ->
        body
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          line |> Base.decode64!() |> :erlang.binary_to_term()
        end)

      {:error, _} ->
        []
    end
  end
end
