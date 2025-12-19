# CORE.3ox LEXICON
**Purpose:** Terminology guide for .3ox framework  
**Version:** v1.1.0

---

## Core Concepts

**3ox.set**  
A complete, self-contained AI agent package including runtime, configuration, and license system.

**Brain**  
Agent configuration defining personality, rules, and behavior. Written in Rust for speed and compiled to `brain.exe`.

**Spine**  
Configuration files that support the brain: tools.yml, routes.json, limits.json

**Legs**  
The runtime script (`run.rb`) that executes operations using brain + spine configuration.

**Key**  
Activation file (`3ox.key`) that unlocks the agent. Machine-bound and cryptographically signed.

---

## Agent Types

**Sentinel (Guardian-Synchronizer)**  
Focus: Safety, validation, atomic operations  
Used in: CORE.3ox, file management, backup systems

**Alchemist (Creator-Architect)**  
Focus: Rapid deployment, prototyping, building  
Used in: Development, CI/CD, deployment systems

**Lighthouse (Librarian-Weaver)**  
Focus: Knowledge management, semantic connections  
Used in: Documentation, note-taking, knowledge bases

---

## Operations

**File Validation**  
Checking file existence, integrity (hash), and size limits before processing.

**Receipt Generation**  
Creating cryptographic proof of operation with timestamp, hash, and audit info.

**Routing**  
Sending operation results to specific destinations based on operation type.

**Surgical Edit**  
Editing specific line ranges without exposing or parsing full file content.

**Batch Mode**  
Running multiple operations in one process startup for speed.

---

## Security Terms

**Machine Binding**  
Locking license key to specific computer hardware fingerprint.

**Cryptographic Signature**  
SHA256 hash proving key hasn't been tampered with.

**Expiration Date**  
Date after which license key becomes invalid.

**Activation Status**  
ACTIVATED = key is valid, DEACTIVATED = key is revoked

---

## File Types

**`.rs` (Rust)**  
Compiled brain configuration for speed and security.

**`.rb` (Ruby)**  
Runtime scripts for operations.

**`.json` (JSON)**  
Fast configuration files (routes, limits).

**`.yml` (YAML)**  
Human-readable configuration (tools).

**`.log` (Log)**  
Append-only operation logs with timestamps.

---

## Hashing

**xxHash64**  
Fast non-cryptographic hash for file fingerprinting.

**SHA256**  
Cryptographic hash for signatures and security.

**Hash Truncation**  
Using first 16 characters of hash for display (full hash stored).

---

## Outputs

**0ut.3ox/**  
Default output folder for all generated files and receipts.

**receipts.log**  
Chronological log of all operations with hashes.

**3ox.log**  
Detailed operation log with agent sigils and routing info.

**Routed Receipts**  
Individual receipt files created in destination folders.

---

## Compliance

**Offline Capable**  
Software operates without internet connection, no data leaves machine.

**HIPAA/GDPR Compliant**  
No third-party processing, data stays on-premise.

**Audit Trail**  
Cryptographic receipts provide court-admissible evidence.

**Data Minimization**  
Surgical operations expose only necessary data, not full files.

---

**For more info:** See README.md and EXAMPLES.md

:: ∎

