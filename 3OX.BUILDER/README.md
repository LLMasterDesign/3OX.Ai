///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::
▛//▞▞ ⟦⎊⟧ :: ⧗-25.131 // 3OX.BUILDER :: System Builder ▞▞
▛▞// 3OX.Ai.Builder :: ρ{Input}.φ{Bind}.τ{Output} ▹
//▞⋮⋮ ⟦📦⟧ :: [3ox] [builder] [boot] [cube] [setup] [⊢ ⇨ ⟿ ▷]
⫸ 〔runtime.3ox.builder.context〕

```elixir
/// Status: [ACTIVE] | Version: 1.0.0 | Authority: Lucius.Larz.Master | Created: 2025.12.13
/// 3OX.Ai is the substrate. Vec3Boot is the kernel loader.
/// This document locks semantics. Drift is treated as a fault.
```

//▞▞⋮⋮ 💽 [RUN] :: LOADER
```elixir
defmodule Vec3BootLoader do
  @spec load() :: :ok
  def load do
    %{
      load: "VEC3BOOT v1.0",
      priority: 1,
      ar: :on,
      persona: "VEC3BOOT 🚀",
      behavior: "3OX cube boot loader — validates structure, loads faces, activates interactive menu",
      trigger: ["cube_path", "boot", "initialize", "3ox"]
    }
  end
end
```

```elixir
defmodule Setup3OXLoader do
  @spec load() :: :ok
  def load do
    %{
      load: "SETUP-3OX v1.0",
      priority: 0,
      ar: :on,
      persona: "SETUP-3OX ⚙️",
      behavior: "Interactive 3OX cube initialization — creates .3ox structure with templates",
      trigger: ["setup", "initialize", "new cube", "sparkfile missing"]
    }
  end
end
```

▛//▞ Runtime.Binding :: 3OX.BUILDER

3OX.BUILDER is a complete system for building and booting 3OX.Ai agent cubes. It includes Vec3Boot (Rust-based boot loader), setup-3ox.rb (cube initialization), and all necessary templates. The system validates cube structures, loads faces with animated terminal UI, and provides interactive setup prompts on page 3.

## Architecture

### Vec3Boot (Rust Boot Loader)

```rust
// boot/src/main.rs
mod page1;  // Splash screen
mod page2;  // Cube validation & face loading
mod page3;  // Interactive menu & setup prompts

// System hash embedded at compile time
const SYSTEM_HASH: &str = env!("SYSTEM_HASH");

fn main() -> std::io::Result<()> {
    // Print system hash once on first run
    print_system_hash_once()?;
    
    let cube_root = env::args().nth(1)
        .map(PathBuf::from)
        .unwrap_or_else(|| env::current_dir().unwrap());
    
    page1::show_page1()?;
    if let Some(cube) = page2::show_page2(&cube_root)? {
        page3::show_page3(&cube)?;
    }
    Ok(())
}
```

**System Hash (Machine Binding):**
- Generated at compile time from system identifiers (hostname, MAC address, machine-id, CPU info)
- Embedded in binary as compile-time constant
- Printed once on first run, then stored in `.3ox-builder-hash` marker file
- Prevents easy replication on different systems
- Hash is unique to the build system, not the runtime system

**Page Flow:**
- **Page 1**: Animated splash screen (5 second delay)
- **Page 2**: Validates cube structure, loads 6 faces + 3 vec3 files with progress bars
- **Page 3**: Interactive menu with setup prompts if sparkfile missing

### Setup-3OX (Ruby Initialization)

```ruby
# 3OX.BUILD/setup-3ox.rb
def setup_3ox(target_dir, agent_name, brain_type)
  dot3ox = File.join(target_dir, ".3ox")
  FileUtils.mkdir_p(dot3ox)
  
  # Copy templates from TEMPLATES/
  templates.each do |file|
    FileUtils.cp("#{templates}/#{file}", "#{dot3ox}/#{file}")
  end
  
  # Customize brain.rs and sparkfile.md
  customize_templates(dot3ox, agent_name, brain_type)
end
```

**Templates Copied:**
- `brain.rs` - Agent configuration
- `tools.yml` - Tool registry
- `routes.json` - Routing configuration
- `limits.json` - Resource constraints
- `run.rb` - Ruby runtime
- `sparkfile.md` - AI behavior specification

### Vec3.Core (Rust Library)

```rust
// vec3.core/src/lib.rs
pub struct CubeContext {
    pub cube_root: PathBuf,
    pub agent_name: String,
    pub agent_id: String,
    pub tools: Tools,
    pub routes: Routes,
    pub limits: Limits,
    pub sparkfile: String,
}

pub fn init_cube_context(cube_root: &PathBuf) -> Result<CubeContext> {
    // Loads all cube faces and validates structure
}
```

**Core Functions:**
- `init_cube_context()` - Loads and validates cube
- `load_sparkfile()` - Reads sparkfile.md
- `load_tools()` - Parses tools.yml
- `load_routes()` - Parses routes.json
- `load_limits()` - Parses limits.json

## File Structure

```
3OX.BUILDER/
├── boot/                    # Vec3Boot binary
│   ├── src/
│   │   ├── main.rs         # Entry point
│   │   ├── page1.rs        # Splash screen
│   │   ├── page2.rs        # Validation & loading
│   │   └── page3.rs        # Interactive menu & setup
│   └── Cargo.toml
├── vec3.core/               # Core library
│   ├── src/
│   │   ├── lib.rs          # Cube operations
│   │   └── vec3.rs         # Vec3 utilities
│   └── Cargo.toml
├── 3OX.BUILD/              # Setup system
│   ├── setup-3ox.rb        # Main setup script
│   ├── TEMPLATES/          # Cube templates
│   │   ├── brain.rs
│   │   ├── tools.yml
│   │   ├── routes.json
│   │   ├── limits.json
│   │   ├── run.rb
│   │   └── sparkfile.md
│   ├── RAW.3ox/            # Ruby/Rust base
│   ├── CORE.3ox/           # Python base
│   └── GEM.PROFILES/       # Profile templates
├── compile-run.bun         # Build & run script
├── package.json            # NPM configuration
├── Cargo.toml              # Rust workspace
├── sirius.clock.rb         # Time calculator
├── README.md               # This file
└── START_HERE.md           # Quick start guide
```

## Installation from GitHub

### Step 1: Clone Repository

Clone the repository to any location (it doesn't matter where):

```bash
# Option 1: Home directory
cd ~
git clone https://github.com/LLMasterDesign/ZENS3N.git
cd ZENS3N/3OX.Ai/3OX.BUILDER

# Option 2: System location
cd /opt
sudo git clone https://github.com/LLMasterDesign/ZENS3N.git
cd ZENS3N/3OX.Ai/3OX.BUILDER
```

### Step 2: Build CLI Binary

```bash
# Build the 3ox CLI command
cargo build --release --bin 3ox

# Or use Makefile
make build-cli
```

### Step 3: Install Globally

Install the `3ox` binary to system PATH so it works from anywhere:

```bash
# Option 1: Using Makefile (recommended)
make install-cli

# Option 2: Manual installation
sudo cp target/release/3ox /usr/local/bin/
sudo chmod +x /usr/local/bin/3ox

# Option 3: User-local installation
mkdir -p ~/.local/bin
cp target/release/3ox ~/.local/bin/
chmod +x ~/.local/bin/3ox
# Add to PATH in ~/.bashrc or ~/.zshrc:
# export PATH="$HOME/.local/bin:$PATH"
```

### Step 4: Verify Installation

```bash
which 3ox
3ox help
```

**Important:** After installation, the repository location doesn't matter. The `3ox` command is now globally available and will work from any directory.

## Usage

### 3OX CLI (Global Command)

Once installed, use `3ox` from any directory:

```bash
# Run agent in current directory (searches for .3ox folder)
3ox

# Run specific agent by name
3ox sirius
3ox guardian

# Show agent status
3ox show

# Show agent log (last 50 lines)
3ox show log

# List all found agents
3ox list

# Show help
3ox help
```

**How it works:**
- `3ox` searches for `.3ox` folder starting from current directory
- Walks up parent directories if not found
- Executes `ruby .3ox/run.rb` in the agent directory
- For agent names, searches: `~/<name>`, `/opt/<name>`, `/usr/local/<name>`

### Vec3Boot (Full Boot Screen)

For the full animated boot screen experience:

```bash
# Using Bun (recommended)
bun run compile-run.bun

# Using Cargo directly
cargo build --release
./boot/target/release/vec3-boot

# Or with path
./boot/target/release/vec3-boot /path/to/cube
```

### Building

```bash
# Build everything
cargo build --release

# Build just Vec3Boot
cargo build --release --bin vec3-boot

# Build just CLI
cargo build --release --bin 3ox
make build-cli
```

See `INSTALL_CLI.md` for detailed CLI installation instructions.

### Setup New Cube

```bash
# Via Vec3Boot (interactive)
bun compile-run.bun /path/to/new/cube
# Follow prompts on page 3

# Via setup script (direct)
ruby 3OX.BUILD/setup-3ox.rb MyProject AGENT Sentinel
```

### Cube Structure

After setup, a cube contains:

```
.cube_root/
├── .3ox/
│   ├── brain.rs           # Agent config
│   ├── tools.yml          # Tool registry
│   ├── routes.json        # Routing
│   ├── limits.json       # Resource limits
│   ├── run.rb             # Runtime
│   ├── sparkfile.md       # AI spec
│   └── 3ox.log            # Operations log
└── vec3.core/             # (optional)
    ├── face.map.toml
    ├── manifest.vec3.toml
    └── agent.id
```

## Configuration

### System Hash (Machine Binding)

Each build generates a unique system hash based on:
- Hostname
- MAC address (first active interface)
- Machine ID (`/etc/machine-id` on Linux)
- CPU model information
- Build directory path

**Behavior:**
- Hash is generated during `cargo build` via `build.rs`
- Embedded as compile-time constant `SYSTEM_HASH`
- Printed once on first run: `//▞▞⋮⋮ System Hash (One-Time): [hash]`
- Stored in `.3ox-builder-hash` to prevent re-printing
- Different builds on same system = same hash
- Different systems = different hashes

**Purpose:**
- Machine binding for license verification
- Prevents easy binary replication
- Identifies build system origin

```rust
// boot/build.rs generates hash at compile time
// boot/src/main.rs prints it once on first run
const SYSTEM_HASH: &str = env!("SYSTEM_HASH");
```

### Brain Types

- **Citadel** - Command orchestrator
- **Sentinel** - Guardian/sync (default)
- **Alchemist** - Creator/builder
- **Lighthouse** - Knowledge/library

### Sparkfile Format

Sparkfiles use PHENO/PiCO/PRISM structure:

```markdown
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::
▛//▞▞ ⟦⎊⟧ :: ⧗-YY.SSS // OPERATOR :: AGENT_NAME ▞▞

▛//▞ PHENO.CHAIN :: I/O
ρ{Input}  ≔ ingest.normalize.validate{user.prompt}
φ{Bind}   ≔ map.resolve.contract{tools.yml ∙ routes.json ∙ limits.json}
τ{Output} ≔ emit.render.publish{agent.response ∙ logs ∙ status}
:: ∎
```

## Deployment

### VPS Setup

```bash
# 1. Clone repository
git clone https://github.com/LLMasterDesign/ZENS3N.git
cd ZENS3N/3OX.Ai/3OX.BUILDER
cd 3OX.BUILDER

# 2. Install dependencies
bun install

# 3. Build and install CLI globally
make install-cli
# or manually:
# cargo build --release --bin 3ox
# sudo cp target/release/3ox /usr/local/bin/

# 4. Verify installation
3ox help

# 5. Use from any directory
cd /path/to/agent
3ox
```

### GitHub Distribution

```bash
# Package for distribution
tar -czf 3ox-builder-v1.0.0.tar.gz 3OX.BUILDER/

# Or zip
zip -r 3ox-builder-v1.0.0.zip 3OX.BUILDER/
```

## Troubleshooting

### Build Issues

**Rust not found:**
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

**Bun not found:**
```bash
curl -fsSL https://bun.sh/install | bash
```

### Runtime Issues

**Cube not found:**
- Ensure `.3ox/` directory exists in target path
- Run setup if missing: `ruby 3OX.BUILD/setup-3ox.rb <path> <name> <type>`

**Sparkfile missing:**
- Page 3 will prompt for setup automatically
- Or run setup script manually

**Permission errors:**
- Ensure executable permissions: `chmod +x boot/target/release/vec3-boot`
- Check Ruby script permissions: `chmod +x 3OX.BUILD/setup-3ox.rb`

:: ∎ //▚▚▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂

## License
```r
PROPRIETARY :: Copyright (C) 2025 
▛▞// Z E N S 3 N . S Y S T E M S ⫎▸ - 
Author :: Lucius Larz Master
```


///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂〘・.°𝚫〙