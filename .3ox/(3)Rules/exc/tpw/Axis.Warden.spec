///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::0x000::
▛//▞▞ ⟦⎊⟧ :: ⧗-26.124 // 3OX :: AXIS.WARDEN κ k00 ▞▞
▛▞// Warden.Gate :: ρ{request}.φ{boundary}.τ{verdict} ▹
//▞⋮⋮ ⟦⚙️⟧ :: [tpw] [L1] [k00] [warden] [κ.exc] [⊢ ⇨ ⟿ ▷]
⫸ 〔Ω000〕〔κk00〕

▛///▞ κ [EXC] :: K00.WARDEN
//▞▞〔Gate · Limit · Validity〕

▞▞ JOB
Validate every state transition against max tick and policy; deny invalid motion without killing the spin.

▞▞ PHENO
ρ{state.request}
φ{validate.transition}
τ{allow.or.deny}

▞▞ PiCO
⊢{read.state}
⇨{check.boundary}
⟿{carry.decision}
▷{return.gated.state}

▞▞ META
role{transition.permission}
layer{TPW.L1}
proof{not.required.per_tick}
receipt{only.on.collapse}
runtime{rust}
source{.3ox/(3)Rules/exc/Axis.Warden.exc}

▞▞ RUST.SNIP
#[derive(Debug, Clone)]
pub struct State {
    pub tick: u32,
    pub max: u32,
    pub next: u32,
    pub allowed: bool,
}

pub fn gate(mut state: State) -> State {
    let next = state.tick + 1;
    if next <= state.max {
        state.next = next;
        state.allowed = true;
    } else {
        state.next = state.tick;
        state.allowed = false;
    }
    state
}

▞▞ LAW
WARDEN{validates.transition}
WARDEN{enforces.max}
WARDEN{denies.invalid.motion_without_stopping_spin}

:: ∎
