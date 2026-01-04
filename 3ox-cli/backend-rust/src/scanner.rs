use crate::models::*;
use std::path::{Path, PathBuf};
use walkdir::WalkDir;
use serde_json;
use std::collections::HashMap;
use sha2::{Sha256, Digest};
use std::fs;

#[derive(Clone)]
pub struct AgentScanner {
    sets_path: PathBuf,
}

impl AgentScanner {
    pub fn new(sets_path: PathBuf) -> Self {
        Self { sets_path }
    }

    pub async fn scan_agents(&self) -> Result<Vec<AgentInfo>, Box<dyn std::error::Error>> {
        let mut agents = Vec::new();

        if !self.sets_path.exists() {
            log::warn!("3OX.SETS directory does not exist: {:?}", self.sets_path);
            return Ok(agents);
        }

        for entry in WalkDir::new(&self.sets_path)
            .max_depth(1)
            .into_iter()
            .filter_map(|e| e.ok())
        {
            let path = entry.path();
            
            if path.is_dir() && path.file_name()
                .and_then(|n| n.to_str())
                .map(|s| s.ends_with(".3ox"))
                .unwrap_or(false)
            {
                if let Some(agent) = self.scan_agent_directory(path).await? {
                    agents.push(agent);
                }
            }
        }

        log::info!("Scanned {} agents from {:?}", agents.len(), self.sets_path);
        Ok(agents)
    }

    async fn scan_agent_directory(&self, path: &Path) -> Result<Option<AgentInfo>, Box<dyn std::error::Error>> {
        let agent_name = path.file_name()
            .and_then(|n| n.to_str())
            .ok_or("Invalid agent directory name")?
            .trim_end_matches(".3ox");

        let agent_id = agent_name.to_lowercase().replace(" ", "-");
        let mut agent = AgentInfo::new(agent_id.clone(), agent_name.to_string(), path.to_path_buf());

        // Scan for canon fileset
        let mut files = AgentFiles::default();
        
        for entry in WalkDir::new(path).into_iter().filter_map(|e| e.ok()) {
            let file_path = entry.path();
            let file_name = file_path.file_name().and_then(|n| n.to_str()).unwrap_or("");
            
            match file_name {
                "brain.exe" => files.brain_exe = Some(file_path.to_path_buf()),
                "brain.rs" => files.brain_rs = Some(file_path.to_path_buf()),
                "run.rb" => files.run_rb = Some(file_path.to_path_buf()),
                "tools.yml" => files.tools_yml = Some(file_path.to_path_buf()),
                "limits.json" => files.limits_json = Some(file_path.to_path_buf()),
                "routes.json" => files.routes_json = Some(file_path.to_path_buf()),
                "Cargo.toml" => files.cargo_toml = Some(file_path.to_path_buf()),
                "checksums.json" => {
                    if let Ok(checksums) = self.load_checksums(file_path).await {
                        files.checksums = Some(checksums);
                    }
                }
                _ => {}
            }
        }

        agent.files = files;

        // Load agent metadata
        self.load_agent_metadata(&mut agent).await?;

        // Verify files
        agent.verification = if agent.is_canon_fileset_complete() {
            "valid".to_string()
        } else {
            "invalid".to_string()
        };

        // Set status based on verification
        agent.status = if agent.verification == "valid" {
            "stopped".to_string()
        } else {
            "unknown".to_string()
        };

        Ok(Some(agent))
    }

    async fn load_agent_metadata(&self, agent: &mut AgentInfo) -> Result<(), Box<dyn std::error::Error>> {
        // Load limits.json
        if let Some(limits_path) = &agent.files.limits_json {
            if let Ok(limits_data) = fs::read_to_string(limits_path) {
                if let Ok(limits) = serde_json::from_str::<AgentLimits>(&limits_data) {
                    agent.limits = limits;
                }
            }
        }

        // Load routes.json
        if let Some(routes_path) = &agent.files.routes_json {
            if let Ok(routes_data) = fs::read_to_string(routes_path) {
                if let Ok(routes) = serde_json::from_str::<AgentRoutes>(&routes_data) {
                    agent.capabilities = routes.capabilities.clone();
                    agent.routes = routes;
                }
            }
        }

        // Load tools.yml for additional metadata
        if let Some(tools_path) = &agent.files.tools_yml {
            if let Ok(tools_data) = fs::read_to_string(tools_path) {
                // Parse YAML for additional agent information
                // This is a simplified version - in production you'd use a proper YAML parser
                if let Some(description) = self.extract_yaml_field(&tools_data, "description") {
                    agent.description = description;
                }
                if let Some(role) = self.extract_yaml_field(&tools_data, "role") {
                    agent.role = role;
                }
                if let Some(tier) = self.extract_yaml_field(&tools_data, "tier") {
                    agent.tier = tier;
                }
                if let Some(icon) = self.extract_yaml_field(&tools_data, "icon") {
                    agent.icon = icon;
                }
            }
        }

        Ok(())
    }

    fn extract_yaml_field(&self, yaml_content: &str, field: &str) -> Option<String> {
        // Simple YAML field extraction - in production use a proper YAML parser
        for line in yaml_content.lines() {
            if line.trim().starts_with(&format!("{}:", field)) {
                if let Some(value) = line.split(':').nth(1) {
                    return Some(value.trim().trim_matches('"').to_string());
                }
            }
        }
        None
    }

    async fn load_checksums(&self, path: &Path) -> Result<HashMap<String, String>, Box<dyn std::error::Error>> {
        let content = fs::read_to_string(path)?;
        let checksums: HashMap<String, String> = serde_json::from_str(&content)?;
        Ok(checksums)
    }

    pub async fn verify_agent_files(&self, agent: &AgentInfo) -> HashMap<String, bool> {
        let mut verification_results = HashMap::new();

        if let Some(checksums) = &agent.files.checksums {
            for (file_path, expected_hash) in checksums {
                let full_path = agent.path.join(file_path);
                if let Ok(actual_hash) = self.calculate_file_hash(&full_path).await {
                    verification_results.insert(file_path.clone(), actual_hash == *expected_hash);
                } else {
                    verification_results.insert(file_path.clone(), false);
                }
            }
        } else {
            // If no checksums file, just check if files exist
            let canon_files = vec![
                "brain.exe", "brain.rs", "run.rb", "tools.yml", 
                "limits.json", "routes.json", "Cargo.toml"
            ];
            
            for file_name in canon_files {
                let file_path = agent.path.join(file_name);
                verification_results.insert(file_name.to_string(), file_path.exists());
            }
        }

        verification_results
    }

    async fn calculate_file_hash(&self, path: &Path) -> Result<String, Box<dyn std::error::Error>> {
        let content = fs::read(path)?;
        let mut hasher = Sha256::new();
        hasher.update(&content);
        let hash = hasher.finalize();
        Ok(format!("{:x}", hash))
    }
}