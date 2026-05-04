#!/usr/bin/env python3
# status:[ACTIVE] ver:[1.0.0] created:[26.05.03]
# doc:[PARTIAL] auth:[3OX.AI]
# Verify 3OX.Core{} — routes.json core maps ↔ slot_index k00..k26.

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ROUTES = ROOT / ".3ox" / "(5)Links" / "routes.json"
KAPPA = re.compile(r"^k([01][0-9]|2[0-6])$")  # k00..k26


def die(msg: str, code: int = 1) -> None:
    print(f"core_slots_validate: {msg}", file=sys.stderr)
    raise SystemExit(code)


def main() -> int:
    if not ROUTES.is_file():
        die(f"missing {ROUTES}")
    data = json.loads(ROUTES.read_text(encoding="utf-8"))
    core = data.get("core")
    if not isinstance(core, dict):
        die("routes.json missing object 'core'")

    expected_sectors = ("axis", "encode", "ring", "system")
    slots_from_core: set[str] = set()
    for sector in expected_sectors:
        block = core.get(sector)
        if not isinstance(block, dict):
            die(f"core.{sector} must be object")
        for seat, sid in block.items():
            if not isinstance(sid, str) or not KAPPA.match(sid):
                die(f"core.{sector}[{seat!r}] = {sid!r} must be k00..k26")
            slots_from_core.add(sid)

    want = {f"k{i:02d}" for i in range(27)}
    if slots_from_core != want:
        missing = want - slots_from_core
        extra = slots_from_core - want
        die(f"core maps must list exactly k00..k26 once; missing={missing!r} extra={extra!r}")

    slot_index = data.get("slot_index")
    if not isinstance(slot_index, dict):
        die("routes.json missing slot_index")

    for sid in sorted(want):
        row = slot_index.get(sid)
        if not isinstance(row, dict):
            die(f"slot_index missing {sid}")
        if row.get("class") != "κ":
            die(f"slot_index[{sid}].class must be κ (Core chamber)")
        c = row.get("core")
        if not isinstance(c, dict) or "sector" not in c or "seat" not in c:
            die(f"slot_index[{sid}] must have core.sector and core.seat")

    # Leo proof frame (ξ) — optional but keeps narrative consistent
    e101 = slot_index.get("E101")
    if isinstance(e101, dict) and e101.get("class") == "ξ":
        note = (e101.get("note") or "") + (e101.get("name") or "")
        if "Leo" not in note and "LEONIS" not in note and "proof" not in note.lower():
            die("slot_index.E101 should mention Leo or proof example (narrative consistency)")

    print(f"ok: 3OX.Core{{}} — 27 κ slots (k00..k26); core maps align with slot_index")
    return 0


if __name__ == "__main__":
    sys.exit(main())
