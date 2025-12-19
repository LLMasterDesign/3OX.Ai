# GEM.PROFILES - Personality & Behavior Overlays

**Purpose**: Behavior modifiers that integrate into .3ox systems  
**Type**: Personality/tone configuration overlays  
**Status**: Concept defined, integration mechanism TBD

## ▛▞ WHAT ARE GEM PROFILES? ::

**GEM Profiles** are small configuration overlays that alter agent personality and behavior without changing the base implementation.

**The Pattern**:
```
Base Implementation (RAW.3ox or CORE.3ox)
    +
GEM Profile (Chatty, Reserved, Formal, etc)
    =
Customized .3ox System
```

### Example Combinations

**RAW.3ox + Chatty Assistant Gem**
→ Ruby/Rust engine with friendly, talkative personality

**CORE.3ox + Reserved Professional Gem**
→ Python engine with terse, formal communication

**RAW.3ox + Technical Expert Gem**
→ Ruby/Rust engine with detailed technical explanations

:: ∎

## ▛▞ PROFILE TYPES (TO BUILD) ::

**Communication Style**:
- **Chatty** - Friendly, verbose, explains everything
- **Reserved** - Terse, minimal, gets to the point
- **Formal** - Professional, structured responses
- **Technical** - Detailed technical explanations

**Behavior Traits**:
- **Cautious** - Asks before operations, risk-averse
- **Decisive** - Acts with confidence, minimal confirmation
- **Teaching** - Explains reasoning, educational tone
- **Executor** - Just do it, minimal commentary

**Domain Focus**:
- **Developer** - Code-focused, git-aware
- **Business** - ROI-focused, efficiency-minded
- **Creative** - Idea-generating, exploratory
- **Analyst** - Data-driven, metrics-focused

:: ∎

## ▛▞ INTEGRATION (TBD) ::

**How GEM profiles integrate into .3ox systems:**

**Option A - Configuration Merge**:
```json
// In brain.rs or tools.yml
"gem_profile": "chatty-assistant",
"personality_traits": {
  "verbosity": "high",
  "confirmation": "minimal",
  "tone": "friendly"
}
```

**Option B - Instruction Overlay**:
```rust
// In brain.rs
instructions: BASE_INSTRUCTIONS + GEM_OVERLAY
```

**Option C - Separate Gem File**:
```
.3ox/
├── brain.rs
├── tools.yml
└── personality.gem  ← Profile configuration
```

**To Determine**: Best integration method for modularity and clarity

:: ∎

## ▛▞ CURRENT STATUS ::

**Defined**: Concept and purpose clear  
**Profiles**: Need to create actual profile files  
**Integration**: Mechanism needs design  
**Testing**: Not yet implemented  

**Next Steps**:
1. Design integration mechanism
2. Create first profile (Chatty Assistant)
3. Test with RAW.3ox base
4. Document pattern for creating new profiles

:: ∎

**Concept**: Clear ✓  
**Implementation**: Pending  
**Location**: 3OX.BUILD/GEM.PROFILES/

:: ∎
