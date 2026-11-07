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

# An edge metadata root is a declared filesystem address, never admission.
# Both ".3ox/_meta/" and "_meta/" are supported, without fallback or writes.
defmodule Boxd.B0.Metadata do
  @meta_line ~r/^\s*meta_root(?:\s|$)/
  @meta_value ~r/^\s*meta_root\s+"([^"\r\n]+)"\s*$/
  @safe_edge ~r/^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,63}$/

  @doc "Resolve an existing edge PID slot from an explicit *.ID declaration."
  def resolve(identity_file, edge) when is_binary(identity_file) and is_binary(edge) do
    root = Path.dirname(Path.expand(identity_file))

    with :ok <- validate_edge(edge),
         :ok <- require_regular(identity_file),
         {:ok, contents} <- File.read(identity_file),
         {:ok, declared} <- declaration(contents),
         {:ok, parts} <- safe_meta_path(declared),
         :ok <- require_directories(root, parts ++ ["edges", edge]),
         meta_root = Path.join([root | parts]),
         slot = Path.join([meta_root, "edges", edge, "pid"]),
         :ok <- require_regular(slot),
         {:ok, pid_text} <- File.read(slot) do
      binding = if String.trim(pid_text) == "", do: "unbound", else: "present-unverified"
      {:ok, %{meta_root: meta_root, edge: edge, pid_slot: slot, binding: binding}}
    end
  end

  def resolve(_, _), do: {:error, :invalid_arguments}

  defp validate_edge(edge) do
    if Regex.match?(@safe_edge, edge), do: :ok, else: {:error, :invalid_edge}
  end

  defp declaration(contents) do
    lines =
      contents
      |> String.split("\n")
      |> Enum.filter(&Regex.match?(@meta_line, &1))

    case lines do
      [] -> {:error, :metadata_root_undeclared}
      [line] ->
        case Regex.run(@meta_value, line) do
          [_, raw] -> {:ok, raw}
          _ -> {:error, :invalid_metadata_declaration}
        end
      _ -> {:error, :ambiguous_metadata_declaration}
    end
  end

  defp safe_meta_path(raw) do
    parts = String.split(raw, "/", trim: true)

    if Path.type(raw) == :relative and
       List.last(parts) == "_meta" and
       not Enum.any?(parts, &(&1 in [".", ".."])) and
       not String.contains?(raw, <<0>>) do
      {:ok, parts}
    else
      {:error, :unsafe_metadata_root}
    end
  end

  defp require_directories(root, parts) do
    Enum.reduce_while(parts, root, fn part, parent ->
      next = Path.join(parent, part)

      case File.lstat(next) do
        {:ok, %File.Stat{type: :directory}} -> {:cont, next}
        _ -> {:halt, {:error, :missing_or_linked_metadata_directory}}
      end
    end)
    |> case do
      {:error, reason} -> {:error, reason}
      _ -> :ok
    end
  end

  defp require_regular(file) do
    case File.lstat(file) do
      {:ok, %File.Stat{type: :regular}} -> :ok
      _ -> {:error, :missing_or_linked_file}
    end
  end
end


# Real, separately supervised RAV3N main-edge adapter.
# It monitors the existing SysGen-declared inference endpoint.
# The OS inference process remains with its current lifecycle owner.
defmodule Boxd.B0.RavenMain do
  use GenServer

  @registration "RAV3N.main"
  @port 8893
  @interval 10_000

  def child_spec({identity_file, seats_file}) do
    %{
      id: {__MODULE__, @registration},
      start: {__MODULE__, :start_link, [{identity_file, seats_file}]},
      restart: :permanent,
      shutdown: 5_000,
      type: :worker
    }
  end

  def start_link({identity_file, seats_file}) do
    GenServer.start_link(__MODULE__, {identity_file, seats_file},
      name: {:via, Registry, {Boxd.B0.Registry, @registration}}
    )
  end

  def registration, do: @registration

  def admit(identity_file, seats_file) do
    DynamicSupervisor.start_child(
      Boxd.B0.Cubes, {__MODULE__, {identity_file, seats_file}}
    )
  end

  def status do
    case Boxd.B0.find(@registration) do
      {:ok, pid} -> {:ok, GenServer.call(pid, :status, 3_000)}
      :absent -> {:error, :absent}
    end
  end

  @impl true
  def init({identity_file, seats_file}) do
    with {:ok, resolved} <- Boxd.B0.Metadata.resolve(identity_file, "main"),
         :ok <- validate_identity(identity_file),
         :ok <- validate_seat(seats_file),
         :ok <- start_http() do
      state = %{
        entity: "RAV3N", edge: "main", meta_root: resolved.meta_root,
        pid_slot: resolved.pid_slot, pid_binding: resolved.binding,
        external_owner: "SysGen", external_seat: "rvn-inference",
        health_target: "127.0.0.1:#{@port}", health: "pending",
        health_checked_at: nil, instance: System.unique_integer([:positive])
      }
      send(self(), :probe)
      {:ok, state}
    else
      {:error, reason} -> {:stop, {:preflight, reason}}
    end
  end

  defp validate_identity(path) do
    case File.read(path) do
      {:ok, content} ->
        if String.contains?(content, ~s(entity_id "RAV3N")) and
             String.contains?(content, ~s(host "minsky")) do
          :ok
        else
          {:error, :identity_mismatch}
        end
      {:error, reason} -> {:error, {:identity_unavailable, reason}}
    end
  end

  defp validate_seat(path) do
    with {:ok, body} <- File.read(path),
         [_, seat] <- Regex.run(~r/seat "rvn-inference" \{(.*?)^\}/ms, body),
         true <- String.contains?(seat, ~s(port "#{@port}")),
         true <- String.contains?(seat, "--host 127.0.0.1 --port #{@port}"),
         true <- String.contains?(seat, "enabled #true"),
         true <- String.contains?(seat, "keep #true") do
      :ok
    else
      _ -> {:error, :sysgen_seat_contract_mismatch}
    end
  end

  defp start_http do
    case Application.ensure_all_started(:inets) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, {:http_client_start_failed, reason}}
    end
  end

  @impl true
  def handle_info(:probe, state) do
    health =
      case :httpc.request(
             :get,
             {~c"http://127.0.0.1:8893/health", []},
             [timeout: 2_000, connect_timeout: 1_000],
             [body_format: :binary]
           ) do
        {:ok, {{_, 200, _}, _, body}} ->
          if String.contains?(body, ~s("status":"ok")), do: "ok", else: "unexpected-response"
        {:ok, {{_, code, _}, _, _}} -> "http-#{code}"
        _ -> "unreachable"
      end
    Process.send_after(self(), :probe, @interval)
    {:noreply, %{state | health: health, health_checked_at: DateTime.to_iso8601(DateTime.utc_now())}}
  end

  @impl true
  def handle_call(:status, _from, state) do
    {:reply, Map.put(state, :beam_child, inspect(self())), state}
  end
end

defmodule Boxd.B0.RavenService do
  @doc "Run B0 with a real RAV3N main adapter, reporting to its sibling _meta/state."
  def run(identity_file, seats_file) do
    Process.flag(:trap_exit, true)
    {:ok, root} = Boxd.B0.start_link()
    {:ok, child} = Boxd.B0.RavenMain.admit(identity_file, seats_file)
    IO.puts("BOXD_B0_RAVEN_READY supervisor=#{inspect(root)} child=#{inspect(child)}")
    status_path = Path.join([Path.dirname(Path.expand(identity_file)), "_meta", "state", "b0.json"])
    report_loop(root, status_path)
  end

  defp report_loop(root, status_path) do
    case Boxd.B0.RavenMain.status() do
      {:ok, state} ->
        payload = %{
          "schema" => "boxd.b0.rav3n-main/v1",
          "entity" => state.entity, "edge" => state.edge,
          "registration" => Boxd.B0.RavenMain.registration(),
          "supervisor" => "running", "child" => "registered",
          "beam_child" => state.beam_child,
          "instance" => state.instance,
          "pid_record" => state.pid_slot,
          "pid_binding" => state.pid_binding,
          "external_owner" => state.external_owner,
          "external_seat" => state.external_seat,
          "health_target" => state.health_target,
          "health" => state.health,
          "health_checked_at" => state.health_checked_at,
          "host_pid" => System.pid(),
          "observed_at_utc" => DateTime.to_iso8601(DateTime.utc_now())
        }
        write_status(status_path, payload)
      {:error, :absent} ->
        raise("RAV3N main child missing from B0 registry")
    end

    receive do
      {:EXIT, ^root, reason} -> raise("B0 exited: #{inspect(reason)}")
      _ -> report_loop(root, status_path)
    after
      5_000 -> report_loop(root, status_path)
    end
  end

  defp write_status(path, payload) do
    directory = Path.dirname(path)
    case File.lstat(directory) do
      {:ok, %File.Stat{type: :directory}} -> :ok
      _ -> raise("B0 status directory untrusted")
    end
    tmp = path <> ".tmp." <> System.pid()
    encoded = IO.iodata_to_binary(:json.encode(payload)) <> "\n"
    :ok = File.write(tmp, encoded, [:exclusive])
    :ok = File.chmod(tmp, 0o600)
    :ok = File.rename(tmp, path)
  end
end

defmodule Boxd.B0.CLI do
  def main(["b0", "run", "--rav3n-main", identity_file, seats_file]) do
    Boxd.B0.RavenService.run(identity_file, seats_file)
  end

  def main(["b0", "raven-proof", identity_file, seats_file]) do
    {:ok, root} = Boxd.B0.start_link()
    {:ok, initial} = Boxd.B0.RavenMain.admit(identity_file, seats_file)
    {:ok, first} = Boxd.B0.RavenMain.status()
    true = first.entity == "RAV3N" and first.edge == "main"
    true = first.pid_binding == "unbound"
    true = Boxd.B0.healthy?()
    IO.puts("BOXD_RAVEN_PASS stage=real-child-registered")

    Process.exit(initial, :kill)
    replacement =
      Enum.reduce_while(1..100, nil, fn _, _ ->
        case Boxd.B0.find("RAV3N.main") do
          {:ok, next} when next != initial -> {:halt, next}
          _ -> Process.sleep(20); {:cont, nil}
        end
      end)
    true = is_pid(replacement) and Process.alive?(replacement)
    {:ok, second} = Boxd.B0.RavenMain.status()
    true = second.instance != first.instance
    IO.puts("BOXD_RAVEN_PASS stage=real-child-auto-restart")
    :ok = Supervisor.stop(root)
    IO.puts("BOXD_RAVEN_RESULT status=ok stages=2")
  end

  def main(["b0", "meta", identity_file, edge]) do
    case Boxd.B0.Metadata.resolve(identity_file, edge) do
      {:ok, resolved} ->
        IO.puts(
          "BOXD_B0_META_RESOLVED root=#{resolved.meta_root} edge=#{resolved.edge} " <>
          "pid_slot=#{resolved.pid_slot} binding=#{resolved.binding}"
        )
      {:error, reason} ->
        IO.puts(:stderr, "BOXD_B0_META_HOLD reason=#{reason}")
        System.halt(2)
    end
  end

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
    IO.puts(:stderr, "usage: elixir b0.exs b0 proof | b0 raven-proof <identity.ID> <seats.kdl> | b0 run --isolated | b0 run --rav3n-main <identity.ID> <seats.kdl> | b0 meta <identity.ID> <edge>")
    System.halt(64)
  end
end

Boxd.B0.CLI.main(System.argv())
