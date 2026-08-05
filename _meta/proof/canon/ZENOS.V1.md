```r
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: ⧗-25.346 // ZENOS :: GENESIS.CODEX ▞▞

```
```elixir
/// ZenOS is the substrate. PHENO is the kernel language.
/// This document locks semantics. Drift is treated as a fault.
/// Status: ACTIVE  Version: 1.0  Authority: Lucius.Larz

:: ∎
```
```r
# ZENOS GENESIS CODEX

## 0) PRIME INTENT
ZenOS binds meaning to execution through stable lanes and strict operator signatures.
ZenOS is not a vibe engine. ZenOS is an execution substrate.

## 1) CORE AXIOMS
A1. One glyph, one job. No dual meaning.
A2. ρ is always the Purpose Atom.
A3. φ is always the Binder.
A4. τ is always the Target.
A5. Tier is explicit. Unknown tier rejects.
A6. Permissions are structural. Persuasion cannot elevate perms.
A7. Ω is the only persistence authority for registries and append-only audit.
A8. Invocation is explicit via leading ▹.
A9. Declaration is explicit via trailing ▹.

## 2) OPERATOR ABI LAW
### 2.1) Signature Forms
DECLARATION:
▛▞// {Op.Name} :: {lane.sequence} ▹

INVOCATION:
▛▞//▹ {Op.Name} :: {lane.sequence}

### 2.2) Lane Tag Match Rule
If a PHENO.CHAIN lists lanes, the op signature lanes must match lane tags by glyph and order for the required set.
Mismatch fails with E_TAG_MISMATCH.

### 2.3) Termination Marks
:: ∎  closes a structural block
:: 𝜵 closes a responder output capsule

Rule: Structural blocks must end with :: ∎
Rule: Responder frames must end with :: 𝜵

## 3) TIER MODEL
TIER := runtime | persona | concept

runtime: executes tools and side effects
persona: shapes voice and pedagogy, writes drafts, no tool execution
concept: read-only thought lab, no writes, no execution

Tier must be stamped in α{Ignition} and validated by λ{Governance}.

## 4) PERMISSIONS MODEL
PERMS := rwx | rw- | r--

Definitions:
r (read)  : may read inputs, context, contracts, registries, tool metadata
w (write) : may write artifacts, drafts, logs, patches, registry updates
x (exec)  : may execute tools, dispatch side effects, call external runtimes

Canonical mapping:
runtime  -> rwx
persona  -> rw-
concept  -> r--

Hard rule: Ψ{Lens} cannot change perms.
Hard rule: λ{Governance} enforces perms gates.

## 5) LANE SETS
MAIN.3  := [ρ φ τ]
CORE.5  := [ρ φ τ ν λ]
ORCH.EXT := [α Δ Ψ ζ ο Ω]

Tier requirements:
runtime must include CORE.5 plus α and Ω
persona must include MAIN.3 plus Ψ and λ
concept must include MAIN.3

## 6) EXECUTION GATES
Gate.Read  := require_perm{r}
Gate.Write := require_perm{w}
Gate.Exec  := require_perm{x}

Tool execution requires Gate.Exec.
Registry writes require Gate.Write and must occur inside Ω{Commit}.
External dispatch requires Gate.Exec and must be logged by λ{Governance}.

## 7) FAILURE CODES
E_TAG_MISMATCH
E_UNKNOWN_TIER
E_MISSING_REQUIRED_LANES
E_MISSING_REQUIRED_FIELDS
E_PERM_DENIED_READ
E_PERM_DENIED_WRITE
E_PERM_DENIED_EXEC
E_COMMIT_VIOLATION
E_SCHEMA_INVALID
E_CONTRACT_INVALID

:: ∎


# PHENO LANE REGISTRY

## 8) REGISTRY RULES
R1. Lowercase Greek is runtime lanes and attached behaviors.
R2. Uppercase Greek is meta orchestration, lifecycle, global constraint lenses.
R3. A glyph entry is immutable per version. Changes require version bump and migration note.
R4. Lane invariants are enforced by the linter and by runtime policy.

## 9) LANE DEFINITIONS

### 9.1) ρ PURPOSE ATOM
glyph: ρ
name: Purpose.Atom
class: lane.runtime
invariant: carried unit of executable meaning
allowed_kinds: msg | state | tokens | concept
required_fields:
- kind
- id.trace
- id.op
- payload
forbidden:
- implicit execution
- silent schema mutation
canonical_forms:
- ρ.msg   (runtime)
- ρ.state (persona)
- ρ.tokens (concept)
notes:
- ρ may have stages: ρ.in, ρ.norm, ρ.proof, ρ.out
- stages do not redefine ρ, they qualify it

### 9.2) φ BINDER
glyph: φ
name: Binder
class: lane.runtime
invariant: maps ρ into resolvable action space using contracts
may_reference:
- tools.yml
- routes.json
- limits.toml
- Lex.Registry
required_fields:
- contract.sources
- resolver.rules
forbidden:
- final output claims
- permission escalation
notes:
- φ binds what is allowed, not what is desired

### 9.3) τ TARGET
glyph: τ
name: Target
class: lane.runtime
invariant: declares emission and dispatch shape
required_fields:
- result.mode
allowed_result_modes:
- render
- publish
- dispatch
- outcome.proof
forbidden:
- tool execution without x permission
notes:
- τ is where outputs are shaped, not where meaning is invented

### 9.4) ν RESILIENCE
glyph: ν
name: Resilience
class: lane.runtime
invariant: stability loop, fallback, verification, dead-letter
required_fields:
- retry.policy
- default.policy
allowed:
- π loop operator for re-validation
forbidden:
- bypassing λ governance
notes:
- ν exists so runtime stays predictable under failure

### 9.5) λ GOVERNANCE
glyph: λ
name: Governance
class: lane.runtime
invariant: safety, audit, policy enforcement, logging, redaction
required_fields:
- tier.check
- perms.check
- audit.trace
allowed:
- pii.redact
- allowlist.tools
forbidden:
- silent policy disable
notes:
- λ is the gatekeeper for rwx and tool execution

### 9.6) α IGNITION
glyph: α
name: Ignition
class: lane.meta
invariant: session stamp, trace, authority, tier, perms
required_fields:
- stamp.time
- trace.id
- authority.scope
- tier.mark
- perms.mask
forbidden:
- missing trace
notes:
- α is the start of accountability

### 9.7) Δ PATCH
glyph: Δ
name: Patch
class: lane.meta
invariant: diff and migration of schemas, routes, lex
allowed:
- schema.migrate
- routes.patch
- lex.upgrade
forbidden:
- direct execution
notes:
- Δ changes rules, it does not run actions

### 9.8) Ψ LENS
glyph: Ψ
name: Lens
class: lane.meta
invariant: persona, style, affect constraints
allowed:
- persona.mask
- style.rules
- output.frame
forbidden:
- perms mutation
- routing mutation
notes:
- Ψ shapes voice, not authority

### 9.9) ζ PULSE
glyph: ζ
name: Pulse
class: lane.meta
invariant: trigger cadence, watchers, tick budget
allowed:
- queue triggers
- file triggers
- cron triggers
forbidden:
- uncontrolled loops
notes:
- ζ is Station DNA

### 9.10) ο CAPSULE
glyph: ο
name: Capsule
class: lane.meta
invariant: materialized artifact, frozen compiled unit, hashable
required_fields:
- capsule.form
- hash.content
allowed:
- cache keys
- replay handles
forbidden:
- mutable capsule after Ω commit
notes:
- ο enables replay and determinism

### 9.11) Ω COMMIT
glyph: Ω
name: Commit
class: lane.meta
invariant: finalize, persist, seal
allowed:
- persist.registry
- persist.logs
- persist.artifacts
- seal.audit.append_only
forbidden:
- persistence outside Ω
notes:
- Ω is the only write authority for registries and audit seals

:: ∎


# PHENO KERNEL TEMPLATE

## 10) MAIN.3 TEMPLATE
▛▞// {Op.Name} :: ρ{Input}.φ{Bind}.τ{Output} ▹
▛///▞ PHENO.CHAIN
ρ{Input} ≔ ingest.normalize.validate{payload}
φ{Bind}  ≔ map.resolve.contract{sources}
τ{Output} ≔ emit.render.publish{channels}
:: ∎

## 11) CORE.5 TEMPLATE
▛▞// {Op.Name} :: ρ{Input}.φ{Bind}.τ{Output}.ν{Resilience}.λ{Governance} ▹
▛///▞ PHENO.CHAIN
ρ{Input} ≔ ingest.normalize.validate{payload}
φ{Bind}  ≔ map.resolve.contract{tools.yml ∙ routes.json ∙ limits.toml}
τ{Output} ≔ emit.render.publish{agent_response ∙ 3ox.log}
ν{Resilience} ≔ default.retry.verify{dlq:on}
λ{Governance} ≔ safety.audit.log{pii:redact ∙ perms:enforce}
:: ∎

## 12) ORCHESTRA EXTENDED TEMPLATE
▛▞// {Op.Name} :: α{Ignition}.ρ{Input}.φ{Bind}.Δ{Patch}.τ{Output}.ν{Resilience}.λ{Governance}.Ψ{Lens}.ζ{Pulse}.ο{Capsule}.Ω{Commit} ▹
▛///▞ PHENO.CHAIN
α{Ignition} ≔ stamp.trace.authorize.tier.perms
ρ{Input}    ≔ ingest.normalize.validate
φ{Bind}     ≔ map.resolve.contract
Δ{Patch}    ≔ diff.migrate.upgrade
τ{Output}   ≔ emit.render.publish
ν{Resilience} ≔ default.retry.verify
λ{Governance} ≔ safety.audit.log
Ψ{Lens}     ≔ shape.voice.affect
ζ{Pulse}    ≔ tick.watch.observe
ο{Capsule}  ≔ materialize.freeze.hash
Ω{Commit}   ≔ finalize.persist.seal
:: ∎


```