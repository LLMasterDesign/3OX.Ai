use crate::models::*;
use std::process::{Command, Stdio};
use std::time::SystemTime;
use std::path::PathBuf;
use std::fs;
use std::io::{BufRead, BufReader};
use std::os::unix::process::ExitStatusExt;

#[derive(Clone)]
pub struct AgentExecutor {
    log_dir: PathBuf,
}

impl AgentExecutor {
    pub fn new() -> Self {
        let log_dir = PathBuf::from("logs");
        if !log_dir.exists() {
            let _ = fs::create_dir_all(&log_dir);
        }
        
        Self { log_dir }
    }

    pub async fn launch_agent(&self, agent: &AgentInfo) -> Result<ProcessInfo, Box<dyn std::error::Error>> {
        let run_script = agent.path.join("run.rb");
        
        if !run_script.exists() {
            return Err("run.rb not found".into());
        }

        // Set up environment variables
        let mut env_vars = std::collections::HashMap::new();
        env_vars.insert("3OX_FREE_MODE", "true");
        let agent_home = agent.path.to_string_lossy().to_string();
        env_vars.insert("AGENT_HOME", agent_home.as_str());
        env_vars.insert("AGENT_ID", agent.id.as_str());
        env_vars.insert("RABBITMQ_URL", "amqp://localhost:5672");

        // Create log file path
        let log_file = self.log_dir.join(format!("{}.log", agent.id));
        let log_file_path = log_file.to_string_lossy().to_string();

        // Launch the agent process
        let mut child = Command::new("ruby")
            .arg("run.rb")
            .current_dir(&agent.path)
            .envs(&env_vars)
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()?;

        let pid = child.id();
        let started_at = SystemTime::now();

        // Spawn a task to handle output redirection
        let log_file_path_clone = log_file_path.clone();
        tokio::spawn(async move {
            if let Some(stdout) = child.stdout.take() {
                let reader = BufReader::new(stdout);
                let mut log_file = fs::OpenOptions::new()
                    .create(true)
                    .append(true)
                    .open(&log_file_path_clone)
                    .unwrap_or_else(|_| std::process::exit(1));

                for line in reader.lines() {
                    if let Ok(line) = line {
                        let log_entry = format!("[{}] {}\n", 
                            chrono::Utc::now().format("%Y-%m-%d %H:%M:%S"), 
                            line
                        );
                        let _ = fs::write(&log_file_path_clone, log_entry);
                    }
                }
            }
        });

        // Spawn a task to handle stderr
        let log_file_path_clone = log_file_path.clone();
        tokio::spawn(async move {
            if let Some(stderr) = child.stderr.take() {
                let reader = BufReader::new(stderr);
                let mut log_file = fs::OpenOptions::new()
                    .create(true)
                    .append(true)
                    .open(&log_file_path_clone)
                    .unwrap_or_else(|_| std::process::exit(1));

                for line in reader.lines() {
                    if let Ok(line) = line {
                        let log_entry = format!("[{}] ERROR: {}\n", 
                            chrono::Utc::now().format("%Y-%m-%d %H:%M:%S"), 
                            line
                        );
                        let _ = fs::write(&log_file_path_clone, log_entry);
                    }
                }
            }
        });

        log::info!("Launched agent {} with PID {}", agent.name, pid);

        Ok(ProcessInfo {
            pid,
            started_at,
            status: "running".to_string(),
        })
    }

    pub async fn stop_agent(&self, pid: u32) -> Result<(), Box<dyn std::error::Error>> {
        // Try graceful shutdown first
        if let Err(_) = self.send_signal(pid, "TERM").await {
            log::warn!("Failed to send TERM signal to PID {}", pid);
        }

        // Wait a bit for graceful shutdown
        tokio::time::sleep(tokio::time::Duration::from_secs(5)).await;

        // Check if process is still running
        if self.is_agent_running(pid).await {
            log::warn!("Process {} did not stop gracefully, forcing kill", pid);
            if let Err(e) = self.send_signal(pid, "KILL").await {
                return Err(format!("Failed to kill process {}: {}", pid, e).into());
            }
        }

        log::info!("Stopped agent with PID {}", pid);
        Ok(())
    }

    async fn send_signal(&self, pid: u32, signal: &str) -> Result<(), Box<dyn std::error::Error>> {
        let output = Command::new("kill")
            .arg(format!("-{}", signal))
            .arg(pid.to_string())
            .output()?;

        if !output.status.success() {
            return Err(format!("kill command failed: {}", String::from_utf8_lossy(&output.stderr)).into());
        }

        Ok(())
    }

    pub async fn is_agent_running(&self, pid: u32) -> bool {
        let output = Command::new("ps")
            .arg("-p")
            .arg(pid.to_string())
            .output()
            .unwrap_or_else(|_| std::process::Output {
                status: std::process::ExitStatus::from_raw(1),
                stdout: Vec::new(),
                stderr: Vec::new(),
            });

        output.status.success()
    }

    pub async fn get_agent_logs(&self, agent: &AgentInfo) -> Result<Vec<String>, Box<dyn std::error::Error>> {
        let log_file = self.log_dir.join(format!("{}.log", agent.id));
        
        if !log_file.exists() {
            return Ok(vec!["No logs available".to_string()]);
        }

        let content = fs::read_to_string(&log_file)?;
        let lines: Vec<String> = content.lines().map(|s| s.to_string()).collect();
        
        // Return last 100 lines
        let start = if lines.len() > 100 { lines.len() - 100 } else { 0 };
        Ok(lines[start..].to_vec())
    }

    pub async fn get_agent_status(&self, pid: u32) -> String {
        if self.is_agent_running(pid).await {
            "running".to_string()
        } else {
            "stopped".to_string()
        }
    }
}