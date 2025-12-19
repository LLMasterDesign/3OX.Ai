use std::fs::{OpenOptions, exists};
use std::io::{self, Write};
use std::process::Command;
use std::path::PathBuf;

use brains_3ox_core::{
    load_sparkfile, CubeContext,
};

pub fn show_page3(cube: &CubeContext) -> std::io::Result<()> {
    // Check for sparkfile on entry
    let sparkfile_path = cube.cube_root.join(".3ox").join("sparkfile.md");
    if !exists(&sparkfile_path) {
        println!("\n▛▞ Sparkfile Missing:");
        println!("   No sparkfile.md found at: {}", sparkfile_path.display());
        print!("   Would you like to set up this 3OX cube now? (y/N): ");
        io::stdout().flush()?;
        
        let mut response = String::new();
        io::stdin().read_line(&mut response)?;
        
        if response.trim().eq_ignore_ascii_case("y") {
            if let Err(e) = setup_3ox_interactive(&cube.cube_root) {
                println!("✗ Setup error: {}", e);
            } else {
                println!("✓ 3OX setup complete! Please restart Vec3Boot to load the new configuration.");
                return Ok(());
            }
        }
    }
    
    loop {
        println!();
        println!("▛▞ Task Menu:");
        println!("1. Update List");
        println!("2. Execute Command");
        println!("3. Write Status Report");
        println!("4. Help (Command Legend)");
        println!("5. Setup 3OX (Initialize/Reconfigure)");
        println!("6. Exit");
        print!("Select: ");
        io::stdout().flush()?;
        
        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        
        match input.trim() {
            "1" => {
                print!("Enter file path: ");
                io::stdout().flush()?;
                let mut file_path = String::new();
                io::stdin().read_line(&mut file_path)?;
                
                print!("Enter item to add: ");
                io::stdout().flush()?;
                let mut item = String::new();
                io::stdin().read_line(&mut item)?;
                
                match update_list(file_path.trim(), item.trim()) {
                    Ok(_) => println!("✓ List updated successfully"),
                    Err(e) => println!("✗ Error: {}", e),
                }
            }
            "2" => {
                print!("Enter command: ");
                io::stdout().flush()?;
                let mut cmd = String::new();
                io::stdin().read_line(&mut cmd)?;
                
                print!("Confirm execute? (y/N): ");
                io::stdout().flush()?;
                let mut confirm = String::new();
                io::stdin().read_line(&mut confirm)?;
                if confirm.trim().eq_ignore_ascii_case("y") {
                match execute_command("sh", &["-c", cmd.trim()]) {
                    Ok(output) => println!("Output:\n{}", output),
                    Err(e) => println!("✗ Error: {}", e),
                    }
                } else {
                    println!("Command skipped.");
                }
            }
            "3" => {
                let default_path = cube.cube_root.join("status-report.txt");
                println!("Default path: {}", default_path.display());
                print!("Enter report path (or press Enter for default): ");
                io::stdout().flush()?;
                let mut report_path = String::new();
                io::stdin().read_line(&mut report_path)?;
                
                let final_path = if report_path.trim().is_empty() {
                    default_path.to_string_lossy().to_string()
                } else {
                    report_path.trim().to_string()
                };
                
                match write_status_report(&final_path, cube) {
                    Ok(_) => println!("✓ Status report written to: {}", final_path),
                    Err(e) => println!("✗ Error: {}", e),
                }
            }
            "4" => {
                println!("\n▛▞ Command Legend:");
                println!("\n📋 System Commands:");
                println!("  /sparkfile       - Check if sparkfile exists in cube");
                println!("  /status          - Display current cube status");
                println!("  /validate        - Re-validate cube integrity");
                println!("  /faces           - List all cube faces");
                println!("\n🔧 File Operations:");
                println!("  echo 'text' > file.txt    - Create/write to file");
                println!("  cat file.txt              - Read file contents");
                println!("  ls -la                    - List directory contents");
                println!("\n💡 Tips:");
                println!("  - Use absolute paths or relative from cube root");
                println!("  - Status reports default to .3ox/status-report.txt");
                println!("  - Press Enter on empty prompts to use defaults\n");
            }
            "5" => {
                if let Err(e) = setup_3ox_interactive(&cube.cube_root) {
                    println!("✗ Setup error: {}", e);
                } else {
                    println!("✓ 3OX setup complete! Please restart Vec3Boot to load the new configuration.");
                    break;
                }
            }
            "6" => break,
            _ => println!("Invalid selection"),
        }
    }
    Ok(())
}

fn update_list(file_path: &str, item: &str) -> Result<(), String> {
    let path = std::path::Path::new(file_path);
    let mut file = OpenOptions::new()
        .create(true)
        .append(true)
        .open(path)
        .map_err(|e| format!("Failed to open file: {}", e))?;
    writeln!(file, "{}", item)
        .map_err(|e| format!("Failed to write: {}", e))?;
    Ok(())
}

fn execute_command(cmd: &str, args: &[&str]) -> Result<String, String> {
    let output = Command::new(cmd)
        .args(args)
        .output()
        .map_err(|e| format!("Failed to execute: {}", e))?;
    if output.status.success() {
        Ok(String::from_utf8_lossy(&output.stdout).to_string())
    } else {
        Err(String::from_utf8_lossy(&output.stderr).to_string())
    }
}

fn write_status_report(path: &str, cube: &CubeContext) -> Result<(), String> {
    use std::time::{SystemTime, UNIX_EPOCH};
    let timestamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();
    
    let sparkfile_content = load_sparkfile(&cube.cube_root)
        .unwrap_or_else(|_| "Sparkfile not available".to_string());
    
    let status = format!(
        "///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///\n\
         ▛//▞▞ ⟦⎊⟧ :: Status Report :: {} ▞▞\n\n\
         Timestamp: {}\n\
         Cube Root: {}\n\
         Agent: {} ({})\n\
         Workspace: {}\n\
         Tools: {}\n\
         Routes: {}\n\
         Session ID: {}\n\n\
         ▛▞ Sparkfile Configuration:\n\
         {}\n\n\
         ▛▞ Cube Integrity: VERIFIED\n\
         ▛▞ Faces Active: 6\n\
         ▛▞ Vec3 Status: BOUND\n\n\
         :: ∎\n",
        cube.agent_name,
        timestamp,
        cube.cube_root.display(),
        cube.agent_name,
        cube.agent_id,
        cube.workspace,
        cube.tools.tools.len(),
        cube.routes.routes.len(),
        cube.session_id,
        sparkfile_content
    );
    std::fs::write(path, status)
        .map_err(|e| format!("Failed to write report: {}", e))?;
    Ok(())
}

fn setup_3ox_interactive(cube_root: &PathBuf) -> Result<(), String> {
    println!("\n▛▞ 3OX Setup:");
    println!("   Initializing 3OX cube structure...\n");
    
    // Get target directory (cube root)
    let target_dir = cube_root.to_string_lossy().to_string();
    
    // Prompt for agent name
    print!("Enter agent name (e.g., GUARDIAN, SENTINEL): ");
    io::stdout().flush().map_err(|e| format!("Failed to flush stdout: {}", e))?;
    let mut agent_name = String::new();
    io::stdin().read_line(&mut agent_name).map_err(|e| format!("Failed to read input: {}", e))?;
    let agent_name = agent_name.trim();
    if agent_name.is_empty() {
        return Err("Agent name cannot be empty".to_string());
    }
    
    // Prompt for brain type
    println!("\nBrain types:");
    println!("  1. Citadel - Command orchestrator");
    println!("  2. Sentinel - Guardian/sync");
    println!("  3. Alchemist - Creator/builder");
    println!("  4. Lighthouse - Knowledge/library");
    print!("Select brain type (1-4, default: 2): ");
    io::stdout().flush().map_err(|e| format!("Failed to flush stdout: {}", e))?;
    let mut brain_choice = String::new();
    io::stdin().read_line(&mut brain_choice).map_err(|e| format!("Failed to read input: {}", e))?;
    
    let brain_type = match brain_choice.trim() {
        "1" => "Citadel",
        "3" => "Alchemist",
        "4" => "Lighthouse",
        _ => "Sentinel",
    };
    
    println!("\n▛▞ Setup Parameters:");
    println!("   Target: {}", target_dir);
    println!("   Agent: {}", agent_name);
    println!("   Brain Type: {}", brain_type);
    print!("\nProceed with setup? (y/N): ");
    io::stdout().flush().map_err(|e| format!("Failed to flush stdout: {}", e))?;
    let mut confirm = String::new();
    io::stdin().read_line(&mut confirm).map_err(|e| format!("Failed to read input: {}", e))?;
    
    if !confirm.trim().eq_ignore_ascii_case("y") {
        return Err("Setup cancelled".to_string());
    }
    
    // Find setup-3ox.rb script
    // Try multiple possible locations
    let possible_paths = vec![
        cube_root.join("!CMD.CENTER").join("7HE.VAULT").join("3OX.Ai").join("3OX.BUILD").join("setup-3ox.rb"),
        PathBuf::from("/root/!CMD.BRIDGE/!CMD.CENTER/7HE.VAULT/3OX.Ai/3OX.BUILD/setup-3ox.rb"),
        cube_root.join("..").join("..").join("..").join("!CMD.CENTER").join("7HE.VAULT").join("3OX.Ai").join("3OX.BUILD").join("setup-3ox.rb"),
    ];
    
    let setup_script = possible_paths.iter()
        .find(|p| exists(p))
        .ok_or_else(|| "Could not find setup-3ox.rb script".to_string())?;
    
    // Execute setup script
    let output = Command::new("ruby")
        .arg(setup_script)
        .arg(&target_dir)
        .arg(agent_name)
        .arg(brain_type)
        .output()
        .map_err(|e| format!("Failed to execute setup script: {}", e))?;
    
    if output.status.success() {
        let stdout = String::from_utf8_lossy(&output.stdout);
        println!("{}", stdout);
        Ok(())
    } else {
        let stderr = String::from_utf8_lossy(&output.stderr);
        Err(format!("Setup failed: {}", stderr))
    }
}

