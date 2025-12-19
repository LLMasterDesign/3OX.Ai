# 3OX.Ai

Kernel-style architecture for AI agents. Reliable, auditable, state-preserving.

---

## ▛▞ What This Is

3OX is a framework for building AI agents that operate with operating system-level reliability. Instead of fragile prompt chains that lose context, 3OX agents run on a kernel architecture with protected surfaces, immutable rules, and provable operations.

Think systemd for AI agents.

---

## ▛▞ Core Files :: ρ{define}.φ{compile}.τ{run}

Every 3ox agent has **7 core files**. Here's what each one does:

### `sparkfile.md` → The Agent Specification

The comprehensive prompt. Defines identity, capabilities, rules, and behavior.

```markdown
▛▞// VSO.AGENT :: ρ{input}.φ{assess}.τ{guidance} ▹

[ENV]
base        = "${AGENT_WORKSPACE}"
kind        = "3ox.agent"
domain      = "va.claims.management"

[RULES]
- Always ask clarifying questions before acting
- Reference DBQ requirements for every condition
- Track all deadlines with alerts
- Validate evidence before submission
```

### `brain.rs` → Compiled Configuration

Rust config that compiles to an executable. Type-safe rules, not prompt engineering.

```rust
pub const VSO_AGENT_BRAIN: AgentConfig = AgentConfig {
    name: "VSO.AGENT",
    brain: BrainType::Advisor,
    model: "claude-sonnet-4.5",
    max_turns: 20,
};

pub const RULES: &[Rule] = &[
    Rule::StrategicQuestioning,
    Rule::DBQReferenceRequired,
    Rule::DeadlineTracking,
    Rule::EvidenceValidation,
];
```

### `tools.yml` → Tool Registry

What the agent can do. Declarative, auditable.

```yaml
tools:
  - name: FileOrganizer
    function: organize_files(category, files)
    description: Organize files into structured categories

  - name: DeadlineTracker
    function: track_deadline(name, date, alert_days)
    description: Track deadlines with configurable alerts

  - name: WebSearch
    function: search_web(query)
    description: Search for current VA policies
```

### `routes.json` → Operation Routing

Where operations go. Controlled flow.

```json
{
  "routes": {
    "file_operations": "local",
    "web_search": "external",
    "reference_lookup": "vec3/lib",
    "state_write": "vec3/var"
  }
}
```

### `run.rb` → Ruby Runtime

The execution engine. Simple, readable.

```ruby
def execute_operation(op)
  validate_inputs(op)
  result = perform(op)
  write_receipt(op, result)
  log_activity(op, result)
  result
end
```

### `3ox.log` → Activity Log

Everything logged. Structured, traceable.

```
[2025-12-19 00:45:12] ::VSO.Agent
  Operation: evidence_review
  Status: complete
  Details: Reviewed 3 medical records, flagged 1 incomplete
  Receipt: rx_a7f3b2c1
```

---

## ▛▞ vec3 Kernel :: ρ{protect}.φ{route}.τ{persist}

Four protected surfaces for agent backend:

### `vec3/rc/` → Rules & Control

Immutable rules and mutable control knobs.

```markdown
# rules.ref (immutable)
RULE: atomic_operations_only
RULE: always_write_receipts
RULE: validate_before_write

# sys.ref (control knobs)
features:
  web_search: enabled
  file_write: enabled
rate_limits:
  operations_per_minute: 60
```

### `vec3/lib/` → Protected References

Read-only knowledge. The agent's reference library.

```markdown
# dbq-guide.ref
PTSD:
  form: DBQ-PTSD
  requirements:
    - Stressor verification
    - Symptom frequency/severity
    - Functional impairment
  rating_criteria: 0%, 10%, 30%, 50%, 70%, 100%
```

### `vec3/dev/` → Adapters

External bridges. How the agent talks to the world.

```
dev/
├── io/
│   ├── tg/ingress/    # Telegram input
│   └── mq/publish/    # Message queue output
└── ops/
    └── python/exec/   # Python runner
```

### `vec3/var/` → Runtime Data

Receipts, events, in-flight state. The audit trail.

```yaml
# receipts/rx_a7f3b2c1.yml
timestamp: 2025-12-19T00:45:12Z
actor: VSO.Agent
intent: evidence_review
inputs_hash: xxh64:a7f3b2c1d4e5f6a7
outputs: [evidence_report.md]
status: complete
```

---

## ▛▞ Why This Matters :: ρ{problem}.φ{solution}.τ{result}

**Current AI agents:**
- Lose context between sessions
- Can't prove what they did
- Break state on errors
- Drift from original intent

**3OX agents:**
- Preserve state across sessions (`vec3/var`)
- Generate receipts for every action
- Enforce atomic operations with rollback
- Follow immutable rules (`vec3/rc`)

For teams building AI systems that need to be production-ready, auditable, and reliable.

---

## ▛▞ Tier System :: ρ{simple}.φ{kernel}.τ{production}

| Tier | Files | vec3 | Compiles | Best For |
|------|-------|------|----------|----------|
| **T1** | 7 core | None | No | Prototypes, simple agents |
| **T2** | 7 core | rc, lib, var | Yes | Internal tools, structured agents |
| **T3** | 7 core | rc, lib, dev, var | Yes | Production systems, external integrations |

---

## ▛▞ Get Started :: ρ{clone}.φ{configure}.τ{run}

```bash
git clone https://github.com/LLMasterDesign/3OX.Ai.git
cd "3OX.Ai/3OX Agents/VSO Agent"
cat .3ox/sparkfile.md   # See what the agent does
```

**Explore:**
- [VSO Agent](3OX%20Agents/VSO%20Agent/) - Full T3 agent example
- [3OX.BUILDER](3OX.BUILDER/) - Framework and templates

---

## ▛▞ Components :: ρ{agents}.φ{builder}.τ{capsules}

**3OX Agents** - Pre-built, production-ready:
- [VSO Agent](3OX%20Agents/VSO%20Agent/) - Veterans claims advisor

**3OX.BUILDER** - Framework tooling:
- Agent scaffolding
- Brain compilation
- vec3 generators

**Capsules** (Coming) - Portable AI workspaces:
- Package agent + data + state
- Move between environments
- State travels with the agent

---

## ▛▞ Status

**Active Development**  
Version: 1.0.0  
⧗-25.133

MIT License

---

Built for systems that can't afford to lose context.
