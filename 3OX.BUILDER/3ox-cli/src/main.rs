///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::
// 3OX CLI - Micro CLI for 3OX agents

use std::env;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::io::{self, Write};

fn find_3ox_dir(start: &Path) -> Option<PathBuf> {
    let mut current = start.to_path_buf();
    
    loop {
        let dot3ox = current.join(".3ox");
        if dot3ox.exists() && dot3ox.is_dir() {
            return Some(current);
        }
        
        if !current.pop() {
            break;
        }
    }
    
    None
}

fn run_agent(agent_path: &Path) -> std::io::Result<()> {
    let dot3ox = agent_path.join(".3ox");
    let run_rb = dot3ox.join("run.rb");
    
    if run_rb.exists() {
        // Run Ruby agent
        println!("▛▞ Running 3OX agent: {}", agent_path.display());
        let status = Command::new("ruby")
            .arg(&run_rb)
            .current_dir(agent_path)
            .status()?;
        
        std::process::exit(status.code().unwrap_or(1));
    } else {
        eprintln!("✗ No run.rb found in {}", dot3ox.display());
        std::process::exit(1);
    }
}

fn show_log(agent_path: &Path) -> std::io::Result<()> {
    let log_path = agent_path.join(".3ox").join("3ox.log");
    
    if log_path.exists() {
        let output = Command::new("tail")
            .arg("-n")
            .arg("50")
            .arg(&log_path)
            .output()?;
        
        io::stdout().write_all(&output.stdout)?;
        Ok(())
    } else {
        eprintln!("✗ No log file found at {}", log_path.display());
        std::process::exit(1);
    }
}

fn show_status(agent_path: &Path) -> std::io::Result<()> {
    let dot3ox = agent_path.join(".3ox");
    
    println!("▛▞ 3OX Agent Status:");
    println!("   Path: {}", agent_path.display());
    
    // Check required files
    let files = vec![
        ("brains.rs", "brain.rs"),
        ("tools.yml", "tools.yml"),
        ("routes.json", "routes.json"),
        ("limits.toml", "limits.json"),
        ("run.rb", "run.rb"),
        ("sparkfile.md", "sparkfile.md"),
    ];
    
    println!("\n   Files:");
    for (primary, fallback) in &files {
        let primary_path = dot3ox.join(primary);
        let fallback_path = dot3ox.join(fallback);
        
        if primary_path.exists() {
            println!("   ✓ {}", primary);
        } else if fallback_path.exists() {
            println!("   ✓ {} (as {})", fallback, primary);
        } else {
            println!("   ✗ {}", primary);
        }
    }
    
    // Check log
    let log_path = dot3ox.join("3ox.log");
    if log_path.exists() {
        if let Ok(metadata) = std::fs::metadata(&log_path) {
            println!("\n   Log: {} bytes", metadata.len());
        }
    }
    
    Ok(())
}

fn list_agents() -> std::io::Result<()> {
    let home = env::var("HOME").unwrap_or_else(|_| "/".to_string());
    let search_paths = vec![
        PathBuf::from(&home),
        PathBuf::from("/opt"),
        PathBuf::from("/usr/local"),
        env::current_dir().unwrap_or_else(|_| PathBuf::from(".")),
    ];
    
    println!("▛▞ Searching for 3OX agents...\n");
    
    let mut found = false;
    for search_path in &search_paths {
        if let Ok(entries) = std::fs::read_dir(search_path) {
            for entry in entries.flatten() {
                let path = entry.path();
                if path.is_dir() {
                    let dot3ox = path.join(".3ox");
                    if dot3ox.exists() && dot3ox.is_dir() {
                        println!("   ✓ {}", path.display());
                        found = true;
                    }
                }
            }
        }
    }
    
    if !found {
        println!("   No agents found.");
    }
    
    Ok(())
}

fn main() -> std::io::Result<()> {
    let args: Vec<String> = env::args().collect();
    
    // Handle subcommands
    if args.len() > 1 {
        match args[1].as_str() {
            "show" | "log" => {
                if args.len() > 2 && args[2] == "log" {
                    // 3ox show log
                    if let Some(agent_path) = find_3ox_dir(&env::current_dir()?) {
                        show_log(&agent_path)?;
                    } else {
                        eprintln!("✗ No .3ox directory found in current or parent directories");
                        std::process::exit(1);
                    }
                } else {
                    // 3ox show (status)
                    if let Some(agent_path) = find_3ox_dir(&env::current_dir()?) {
                        show_status(&agent_path)?;
                    } else {
                        eprintln!("✗ No .3ox directory found in current or parent directories");
                        std::process::exit(1);
                    }
                }
                return Ok(());
            }
            "list" => {
                list_agents()?;
                return Ok(());
            }
            "help" | "--help" | "-h" => {
                println!(r#"
▛▞ 3OX CLI - Micro CLI for 3OX Agents

Usage:
  3ox                    Run agent in current directory (if .3ox exists)
  3ox <agent-name>       Run specific agent by name
  3ox show               Show agent status
  3ox show log           Show agent log (last 50 lines)
  3ox list               List all 3OX agents found
  3ox help               Show this help

Examples:
  3ox                    # Run agent in current folder
  3ox sirius             # Run sirius agent
  3ox show               # Show current agent status
  3ox show log           # Show current agent log
  3ox list               # List all agents

The CLI searches for .3ox directories starting from current directory,
then walks up to parent directories.
"#);
                return Ok(());
            }
            agent_name => {
                // Try to find agent by name
                let home = env::var("HOME").unwrap_or_else(|_| "/".to_string());
                let possible_paths = vec![
                    PathBuf::from(&home).join(agent_name),
                    PathBuf::from(&home).join(format!(".{}", agent_name)),
                    PathBuf::from("/opt").join(agent_name),
                    PathBuf::from("/usr/local").join(agent_name),
                    env::current_dir().unwrap_or_else(|_| PathBuf::from(".")).join(agent_name),
                ];
                
                for path in &possible_paths {
                    let dot3ox = path.join(".3ox");
                    if dot3ox.exists() && dot3ox.is_dir() {
                        run_agent(path)?;
                        return Ok(());
                    }
                }
                
                eprintln!("✗ Agent '{}' not found", agent_name);
                eprintln!("   Try: 3ox list");
                std::process::exit(1);
            }
        }
    }
    
    // No arguments - run agent in current directory
    if let Some(agent_path) = find_3ox_dir(&env::current_dir()?) {
        run_agent(&agent_path)?;
    } else {
        eprintln!("✗ No .3ox directory found in current or parent directories");
        eprintln!("   Try: 3ox help");
        std::process::exit(1);
    }
    
    Ok(())
}

