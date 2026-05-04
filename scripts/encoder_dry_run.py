#!/usr/bin/env python3
# status:[ACTIVE] ver:[1.0.0] created:[26.05.03]
# doc:[PARTIAL] auth:[3OX.AI]
# Phase 2 dry run: MAP (hex → routes) → RECEIPT v1 → TAPE append + optional pulse snapshot file.

from __future__ import annotations

import argparse
import json
import random
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LINKS = ROOT / ".3ox" / "(5)Links"
PULSE_RT = ROOT / ".3ox" / "(6)Pulse" / "runtime"
LOGS = PULSE_RT / "logs"
TAPE_DIR = PULSE_RT / "tape"
TAPE_FILE = TAPE_DIR / "tape.jsonl"


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def die(msg: str, code: int = 1) -> None:
    print(f"encoder_dry_run: {msg}", file=sys.stderr)
    raise SystemExit(code)


def norm_code(s: str) -> str:
    s = s.strip().lower()
    if not s.startswith("0x"):
        die(f"code must start with 0x, got {s!r}")
    rest = s[2:]
    if len(rest) != 3 or any(c not in "0123456789abcdef" for c in rest):
        die(f"code must be 0x + 3 hex digits, got {s!r}")
    return "0x" + rest.upper()


def load_json(path: Path) -> dict:
    if not path.is_file():
        die(f"missing file: {path}")
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        die(f"invalid JSON {path}: {e}")


def resolve_map(code: str, hex_data: dict, routes: dict) -> dict:
    entries = hex_data.get("entries") or {}
    if code not in entries:
        die(f"no hex.index entries[{code!r}]")
    entry = entries[code]
    maps = routes.get("maps") or {}
    hex_map = maps.get("hex") or {}
    slot_id = entry.get("slot") or hex_map.get(code)
    slot_index = routes.get("slot_index") or {}
    slot_row = slot_index.get(slot_id) if slot_id else None

    route_keys: list[str] = []
    rt = routes.get("routes") or {}
    for k, v in rt.items():
        if isinstance(v, dict) and v.get("slot") == slot_id:
            route_keys.append(k)

    return {
        "hex_entry": entry,
        "slot_id": slot_id,
        "slot_row": slot_row,
        "route_keys": route_keys,
    }


def main() -> int:
    ap = argparse.ArgumentParser(description="Encoder Phase 2 MAP dry run → RECEIPT + TAPE.")
    ap.add_argument("--code", default="0x02A", help="4096 code (default 0x02A)")
    ap.add_argument("--no-tape", action="store_true", help="write receipt only, skip tape append")
    args = ap.parse_args()

    code = norm_code(args.code)
    hex_path = LINKS / "hex.index.json"
    routes_path = LINKS / "routes.json"
    hex_data = load_json(hex_path)
    routes = load_json(routes_path)

    mmap = resolve_map(code, hex_data, routes)

    ts = int(time.time())
    jid = f"dry-run-{ts}-{random.randint(1000, 9999)}"
    completed = utc_now()

    receipt = {
        "receipt_version": "1",
        "job_id": jid,
        "completed_at": completed,
        "status": "completed",
        "output_preview": [
            f"encoder_dry_run MAP code={code} slot_id={mmap['slot_id']!r} routes={mmap['route_keys']}"
        ],
        "encoder": {
            "layer_6_receipt": True,
            "dry_run": True,
            "code_4096": code,
            "map": mmap,
            "tape_relative_path": "(6)Pulse/runtime/tape/tape.jsonl",
        },
    }

    LOGS.mkdir(parents=True, exist_ok=True)
    receipt_path = LOGS / f"{jid}.json"
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")

    pulse_snap = {
        "updated_at": completed,
        "dry_run_job_id": jid,
        "code_4096": code,
        "last_completed_job_ref": str(receipt_path.relative_to(ROOT)),
        "note": "encoder_dry_run does not overwrite status.json; use this for audit or merge into PULSE later",
    }
    pulse_path = LOGS / "dry_run_pulse.json"
    pulse_path.write_text(json.dumps(pulse_snap, indent=2) + "\n", encoding="utf-8")

    if not args.no_tape:
        TAPE_DIR.mkdir(parents=True, exist_ok=True)
        with TAPE_FILE.open("a", encoding="utf-8") as f:
            f.write(json.dumps(receipt, separators=(",", ":")) + "\n")

    print(f"wrote receipt: {receipt_path.relative_to(ROOT)}")
    print(f"wrote pulse snapshot: {pulse_path.relative_to(ROOT)}")
    if not args.no_tape:
        print(f"appended TAPE: {TAPE_FILE.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
