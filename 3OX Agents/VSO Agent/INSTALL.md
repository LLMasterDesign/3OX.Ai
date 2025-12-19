# VSO.AGENT Installation Guide

## Prerequisites

Ensure you have the following installed:

- **Ruby 3.2+** - Check with `ruby --version`
- **Rust compiler** - Check with `rustc --version`
- **Git** (optional, for cloning)

## Installation Steps

### 1. Download the Agent

```bash
# Clone or download to your workspace
cd /path/to/your/workspace

# Navigate to the agent directory
cd "3OX Agents/VSO Agent"
```

### 2. Set Environment Variables

Create a `.env` file or export variables in your shell:

```bash
export AGENT_WORKSPACE="/path/to/your/workspace"
export AGENT_ID="VSO01"  # or your preferred identifier
export VERSION="1.0.0"
export SIRIUS_TIME=$(ruby sirius.clock.rb)
```

### 3. Compile the Brain

```bash
cd .3ox
rustc brain.rs -o brain.exe

# Verify compilation
./brain.exe config
```

### 4. Initialize Directory Structure

```bash
# Create user data directories
mkdir -p Claims Templates Archive

# Verify vec3 structure
ls -la vec3/rc/ vec3/lib/ vec3/dev/ vec3/var/
```

### 5. Test the Runtime

```bash
# Run a test operation
ruby .3ox/run.rb

# Check the log
tail .3ox/3ox.log
```

### 6. Review the Specification

Open `.3ox/sparkfile.md` to understand:
- Agent capabilities and behavior
- Strategic questioning methodology
- File management structure
- DBQ and VA rules references
- Operational loop

## Configuration

### vec3 Surfaces

- **rc/** - Immutable rules and mutable control knobs
- **lib/** - Protected references (DBQ guide, VA rules)
- **dev/** - Adapters for external integrations
- **var/** - Runtime data (receipts, events, inflight)

### Environment Variables

- `AGENT_WORKSPACE` - Base path for agent operations
- `AGENT_ID` - Unique identifier for this instance
- `VERSION` - Agent version (semantic versioning)
- `SIRIUS_TIME` - Current Sirius time

## Verification

After installation, verify:

1. Brain compiles without errors
2. Ruby runtime executes successfully
3. vec3 directories are accessible
4. References are readable (vec3/lib/)
5. Runtime directories are writable (vec3/var/)

## Troubleshooting

**Brain won't compile**: Check Rust version and PATH
**Ruby errors**: Verify Ruby 3.2+ is installed
**Permission errors**: Check filesystem permissions for vec3/var/
**Missing references**: Ensure vec3/lib/ files are present

## Next Steps

See the main README.md for usage guidance and capabilities.

