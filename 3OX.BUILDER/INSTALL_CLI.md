///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::
▛//▞▞ ⟦⎊⟧ :: ⧗-25.131 // INSTALL.CLI :: 3OX CLI Installation ▞▞
▛▞// CLI.Installation :: ρ{Input}.φ{Bind}.τ{Output} ▹
//▞⋮⋮ ⟦📦⟧ :: [install] [cli] [global] [command] [⊢ ⇨ ⟿ ▷]
⫸ 〔runtime.cli.install.context〕

```elixir
/// Status: [ACTIVE] | Version: 1.0.0 | Authority: Lucius.Larz | Created: 2025.12.13
/// Installation guide for 3OX global CLI command.
```

## Installation

### Build CLI Binary

```bash
cd 3OX.BUILDER
cargo build --release --bin 3ox
```

### Install Globally (Linux)

**Option 1: Copy to /usr/local/bin (Recommended)**
```bash
sudo cp target/release/3ox /usr/local/bin/
sudo chmod +x /usr/local/bin/3ox
```

**Option 2: Copy to ~/.local/bin**
```bash
mkdir -p ~/.local/bin
cp target/release/3ox ~/.local/bin/
chmod +x ~/.local/bin/3ox

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/.local/bin:$PATH"
```

**Option 3: Symlink**
```bash
sudo ln -s $(pwd)/target/release/3ox /usr/local/bin/3ox
```

### Verify Installation

```bash
which 3ox
3ox help
```

## Usage

### Basic Commands

```bash
# Run agent in current directory (if .3ox exists)
3ox

# Run specific agent
3ox sirius
3ox guardian

# Show agent status
3ox show

# Show agent log
3ox show log

# List all agents
3ox list

# Help
3ox help
```

### How It Works

1. **Current Directory**: `3ox` searches for `.3ox` starting from current directory
2. **Parent Walk**: If not found, walks up parent directories
3. **Agent Name**: `3ox <name>` searches common locations for agent
4. **Ruby Runtime**: Executes `ruby .3ox/run.rb` in agent directory

### Agent Detection

The CLI searches for `.3ox` directories in:
- Current directory
- Parent directories (walks up)
- `~/<agent-name>`
- `/opt/<agent-name>`
- `/usr/local/<agent-name>`

## Integration with Vec3Boot

For full boot screen experience, use Vec3Boot:

```bash
# Vec3Boot (full boot screen)
bun compile-run.bun

# 3OX CLI (quick agent run)
3ox
```

## Troubleshooting

**Command not found:**
- Ensure binary is in PATH
- Check: `which 3ox`
- Verify: `ls -la /usr/local/bin/3ox`

**Agent not found:**
- Check `.3ox` directory exists
- Verify `run.rb` exists in `.3ox/`
- Try: `3ox list` to see all agents

**Permission denied:**
- `chmod +x /usr/local/bin/3ox`
- Or use `~/.local/bin` instead

## Uninstall

```bash
sudo rm /usr/local/bin/3ox
# or
rm ~/.local/bin/3ox
```

:: 𝜵 //▚▚▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂

