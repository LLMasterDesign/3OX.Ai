# 3OX SETS Viewer

A Tauri-based desktop application for managing and monitoring 3OX agents. This application provides a modern, dark-themed interface inspired by the USAA platform design for viewing, launching, and managing your 3OX agent ecosystem.

## Features

- **Agent Management**: View all installed agents from the `3OX.SETS/` directory
- **Real-time Status**: Monitor agent status (running/stopped/unknown)
- **Agent Details**: Detailed view of agent capabilities, limits, and verification status
- **Launch/Stop Controls**: Start and stop agents with a single click
- **File Verification**: Verify agent file integrity using checksums
- **Modern UI**: Dark theme with USAA-inspired design
- **Backend API**: Rust-based backend with Actix-web for agent management
- **Docker Support**: Containerized deployment with Docker Compose

## Architecture

- **Frontend**: Tauri app (HTML/CSS/JavaScript) with dark theme
- **Backend**: Rust API (Actix-web) for agent scanning and management
- **Communication**: RabbitMQ for agent messaging (1N.3OX/0UT.3OX)
- **Deployment**: Docker containers for API and agent runtime

## Quick Start

### Prerequisites

- Node.js and npm
- Rust toolchain
- Docker and Docker Compose (optional)

### Development Setup

1. **Install Dependencies**
   ```bash
   cd 3ox-cli
   npm install
   ```

2. **Start the Backend**
   ```bash
   cd backend-rust
   cargo run
   ```
   The backend will start on `http://localhost:8000`

3. **Start the Frontend**
   ```bash
   npm run tauri dev
   ```

### Docker Setup

1. **Build and Start Services**
   ```bash
   docker-compose up --build
   ```

2. **Access the Application**
   - Frontend: Launch the Tauri app
   - Backend API: `http://localhost:8000`
   - RabbitMQ Management: `http://localhost:15672` (user: 3ox, pass: 3ox123)

## Agent Structure

Agents should be placed in the `3OX.SETS/` directory with the following structure:

```
3OX.SETS/
├── AGENT_NAME.3ox/
│   ├── brain.exe          # Compiled agent executable
│   ├── brain.rs           # Rust source code
│   ├── run.rb             # Ruby launcher script
│   ├── tools.yml          # Agent metadata and tools
│   ├── limits.json        # Resource limits and constraints
│   ├── routes.json        # API endpoints and capabilities
│   ├── Cargo.toml         # Rust dependencies
│   └── checksums.json     # File integrity checksums (optional)
```

## API Endpoints

- `GET /health` - Health check
- `GET /api/agents` - List all agents
- `GET /api/agents/{id}` - Get specific agent details
- `GET /api/agents/{id}/verify` - Verify agent files
- `POST /api/agents/{id}/launch` - Launch agent
- `POST /api/agents/{id}/stop` - Stop agent
- `GET /api/agents/{id}/status` - Get agent status
- `GET /api/agents/{id}/logs` - Get agent logs

## Sample Agent

A sample Finance agent is included in `3OX.SETS/FINANCE.3ox/` for testing purposes.

## Development

### Frontend Development

The frontend is built with vanilla HTML/CSS/JavaScript and uses the Tauri framework for desktop integration.

- `src/index.html` - Main HTML structure
- `src/styles.css` - Dark theme CSS
- `src/main.js` - Application logic

### Backend Development

The backend is built with Rust and Actix-web:

- `backend-rust/src/main.rs` - Main server and API routes
- `backend-rust/src/scanner.rs` - Agent directory scanning
- `backend-rust/src/executor.rs` - Process management
- `backend-rust/src/models.rs` - Data structures

## Configuration

### Environment Variables

- `3OX_SETS_PATH` - Path to the 3OX.SETS directory (default: `3OX.SETS`)
- `RABBITMQ_URL` - RabbitMQ connection string
- `RUST_LOG` - Log level (default: `info`)

### Tauri Configuration

The Tauri configuration is in `src-tauri/tauri.conf.json` and includes:
- Window settings (1200x800, resizable)
- Security settings for HTTP requests
- App metadata

## Troubleshooting

### Backend Not Starting

1. Check if port 8000 is available
2. Ensure Rust toolchain is installed
3. Check logs for dependency issues

### Agents Not Loading

1. Verify `3OX.SETS/` directory exists
2. Check agent directory structure
3. Ensure all required files are present

### Frontend Connection Issues

1. Verify backend is running on port 8000
2. Check browser console for CORS errors
3. Ensure Tauri security settings allow HTTP requests

## License

This project is part of the 3OX ecosystem and follows the 3OX licensing terms.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For issues and questions, please refer to the 3OX documentation or contact the development team.