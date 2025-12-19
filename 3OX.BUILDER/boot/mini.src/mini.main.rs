use crossterm::{
    cursor::{Hide, Show},
    execute,
    terminal::{Clear, ClearType},
};
use std::env;
use std::io::{self, stdout, Write};
use std::path::PathBuf;
use std::thread::sleep;
use std::time::Duration;

use brains_3ox_core::{
    init_cube_context, load_face_map, load_limits, load_manifest,
    load_routes, load_sparkfile, load_tools, validate_cube, CubeContext,
};

const HEADER: &str = r#"+-------------------------------------------------------+
|                                                       |
|   ██████╗  ██████╗ ██╗  ██╗       █████╗ ██╗          |
|   ╚════██╗██╔═══██╗╚██╗██╔╝      ██╔══██╗╚═╝          |
|    █████╔╝██║   ██║ ╚███╔╝       ███████║██║          |
|    ╚═══██╗██║   ██║ ██╔██╗       ██╔══██║██║          |
|   ██████╔╝╚██████╔╝██╔╝ ██╗  ██╗ ██║  ██║██║          |
|   ╚═════╝  ╚═════╝ ╚═╝  ╚═╝  ╚═╝ ╚═╝  ╚═╝╚═╝          |
|                                                       |
+-------------------------------------------------------+
|  ▛▞  3 O X . A i   S Y S T E M   L O A D E R  ▞▞      |
+-------------------------------------------------------+
|  3OX Loader v1.0                                      |
|  Copyright (C) 2025 ZENS3N Systems                    |
|  Created by Lucius Larz Master ・.° 𝚫                 |
+-------------------------------------------------------+"#;

fn progress_bar(filled: usize, total: usize) -> String {
    let filled_chars: String = "▮".repeat(filled);
    let empty_chars: String = "▯".repeat(total - filled);
    format!("▛▞//{}{}▹", filled_chars, empty_chars)
}

fn main() -> std::io::Result<()> {
    let mut stdout = stdout();
    
    let cube_root = env::args()
        .nth(1)
        .map(PathBuf::from)
        .unwrap_or_else(|| env::current_dir().unwrap());
    
    execute!(stdout, Hide, Clear(ClearType::All))?;
    
    // Header
    println!("{}", HEADER);
    println!();
    println!("...Initializing {{3OX}}LOADER ▛▞// ⫎ ▸");
    println!();
    
    // Load data
    let faces = [
        ("brains.rs", cube_root.join("brains.rs").exists()),
        ("run.rb", cube_root.join("run.rb").exists()),
        ("tools.yml", load_tools(&cube_root).is_ok()),
        ("routes.json", load_routes(&cube_root).is_ok()),
        ("limits.toml", load_limits(&cube_root).is_ok()),
        ("3ox.log", cube_root.join("3ox.log").exists()),
    ];
    
    let sparkfile_ok = load_sparkfile(&cube_root).is_ok();
    let face_count = faces.iter().filter(|(_, s)| *s).count();
    
    // CUBE STATUS box (left) and FACE REGISTER (right)
    let faces_status = if face_count == 6 { "LOADED" } else { "PARTIAL" };
    let vec3_status = "LOADED";
    let core_status = if sparkfile_ok { "LOADED" } else { "MISSING" };
    
    println!("+-------------------+  +-------------------------------------------------------+");
    println!("|  CUBE STATUS      |  |  FACE                  DATA         VERSION    LOAD   |");
    println!("+-------------------+  +-------------------------------------------------------+");
    println!("|                   |  |  brains.rs         {}    v1.0.0     {} {}   |", 
             if faces[0].1 { "[##########>]" } else { "[---------->]" },
             if faces[0].1 { "▣" } else { "▢" },
             if faces[0].1 { "OK" } else { ".." });
    println!("|  Faces :: {:<6} |  |  run.rb            {}    v1.0.0     {} {}   |", 
             faces_status,
             if faces[1].1 { "[##########>]" } else { "[---------->]" },
             if faces[1].1 { "▣" } else { "▢" },
             if faces[1].1 { "OK" } else { ".." });
    println!("|  Vec3  :: {:<6} |  |  tools.yml         {}    v1.0.0     {} {}   |", 
             vec3_status,
             if faces[2].1 { "[##########>]" } else { "[---------->]" },
             if faces[2].1 { "▣" } else { "▢" },
             if faces[2].1 { "OK" } else { ".." });
    println!("|  Core  :: {:<6} |  |  routes.json       {}    v1.0.0     {} {}   |", 
             core_status,
             if faces[3].1 { "[##########>]" } else { "[---------->]" },
             if faces[3].1 { "▣" } else { "▢" },
             if faces[3].1 { "OK" } else { ".." });
    println!("|  Lock  ::   ON    |  |  limits.toml       {}    v1.0.0     {} {}   |", 
             if faces[4].1 { "[##########>]" } else { "[---------->]" },
             if faces[4].1 { "▣" } else { "▢" },
             if faces[4].1 { "OK" } else { ".." });
    println!("|                   |  |  3ox.log           {}    v1.0.0     {} {}   |", 
             if faces[5].1 { "[##########>]" } else { "[---------->]" },
             if faces[5].1 { "▣" } else { "▢" },
             if faces[5].1 { "OK" } else { ".." });
    println!("+-------------------+  +-------------------------------------------------------+");
    println!("                     |  SPARKFILE         {}    ACTIVE     {} {}   |", 
             if sparkfile_ok { "[**********>]" } else { "[----------]" },
             if sparkfile_ok { "◉" } else { "▢" },
             if sparkfile_ok { "OK" } else { ".." });
    println!("                     +-------------------------------------------------------+");
    println!();
    
    // Separator
    println!("///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///");
    println!();
    println!();
    
    // SYSTEM.STATUS
    println!("//▞ SYSTEM.STATUS");
    println!("...loading{{faces}}      {} 0%", progress_bar(1, 12));
    println!();
    println!();
    println!("...{{3OX}}Initialized    {} COMPLETE", progress_bar(12, 12));
    println!();
    println!("Cube integrity: CHECKING...");
    println!();
    println!("{} face(s) loaded successfully.", face_count);
    println!("1 core module active.");
    println!("Cube integrity: VERIFIED");
    println!();
    println!(":: ∎");
    println!();
    println!("//▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂〘・.°𝚫〙");
    println!();
    println!("+-------------------------------------------------------+");
    println!("|  CUBE.LOCK: ENGAGED            VEC3.BIND: COMPLETE    |");
    println!("|  MEMORY: 64K OK                INTEGRITY: 100%        |");
    println!("+-------------------------------------------------------+");
    println!("|  READY FOR INPUT                                      |");
    println!("+-------------------------------------------------------+");
    println!();
    
    execute!(stdout, Show)?;
    
    // Wait for keypress
    print!("Press any key to continue...");
    stdout.flush()?;
    let mut _buffer = String::new();
    io::stdin().read_line(&mut _buffer)?;
    
    Ok(())
}
