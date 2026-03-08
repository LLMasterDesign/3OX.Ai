///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::
▛//▞▞ ⟦⎊⟧ :: ⧗-25.131 // START.HERE :: 3OX.BUILDER ▞▞
▛▞// Quick.Start :: ρ{Input}.φ{Bind}.τ{Output} ▹
//▞⋮⋮ ⟦📦⟧ :: [quick.start] [installation] [usage] [⊢ ⇨ ⟿ ▷]
⫸ 〔runtime.start.here.context〕

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[25.12.13]
/// doc:[COMPLETE] modified:[26.03.03] auth:[3OX.AI]
/// Start here for 3OX.BUILDER setup and usage
```

## Quick Start

### Prerequisites

```bash
# Required
- Rust (latest stable, 2021 edition)
- Bun (>=1.0.0) or Node.js (>=18.0.0)
- Ruby (>=3.2.0)

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install Bun
curl -fsSL https://bun.sh/install | bash
```

### Installation

```bash
# Clone or download this repository
cd 3OX.BUILDER

# Install dependencies (if using npm)
npm install

# Or use Bun directly
bun install
```

### Build & Run

```bash
# Using Bun (recommended)
bun run compile-run.bun

# Or using npm
npm run build
npm start

# Or directly with Bun
bun compile-run.bun
```

### First Time Setup

When you run Vec3Boot for the first time on a directory without a `.3ox/` folder:

1. **Page 1**: Boot screen splash
2. **Page 2**: Cube validation and face loading
3. **Page 3**: Interactive setup prompts (if sparkfile missing)
   - Enter agent name
   - Select brain type (Citadel, Sentinel, Alchemist, Lighthouse)
   - Confirm setup
4. **Setup Complete**: Restart Vec3Boot to load new configuration

### Manual Setup

```bash
# Run setup script directly
ruby 3OX.BUILD/setup-3ox.rb <target_dir> <agent_name> <brain_type>

# Example
ruby 3OX.BUILD/setup-3ox.rb MyProject GUARDIAN Sentinel
```

### Project Structure

```
3OX.BUILDER/
├── boot/              # Vec3Boot binary (Rust)
├── vec3.core/         # Core library (Rust)
├── 3OX.BUILD/         # Setup system (Ruby)
│   ├── setup-3ox.rb   # Main setup script
│   └── TEMPLATES/     # Cube templates
├── compile-run.bun    # Build & run script
├── package.json       # NPM configuration
├── Cargo.toml         # Rust workspace
└── README.md          # Full documentation
```

### Usage Examples

**Boot existing cube:**
```bash
bun compile-run.bun /path/to/cube
```

**Boot current directory:**
```bash
bun compile-run.bun
```

**Setup new cube:**
```bash
ruby 3OX.BUILD/setup-3ox.rb ./MyAgent AGENT Sentinel
```

### VPS Deployment

```bash
# On VPS
git clone https://github.com/LLMasterDesign/ZENS3N.git
cd ZENS3N/3OX.Ai/3OX.BUILDER
bun install
bun compile-run.bun
```

### Troubleshooting

**Build errors:**
- Ensure Rust is installed: `rustc --version`
- Update Rust: `rustup update`

**Ruby errors:**
- Check Ruby version: `ruby --version` (needs >= 3.2.0)
- Install missing gems if needed

**Bun errors:**
- Install Bun: `curl -fsSL https://bun.sh/install | bash`
- Or use Node.js with npm instead

:: 𝜵 //▚▚▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂

