# How to Build a .3ox System

## Quick Start

```bash
ruby 3OX.BUILD/setup-3ox.rb <target_dir> <agent_name> <brain_type>
```

Example:
```bash
ruby 3OX.BUILD/setup-3ox.rb MyProject GUARDIAN Sentinel
```

This creates:
```
MyProject/.3ox/
├── brain.rs        (agent config)
├── tools.yml       (tools registry)
├── limits.json     (resource limits)
├── routes.json     (output routing)
└── run.rb          (runtime)
```

## Brain Types

- **Citadel** - Command orchestrator
- **Sentinel** - Guardian/sync
- **Alchemist** - Creator/builder
- **Lighthouse** - Knowledge/library

## Templates

All templates in `TEMPLATES/` folder - customize as needed.

:: ∎

