///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.124 // _META :: README ▞▞

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[26.05.04]
/// doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
/// _meta/ navigation — cube vs canon split
```

# `_meta/` — what lives here, and why it's split

Top-level `_meta/` does **two** different jobs. They were tangled together
until 26.05.04 when Lucius asked the clarifying question. They are now
split into two subfolders.

## Layout

```
_meta/
├── cube/    ← the project-root cube's _meta (mirrors .3ox/_meta/ pattern)
│   ├── WHOAMI.md                  project identity (project=3OX.Ai, framework)
│   ├── NAMING.CONTRACT.toml       framework-level naming
│   ├── SESSION.CHECKPOINT.toml    framework-level resume state
│   └── CHANGELOG.toml             framework-level change feed
│
└── canon/   ← framework-wide architectural law (governs ALL cubes)
    ├── ARCHITECTURE.SPEC.md           the 18-section architecture freeze
    ├── ARCHITECTURE.RECONCILIATION.md verdict + ruling log against κ27 / Warden / .vec3 canon
    ├── VEC3.SURFACES.md               the 7 .vec3/ surfaces; place vs authority
    ├── RAVEN.SUITE.md                 Sidekik runtime + edge-only law
    ├── ENCODER.RULES.md               encoder warden-laws table
    ├── KERNEL.V1.md                   κ27 kernel field: 3 rings × 9 slots + 216 encoder = 243 total
    ├── ZENOS.V1.md                    ZenOS genesis codex: tiers, perms, lanes, pheno templates
    └── LINUX.SYSTEM.MAPPING.md        3OX folder → Linux filesystem mapping
```

## Why the split

`_meta/cube/` files mirror what every cube has at `.3ox/_meta/` — the
**four canonical face files** plus optionally `BOX.ALIVENESS.equation`.
The repo as a whole is a cube (the project-root cube), so it has its
own _meta. That's legitimate.

`_meta/canon/` files are different in kind: they are the **framework
law** — the rules every cube obeys, not the data of any single cube.
Calling them `_meta` was a category error. They're meta *about* the
framework, but they're not cube _meta.

The distinction:

```
Cube _meta        :: data of one cube (this cube's identity, log, state)
Framework canon   :: law that all cubes obey (the spec, the surfaces, the rules)
```

## The "two underscore" rule

There are exactly **two** underscore-prefixed top-level directories:

```
_meta/   ← cube + canon meta (this directory)
_TRON/   ← device / runtime / receipts contract
```

Not three. Not four. **Per Lucius, fixed for Quantum reasons (26.05.04).**
Anything that feels like it needs a third `_*/` directory is wrong by
construction — find a subfolder home under `_meta/` or `_TRON/` instead.

Recorded in `.3ox/_meta/NAMING.CONTRACT.toml [layout]` with
`maximum = 2` and `quantum_lock = "two _*/ siblings only"`.

## Per-cube `.3ox/_meta/` is unchanged

Every cube — root and otherwise — keeps `.3ox/_meta/` for its own
identity. Cubes do **not** carry framework canon (they obey it, they
don't define it), so per-cube `_meta/` does not have a `canon/`
subfolder. The four canon files plus optionally `BOX.ALIVENESS.equation`
is the per-cube contract.

```
.3ox/_meta/
├── WHOAMI.md
├── NAMING.CONTRACT.toml
├── SESSION.CHECKPOINT.toml
├── CHANGELOG.toml
└── BOX.ALIVENESS.equation   (root cube + agent cubes that opt in)
```

## See also

- `.3ox/_meta/NAMING.CONTRACT.toml [layout]` — the underscore-tier rule, machine-readable
- `_meta/canon/VEC3.SURFACES.md` — the four-tier prefix system (`.`, `_`, `!`, bare)
- `PLAN.md §_META CONTRACT (per cube)` — the four-file per-cube contract

:: ∎
