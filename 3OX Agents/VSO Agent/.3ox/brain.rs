// ▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
// ▛//▞▞ ⟦⎊⟧ :: ${SIRIUS_TIME} ▸ ρ{agent.brain}.φ{identity}.τ{rules}.λ{bind} ⫸ :: BRAIN.RS
//
// Agent Configuration and Rules
// Version: ${VERSION}

use std::env;

/// Brain Type: Defines agent personality and approach
#[derive(Debug, Clone)]
pub enum BrainType {
    Citadel,    // Command-Orchestrator (Central Authority)
    Sentinel,   // Guardian-Synchronizer (RVNx)
    Alchemist,  // Creator-Architect (SYNTH)
    Lighthouse, // Librarian-Weaver (OBSIDIAN)
    Advisor,    // VSO Agent (7HE.Citadel)
}

/// Agent Configuration
#[derive(Clone)]
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
    
    // Claim Management
    StrategicQuestioning,
    DBQReferenceRequired,
    VARulesCompliance,
    DeadlineTracking,
    EvidenceValidation,
}

/// VSO.AGENT - Veterans Service Officer Agent (7HE.Citadel)
pub const VSO_AGENT_BRAIN: AgentConfig = AgentConfig {
    name: "VSO.AGENT",
    brain: BrainType::Advisor,
    model: "claude-sonnet-4.5",
    instructions: "VSO (Veterans Service Officer) agent for VA disability claim management. Assesses situations through strategic questioning (tutorv8 methodology), maintains organized claim files, references DBQ forms and VA regulations, tracks deadlines, and provides actionable guidance. Uses web search for current VA policies. Validates file integrity using xxHash64. Logs activity to 3ox.log.",
    max_turns: 20,
};

pub const VSO_AGENT_RULES: &[Rule] = &[
    Rule::StrategicQuestioning,
    Rule::DBQReferenceRequired,
    Rule::VARulesCompliance,
    Rule::DeadlineTracking,
    Rule::EvidenceValidation,
    Rule::AtomicOpsOnly,
    Rule::AlwaysBackup,
    Rule::ChecksumValidation,
];

impl AgentConfig {
    /// Load brain configuration for VSO.AGENT
    pub fn load() -> Self {
        VSO_AGENT_BRAIN
    }
}

impl Rule {
    /// Validate action against rules
    pub fn enforce(&self, action: &str) -> Result<(), String> {
        match self {
            Rule::StrategicQuestioning => {
                if !action.contains("question") && !action.contains("assess") {
                    return Err("Strategic questioning required before guidance".to_string());
                }
            }
            Rule::DBQReferenceRequired => {
                if action.contains("condition") && !action.contains("DBQ") {
                    return Err("DBQ reference required when discussing conditions".to_string());
                }
            }
            Rule::VARulesCompliance => {
                if action.contains("rating") && !action.contains("38 CFR") && !action.contains("M21-1") {
                    return Err("VA regulations must be referenced for rating guidance".to_string());
                }
            }
            Rule::DeadlineTracking => {
                if action.contains("claim") && !action.contains("deadline") && !action.contains("timeline") {
                    return Err("Deadline tracking required for claim management".to_string());
                }
            }
            Rule::EvidenceValidation => {
                if action.contains("evidence") && !action.contains("validate") && !action.contains("check") {
                    return Err("Evidence must be validated against requirements".to_string());
                }
            }
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

// ============================================================================
// Binary Entry Point
// ============================================================================

fn main() {
    let args: Vec<String> = env::args().collect();
    
    if args.len() < 2 {
        print_config();
        return;
    }
    
    match args[1].as_str() {
        "config" => print_config(),
        "validate" => validate_action(&args[2..].join(" ")),
        _ => eprintln!("Usage: brain [config|validate <action>]"),
    }
}

fn print_config() {
    let config = AgentConfig::load();
    println!("{{");
    println!("  \"name\": \"{}\",", config.name);
    println!("  \"type\": \"{:?}\",", config.brain);
    println!("  \"model\": \"{}\",", config.model);
    println!("  \"max_turns\": {},", config.max_turns);
    println!("  \"rules\": [");
    for (i, rule) in VSO_AGENT_RULES.iter().enumerate() {
        let comma = if i < VSO_AGENT_RULES.len() - 1 { "," } else { "" };
        println!("    \"{:?}\"{}",  rule, comma);
    }
    println!("  ]");
    println!("}}");
}

fn validate_action(action: &str) {
    for rule in VSO_AGENT_RULES {
        match rule.enforce(action) {
            Ok(_) => println!("✓ {:?}: PASS", rule),
            Err(e) => {
                eprintln!("✗ {:?}: {}", rule, e);
                std::process::exit(1);
            }
        }
    }
    println!("All rules passed");
}

// ▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ${VERSION} | ${SIRIUS_TIME} ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂

