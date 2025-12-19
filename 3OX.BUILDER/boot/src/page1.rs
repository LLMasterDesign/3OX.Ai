use crossterm::{

  cursor::{Hide, MoveTo},
    execute,
    terminal::{Clear, ClearType},
};
use std::io::{stdout, Write};
use std::thread::sleep;
use std::time::Duration;

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

pub fn show_page1() -> std::io::Result<()> {
    let mut stdout = stdout();
    
    // Hide cursor, clear screen, move to top
    execute!(stdout, Hide, Clear(ClearType::All), MoveTo(0, 0))?;
    
    // Header
    println!("{}", HEADER);
    println!();
    
    // Initializing message
    println!("...Initializing {{3OX}}LOADER ▛▞// ⫎ ▸");
    
    // Animated dots with 5 second total delay
    let dot_delay = 200u64; // ms per dot
    let total_dots_time = 7 * dot_delay; // 1400ms for dots
    let target_total = 5000u64; // 5 seconds total
    let remaining_delay = target_total.saturating_sub(total_dots_time); // Remaining to reach 5 seconds
    
    for _ in 0..7 {
        print!(".");
        stdout.flush()?;
        sleep(Duration::from_millis(dot_delay));
    }
    
    // Add remaining delay to make total 5 seconds
    if remaining_delay > 0 {
        sleep(Duration::from_millis(remaining_delay));
    }
    
    // Clear the dots
    print!("\r{}", " ".repeat(10));
    print!("\r");
    stdout.flush()?;
    println!();
    println!();
    
    Ok(())
}

