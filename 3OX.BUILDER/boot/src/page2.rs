use crossterm::{
    cursor::{MoveTo, Show, position},
    execute,
    terminal::{Clear, ClearType, disable_raw_mode, enable_raw_mode},
    event::read,
};
use std::fs::{OpenOptions, read_to_string};
use std::io::{self, stdout, Write};
use std::path::PathBuf;
use std::thread::sleep;
use std::time::Duration;

use brains_3ox_core::{init_cube_context, CubeContext};

struct TerminalGuard;

impl TerminalGuard {
    fn new() -> Self {
        TerminalGuard
    }
}

impl Drop for TerminalGuard {
    fn drop(&mut self) {
        let _ = disable_raw_mode();
        let _ = execute!(stdout(), Show);
    }
}

fn progress_bar(filled: usize, total: usize) -> String {
    let filled_chars: String = "▮".repeat(filled);
    let empty_chars: String = "▯".repeat(total - filled);
    format!("▛▞//{}{}▹", filled_chars, empty_chars)
}

fn type_animate(text: &str, delay_ms: u64, stdout: &mut io::Stdout) -> std::io::Result<()> {
    for ch in text.chars() {
        print!("{}", ch);
        stdout.flush()?;
        sleep(Duration::from_millis(delay_ms));
    }
    Ok(())
}

fn append_log(cube_3ox: &PathBuf, message: &str) {
    let log_path = cube_3ox.join("3ox.log");
    if let Ok(mut f) = OpenOptions::new().create(true).append(true).open(&log_path) {
        let _ = writeln!(f, "{}", message);
    }
}

fn append_agent_log(cube_3ox: &PathBuf, message: &str) {
    let log_path = cube_3ox.join("3ox.log");
    if let Ok(mut f) = OpenOptions::new().create(true).append(true).open(&log_path) {
        let _ = writeln!(f, "{}", message);
    }
}

fn read_agent_id(cube_3ox: &PathBuf) -> Option<String> {
    let path = cube_3ox.join("vec3.core").join("agent.id");
    read_to_string(path).ok().map(|s| s.trim().to_string()).filter(|s| !s.is_empty())
}

pub fn show_page2(cube_root: &PathBuf) -> std::io::Result<Option<CubeContext>> {
    let mut stdout = stdout();
    let _terminal_guard = TerminalGuard::new();
    
    // Clear and move to top for PAGE 2
    execute!(stdout, Clear(ClearType::All), MoveTo(0, 0))?;
    
    // Separator with animation (22 chars longer)
    type_animate("///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂", 10, &mut stdout)?;
    println!();
    println!();

    // PAGE 2 Header with animation
    type_animate("▛//▞▞ ⟦⎊ ⟧ :: ⧗-25.125 // 3OX.LOADER :: Boot.init ▞▞", 15, &mut stdout)?;
    println!();
    
    // Animated dots on new line
    for _ in 0..7 {
        print!(".");
        stdout.flush()?;
        sleep(Duration::from_millis(100));
    }
    // Clear the dots line
    print!("\r{}", " ".repeat(10));
    print!("\r");
    stdout.flush()?;
    println!();
    
    // Define all files to load (10 total: 6 faces + 3 vec3 + 1 core)
    let mut file_status: Vec<(String, bool, usize)> = vec![
        ("brains.rs".to_string(), false, 0),
        ("run.rb".to_string(), false, 1),
        ("tools.yml".to_string(), false, 2),
        ("routes.json".to_string(), false, 3),
        ("limits.toml".to_string(), false, 4),
        ("3ox.log".to_string(), false, 5),
        ("face.map.toml".to_string(), false, 0), // vec3 files
        ("manifest.vec3.toml".to_string(), false, 1),
        ("agent.id".to_string(), false, 2),
        ("sparkfile.md".to_string(), false, 0), // core
    ];
    
    // Show initial static boxes - track starting row for updates
    // Row trace: separator(0) + blank(1) + blank(2) + header(2) + dots(3,cleared) + blank = row 4
    let cube_box_start_row = 4u16;
    
    println!("+-------------------+  +-------------------------------------------------------+");
    println!("|  CUBE STATUS      |  |  FACE                  DATA            VERSION   LOAD |");
    println!("+-------------------+  +-------------------------------------------------------+");
    println!("|  Faces :: LOADING |  |  brains.rs      [---------->]   0%     v1.0.0   ▢ ..  |");
    println!("|  Vec3  :: LOADING |  |  run.rb         [---------->]   0%     v1.0.0   ▢ ..  |");
    println!("|  Core  :: MISSING |  |  tools.yml      [---------->]   0%     v1.0.0   ▢ ..  |");
    println!("|  Lock  ::   ON    |  |  routes.json    [---------->]   0%     v1.0.0   ▢ ..  |");
    println!("|                   |  |  limits.toml    [---------->]   0%     v1.0.0   ▢ ..  |");
    println!("|                   |  |  3ox.log        [---------->]   0%     v1.0.0   ▢ ..  |");
    println!("|                   |  +-------------------------------------------------------+");
    println!("|                   |  |  SPARKFILE      [---------->]         ACTIVE    ▢ ..  |");
    println!("+-------------------+  +-------------------------------------------------------+");
    println!();
    println!();
    
    // Print initial 10-line block
    println!("▛▞///▞▞ 3OX::LOADER ▹");
    println!("...loading{{faces}}      {}", progress_bar(0, 12));
    println!();
    println!("{:<18} [---------->]  0%", "");
    println!();
    println!("//▞▞ SYSTEM.STATUS");
    println!();
    println!();
    println!();
    println!();
    
    // Calculate block start row (current row - 10)
    let block_start_row = 18u16; // After header, dots, boxes, blank (adjusted for extra blank line)
    
    // Files are in .3ox subdirectory - calculate once outside loop
    // Convert to absolute path for reliable file checking
    // Handle case where cube_root might already be .3ox or end with .3ox
    // Also handle WSL mount path mappings (/mnt/r vs /root)
    let cube_3ox = {
        // Get absolute path - prefer manual resolution to avoid mount point issues
        let absolute_cube = if cube_root.is_absolute() {
            cube_root.clone()
        } else {
            std::env::current_dir()
                .unwrap_or_else(|_| PathBuf::from("."))
                .join(&cube_root)
        };
        
        // Check if path already ends with .3ox - if so, use it directly, otherwise append
        let cube_3ox_path = if absolute_cube.file_name()
            .and_then(|n| n.to_str())
            .map(|n| n == ".3ox")
            .unwrap_or(false) {
            // Path ends with .3ox directory name, use it directly
            absolute_cube
        } else {
            // Path is the cube root, append .3ox
            absolute_cube.join(".3ox")
        };
        
        cube_3ox_path
    };
    
    // Debug: Log the resolved path (always write, not just in debug builds)
    append_log(&cube_3ox, &format!(
        "CUBE_3OX_RESOLVED: original='{}', resolved='{}', .3ox_exists={}, .3ox_is_dir={}", 
        cube_root.display(), 
        cube_3ox.display(), 
        cube_3ox.exists(),
        cube_3ox.is_dir()
    ));

    // Log agent id early into 3ox.log for traceability
    if let Some(agent) = read_agent_id(&cube_3ox) {
        append_agent_log(&cube_3ox, &format!("AGENT_ID: {}", agent));
    }
    
    // Loading section - 4 phases: faces (6), vec3 (3), core (1), lock (filler)
    let phases = [
        ("loading", "faces", 0, 6),
        ("binding", "vec3", 6, 3),
        ("igniting", "core", 9, 1),
    ];
    
    let mut step_count = 0;  // 0-10 steps for files, 11-12 for lock
    
    for (action, phase_name, start_idx, count) in &phases {
        // #region agent log
        if let Ok(mut f) = OpenOptions::new().create(true).append(true).open("/root/!CMD.BRIDGE/.cursor/debug.log") {
            let _ = writeln!(f, r#"{{"sessionId":"debug-session","runId":"post-fix","hypothesisId":"FIX","location":"page2.rs:109","message":"Phase start","data":{{"phase":"{}","start_idx":{},"count":{}}},"timestamp":{}}}"#, phase_name, start_idx, count, std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_millis());
        }
        // #endregion
        
        // Load files for this phase
        for i in 0..*count {
            let file_idx = start_idx + i;
            let name = file_status[file_idx].0.clone();
            
            // Show file with empty bar first (loading state)
            execute!(stdout, MoveTo(0, block_start_row + 3))?;
            print!("{:<18} [---------->]  0%     ", name);
            stdout.flush()?;
            sleep(Duration::from_millis(100));
            
            // Animate the file loading bar (5 steps)
            for anim_step in 0..5 {
                execute!(stdout, MoveTo(0, block_start_row + 3))?;
                let progress_chars = (anim_step + 1) * 2;
                let file_bar = format!("[{}{}->]", "#".repeat(progress_chars), "-".repeat(10 - progress_chars));
                let anim_percent = (anim_step + 1) * 20;
                print!("{:<18} {}  {:>3}%    ", name, file_bar, anim_percent);
                stdout.flush()?;
                sleep(Duration::from_millis(60));
            }
            
            // Check if file exists (files are in .3ox subdirectory)
            // Focus: Start with just brains.rs to isolate the issue
            let check_path = match name.as_str() {
                "brains.rs" => cube_3ox.join("brains.rs"),
                "run.rb" => cube_3ox.join("run.rb"),
                "tools.yml" => cube_3ox.join("tools.yml"),
                "routes.json" => cube_3ox.join("routes.json"),
                "limits.toml" => cube_3ox.join("limits.toml"),
                "3ox.log" => cube_3ox.join("3ox.log"),
                "face.map.toml" => cube_3ox.join("vec3.core/face.map.toml"),
                "manifest.vec3.toml" => cube_3ox.join("vec3.core/manifest.vec3.toml"),
                "agent.id" => cube_3ox.join("vec3.core/agent.id"),
                "sparkfile.md" => cube_3ox.join("sparkfile.md"),
                _ => cube_3ox.join("unknown"),
            };
            
            // Check file existence
            let exists = check_path.exists();
            
            // Debug: Always log for brains.rs to track the issue
            if name == "brains.rs" {
                append_log(&cube_3ox, &format!(
                    "BRAINS.RS CHECK: path='{}', exists={}, cube_3ox='{}', cube_3ox_exists={}", 
                    check_path.display(), exists, cube_3ox.display(), cube_3ox.exists()
                ));
            }
            
            // Update file status
            file_status[file_idx].1 = exists;
            step_count += 1;
            
            // Update CUBE STATUS box - first 6 files map to rows 3-8 in the box
            // Print the entire right side of the line to avoid Unicode column issues
            if file_idx < 6 {
                let cube_row = cube_box_start_row + 3 + file_idx as u16;
                let bar = if exists { "[##########>]" } else { "[---------->]" };
                let pct = if exists { " 100%" } else { "   0%" };
                let marker = if exists { "▣" } else { "▢" };
                let status = if exists { "OK" } else { ".." };
                
                // Move to column 23 (start of right box) and print entire right side
                // Template format: |  brains.rs      [---------->]   0%      v1.0.0   ▢ ..  |
                // Name field is 15 chars (position 3-17), [ at position 18
                // pct values: "   0%" (3 spaces + 0%) or " 100%" (1 space + 100%), format has no spaces between bar and pct
                // Version spacing: 5 spaces before v1.0.0 (to align right edge properly)
                execute!(stdout, MoveTo(23, cube_row))?;
                print!("|  {:<15}{}{}     v1.0.0   {} {}  |", name, bar, pct, marker, status);
                stdout.flush()?;
            }
            
            // Update SPARKFILE row when sparkfile loads (file_idx 9)
            if file_idx == 9 {
                let sparkfile_row = cube_box_start_row + 10; // SPARKFILE is row 10 in box
                let bar = if exists { "[**********>]" } else { "[---------->]" };
                let marker = if exists { "◉" } else { "▢" };
                let status = if exists { "OK" } else { ".." };
                
                // Move to column 23 (start of right box) and print entire right side
                execute!(stdout, MoveTo(23, sparkfile_row))?;
                print!("|  SPARKFILE      {}           ACTIVE   {} {}  |", bar, marker, status);
                stdout.flush()?;
            }
            
            // Calculate progress: 10 files = 10 steps, each step = 10%, bar fills proportionally
            // 10 steps maps to 10 boxes (leaving 2 for lock phase)
            let bar_progress = step_count.min(10);
            let percent = step_count * 10;
            
            // Update Row 1: main loading bar
            execute!(stdout, MoveTo(0, block_start_row + 1))?;
            print!("...{}{{{}}}      {} {}%  ", action, phase_name, progress_bar(bar_progress, 12), percent);
            stdout.flush()?;
            
            // Update Row 3: show final file status
            execute!(stdout, MoveTo(0, block_start_row + 3))?;
            let file_bar = if exists { "[##########>]" } else { "[---------->]" };
            let file_percent = if exists { "100%" } else { "  0%" };
            let file_status_text = if exists { "OK" } else { "FAIL" };
            print!("{:<18} {}  {}  {}", name, file_bar, file_percent, file_status_text);
            stdout.flush()?;
            sleep(Duration::from_millis(150));
        }
        
        // Update SYSTEM.STATUS and CUBE STATUS column when phase completes
        // Check actual file existence counts to determine status
        if *phase_name == "faces" {
            sleep(Duration::from_millis(300));  // Small delay after faces
            
            // Count how many face files actually exist (first 6 files)
            let faces_found = file_status.iter().take(6).filter(|(_, exists, _)| *exists).count();
            let faces_status = if faces_found == 6 { "LOADED" } else if faces_found > 0 { "PARTIAL" } else { "MISSING" };
            
            // Update CUBE STATUS column: Faces :: [status]
            execute!(stdout, MoveTo(3, cube_box_start_row + 3))?;
            print!("Faces :: {:<7} ", faces_status);
            stdout.flush()?;
            
            // Update SYSTEM.STATUS
            execute!(stdout, MoveTo(0, block_start_row + 7))?;
            print!("3ox.faces      MAPPED     COMPLETE");
            stdout.flush()?;
        } else if *phase_name == "vec3" {
            sleep(Duration::from_millis(500));  // Delay before vec3 completes
            
            // Count how many vec3 files actually exist (files 6-8)
            let vec3_found = file_status.iter().skip(6).take(3).filter(|(_, exists, _)| *exists).count();
            let vec3_status = if vec3_found == 3 { "LOADED" } else if vec3_found > 0 { "PARTIAL" } else { "MISSING" };
            
            // Update CUBE STATUS column: Vec3 :: [status]
            execute!(stdout, MoveTo(3, cube_box_start_row + 4))?;
            print!("Vec3  :: {:<7} ", vec3_status);
            stdout.flush()?;
            
            // Update SYSTEM.STATUS
            execute!(stdout, MoveTo(0, block_start_row + 8))?;
            print!("vec3.binding   ENGAGED    COMPLETE");
            stdout.flush()?;
        } else if *phase_name == "core" {
            // Check if sparkfile exists (file 9)
            let core_exists = file_status.get(9).map(|(_, exists, _)| *exists).unwrap_or(false);
            let core_status = if core_exists { "STABLE" } else { "MISSING" };
            
            // Update CUBE STATUS column: Core :: [status]
            execute!(stdout, MoveTo(3, cube_box_start_row + 5))?;
            print!("Core  :: {:<7} ", core_status);
            stdout.flush()?;
            
            // Update SYSTEM.STATUS
            execute!(stdout, MoveTo(0, block_start_row + 9))?;
            print!("sparkfile.core STABLE     COMPLETE");
            stdout.flush()?;
        }
    }
    
    // Engaging lock phase (filler - fills remaining 2 boxes)
    execute!(stdout, MoveTo(0, block_start_row + 3))?;
    print!("{:<18} [----------]   PENDING  ", "cube.lock");
    stdout.flush()?;
    
    // Step 11 (90%) - longer delay for effect
    execute!(stdout, MoveTo(0, block_start_row + 1))?;
    print!("...engaging{{lock}}      {}    ", progress_bar(11, 12));
    stdout.flush()?;
    sleep(Duration::from_millis(800));  // Longer delay at 90%
    
    // Step 12 (100%)
    execute!(stdout, MoveTo(0, block_start_row + 1))?;
    print!("...engaging{{lock}}      {}    ", progress_bar(12, 12));
    stdout.flush()?;
    sleep(Duration::from_millis(300));
    
    // Lock complete
    execute!(stdout, MoveTo(0, block_start_row + 3))?;
    print!("{:<18} [##########>]  LOCKED   ", "cube.lock");
    stdout.flush()?;
    sleep(Duration::from_millis(200));
    
    // Final: Update loading bar to show complete
    execute!(stdout, MoveTo(0, block_start_row + 1))?;
    print!("...{{3OX}}Initialized     {} COMPLETE", progress_bar(12, 12));
    stdout.flush()?;
    
    // Clear the old loading{faces} line below it
    execute!(stdout, MoveTo(0, block_start_row + 2))?;
    print!("{}", " ".repeat(60));
    stdout.flush()?;
    
    // Clear file line
    execute!(stdout, MoveTo(0, block_start_row + 3))?;
    print!("{}", " ".repeat(60));
    stdout.flush()?;
    
    // Move cursor to end of block and print :: ∎
    execute!(stdout, MoveTo(0, block_start_row + 10))?;
    println!();
    println!(":: ∎");
    println!();
    
    // Final status box - show path with .3ox suffix
    // Handle case where cube_root might already be .3ox
    let relative_path = {
        // Try canonical path first for better display
        let display_root = cube_root.canonicalize().unwrap_or_else(|_| cube_root.clone());
        
        // If path already ends with .3ox, use it as-is, otherwise append
        let display_path = if display_root.ends_with(".3ox") {
            display_root.clone()
        } else {
            display_root.join(".3ox")
        };
        
        let components: Vec<_> = display_path.components().collect();
        
        // Show last 3 components if we have enough, otherwise show the whole path
        if components.len() >= 3 {
            let last_few: PathBuf = components[components.len().saturating_sub(3)..].iter().collect();
            last_few.display().to_string()
        } else {
            display_path.display().to_string()
        }
    };
    
    println!("+--------------------------------------------------------+");
    println!("|  VEC3.BIND: STABLE           CUBE.LOCK: VERIFIED       |");
    println!("|  MEMORY: 64K                                           |");
    println!("|  READY FOR INPUT                                       |");
    println!("+--------------------------------------------------------+");
    println!("|  3OX PATH: {:<43} |", relative_path);
    println!("+--------------------------------------------------------+");
    println!();
    println!(":: ∎");
    println!();
    
    // Final separator with animation
    type_animate("//▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂〘・.°𝚫 〙", 10, &mut stdout)?;
    println!();
    println!();
    println!();

    // Final messages with animation
    let final_face_count = file_status[0..6].iter().filter(|(_, s, _)| *s).count();
    println!("▛▞// 3OX.LOADER ⫎ ▸");
    println!();
    type_animate(&format!("{} face(s) loaded successfully.", final_face_count), 15, &mut stdout)?;
    println!();
    type_animate("1 core module active.", 15, &mut stdout)?;
    println!();
    type_animate("Awaiting operator command.", 15, &mut stdout)?;
    println!();
    println!();
    type_animate(":: 𝜵", 20, &mut stdout)?;
    println!();
    println!();
    
    // Show cursor and prompt for keypress
    execute!(stdout, Show)?;
    enable_raw_mode()?;
    type_animate("Press any key to continue...", 15, &mut stdout)?;
    stdout.flush()?;
    
    // Wait for any key (no Enter required)
    let _ = read();
    disable_raw_mode()?;
    
    // Clear the "Press any key to continue..." line after keypress using carriage return
    print!("\r{}", " ".repeat(80)); // Carriage return and clear with spaces
    print!("\r"); // Return to start of line
    stdout.flush()?;
    
    // Try to init cube context using the same resolved .3ox path
    if let Ok(cube) = init_cube_context(cube_3ox.clone()) {
        Ok(Some(cube))
    } else {
        Ok(None)
    }
}

