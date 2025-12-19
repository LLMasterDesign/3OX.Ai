///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: ⧗-25.291 ▸ ρ{agent.brain}.φ{identity}.τ{rules}.λ{bind} ⫸ :: BRAIN.RS

/// Brain Type: Defines agent personality and approach
#[derive(Debug, Clone)]
pub enum BrainType {
    Sentinel,   // Guardian-Synchronizer (RVNx)
    Alchemist,  // Creator-Architect (SYNTH)
    Lighthouse, // Librarian-Weaver (OBSIDIAN)
}

/// Agent Configuration
#[derive(Clone, Copy)]
pub struct AgentConfig {
    pub name: &'static str,
    pub brain: BrainType,
    pub model: &'static str,
    pub instructions: &'static str,
    pub max_turns: u8,
}

/// Core Rules & Constraints
#[derive(Debug, Clone)]
pub enum Rule {
    // Sync & Safety
    AtomicOpsOnly,
    LastWriteWins,
    AlwaysBackup,
    ChecksumValidation,
    
    // Deployment
    DevStagingProd,
    RollbackReady,
    CloudCostAware,
    
    // Knowledge
    LinkIntegrityCheck,
    SemanticConnections,
    BidirectionalLinks,
}

/// TESTRUN X3 PYTHON VALIDATOR Configuration
pub const TESTRUN_BRAIN: AgentConfig = AgentConfig {
    name: "VALIDATOR",
    brain: BrainType::Sentinel,
    model: "claude-sonnet-4.5",
    instructions: "Validate files before processing. Generate cryptographic receipts using xxHash3_64. Route operations to correct destinations. Enforce resource limits. Log all operations to 3ox.log with unique sigil.",
    max_turns: 10,
};

pub const TESTRUN_RULES: &[Rule] = &[
    Rule::AtomicOpsOnly,
    Rule::AlwaysBackup,
    Rule::ChecksumValidation,
];

impl AgentConfig {
    /// Load brain configuration for TESTRUN X3
    pub fn load() -> Self {
        TESTRUN_BRAIN
    }
}

impl Rule {
    /// Validate action against rules
    pub fn enforce(&self, action: &str) -> Result<(), String> {
        match self {
            Rule::AtomicOpsOnly => {
                if !action.contains("atomic") {
                    return Err("Non-atomic operation blocked".to_string());
                }
            }
            Rule::AlwaysBackup => {
                if !action.contains("backup") {
                    return Err("Backup flag required before execution".to_string());
                }
            }
            Rule::ChecksumValidation => {
                if !action.contains("checksum") && !action.contains("hash") {
                    return Err("Checksum validation required".to_string());
                }
            }
            _ => {}
        }
        Ok(())
    }
}

///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ v1.1.0 | ⧗-25.291 ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///

