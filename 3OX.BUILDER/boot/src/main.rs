mod page1;
mod page2;
mod page3;

use std::env;
use std::path::PathBuf;
use std::fs;

// System hash embedded at compile time
const SYSTEM_HASH: &str = env!("SYSTEM_HASH");

fn print_system_hash_once() -> std::io::Result<()> {
    // Check if hash has been printed before
    let hash_file = env::current_exe()?
        .parent()
        .map(|p| p.join(".3ox-builder-hash"))
        .unwrap_or_else(|| PathBuf::from(".3ox-builder-hash"));
    
    if !hash_file.exists() {
        // Print hash
        println!("\n▛▞ System Hash (One-Time):");
        println!("   {}", SYSTEM_HASH);
        println!("   This hash is unique to this build system.\n");
        
        // Create marker file
        if let Some(parent) = hash_file.parent() {
            fs::create_dir_all(parent)?;
        }
        fs::write(&hash_file, SYSTEM_HASH)?;
    }
    
    Ok(())
}

fn main() -> std::io::Result<()> {
    // Print system hash once
    let _ = print_system_hash_once();
    
    // Get cube path from args or use current directory
    let cube_root = env::args()
        .nth(1)
        .map(PathBuf::from)
        .unwrap_or_else(|| env::current_dir().unwrap());
    
    // Show PAGE 1 (with 5 second delay)
    page1::show_page1()?;
    
    // Show PAGE 2 (loading and status)
    if let Some(cube) = page2::show_page2(&cube_root)? {
        // Show PAGE 3 (task menu) if cube loaded successfully
        page3::show_page3(&cube)?;
    }
    
    Ok(())
}
