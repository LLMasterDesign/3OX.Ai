#!/usr/bin/env python3
"""Verify routes.json core{} maps ↔ slot_index for κ k00..k26."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ROUTES = ROOT / ".3ox" / "(5)Links" / "routes.json"
KAPPA = re.compile(r"^k([01][0-9]|2[0-6])$")

SECTOR_TITLE = {
    "axis": "Axis",
    "encode": "Encode",
    "ring": "Ring",
    "system": "System",
}


def die(msg: str) -> None:
    print(f"core_slots_validate: {msg}", file=sys.stderr)
    raise SystemExit(1)


def main() -> int:
    if not ROUTES.is_file():
        die(f"missing {ROUTES}")
    data = json.loads(ROUTES.read_text(encoding="utf-8"))
    core = data.get("core")
    if not isinstance(core, dict):
        die("routes.json missing object 'core'")

    want_sectors = ("axis", "encode", "ring", "system")
    slots_from_core: set[str] = set()
    for sector in want_sectors:
        block = core.get(sector)
        if not isinstance(block, dict):
            die(f"core.{sector} must be object")
        for seat, sid in block.items():
            if not isinstance(sid, str) or not KAPPA.match(sid):
                die(f"core.{sector}[{seat!r}] = {sid!r} must be k00..k26")
            slots_from_core.add(sid)

    need = {f"k{i:02d}" for i in range(27)}
    if slots_from_core != need:
        die(f"core maps must list exactly k00..k26 once; missing={need - slots_from_core!r} extra={slots_from_core - need!r}")

    slot_index = data.get("slot_index")
    if not isinstance(slot_index, dict):
        die("routes.json missing slot_index")

    for sid in sorted(need):
        row = slot_index.get(sid)
        if not isinstance(row, dict):
            die(f"slot_index missing {sid}")
        if row.get("class") != "\u03ba":  # κ
            die(f"slot_index[{sid}].class must be κ (Core chamber)")
        c = row.get("core")
        if not isinstance(c, dict):
            die(f"slot_index[{sid}] missing core object")
        if "sector" not in c or "seat" not in c:
            die(f"slot_index[{sid}].core must have sector and seat")

    # Cross-check each core seat → slot row matches sector/seat/route_key
    for sector, block in [(s, core[s]) for s in want_sectors]:
        title = SECTOR_TITLE[sector]
        for seat, sid in block.items():
            row = slot_index[sid]
            c = row["core"]
            if c["sector"] != title:
                die(f"slot_index[{sid}].core.sector expected {title!r}, got {c['sector']!r}")
            if c["seat"] != seat:
                die(f"slot_index[{sid}].core.seat expected {seat!r}, got {c['seat']!r}")
            rk = f"core.{sector}.{seat.lower()}"
            if row.get("route_key") != rk:
                die(f"slot_index[{sid}].route_key expected {rk!r}, got {row.get('route_key')!r}")

    e042 = slot_index.get("E042")
    if not isinstance(e042, dict) or e042.get("class") != "\u03be":
        die("slot_index.E042 must exist as ξ example row")

    print("ok: 3OX.Core{} — 27 κ slots (k00..k26); core maps align with slot_index")
    return 0


if __name__ == "__main__":
    sys.exit(main())
