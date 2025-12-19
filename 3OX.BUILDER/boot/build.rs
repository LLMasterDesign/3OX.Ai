///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::
// Build script to generate system hash for machine binding

use std::process::Command;
use std::env;
use std::collections::hash_map::DefaultHasher;
use std::hash::{Hash, Hasher};

fn main() {
    // Generate system hash from multiple system identifiers
    let mut hasher = DefaultHasher::new();
    
    // Hostname
    if let Ok(hostname) = Command::new("hostname").output() {
        let hostname_str = String::from_utf8_lossy(&hostname.stdout);
        hostname_str.hash(&mut hasher);
    }
    
    // MAC address (first network interface)
    if let Ok(ip_output) = Command::new("sh")
        .arg("-c")
        .arg("ip link show 2>/dev/null | grep -A1 'state UP' | head -2 | grep -oE '([0-9a-f]{2}:){5}[0-9a-f]{2}' | head -1")
        .output() {
        let mac = String::from_utf8_lossy(&ip_output.stdout);
        mac.hash(&mut hasher);
    } else if let Ok(ifconfig_output) = Command::new("sh")
        .arg("-c")
        .arg("ifconfig 2>/dev/null | grep -oE '([0-9a-f]{2}:){5}[0-9a-f]{2}' | head -1")
        .output() {
        let mac = String::from_utf8_lossy(&ifconfig_output.stdout);
        mac.hash(&mut hasher);
    }
    
    // Machine ID (Linux) or System UUID
    if let Ok(machine_id) = std::fs::read_to_string("/etc/machine-id") {
        machine_id.trim().hash(&mut hasher);
    } else if let Ok(uuid) = std::fs::read_to_string("/var/lib/dbus/machine-id") {
        uuid.trim().hash(&mut hasher);
    }
    
    // CPU info (first line of /proc/cpuinfo)
    if let Ok(cpu) = std::fs::read_to_string("/proc/cpuinfo") {
        if let Some(line) = cpu.lines().find(|l| l.starts_with("model name") || l.starts_with("Processor")) {
            line.hash(&mut hasher);
        }
    }
    
    // Build directory (adds some randomness)
    if let Ok(out_dir) = env::var("OUT_DIR") {
        out_dir.hash(&mut hasher);
    }
    
    // Generate hash
    let hash = hasher.finish();
    let hash_str = format!("{:016x}", hash);
    
    // Pass to compiler as environment variable
    println!("cargo:rustc-env=SYSTEM_HASH={}", hash_str);
    println!("cargo:warning=System hash generated: {}", hash_str);
}
