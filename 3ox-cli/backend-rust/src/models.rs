use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::PathBuf;
use std::time::SystemTime;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentInfo {
    pub id: String,
    pub name: String,
    pub role: String,
    pub description: String,
    pub status: String,
    pub capabilities: Vec<String>,
    pub verification: String,
    pub tier: String,
    pub icon: String,
    pub path: PathBuf,
    pub files: AgentFiles,
    pub limits: AgentLimits,
    pub routes: AgentRoutes,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentFiles {
    pub brain_exe: Option<PathBuf>,
    pub brain_rs: Option<PathBuf>,
    pub run_rb: Option<PathBuf>,
    pub tools_yml: Option<PathBuf>,
    pub limits_json: Option<PathBuf>,
    pub routes_json: Option<PathBuf>,
    pub cargo_toml: Option<PathBuf>,
    pub checksums: Option<HashMap<String, String>>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentLimits {
    pub max_memory_mb: Option<u64>,
    pub max_cpu_percent: Option<f64>,
    pub max_disk_mb: Option<u64>,
    pub timeout_seconds: Option<u64>,
    pub max_concurrent_tasks: Option<u32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentRoutes {
    pub capabilities: Vec<String>,
    pub endpoints: Vec<AgentEndpoint>,
    pub message_types: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentEndpoint {
    pub path: String,
    pub method: String,
    pub description: String,
    pub parameters: Vec<AgentParameter>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentParameter {
    pub name: String,
    pub param_type: String,
    pub required: bool,
    pub description: String,
}

impl Default for AgentFiles {
    fn default() -> Self {
        Self {
            brain_exe: None,
            brain_rs: None,
            run_rb: None,
            tools_yml: None,
            limits_json: None,
            routes_json: None,
            cargo_toml: None,
            checksums: None,
        }
    }
}

impl Default for AgentLimits {
    fn default() -> Self {
        Self {
            max_memory_mb: Some(512),
            max_cpu_percent: Some(50.0),
            max_disk_mb: Some(1024),
            timeout_seconds: Some(300),
            max_concurrent_tasks: Some(5),
        }
    }
}

impl Default for AgentRoutes {
    fn default() -> Self {
        Self {
            capabilities: vec![],
            endpoints: vec![],
            message_types: vec![],
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProcessInfo {
    pub pid: u32,
    pub started_at: SystemTime,
    pub status: String,
}

impl AgentInfo {
    pub fn new(id: String, name: String, path: PathBuf) -> Self {
        Self {
            id,
            name,
            role: "Unknown".to_string(),
            description: "No description available".to_string(),
            status: "stopped".to_string(),
            capabilities: vec![],
            verification: "unknown".to_string(),
            tier: "Standard".to_string(),
            icon: "🤖".to_string(),
            path,
            files: AgentFiles::default(),
            limits: AgentLimits::default(),
            routes: AgentRoutes::default(),
        }
    }

    pub fn is_canon_fileset_complete(&self) -> bool {
        self.files.brain_exe.is_some() &&
        self.files.brain_rs.is_some() &&
        self.files.run_rb.is_some() &&
        self.files.tools_yml.is_some() &&
        self.files.limits_json.is_some() &&
        self.files.routes_json.is_some() &&
        self.files.cargo_toml.is_some()
    }

    pub fn get_missing_files(&self) -> Vec<String> {
        let mut missing = vec![];
        
        if self.files.brain_exe.is_none() { missing.push("brain.exe".to_string()); }
        if self.files.brain_rs.is_none() { missing.push("brain.rs".to_string()); }
        if self.files.run_rb.is_none() { missing.push("run.rb".to_string()); }
        if self.files.tools_yml.is_none() { missing.push("tools.yml".to_string()); }
        if self.files.limits_json.is_none() { missing.push("limits.json".to_string()); }
        if self.files.routes_json.is_none() { missing.push("routes.json".to_string()); }
        if self.files.cargo_toml.is_none() { missing.push("Cargo.toml".to_string()); }
        
        missing
    }
}