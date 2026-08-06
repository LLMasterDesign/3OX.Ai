use actix_web::{web, App, HttpServer, Result, HttpResponse, middleware::Logger};
use actix_cors::Cors;
use std::collections::HashMap;
use std::sync::{Mutex, Arc};
use std::path::PathBuf;

mod scanner;
mod models;
mod executor;

use scanner::AgentScanner;
use models::*;
use executor::AgentExecutor;

pub struct AppState {
    pub scanner: AgentScanner,
    pub executor: AgentExecutor,
    pub agents: Mutex<HashMap<String, AgentInfo>>,
    pub processes: Mutex<HashMap<String, ProcessInfo>>,
}


#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init();

    let sets_path = std::env::var("3OX_SETS_PATH")
        .unwrap_or_else(|_| "3OX.SETS".to_string());
    
    let scanner = AgentScanner::new(PathBuf::from(sets_path));
    let executor = AgentExecutor::new();
    
    let app_state = Arc::new(AppState {
        scanner,
        executor,
        agents: Mutex::new(HashMap::new()),
        processes: Mutex::new(HashMap::new()),
    });

    // Initial scan for agents
    if let Ok(agents) = app_state.scanner.scan_agents().await {
        let mut agents_map = app_state.agents.lock().unwrap();
        for agent in agents {
            agents_map.insert(agent.id.clone(), agent);
        }
        log::info!("Loaded {} agents from 3OX.SETS", agents_map.len());
    }

    log::info!("Starting 3OX SETS Viewer Backend on http://localhost:8000");

    HttpServer::new(move || {
        let cors = Cors::default()
            .allow_any_origin()
            .allow_any_method()
            .allow_any_header()
            .max_age(3600);

        App::new()
            .app_data(web::Data::from(app_state.clone()))
            .wrap(cors)
            .wrap(Logger::default())
            .route("/health", web::get().to(health_check))
            .service(
                web::scope("/api")
                    .route("/agents", web::get().to(get_agents))
                    .route("/agents/{id}", web::get().to(get_agent))
                    .route("/agents/{id}/verify", web::get().to(verify_agent))
                    .route("/agents/{id}/launch", web::post().to(launch_agent))
                    .route("/agents/{id}/stop", web::post().to(stop_agent))
                    .route("/agents/{id}/status", web::get().to(get_agent_status))
                    .route("/agents/{id}/logs", web::get().to(get_agent_logs))
            )
    })
    .bind("127.0.0.1:8001")?
    .run()
    .await
}

async fn health_check() -> Result<HttpResponse> {
    Ok(HttpResponse::Ok().json(serde_json::json!({
        "status": "healthy",
        "service": "3OX SETS Viewer Backend",
        "version": "0.1.0"
    })))
}

async fn get_agents(data: web::Data<AppState>) -> Result<HttpResponse> {
    let agents = data.agents.lock().unwrap();
    let agents_list: Vec<&AgentInfo> = agents.values().collect();
    
    Ok(HttpResponse::Ok().json(agents_list))
}

async fn get_agent(
    data: web::Data<AppState>,
    path: web::Path<String>
) -> Result<HttpResponse> {
    let agent_id = path.into_inner();
    let agents = data.agents.lock().unwrap();
    
    match agents.get(&agent_id) {
        Some(agent) => Ok(HttpResponse::Ok().json(agent)),
        None => Ok(HttpResponse::NotFound().json(serde_json::json!({
            "error": "Agent not found"
        })))
    }
}

async fn verify_agent(
    data: web::Data<AppState>,
    path: web::Path<String>
) -> Result<HttpResponse> {
    let agent_id = path.into_inner();
    let agents = data.agents.lock().unwrap();
    
    match agents.get(&agent_id) {
        Some(agent) => {
            let verification_result = data.scanner.verify_agent_files(agent).await;
            Ok(HttpResponse::Ok().json(serde_json::json!({
                "agent_id": agent_id,
                "verification": verification_result
            })))
        },
        None => Ok(HttpResponse::NotFound().json(serde_json::json!({
            "error": "Agent not found"
        })))
    }
}

async fn launch_agent(
    data: web::Data<AppState>,
    path: web::Path<String>
) -> Result<HttpResponse> {
    let agent_id = path.into_inner();
    let agents = data.agents.lock().unwrap();
    
    match agents.get(&agent_id) {
        Some(agent) => {
            match data.executor.launch_agent(agent).await {
                Ok(process_info) => {
                    let mut processes = data.processes.lock().unwrap();
                    processes.insert(agent_id.clone(), process_info);
                    
                    Ok(HttpResponse::Ok().json(serde_json::json!({
                        "status": "launched",
                        "agent_id": agent_id,
                        "message": "Agent launched successfully"
                    })))
                },
                Err(e) => Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                    "error": format!("Failed to launch agent: {}", e)
                })))
            }
        },
        None => Ok(HttpResponse::NotFound().json(serde_json::json!({
            "error": "Agent not found"
        })))
    }
}

async fn stop_agent(
    data: web::Data<AppState>,
    path: web::Path<String>
) -> Result<HttpResponse> {
    let agent_id = path.into_inner();
    let mut processes = data.processes.lock().unwrap();
    
    match processes.remove(&agent_id) {
        Some(process_info) => {
            match data.executor.stop_agent(process_info.pid).await {
                Ok(_) => Ok(HttpResponse::Ok().json(serde_json::json!({
                    "status": "stopped",
                    "agent_id": agent_id,
                    "message": "Agent stopped successfully"
                }))),
                Err(e) => Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                    "error": format!("Failed to stop agent: {}", e)
                })))
            }
        },
        None => Ok(HttpResponse::NotFound().json(serde_json::json!({
            "error": "Agent not running"
        })))
    }
}

async fn get_agent_status(
    data: web::Data<AppState>,
    path: web::Path<String>
) -> Result<HttpResponse> {
    let agent_id = path.into_inner();
    let processes = data.processes.lock().unwrap();
    
    match processes.get(&agent_id) {
        Some(process_info) => {
            let is_running = data.executor.is_agent_running(process_info.pid).await;
            Ok(HttpResponse::Ok().json(serde_json::json!({
                "agent_id": agent_id,
                "status": if is_running { "running" } else { "stopped" },
                "pid": process_info.pid,
                "started_at": process_info.started_at
            })))
        },
        None => Ok(HttpResponse::Ok().json(serde_json::json!({
            "agent_id": agent_id,
            "status": "stopped"
        })))
    }
}

async fn get_agent_logs(
    data: web::Data<AppState>,
    path: web::Path<String>
) -> Result<HttpResponse> {
    let agent_id = path.into_inner();
    let agents = data.agents.lock().unwrap();
    
    match agents.get(&agent_id) {
        Some(agent) => {
            match data.executor.get_agent_logs(agent).await {
                Ok(logs) => Ok(HttpResponse::Ok().json(serde_json::json!({
                    "agent_id": agent_id,
                    "logs": logs
                }))),
                Err(e) => Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                    "error": format!("Failed to get logs: {}", e)
                })))
            }
        },
        None => Ok(HttpResponse::NotFound().json(serde_json::json!({
            "error": "Agent not found"
        })))
    }
}