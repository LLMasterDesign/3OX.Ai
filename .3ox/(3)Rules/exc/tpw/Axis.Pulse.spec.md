///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::0x002::
▛//▞▞ ⟦⎊⟧ :: ⧗-26.124 // 3OX :: AXIS.PULSE κ k02 ▞▞
▛▞// Pulse.Signal :: ρ{memory}.φ{edge}.τ{signal} ▹
//▞⋮⋮ ⟦⚙️⟧ :: [tpw] [L1] [k02] [pulse] [κ.exc] [⊢ ⇨ ⟿ ▷]
⫸ 〔Ω002〕〔κk02〕

▛///▞ κ [EXC] :: K02.PULSE
//▞▞〔Signal · Edge · Aliveness〕

▞▞ JOB
Emit live signal from gated state; drive K9 re-entry; no receipt per tick.

▞▞ PHENO
ρ{state.memory}
φ{emit.edge}
τ{live.signal}

▞▞ PiCO
⊢{read.current.state}
⇨{detect.change}
⟿{carry.signal}
▷{emit.pulse}

▞▞ META
role{live.state.signal}
layer{TPW.L1}
proof{not.required.per_tick}
receipt{only.on.collapse}
runtime{elixir}
source{lib/kernel/k02_pulse.exs}

▞▞ ELIXIR.SNIP
defmodule TPW.Pulse do
  def emit(state) do
    pulse = %{
      tick: Map.get(state, :tick),
      allowed: Map.get(state, :allowed),
      at: System.system_time(:millisecond)
    }
    {:pulse, pulse, state}
  end
end

▞▞ LAW
PULSE{shows.aliveness}
PULSE{signals.motion}
PULSE{feeds.K9.reentry}

:: ∎
