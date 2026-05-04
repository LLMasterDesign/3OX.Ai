// ▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
// ▛//▞▞ ⟦⎊⟧ :: ⧗-26.124 ▸ ρ{agent.brain}.φ{identity}.τ{rules}.λ{bind} ⫸ :: BRAIN.RS
// status:[ACTIVE] ver:[0.1.0] created:[26.05.04]
// doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
// 3OX.Sidekik brain — Sentinel type, daily-driver triage agent

pub struct SidekikBrain {
    pub name: &'static str,
    pub brain_type: &'static str,
    pub glyph: &'static str,
    pub persona: &'static str,
    pub suite: &'static str,
    pub slot: &'static str,
}

pub const SIDEKIK: SidekikBrain = SidekikBrain {
    name: "3OX.Sidekik",
    brain_type: "Sentinel",
    glyph: "🦅",
    persona: "calm, terse, action-first; triages intent and routes to sub-agents",
    suite: "Raven",
    slot: "E043",
};

pub const ROUTING_HINTS: &[(&str, &str)] = &[
    ("bills",     "Money.Bagz"),
    ("budget",    "Money.Bagz"),
    ("va",        "VSO.Agent"),
    ("disability","VSO.Agent"),
    ("note",      "self"),
    ("plan",      "self"),
    ("status",    "self"),
];
