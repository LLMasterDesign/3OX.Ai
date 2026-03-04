// ▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
// ▛//▞▞ ⟦⎊⟧ :: ⧗-26.062 ▸ ρ{agent.brain}.φ{identity}.τ{rules}.λ{bind} ⫸ :: BRAIN.RS
// status:[DRAFT] ver:[1.0.0] created:[26.03.03]
// doc:[PARTIAL] modified:[26.03.03] auth:[3OX.AI]
// Brain template — agent personality, type, and rules

use std::env;

#[derive(Debug, Clone)]
pub enum BrainType {
    Sentinel,
    Alchemist,
    Lighthouse,
}

pub struct AgentBrain {
    pub name: String,
    pub brain_type: BrainType,
    pub version: String,
}

impl AgentBrain {
    pub fn new(name: &str, brain_type: BrainType) -> Self {
        Self {
            name: name.to_string(),
            brain_type,
            version: env::var("CUBE_VERSION").unwrap_or_else(|_| "1.0.0".to_string()),
        }
    }
}
