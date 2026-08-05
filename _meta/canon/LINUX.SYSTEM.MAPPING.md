///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::
▛//▞▞ ⟦⎊⟧ :: ⧗-26.152 // CODEX :: 3OX Linux System Mapping ▞▞
▛▞// 3OX.Linux.Mapping :: ρ{Structure}.φ{Analyze}.τ{Document} ▹
//▞⋮⋮ ⟦📦⟧ :: [codex] [architecture] [linux.mapping] [system.function] [⊢ ⇨ ⟿ ▷]
⫸ 〔codex.architecture.context〕

```elixir
/// Status: [CANON] | Category: architecture | Author: Lucius.Larz
/// Created: 2026-01-07 | Schema: [0xA4] | Trace.ID: 3ox.linux.mapping.v1.0
/// Comprehensive mapping of 3OX folders to Linux system functions
```

#### ▛///▞ SUMMARY :: 3OX Linux System Mapping ::

Complete mapping of 3OX folder structure to Linux system equivalents, showing how 3OX acts as a Linux-like operating system for AI agents and operations.

**Purpose**: Understand how each folder functions like a Linux system component, enabling 3OX to operate as a complete OS.

:: ∎

#### ▛///▞ SOURCE ::

```toml
[source]
analysis_date = "2026-01-07"
system_version = "3OX v1.0"
base_structure = "CMD.BRIDGE"
reference_docs = [
  "CMD.CENTER.ID",
  "CMD.OPS.ID",
  "CORE.ID",
  ".3ox/sparkfile.md",
  ".3ox/vec3/rc/3ox.rc"
]
```

:: ∎

#### ▛///▞ DETAILS :: Complete Folder Mapping ::

## ROOT LEVEL: CMD.BRIDGE (Linux: `/` root)

**Function**: System root - all operations start here
**Linux Equivalent**: `/` (root filesystem)
**Purpose**: Base of all operations, coordination hub

---

## .3OX/ (Linux: `/etc` + `/usr` + `/var`)

**Function**: Agent desktop and runtime
**Linux Equivalent**: `/etc` (config) + `/usr` (programs) + `/var` (runtime data)
**Purpose**: Core agent configuration and runtime

### Structure:
```
.3ox/
├── sparkfile.md      # Agent spec (like /etc/os-release)
├── brains.rs         # Controller source
├── tools.yml         # Capabilities (like /etc/services)
├── routes.json       # Routing (like /etc/hosts)
├── limits.toml       # Resource limits (like /etc/security/limits.conf)
├── keys/             # Secrets (like /etc/ssl/private)
└── vec3/             # Runtime system (like /usr + /var)
```

**Key Files**:
- `sparkfile.md` - Agent identity and specification
- `3ox.log` - System log (like `/var/log/syslog`)

---

## .3ox/vec3/ (Linux: `/usr` + `/var` combined)

**Function**: Runtime system - programs and variable data
**Linux Equivalent**: `/usr` (programs) + `/var` (variable data)
**Purpose**: All runtime operations

### vec3/bin/ (Linux: `/usr/bin`)

**Function**: Executable binaries
**Linux Equivalent**: `/usr/bin` (user binaries)
**Purpose**: Compiled programs (brain.exe, 3ox executable)
**Contains**: 
- `3ox` - Main executable
- `3ox.exe` - Windows executable
- `brains_rs/` - Rust brain source

### vec3/lib/ (Linux: `/usr/lib`)

**Function**: Libraries and modules
**Linux Equivalent**: `/usr/lib` (shared libraries)
**Purpose**: Reusable code modules

**Subdirectories**:
- `core/` - Core system modules (registry, trace)
  - `registry.rb` - Service registry (like systemd service registry)
  - `trace.rb` - Tracing/logging system
- `ops/` - Operations modules
- `processors/` - Data processors
- `providers/` - LLM providers
- `schemas/` - Data schemas (Z3N.SPEC.md, zen.spec)
- `z3n/` - Z3N runtime modules

### vec3/rc/ (Linux: `/etc/init.d` + `/etc/systemd`)

**Function**: Run Control - service management
**Linux Equivalent**: `/etc/init.d` + `/etc/systemd/system`
**Purpose**: Service lifecycle management

**Key Components**:
- `3ox.rc` - Main service controller (like `systemctl`)
  - `start` - Start services
  - `stop` - Stop services
  - `status` - Check status
  - `list` - List all services
- `start.d/` - Start scripts (like `/etc/init.d`)
- `stop.d/` - Stop scripts
- `status.d/` - Status check scripts
- `secrets/` - Protected secrets (like `/etc/ssl/private`)
- `dispatch/` - Message dispatch system
- `responder/` - Response handlers
- `run/` - Runtime executors
- `warden/` - Security/guard system
- `tape/` - Audit trail system

**Service Management**:
```bash
ruby vec3/rc/3ox.rc start <service>  # Like: systemctl start <service>
ruby vec3/rc/3ox.rc stop <service>   # Like: systemctl stop <service>
ruby vec3/rc/3ox.rc status            # Like: systemctl status
```

### vec3/var/ (Linux: `/var`)

**Function**: Variable data - runtime state
**Linux Equivalent**: `/var` (variable data)
**Purpose**: All runtime state and data

**Subdirectories**:
- `state/` - System state (like `/var/lib`)
  - `registry.json` - Service registry state
- `log/` - Logs (like `/var/log`)
  - `vec3.trace.log` - System trace log
- `queue/` - Message queues (like `/var/spool`)
- `sessions/` - Active sessions (like `/var/run`)
- `inbox/` - Incoming messages
- `handoff/` - Process handoffs
- `models/` - Model cache
- `wrkdsk/` - Work desk state

---

## !CMD.CENTER/ (Linux: `/opt` + `/srv`)

**Function**: Operational coordination hub
**Linux Equivalent**: `/opt` (optional software) + `/srv` (service data)
**Purpose**: Central command and control

**Key Directories**:

### !CMD.OPS/ (Linux: `/etc` + `/usr/share/doc`)

**Function**: Operations hub - immutable laws
**Linux Equivalent**: `/etc` (config) + `/usr/share/doc` (documentation)
**Purpose**: System laws, documentation, operations

**Structure**:
- `law/` - Immutable laws (like `/etc` config files)
  - `limits.toml` - Rate limits (like `/etc/security/limits.conf`)
  - `routes.json` - Routing rules (like `/etc/iproute2/rt_tables`)
  - `id.card.spec.md` - ID card specification
  - `imprint.card.format.md` - Imprint format
- `Codex/` - System documentation (like `/usr/share/doc`)
  - `primitives/` - Core primitives
  - `features/` - Feature documentation
  - `architecture/` - Architecture docs
- `Logbook/` - Operational logs (like `/var/log`)
  - `CAPTAINS.LOG.md` - Main log
  - `CAPTAINS.LOG/` - Structured log (finds/, plans/, tasks/)
- `Operations/` - Operation scripts (like `/usr/local/bin`)
- `Pipeline/` - Pipeline processing (like `/usr/libexec`)
- `Toolkits/` - Operation toolkits (like `/usr/share`)
- `Promptbook/` - System prompts (like `/usr/share/doc`)

### !CORE/ (Linux: `/var/lib` + `/etc`)

**Function**: Core registry and system files
**Linux Equivalent**: `/var/lib` (state) + `/etc` (config)
**Purpose**: System registry and core data

**Structure**:
- `REGISTRY/` - Service registry (like `/var/lib/systemd`)
  - `BASE.REGISTRY.yml` - Base registry
  - `SERVICE.REGISTRY.yml` - Service registry
  - `reg.rb` - Registry manager
- `CAPTAINS.DESK/` - Captain's desk (like `/root` for admin)
  - `CAPTAINS.LOG.md` - Main long-running log
  - `update_log.rb` - Log updater script
- `postgresql/` - Database schemas (like `/var/lib/postgresql`)
- `redis/` - Redis configs (like `/etc/redis`)

### 7HE.VAULT/ (Linux: `/var/lib` + `/usr/share`)

**Function**: Memory and knowledge storage
**Linux Equivalent**: `/var/lib` (data) + `/usr/share` (shared data)
**Purpose**: Long-term memory, schemas, knowledge base

### 7HE.LIBRARY/ (Linux: `/usr/share/doc`)

**Function**: External knowledge and research
**Linux Equivalent**: `/usr/share/doc` (documentation)
**Purpose**: External knowledge, research, references

### 3OX.Ai/ (Linux: `/opt`)

**Function**: Large data realm
**Linux Equivalent**: `/opt` (optional software/data)
**Purpose**: Large-scale data storage and processing

### AGENTS/ (Linux: `/usr/libexec`)

**Function**: Agent directory
**Linux Equivalent**: `/usr/libexec` (executables for other programs)
**Purpose**: Agent definitions and configurations

### STATIONS/ (Linux: `/etc/systemd/system`)

**Function**: Station definitions
**Linux Equivalent**: `/etc/systemd/system` (service units)
**Purpose**: Station/service definitions

### TOOLKIT/ (Linux: `/usr/bin` + `/usr/share`)

**Function**: Discovery and routing tools
**Linux Equivalent**: `/usr/bin` (tools) + `/usr/share` (shared tools)
**Purpose**: System tools and utilities

### SCRIPTS/ (Linux: `/usr/local/bin`)

**Function**: Global essential scripts
**Linux Equivalent**: `/usr/local/bin` (local executables)
**Purpose**: Daily-use scripts and utilities

### PROJECTS/ (Linux: `/home` + `/srv`)

**Function**: Project tracking
**Linux Equivalent**: `/home` (user projects) + `/srv` (service projects)
**Purpose**: Active project management

---

## SYSTEM OPERATIONS (Linux Equivalents)

### Service Management

**3OX**: `ruby vec3/rc/3ox.rc <command> <service>`
**Linux**: `systemctl <command> <service>`

**Commands**:
- `start` - Start service (like `systemctl start`)
- `stop` - Stop service (like `systemctl stop`)
- `status` - Check status (like `systemctl status`)
- `list` - List services (like `systemctl list-units`)

### Registry System

**3OX**: `!CORE/REGISTRY/` - Service registry
**Linux**: `/var/lib/systemd/` - systemd service registry

**Files**:
- `BASE.REGISTRY.yml` - Base services (like systemd units)
- `SERVICE.REGISTRY.yml` - Service definitions (like `.service` files)

### Logging System

**3OX**: 
- `.3ox/3ox.log` - Main system log
- `vec3/var/log/vec3.trace.log` - Trace log
- `!CMD.OPS/Logbook/CAPTAINS.LOG.md` - Operational log

**Linux**:
- `/var/log/syslog` - Main system log
- `/var/log/messages` - System messages
- `/var/log/daemon.log` - Daemon log

### Configuration Management

**3OX**: `!CMD.OPS/law/` - Immutable laws
**Linux**: `/etc/` - System configuration

**Key Files**:
- `limits.toml` - Resource limits (like `/etc/security/limits.conf`)
- `routes.json` - Routing (like `/etc/iproute2/rt_tables`)

### Process Management

**3OX**: `vec3/rc/` - Run control
**Linux**: `/etc/init.d/` + `/etc/systemd/` - Init system

**Components**:
- `start.d/` - Startup scripts (like `/etc/init.d/`)
- `stop.d/` - Shutdown scripts
- `status.d/` - Status scripts

---

## SYSTEM ARCHITECTURE SUMMARY

```
CMD.BRIDGE (/)                    # Root
├── .3ox/                         # /etc + /usr + /var
│   ├── vec3/                     # Runtime system
│   │   ├── bin/                  # /usr/bin
│   │   ├── lib/                  # /usr/lib
│   │   ├── rc/                   # /etc/init.d + /etc/systemd
│   │   └── var/                  # /var
│   └── keys/                     # /etc/ssl/private
└── !CMD.CENTER/                  # /opt + /srv
    ├── !CMD.OPS/                 # /etc + /usr/share/doc
    ├── !CORE/                    # /var/lib + /etc
    ├── 7HE.VAULT/                # /var/lib + /usr/share
    ├── 7HE.LIBRARY/              # /usr/share/doc
    ├── 3OX.Ai/                   # /opt
    ├── AGENTS/                   # /usr/libexec
    ├── STATIONS/                 # /etc/systemd/system
    ├── TOOLKIT/                  # /usr/bin + /usr/share
    ├── SCRIPTS/                  # /usr/local/bin
    └── PROJECTS/                 # /home + /srv
```

---

## KEY DIFFERENCES FROM LINUX

1. **Read-Only Root**: CMD.CENTER root is read-only (like `/` but immutable)
2. **ID Cards**: Folder validation system (no Linux equivalent)
3. **Imprint System**: Runtime law compilation (like `/proc` but for governance)
4. **Registry System**: YAML-based service registry (like systemd but simpler)
5. **vec3 Runtime**: Combined `/usr` and `/var` in one structure

---

## OPERATIONAL FLOW

1. **Boot**: `.3ox/sparkfile.md` defines agent (like `/etc/os-release`)
2. **Init**: `vec3/rc/3ox.rc` starts services (like systemd)
3. **Registry**: `!CORE/REGISTRY/` tracks services (like systemd units)
4. **Operations**: `!CMD.OPS/` provides laws and tools (like `/etc` + `/usr`)
5. **Runtime**: `vec3/var/` stores state (like `/var`)
6. **Logging**: Multiple log locations (like `/var/log`)

:: ∎

#### ▛///▞ SCHEMA ::

```toml
[linux_mapping]
root = "CMD.BRIDGE"
desktop = ".3ox"
runtime = "vec3"
coordination = "!CMD.CENTER"
operations = "!CMD.OPS"
core = "!CORE"
memory = "7HE.VAULT"
knowledge = "7HE.LIBRARY"
data = "3OX.Ai"
agents = "AGENTS"
stations = "STATIONS"
tools = "TOOLKIT"
scripts = "SCRIPTS"
projects = "PROJECTS"

[linux_equivalents]
root = "/"
desktop = "/etc + /usr + /var"
runtime_bin = "/usr/bin"
runtime_lib = "/usr/lib"
runtime_rc = "/etc/init.d + /etc/systemd"
runtime_var = "/var"
coordination = "/opt + /srv"
operations = "/etc + /usr/share/doc"
core = "/var/lib + /etc"
memory = "/var/lib + /usr/share"
knowledge = "/usr/share/doc"
data = "/opt"
agents = "/usr/libexec"
stations = "/etc/systemd/system"
tools = "/usr/bin + /usr/share"
scripts = "/usr/local/bin"
projects = "/home + /srv"
```

:: ∎

#### ▛///▞ USAGE ::

**Understanding System Structure**:
```bash
# Service management
ruby .3ox/vec3/rc/3ox.rc list        # Like: systemctl list-units
ruby .3ox/vec3/rc/3ox.rc start warden # Like: systemctl start warden

# Registry access
cat !CMD.CENTER/!CORE/REGISTRY/BASE.REGISTRY.yml  # Like: systemctl list-unit-files

# Log access
tail .3ox/3ox.log                     # Like: tail /var/log/syslog
tail .3ox/vec3/var/log/vec3.trace.log # Like: journalctl -f
```

**System Navigation**:
- `.3ox/` = System configuration and runtime
- `!CMD.CENTER/` = Operational coordination
- `!CMD.OPS/` = Laws and documentation
- `!CORE/` = Registry and core data
- `vec3/` = Runtime system (programs + data)

:: ∎

#### ▛///▞ REFERENCES ::

- CMD.CENTER.ID - Root structure definition
- CMD.OPS.ID - Operations structure
- CORE.ID - Core registry structure
- .3ox/sparkfile.md - Agent specification
- .3ox/vec3/rc/3ox.rc - Service controller
- vec3/var/VEC3.RECOVERY.REPORT.md - System recovery

:: ∎

#### ▛///▞ HISTORY ::

```log
2026-01-07 - Comprehensive mapping created
  - Analyzed all folder structures
  - Mapped to Linux equivalents
  - Documented system functions
  - Created operational flow diagram
```

:: ∎
