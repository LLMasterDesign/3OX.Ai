// ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂| 3ox v1.0.0 |▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
// ▛//▞▞ ⟦⎊⟧ :: ⧗-25.122 // BRAINS-3OX-CORE :: Core Brain Library ▞▞

pub mod vec3;

use std::collections::HashMap;
use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::Command;
use chrono::{Datelike, Timelike, Utc};
use serde::Deserialize;
use serde_json::Value;
use uuid::Uuid;

// Cube context structure
#[derive(Debug, Clone)]
pub struct CubeContext {
    pub cube_root: PathBuf,
    pub agent_id: String,
    pub agent_name: String,
    pub workspace: String,
    pub sparkfile: String,
    pub tools: ToolsConfig,
    pub routes: RoutesConfig,
    pub limits: LimitsConfig,
    pub face_map: Value,
    pub manifest: Value,
    pub session_id: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct ToolsConfig {
    pub tools: Vec<Tool>,
    #[serde(default)]
    pub dependencies: Vec<String>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct Tool {
    pub name: String,
    pub function: String,
    pub returns: String,
    pub description: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct RoutesConfig {
    pub routes: HashMap<String, String>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct LimitsConfig {
    #[serde(default)]
    pub meta: LimitsMeta,
    #[serde(default)]
    #[serde(rename = "resources.tokens")]
    pub resources_tokens: ResourcesTokens,
    #[serde(default)]
    pub safety: SafetyConfig,
}

#[derive(Debug, Clone, Deserialize)]
pub struct LimitsMeta {
    pub version: Option<String>,
    pub runtime: Option<String>,
    pub component: Option<String>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct ResourcesTokens {
    #[serde(default)]
    pub max_tokens: u64,
    #[serde(default)]
    pub max_tools_per_request: u64,
}

#[derive(Debug, Clone, Deserialize)]
pub struct SafetyConfig {
    #[serde(default = "default_mode")]
    pub mode: String,
    #[serde(default)]
    pub halt_on_critical_error: bool,
}

fn default_mode() -> String {
    "strict".to_string()
}

impl Default for LimitsMeta {
    fn default() -> Self {
        LimitsMeta {
            version: None,
            runtime: None,
            component: None,
        }
    }
}

impl Default for ResourcesTokens {
    fn default() -> Self {
        ResourcesTokens {
            max_tokens: 100000,
            max_tools_per_request: 10,
        }
    }
}

impl Default for SafetyConfig {
    fn default() -> Self {
        SafetyConfig {
            mode: "strict".to_string(),
            halt_on_critical_error: false,
        }
    }
}

// Logger structure
pub struct Logger {
    log_path: PathBuf,
    agent_id: String,
    session_id: String,
}

impl Logger {
    pub fn new(log_path: PathBuf, agent_id: String, session_id: String) -> Self {
        Logger {
            log_path,
            agent_id,
            session_id,
        }
    }

    pub fn init_log(&self, agent_name: &str, brain_type: &str, workspace: &str) -> Result<(), String> {
        // Check if log file exists and has content
        let needs_header = if self.log_path.exists() {
            let content = fs::read_to_string(&self.log_path)
                .map_err(|e| format!("Failed to read log file: {}", e))?;
            content.trim().is_empty() || !content.contains("# AGENT_ID:")
        } else {
            true
        };

        if needs_header {
            let timestamp = format_timestamp();
            let header = format!(
                "# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂| 3ox.log | {} |▂▂▂▂▂▂▂▂▂▂▂▂▂///\n\
                # AGENT_ID: {}\n\
                # AGENT_NAME: {}\n\
                # BRAIN_TYPE: {}\n\
                # WORKSPACE: {}\n\
                # ▛//▞▞ ⟦⎊⟧ :: {} // 3OX.LOG :: Runtime Ledger ▞▞\n\n",
                agent_name, self.agent_id, agent_name, brain_type, workspace, timestamp
            );

            fs::write(&self.log_path, header)
                .map_err(|e| format!("Failed to write log header: {}", e))?;
        }

        Ok(())
    }

    pub fn log_entry(&self, kind: &str, event: &str, fields: &[(&str, &str)]) -> Result<(), String> {
        let timestamp = format_timestamp();
        let mut entry = format!(
            "[{}] | {} | {} | {} | {}",
            timestamp, self.agent_id, self.session_id, kind, event
        );

        for (key, value) in fields {
            entry.push_str(&format!(" | {}: {}", key, value));
        }

        entry.push('\n');

        let mut file = fs::OpenOptions::new()
            .create(true)
            .append(true)
            .open(&self.log_path)
            .map_err(|e| format!("Failed to open log file: {}", e))?;

        file.write_all(entry.as_bytes())
            .map_err(|e| format!("Failed to write log entry: {}", e))?;

        Ok(())
    }
}

// Format timestamp as ⧗-YY.SSS (year.decimal_day_of_year)
fn format_timestamp() -> String {
    let now = Utc::now();
    let year = now.year() % 100; // Last two digits
    let day_of_year = now.ordinal0() as f64 + (now.hour() as f64 / 24.0) + (now.minute() as f64 / 1440.0) + (now.second() as f64 / 86400.0);
    let decimal_day = (day_of_year / 365.0 * 1000.0).round() as u32;
    format!("⧗-{:02}.{:03}", year, decimal_day)
}

// Generate short SESSION_ID (8-char hex)
pub fn generate_session_id() -> String {
    Uuid::new_v4().to_string()[..8].to_string().to_uppercase()
}

// Cube context loading functions
pub fn load_sparkfile(cube_root: &Path) -> Result<String, String> {
    let path = cube_root.join("sparkfile.md");
    fs::read_to_string(&path)
        .map_err(|e| format!("Failed to load sparkfile.md: {}", e))
}

pub fn load_tools(cube_root: &Path) -> Result<ToolsConfig, String> {
    let path = cube_root.join("tools.yml");
    let content = fs::read_to_string(&path)
        .map_err(|e| format!("Failed to load tools.yml: {}", e))?;
    serde_yaml::from_str(&content)
        .map_err(|e| format!("Failed to parse tools.yml: {}", e))
}

pub fn load_routes(cube_root: &Path) -> Result<RoutesConfig, String> {
    let path = cube_root.join("routes.json");
    let content = fs::read_to_string(&path)
        .map_err(|e| format!("Failed to load routes.json: {}", e))?;
    serde_json::from_str(&content)
        .map_err(|e| format!("Failed to parse routes.json: {}", e))
}

pub fn load_limits(cube_root: &Path) -> Result<LimitsConfig, String> {
    let path = cube_root.join("limits.toml");
    let content = fs::read_to_string(&path)
        .map_err(|e| format!("Failed to load limits.toml: {}", e))?;
    toml::from_str(&content)
        .map_err(|e| format!("Failed to parse limits.toml: {}", e))
}

pub fn load_face_map(cube_root: &Path) -> Result<Value, String> {
    let path = cube_root.join("vec3.core/face.map.toml");
    let content = fs::read_to_string(&path)
        .map_err(|e| format!("Failed to load face.map.toml: {}", e))?;
    toml::from_str(&content)
        .map_err(|e| format!("Failed to parse face.map.toml: {}", e))
        .and_then(|v: toml::Value| {
            serde_json::to_value(v)
                .map_err(|e| format!("Failed to convert face.map.toml to JSON: {}", e))
        })
}

pub fn load_manifest(cube_root: &Path) -> Result<Value, String> {
    let path = cube_root.join("vec3.core/manifest.vec3.toml");
    let content = fs::read_to_string(&path)
        .map_err(|e| format!("Failed to load manifest.vec3.toml: {}", e))?;
    toml::from_str(&content)
        .map_err(|e| format!("Failed to parse manifest.vec3.toml: {}", e))
        .and_then(|v: toml::Value| {
            serde_json::to_value(v)
                .map_err(|e| format!("Failed to convert manifest.vec3.toml to JSON: {}", e))
        })
}

pub fn load_agent_id(cube_root: &Path) -> Result<String, String> {
    let path = cube_root.join("vec3.core/agent.id");
    fs::read_to_string(&path)
        .map_err(|e| format!("Failed to load agent.id: {}", e))
        .map(|s| s.trim().to_string())
}

pub fn validate_cube(cube_root: &Path) -> Result<(), String> {
    let required_files = vec![
        "tools.yml",
        "routes.json",
        "limits.toml",
        "run.rb",
        "vec3.core/face.map.toml",
        "vec3.core/manifest.vec3.toml",
        "vec3.core/agent.id",
    ];

    for file in required_files {
        let path = cube_root.join(file);
        if !path.exists() {
            return Err(format!("Required file missing: {}", file));
        }
    }

    Ok(())
}

// Initialize cube context
pub fn init_cube_context(cube_root: PathBuf) -> Result<CubeContext, String> {
    validate_cube(&cube_root)?;

    let agent_id = load_agent_id(&cube_root)?;
    let sparkfile = load_sparkfile(&cube_root)?;
    let tools = load_tools(&cube_root)?;
    let routes = load_routes(&cube_root)?;
    let limits = load_limits(&cube_root)?;
    let face_map = load_face_map(&cube_root)?;
    let manifest = load_manifest(&cube_root)?;

    // Extract agent name and workspace from manifest or use defaults
    let agent_name = manifest
        .get("cube")
        .and_then(|c| c.get("id"))
        .and_then(|v| v.as_str())
        .unwrap_or("AGENT.DEFAULT")
        .to_string();

    let workspace = "CITADEL.BASE".to_string(); // Default workspace

    let session_id = generate_session_id();

    Ok(CubeContext {
        cube_root,
        agent_id,
        agent_name,
        workspace,
        sparkfile,
        tools,
        routes,
        limits,
        face_map,
        manifest,
        session_id,
    })
}

// Tool execution via run.rb
pub fn execute_tool(
    cube_root: &Path,
    request: &str,
    limits: &LimitsConfig,
) -> Result<Value, String> {
    // Check limits before execution
    if request.len() as u64 > limits.resources_tokens.max_tokens {
        return Err(format!(
            "Request exceeds max_tokens limit: {} > {}",
            request.len(),
            limits.resources_tokens.max_tokens
        ));
    }

    let run_rb_path = cube_root.join("run.rb");

    let output = Command::new("ruby")
        .arg(run_rb_path.to_str().unwrap())
        .arg(request)
        .current_dir(cube_root)
        .output()
        .map_err(|e| format!("Failed to execute run.rb: {}", e))?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        return Err(format!("run.rb execution failed: {}", stderr));
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    
    // run.rb may output log messages before JSON, so find the JSON part
    let json_str = if let Some(json_start) = stdout.rfind('{') {
        &stdout[json_start..]
    } else {
        return Err(format!("No JSON found in run.rb output: {}", stdout));
    };
    
    let json: Value = serde_json::from_str(json_str)
        .map_err(|e| format!("Failed to parse run.rb JSON output: {} | Output: {}", e, stdout))?;

    Ok(json)
}

// Describe capabilities (kept for compatibility)
pub fn describe_capabilities() -> String {
    format!(
        "3OX.Agent.Default capabilities:
        - Tools configured via tools.yml
        - Routes defined in routes.json
        - Limits enforced by limits.toml
        - All operations logged to 3ox.log"
    )
}

// ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂| v1.0.0 |▂▂▂▂▂▂▂▂▂▂▂▂///

