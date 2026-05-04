///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.124 // 3OX.AI :: FULL ARCHITECTURE FREEZE ▞▞

```elixir
/// status:[DRAFT] ver:[1.0.0] created:[26.05.04]
/// doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
/// 3OX.AI full architecture freeze — captured verbatim from Lucius's dictation
```

> **Status note (added by repo, not by author):** This is the verbatim spec
> as dictated by Lucius. Three open conflicts with prior canon need ruling
> before this is promoted from DRAFT to ACTIVE. See
> [`_meta/ARCHITECTURE.RECONCILIATION.md`](ARCHITECTURE.RECONCILIATION.md).

---

# 3OX.AI :: FULL ARCHITECTURE SPECS

## 1. IDENTITY

3OX.AI is not a single model.
3OX.AI is a federated agent operating system.

[CANON]
- local-first runtime
- vec3 substrate
- Warden governance
- Queue + Worker orchestration
- Tape proof
- Pulse observability
- Supervisor continuity
- Packs as distributable intelligence units

[CANON]
3OX is not:
- one agent
- a prompt collection
- cron-driven polling automation

## 2. TOP LEVEL STACK

[CANON]
!CMD.BRIDGE  :: host connectivity spine
!CMD.HUB     :: navigation and registry authority
CITADEL.BASE :: home of agents and deployment
.3ox         :: self-contained agent cube
_TRON        :: observer + receipts plane
vec3         :: runtime filesystem geometry

[DERIVED]
3OX.Ai.exe may exist as crown host / launcher / installer shell,
but the real runtime law is the daemon and vec3 architecture, not the filename.

## 3. THE 6 SYSTEM DAEMONS

### 3.1 SUPERVISOR
[CANON]
role ::
- process supervisor
- readiness gate
- starts the other core daemons
- one-for-one restart strategy
- escalates to degraded if needed

inputs ::
- daemon heartbeats
- health checks
- crash signals

outputs ::
- restart action
- readiness state
- SYSTEM_BOOT
- SYSTEM_SHUTDOWN
- DAEMON_READY
- SYSTEM_ONLINE
- SYSTEM_DEGRADED

failure ::
- restart policy
- escalate to degraded

ownership ::
- continuity
- daemon liveness
- arc lifecycle enforcement

### 3.2 WARDEN
[CANON]
role ::
- governance gate
- deny-by-default policy engine
- evaluates rules.ref, limits.toml, allowlists
- enforces write scopes and adapter capabilities

inputs ::
- universal envelope
- requested capabilities
- target paths

outputs ::
- allow / deny
- denial reason
- ACCESS_GRANTED / ACCESS_DENIED
- RULES_ALLOW / RULES_DENY

failure ::
- fail closed
- deny with receipt

ownership ::
- mutation authority
- capability boundaries
- policy law
- rules enforcement on boot

### 3.3 QUEUE
[CANON]
role ::
- durable job intake
- async scheduling
- decouples intent from action
- retries, backoff, delayed jobs, concurrency limits

inputs ::
- jobs from Router / Stations / Scheduler

outputs ::
- job delivery to Workers
- JOB_ENQUEUED / JOB_DEQUEUED / JOB_FAILED

failure ::
- persist jobs
- dead letter
- queue_down -> degraded

ownership ::
- work backlog
- delayed execution
- pressure management

### 3.4 WORKER
[CANON]
role ::
- stateless job execution engine
- executes adapters
- obeys Warden
- emits receipts via Tape
- spins up, does work, dies

inputs ::
- job envelope from Queue

outputs ::
- adapter results
- JOB_STARTED / JOB_FINISHED / JOB_FAILED
- TASK_STARTED / TASK_COMPLETED

failure ::
- bounded retries
- circuit-breaker receipts

ownership ::
- execution
- hot execution context
- per-job cognition surface

### 3.5 TAPE
[CANON]
role ::
- authoritative receipt writer
- append-only proof publisher
- writes local + authoritative receipts
- maintains hash chain / merkle if enabled

inputs ::
- receipt objects from Router / Workers / Stations

outputs ::
- vec3/var/receipts/YYYY/MM/DD/
- _TRON/receipts/YYYY/MM/DD/
- RECEIPT_WRITTEN / PROOF_GENERATED

failure ::
- if receipt write fails -> SYSTEM_DEGRADED
- block non-critical side effects until restored

ownership ::
- truth
- proof
- replayability
- audit chain

### 3.6 PULSE
[CANON]
role ::
- observability stream
- cursor plane
- state / metrics / telemetry exposure
- dashboards and "feeling" of the machine

inputs ::
- internal events
- receipt metadata
- health signals
- stdout / stderr / custom events

outputs ::
- metrics
- alerts
- heartbeat
- HEALTH_REPORT / ALERT / HEARTBEAT

failure ::
- continue degraded
- never block core execution

ownership ::
- visibility
- telemetry
- cursors
- liveness reflection

## 4. PRISM+ POSITION

[CANON]
PRISM+ is not one of the six daemons.
PRISM+ is the output shaping layer between Worker and Station.

runtime ::
- Elixir / BEAM
- isolated node
- hot-loadable snips from vec3/lib/snips/

pipeline ::
1. raw ingest
2. normalization
3. intelligence transform
4. presentation
5. seal

ownership ::
- output contract
- schema validity
- no raw adapter output reaches user

## 5. ARC MODE

[CANON]
ARC defines how often and how much an agent exists.
ARC is enforced by:
- Supervisor for lifecycle
- Warden for resources

vectors ::
- Intensity  :: pulse frequency + worker cpu slice
- Retention  :: tape granularity + vec3/mem depth
- Reactivity :: queue priority + event sensitivity

states ::
1. DORMANT
2. FROZEN
3. COLD
4. WARM
5. PULSE
6. FLOW
7. BURST
8. NOVA
9. ETERNAL

[CANON]
Only system daemons can run in ETERNAL.
Inner ring ::
- Supervisor
- Warden
- Pulse

[CANON]
Default for agents ::
- WARM

## 6. EVENT LAW

[CANON]
3OX is reactive, not polling.
Cron storms and endless polling are architectural failures.

official event sources ::
- FS_EVENT
- QUEUE_EVENT
- RPC_EVENT
- RECEIPT_EVENT
- CLOCK_EVENT

scheduler law ::
- only one Scheduler daemon
- maintains next_due list
- sleeps until next_due
- emits due jobs into Queue
- no per-agent timers

station law ::
- block by default
- wait for real event
- every processed event must produce a receipt

## 7. VEC3 :: FULL GEOMETRY

### 7.1 vec3/rc :: RUN CONTROL
[CANON]
purpose ::
- immutable rules
- mutable config
- boot locks
- binaries

contains ::
- rules.ref
- sys.ref
- boot.lock
- compiled runtime artifacts
- policy.wasm at system scale

governed by ::
- Warden for rule meaning
- Supervisor / boot for startup sequencing

write law ::
- only maintainer or boot process
- not general runtime mutation

### 7.2 vec3/lib :: LIBRARY
[CANON]
purpose ::
- protected read-only packaged logic and references

contains ::
- *.ref
- snips/
- prompts/
- static/

governed by ::
- PRISM+ for snips behavior
- maintainer for content changes

write law ::
- never written at runtime

### 7.3 vec3/dev :: DEVICES
[CANON]
purpose ::
- executable bridge layer
- adapters and drivers
- io and ops surfaces

contains ::
- io/
- ops/
- adapters/
- drivers/
- adapter manifests

governed by ::
- Worker executes through it
- Warden authorizes capability use
- Queue feeds execution demand

write law ::
- capability declared
- side effects must be gated

### 7.4 vec3/var :: VARIABLE STATE
[CANON]
purpose ::
- live state
- receipts mirror
- cursors
- metrics
- append-first runtime evidence

contains ::
- state/
- status.ref
- receipts/YYYY/MM/DD/
- cursors/
- metrics/
- jobs/ optional
- pid
- state.json

governed by ::
- Pulse for metrics/cursors
- Tape for receipt writing authority
- Queue if jobs are filesystem-backed
- Supervisor for state transitions

write law ::
- append-first
- runtime mutable
- authoritative receipts still belong to Tape

### 7.5 vec3/proto :: PROTOCOLS
[CANON]
purpose ::
- gRPC service contracts
- interface definitions
- cross-language agreement surface

contains ::
- *.proto
- service schemas
- transport contracts

governed by ::
- service layer
- Router / Warden / Queue / Worker interoperability

write law ::
- versioned contract surface
- not ad-hoc runtime mutation

### 7.6 vec3/proc :: PROCESS PLANE
[CANON]
purpose ::
- process representation inside the cube
- workers
- queue internals
- internal agents
- self / kernel for L3 depth

contains ::
- workers/
- queue/
- agents/
- self/
- kernel/

governed by ::
- Worker for execution presence
- Queue for local durable flow
- Supervisor for lifecycle continuity

critical distinction ::
- proc is process surface
- Supervisor is lifecycle sovereign

### 7.7 vec3/mem :: AWARENESS
[CANON]
purpose ::
- semantic memory
- indexing
- vector stores
- continuity snapshots

contains ::
- hot/      :: fast temporary active memory
- deep/     :: semantic / vector / long memory
- context/  :: session window snapshots and continuity slices

governed by ::
- agent cognition layer
- retention policy from ARC
- Warden when reads or writes cross declared scopes

critical distinction ::
- var = live operational state
- mem = retained awareness across time

## 8. L1 / L2 / L3

### 8.1 L1 :: LITE
[CANON]
structure ::
- sparkfile.md
- vec3/

capability ::
- services and stations only

use ::
- minimal runtime node
- small observer / service surfaces

### 8.2 L2 :: BASE
[CANON]
structure ::
- sparkfile.md
- brain.rs
- tools.yml
- limits.toml
- routes.json
- 3ox.log
- vec3/

purpose ::
- portable standard agent
- flat fast pack

### 8.3 L3 :: FULL
[CANON]
structure ::
- Spark/
- Brains/
- Toolkit/
- Rules/
- Links/
- Pulse/
- full vec3/

purpose ::
- flagship packs
- extensible deep agents
- multi-modal / multi-runtime / memory-bearing systems

## 9. FOLDER OWNERSHIP MAP

[CANON + DERIVED]
Spark/   ::
- identity
- persona vectors
- mission
- entity declaration roots

Brains/  ::
- logic controllers
- compiled or scripted cognition units
- hot-swappable language substrates

Toolkit/ ::
- capability declarations
- adapters
- plugins

Rules/   ::
- limits.toml
- rules.ref
- governance surface

Links/   ::
- routes.json
- map.toml
- query-to-pointer knowledge graph

Pulse/   ::
- 3ox.log
- local receipts mirror
- telemetry-facing human runtime trace

## 10. LANGUAGE OWNERSHIP

### 10.1 CANON
[CANON]
- Warden enforces rules from rules.ref and limits.toml
- Tape is authoritative receipt writer
- PRISM+ runtime is Elixir / BEAM
- PULSE exposes logs / telemetry / streams
- brains can hotswap across rs / py / ex

### 10.2 CURRENT FREEZE
[DERIVED]
Rust ::
- Warden law
- policy engine
- binary-grade guards
- system-strength execution for constraints

Elixir ::
- Tape truth
- PRISM+ shaping
- high-concurrency stream and transform surfaces

JSONL ::
- Pulse stream representation
- append-first event / log export surface
- not authority

Lisp ::
- symbolic cognition / entity substrate
- hot-loadable behavior law
- Raven / entity cores / symbolic reasoning surface

### 10.3 LISP OWNERSHIP FREEZE
[DERIVED]
Supervisor ::
- owns Lisp host residency
- keeps host alive under ARC

Worker ::
- hot-loads Lisp forms / modules / entity cores
- invokes execution against live host
- does not own eternal continuity

Warden ::
- gates Lisp side effects

PRISM+ ::
- shapes Lisp output for delivery

Tape ::
- seals Lisp outcomes as proof

This is the clean split ::
- Supervisor owns Lisp continuity
- Worker owns Lisp invocation

## 11. UNIVERSAL ENVELOPE

[CANON]
every Router / Warden / Queue / Worker / Adapter call uses one envelope

required input ::
- trace_id
- tid
- ts_in
- caller
- env
- intent.action
- constraints.execution_mode
- constraints.allow_side_effects
- context.pointers optional
- payload

required output ::
- status
- duration_ms
- outputs optional
- error.class optional
- error.pointer optional
- receipt_ref

strict laws ::
- missing trace_id or intent.action fails immediately
- if allow_side_effects=false then Warden denies mutation or outbound net
- trace_id survives full chain

## 12. ROUTER / MAP / POINTER

[CANON]
Router ::
- normalize raw input into envelope
- consult Warden
- match routes.json deterministically
- use map system when needed
- enqueue async jobs
- do not execute side effects directly unless read_only

Map ::
- query -> pointer object
- pointer resolves file slice, line range, hash, version
- hash mismatch -> degraded + re-query + receipt

ownership ::
- Links/ holds route and map declarations
- Router consumes them
- Warden guards execution implications

## 13. RECEIPT LAW

[CANON]
nothing is real until receipted on Tape

receipt storage ::
- vec3/var/receipts/YYYY/MM/DD/
- _TRON/receipts/YYYY/MM/DD/

receipt law ::
- append-only
- write-once
- tamper evident
- only Tape writes authoritative receipts
- logs are support only, not truth

if Tape fails ::
- system degrades
- non-critical side effects blocked

## 14. BOOT SEQUENCE

[CANON]
1. verify canonical locations
2. load vec3/rc/sys.ref
3. load rules.ref
4. register maps
5. start station watchers
6. enable service endpoints
7. emit heartbeat receipt

[DERIVED]
8. self-test golden path
9. self-test denial path
10. mark ready only after proof exists

## 15. GOLDEN PATH :: WHAT WORKING LOOKS LIKE

[CANON]
1. inbound request or file drop
2. Router normalizes envelope
3. Warden gates
4. Queue enqueues
5. Worker executes adapter
6. Tape writes receipt
7. Pulse reports
8. system remains online

golden denial ::
- undeclared capability request
- Warden denies
- Tape writes denial receipt
- system remains stable and observable

fault expectation ::
- Worker crash does not kill kernel
- Supervisor restarts child
- Queue preserves work
- Tape remains authoritative
- Pulse reflects degraded then recovery

## 16. MARKETPLACE / PACK LAW

[CANON]
a Pack is distributable L3 intelligence that must:
- declare capabilities
- declare adapters
- declare write scopes
- include golden-path tests
- be signed
- declare runtime version compatibility

builder commands ::
- scaffold
- validate
- test
- sign
- publish

install law ::
- dry run against golden receipts
- Warden denies undeclared capabilities
- packs are enforceable, not vibes

## 17. CLEAN OWNER SUMMARY

Supervisor ::
- continuity
- readiness
- restart authority
- arc lifecycle

Warden ::
- policy
- scopes
- permissions
- deny-fast mutation control

Queue ::
- durable intake
- retries
- delayed jobs
- work pressure

Worker ::
- execution
- adapters
- hot cognition invocation
- disposable labor

Tape ::
- truth
- receipts
- replay
- audit chain

Pulse ::
- observability
- cursors
- state feeling
- dashboards

PRISM+ ::
- presentation law
- typed output
- snips
- hot shaping

vec3/rc ::
- boot + law + config

vec3/lib ::
- protected references + snips + prompts

vec3/dev ::
- adapters + drivers + io bridges

vec3/var ::
- live mutable runtime state + mirrored receipts

vec3/proto ::
- service contracts

vec3/proc ::
- process topology

vec3/mem ::
- awareness + semantic continuity

## 18. HARD LINES

- proc is part of vec3
- mem is part of vec3
- PRISM+ is not one of the six daemons
- Tape is the sole receipt authority
- Worker is stateless by canon
- Supervisor owns continuity
- no per-agent timer spam
- only Scheduler may emit CLOCK_EVENT
- user agents do not get ETERNAL
- Warden fail-closed is non-negotiable
- logs do not outrank receipts

:: ∎
