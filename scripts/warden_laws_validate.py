#!/usr/bin/env python3
"""Validate [warden] twelve laws in .3ox/(3)Rules/limits.toml (machine-readable policy)."""

from __future__ import annotations

import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIMITS = ROOT / ".3ox" / "(3)Rules" / "limits.toml"

EXPECTED_CODES = (
    "SLOT_CAP",
    "KERNEL_PROTECTION",
    "WARDEN_FIRST",
    "DECLARED_CAPABILITY",
    "SLOT_IDENTITY",
    "ROUTE_DETERMINISM",
    "NO_RAW_MUTATION",
    "RECEIPT_COLLAPSE",
    "TAPE_INTEGRITY",
    "PULSE_VISIBILITY",
    "MIGRATION_SEAL",
    "FAIL_CLOSED",
)


def die(msg: str) -> None:
    print(f"warden_laws_validate: {msg}", file=sys.stderr)
    raise SystemExit(1)


def main() -> int:
    if not LIMITS.is_file():
        die(f"missing {LIMITS}")
    text = LIMITS.read_text(encoding="utf-8")
    try:
        data = tomllib.loads(text)
    except Exception as e:
        die(f"limits.toml parse error: {e}")

    w = data.get("warden")
    if not isinstance(w, dict):
        die("missing [warden] table")
    if str(w.get("version", "")).strip() != "1":
        die('[warden] version must be "1"')

    fld = w.get("field")
    if not isinstance(fld, dict):
        die("missing [warden.field]")
    if fld.get("kernel_slots") != 27 or fld.get("entity_encoder_slots") != 216 or fld.get("total") != 243:
        die("[warden.field] must be kernel_slots=27, entity_encoder_slots=216, total=243")

    laws = w.get("law")
    if not isinstance(laws, list) or len(laws) != 12:
        die("must have exactly 12 [[warden.law]] rows")

    seen: set[str] = set()
    for i, row in enumerate(laws, start=1):
        if not isinstance(row, dict):
            die(f"warden.law[{i}] must be a table")
        if row.get("id") != i:
            die(f"warden.law id sequence: expected id={i}, got {row.get('id')!r}")
        for key in ("code", "summary", "violation"):
            if key not in row or not str(row.get(key, "")).strip():
                die(f"warden.law[{i}] missing non-empty {key!r}")
        code = str(row["code"])
        if code in seen:
            die(f"duplicate warden.law code {code!r}")
        seen.add(code)

    missing = [c for c in EXPECTED_CODES if c not in seen]
    extra = [c for c in seen if c not in EXPECTED_CODES]
    if missing or extra:
        die(f"code set mismatch: missing={missing!r} extra={extra!r}")

    h = data.get("hashing")
    if isinstance(h, dict):
        if "internal_frame" not in h or "internal_daemon" not in h or "external_boundary" not in h:
            die("[hashing] must define internal_frame, internal_daemon, external_boundary")

    print("warden_laws_validate: PASS — 12 laws + field counts + hashing keys")
    return 0


if __name__ == "__main__":
    sys.exit(main())
