# 3OX.BUILD - .3ox System Builder

**Purpose**: Base implementations to build any .3ox system  
**Implementations**: RAW (Ruby/Rust) and CORE (Python)

## Base Implementations

**RAW.3ox/** - Ruby/Rust base (our standard):
- brain.rs, brain.exe (compiled Rust)
- run.rb (Ruby runtime)
- tools.yml, limits.json, routes.json
- Cargo.toml (Rust build config)

**CORE.3ox/** - Python base:
- run.py (Python runtime)
- brain.rs (config)
- IMPLEMENTATION/ folder with Python components
- tools.yml, limits.toml, routes.json

**GEM.PROFILES/** - Profile templates

## Build Tools

- **setup-3ox.rb** - Initialize new .3ox from RAW or CORE
- **BUILD.GUIDE.md** - How to build

## Usage

Copy RAW.3ox or CORE.3ox as starting point, then add domain specialization.

:: ∎

