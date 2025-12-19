///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::
▛//▞▞ ⟦⎊⟧ :: ⧗-25.131 // INSTALL :: 3OX.BUILDER ▞▞
▛▞// Installation.Guide :: ρ{Input}.φ{Bind}.τ{Output} ▹
//▞⋮⋮ ⟦📦⟧ :: [install] [setup] [dependencies] [prerequisites] [⊢ ⇨ ⟿ ▷]
⫸ 〔runtime.install.context〕

```elixir
/// Status: [ACTIVE] | Version: 1.0.0 | Authority: Lucius.Larz | Created: 2025.12.13
/// Installation guide for 3OX.BUILDER on Linux/VPS.
```

## Prerequisites

### Required Software

**Rust (2021 edition or later)**
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Verify installation
rustc --version
cargo --version
```

**Bun (>=1.0.0) or Node.js (>=18.0.0)**
```bash
# Install Bun (recommended)
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc

# Or install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
bun --version
# or
node --version
npm --version
```

**Ruby (>=3.2.0)**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y ruby-full

# Or use rbenv for version management
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
rbenv install 3.2.0
rbenv global 3.2.0

# Verify installation
ruby --version
```

## Installation Steps

### 1. Clone or Download

```bash
# From GitHub
git clone https://github.com/LLMasterDesign/ZENS3N.git
cd ZENS3N/3OX.Ai/3OX.BUILDER

# Or extract from archive
tar -xzf 3ox-builder-v1.0.0.tar.gz
cd 3OX.BUILDER
```

### 2. Install Dependencies

**Using Bun (recommended):**
```bash
bun install
```

**Using NPM:**
```bash
npm install
```

### 3. Build Rust Components

```bash
# Build workspace
cargo build --release

# Or use Bun script
bun run compile-run.bun
```

### 4. Verify Installation

```bash
# Check binary exists
ls -la boot/target/release/vec3-boot

# Test run
./boot/target/release/vec3-boot --help
```

## VPS-Specific Setup

### System Dependencies

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  curl \
  git \
  pkg-config \
  libssl-dev

# CentOS/RHEL
sudo yum groupinstall -y "Development Tools"
sudo yum install -y curl git openssl-devel
```

### Environment Variables

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
```

### Permissions

```bash
# Make scripts executable
chmod +x compile-run.bun
chmod +x 3OX.BUILD/setup-3ox.rb
chmod +x sirius.clock.rb
```

## Troubleshooting

### Rust Installation Issues

**"rustup: command not found"**
```bash
# Re-run installer
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

**Build errors:**
```bash
# Update Rust
rustup update

# Clean build
cargo clean
cargo build --release
```

### Bun/Node Issues

**Bun not found:**
```bash
# Reinstall Bun
curl -fsSL https://bun.sh/install | bash
export PATH="$HOME/.bun/bin:$PATH"
```

**Node version too old:**
```bash
# Use nvm to install Node 18+
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
nvm use 18
```

### Ruby Issues

**Ruby version too old:**
```bash
# Use rbenv
rbenv install 3.2.0
rbenv global 3.2.0
ruby --version
```

**Missing gems:**
```bash
# Install fileutils (usually included)
# No external gems required for setup-3ox.rb
```

## Quick Test

```bash
# Build and run
bun run compile-run.bun

# Should show:
# - Page 1: Splash screen
# - Page 2: Cube validation
# - Page 3: Interactive menu (or setup prompts)
```

## Next Steps

After installation:
1. Read `START_HERE.md` for quick start guide
2. Read `README.md` for full documentation
3. Run `bun compile-run.bun` to start

:: 𝜵 //▚▚▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂

