# AGENTS.md

## Cursor Cloud specific instructions

### Overview

3OX.Ai is a kernel-style architecture for AI agents with a Rust workspace (CLI + TUI boot loader + core library) and Ruby runtime. No external services (databases, Docker, etc.) are required for local development.

### Build & Test

All Rust build commands run from `/workspace/3OX.BUILDER/`:

- `cargo build --release` — builds all workspace members (vec3-boot, 3ox CLI, brains-3ox-core)
- `cargo test` — runs all tests
- `cargo clippy` — lint check (warnings only, no errors expected)

Binaries output to `3OX.BUILDER/target/release/` (NOT `boot/target/release/` as `compile-run.bun` assumes).

### Running the Agent Runtime

From workspace root (`/workspace`):

- `ruby .3ox/run.rb once noop` — run a synchronous noop job (validates Ruby runtime)
- `ruby .3ox/run.rb status` — show station status JSON
- `/workspace/3OX.BUILDER/target/release/3ox help` — show CLI help

### Important Gotchas

1. **Rust version**: The workspace requires Rust 1.85+ due to dependencies using `edition2024`. Run `rustup default stable` if you see `feature edition2024 is required` errors.
2. **`compile-run.bun` binary path mismatch**: The script references `./boot/target/release/vec3-boot` but Cargo workspace builds to `./target/release/vec3-boot`. Use `cargo build --release` directly and run from `target/release/`.
3. **`std::fs::exists` API**: On Rust 1.85+, `std::fs::exists()` returns `Result<bool>`, not `bool`. The code uses `.unwrap_or(false)` to handle this.
4. **vec3-boot is a TUI**: The vec3-boot binary uses crossterm for full terminal UI (clears screen, draws animated splash). Best tested with `timeout 10` prefix in non-interactive contexts.
5. **No external dependencies required**: `package.json` has zero dependencies. Bun is optional (only used as a convenience build runner). Ruby stdlib is sufficient (no gems needed).
