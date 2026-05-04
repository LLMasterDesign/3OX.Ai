///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.124 // WORKBOOK :: TPR.HANDOFF.SCHEMA ▞▞

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[26.05.04]
/// doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
/// tpr.handoff schema — agent → TPR fan-out contract
```

# `tpr.handoff` schema (v1)

## Why this exists

TPR (TelePromptR) is the only Telegram speaker. Agents cannot call the
Telegram Bot API. Instead each agent's `dispatch.rb` writes a JSON
**handoff record** under:

```
<agent_root>/!0UT.<AGENT>/tpr/handoff/<handoff_id>.handoff.json
```

TPR's handoff consumer (this directory) walks those files, validates
them against the schema, fans them into the right sub-agent topic
queue, and writes an ack receipt back so the originating agent's tape
can collapse the lifecycle.

## Wire format (canonical example, from 3OX.Sidekik v0.2.0)

```json
{
  "kind": "tpr.handoff",
  "schema_version": "1",
  "id": "sk.h.20260504T080926-2185",
  "in_reply_to": "sk.i.20260504T080926-2185",
  "from_agent": "3OX.Sidekik",
  "to_agent": "vso_agent",
  "subagent_path": "3OX Agents/VSO Agent",
  "topics_hint": ["va", "disability", "claim", "dbq"],
  "classified_key": "va",
  "text": "VA disability claim for tinnitus",
  "created_at": "2026-05-04T08:09:26Z",
  "consumer": "TelePromptR",
  "merge_via": "TelePromptR/<TPR_ZENS3N>/merge.sh",
  "speaker_unit": "speaker-mesh.service"
}
```

## Required fields

| Field | Type | Notes |
|---|---|---|
| `kind` | `"tpr.handoff"` | Discriminator. Anything else is rejected. |
| `id` | string | Globally unique per handoff. Convention: `<agent>.h.<UTC ts>-<rand>`. |
| `from_agent` | string | Originating agent display name (e.g. `3OX.Sidekik`). |
| `to_agent` | string | Sub-agent route key (e.g. `vso_agent`, `money_bagz`). |
| `subagent_path` | string | Repo-relative path to the sub-agent cube root. |
| `text` | string | The original user intent; what TPR will hand to speaker-mesh. |
| `created_at` | RFC3339 UTC | Used to drop stale records past `STALE_AFTER_HOURS`. |

## Optional but recommended

| Field | Type | Notes |
|---|---|---|
| `schema_version` | string | Defaults to `"1"`. Validator warns on unknown versions. |
| `in_reply_to` | string | Originating intent id, for tape collapse. |
| `topics_hint` | string[] | Hints the consumer uses to score topic match. |
| `classified_key` | string | Triage classifier key (e.g. `va`, `bills`). |
| `consumer` | string | Should be `"TelePromptR"`. |
| `merge_via` | string | Documentary; not executed. |
| `speaker_unit` | string | Documentary; not executed. |

## Consumer behaviour

The consumer rides the rotor — **one invocation = one 3OX.SPIN edge** (Core{Axis} walks Warden → Tape → Pulse).
No timers. The rotor (or a filesystem `path` unit on the handoff dir)
is what triggers the drain. See README §"Why no timer".

1. Walk every registered agent's `!0UT.<AGENT>/tpr/handoff/*.handoff.json` (newest last).
2. Validate each file with `lib/tpr_handoff_schema.rb`.
3. On valid:
   a. Resolve `to_agent` to a TPR topic via `_TRON/TelePromptR/route.map.json` (or fall through to the existing `TPR.ROUTE.MAP.json`).
   b. Append an enqueue record to `<TPR_RUNTIME>/queue/<topic>.jsonl`.
   c. Move the source file to `handoff/.processed/` and write an ack at `handoff/.acks/<id>.ack.json`.
4. On invalid: move to `handoff/.rejected/` with a sibling `<id>.error.json` carrying the validation message.
5. Records older than `TPR_HANDOFF_STALE_AFTER_HOURS` (default 72) move to `.expired/` untouched.

The consumer is **idempotent** by `id`: if `.acks/<id>.ack.json` or `.rejected/<id>.error.json` already exists, the source is just moved to the matching sink without re-emitting. So firing the same rotor edge twice is safe.

## Failure modes that are NOT TPR's job

- Subagent not actually present on the VPS — that's a deploy issue.
- Telegram chat/topic not yet bound — TPR queues anyway; emit phase logs a warning.
- LLM inference errors — speaker-mesh's responsibility.

:: ∎
