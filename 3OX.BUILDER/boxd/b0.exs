# ▛▞ boxd · B0-first BEAM candidate
#
# B0 owns the host-side OTP supervision root. The selected .3ox cubes
# become independently restarted children after static/dependency admission.
# This candidate exposes only a synthetic cube worker; the real Box.Application
# and its B1-B8 processes stay outside this isolated milestone.
#
# Run: elixir b0.exs b0 proof
#      elixir b0.exs b0 run --isolated
#
# Live rollout is intentionally gated; --isolated is required to launch.
defmodule Boxd.B0.Cube do
  use GenServer

  def child_spec(id) when is_binary(id) do
    %{
      id: {__MODULE__, id},
      start: {__MODULE__, :start_link, [id]},
      restart: :permanent,
      shutdown: 5_000,
      type: :worker
    }
  end

  def start_link(id) do
    GenServer.start_link(__MODULE__, id,
      name: {:via, Registry, {Boxd.B0.Registry, id}}
    )
  end

  @impl true
  def init(id), do: {:ok, %{cube_id: id}}

  @impl true
  def handle_call(:ready, _from, %{cube_id: id} = state) do
    {:reply, {:ok, id}, state}
  end
end

defmodule Boxd.B0 do
  use Supervisor

  @doc "Start B0, once per BEAM runtime."
  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    Supervisor.init(
      [
        {Registry, keys: :unique, name: Boxd.B0.Registry},
        {DynamicSupervisor, strategy: :one_for_one, name: Boxd.B0.Cubes}
      ],
      strategy: :one_for_one
    )
  end

  @doc "Admit a preflight-approved cube ID; admission policy is a separate gate."
  def admit(id) when is_binary(id) and byte_size(id) > 0 do
    DynamicSupervisor.start_child(Boxd.B0.Cubes, {Boxd.B0.Cube, id})
  end

  def admit(_id), do: {:error, :invalid_cube_id}

  def find(id) do
    case Registry.lookup(Boxd.B0.Registry, id) do
      [{pid, _}] -> {:ok, pid}
      [] -> :absent
    end
  end

  def healthy? do
    case Process.whereis(__MODULE__) do
      pid when is_pid(pid) ->
        Process.alive?(pid) and is_pid(Process.whereis(Boxd.B0.Cubes)) and
          is_pid(Process.whereis(Boxd.B0.Registry))
      _ ->
        false
    end
  end
end

defmodule Boxd.B0.Proof do
  defp prove(true, stage), do: IO.puts("BOXD_B0_PASS stage=#{stage}")
  defp prove(false, stage), do: raise("BOXD_B0_FAIL stage=#{stage}")

  defp replacement(id, original, attempts \\ 100)
  defp replacement(_id, _original, 0), do: {:error, :timeout}

  defp replacement(id, original, attempts) do
    case Boxd.B0.find(id) do
      {:ok, next} when next != original and is_pid(next) ->
        {:ok, next}
      _ ->
        Process.sleep(20)
        replacement(id, original, attempts - 1)
    end
  end

  def run do
    {:ok, root} = Boxd.B0.start_link()
    prove(Boxd.B0.healthy?(), "start")
    prove(
      match?({:error, {:already_started, _}}, Boxd.B0.start_link()),
      "singleton"
    )
    prove(Boxd.B0.admit("") == {:error, :invalid_cube_id}, "reject-invalid")

    {:ok, first} = Boxd.B0.admit("cube-a")
    {:ok, second} = Boxd.B0.admit("cube-b")
    prove(is_pid(first) and is_pid(second), "admit-two")
    prove(
      GenServer.call(first, :ready) == {:ok, "cube-a"} and
        GenServer.call(second, :ready) == {:ok, "cube-b"},
      "healthy-children"
    )
    prove(
      match?({:error, {:already_started, _}}, Boxd.B0.admit("cube-a")),
      "reject-duplicate"
    )

    Process.sleep(250)
    prove(Boxd.B0.healthy?() and Process.alive?(root), "survive")

    Process.exit(first, :kill)
    {:ok, replacement} = replacement("cube-a", first)
    prove(
      Process.alive?(replacement) and Process.alive?(second) and
        Boxd.B0.find("cube-b") == {:ok, second},
      "isolate-and-restart-child"
    )

    :ok = Supervisor.stop(root, :normal, 5_000)
    prove(Process.whereis(Boxd.B0) == nil, "shutdown-b0")
    prove(Process.whereis(Boxd.B0.Cubes) == nil, "shutdown-children")
    IO.puts("BOXD_B0_RESULT status=ok stages=10")
  end
end

defmodule Boxd.B0.CLI do
  def main(["b0", "proof"]) do
    Boxd.B0.Proof.run()
  end

  def main(["b0", "run", "--isolated"]) do
    Process.flag(:trap_exit, true)
    {:ok, root} = Boxd.B0.start_link()
    if Boxd.B0.healthy?() do
      IO.puts("BOXD_B0_READY state=isolated pid=#{inspect(root)}")
    else
      raise("B0 failed startup health")
    end

    receive do
      :shutdown -> :ok
      {:EXIT, ^root, reason} -> raise("B0 supervisor exited: #{inspect(reason)}")
    end

    if Process.alive?(root), do: Supervisor.stop(root)
    IO.puts("BOXD_B0_STOPPED status=ok")
  end

  def main(_args) do
    IO.puts(:stderr, "usage: elixir b0.exs b0 proof | b0 run --isolated")
    System.halt(64)
  end
end

Boxd.B0.CLI.main(System.argv())
