// ▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
// ▛//▞▞ ⟦⎊⟧ :: ⧗-25.291 ▸ ρ{agent.brain}.φ{identity}.τ{rules}.λ{bind} ⫸ :: BRAIN.RS
//
// Agent Configuration and Rules
// Version: v1.1.0

use std::env;

/// Brain Type: Defines agent personality and approach
#[derive(Debug, Clone)]
pub enum BrainType {
    Sentinel,   // Guardian-Synchronizer (RVNx)
    Alchemist,  // Creator-Architect (SYNTH)
    Lighthouse, // Librarian-Weaver (OBSIDIAN)
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
    
    // Deployment
    DevStagingProd,
    RollbackReady,
    CloudCostAware,
    
    // Knowledge
    LinkIntegrityCheck,
    SemanticConnections,
    BidirectionalLinks,
}

/// TESTRUN X3 RUBY GUARDIAN Configuration
pub const TESTRUN_BRAIN: AgentConfig = AgentConfig {
    name: "GUARDIAN",
    brain: BrainType::Sentinel,
    model: "claude-sonnet-4.5",
    instructions: "Validate files before processing. Generate cryptographic receipts using xxHash64. Route operations to correct destinations. Enforce resource limits. Log all operations to 3ox.log with unique sigil.",
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
    for (i, rule) in TESTRUN_RULES.iter().enumerate() {
        let comma = if i < TESTRUN_RULES.len() - 1 { "," } else { "" };
        println!("    \"{:?}\"{}",  rule, comma);
    }
    println!("  ]");
    println!("}}");
}

fn validate_action(action: &str) {
    for rule in TESTRUN_RULES {
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

// ▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ v1.1.0 | ⧗-25.291 ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂

