#!/usr/bin/env python3
# status:[ACTIVE] ver:[1.0.0] created:[26.05.03]
# doc:[PARTIAL] auth:[3OX.AI]
# Validate hex.index.json (encoder Phase 1) and optionally line-1 Gensing chip in a doc.

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_HEX_INDEX = ROOT / ".3ox" / "(5)Links" / "hex.index.json"

ENTRY_KEY = re.compile(r"^0x[0-9A-Fa-f]{3}$")
CHIP_IN_TEXT = re.compile(r"::0x([0-9A-Fa-f]{3})::")


def die(msg: str, code: int = 1) -> None:
    print(f"encoder_validate: {msg}", file=sys.stderr)
    raise SystemExit(code)


def load_index(path: Path) -> dict:
    if not path.is_file():
        die(f"missing hex index: {path}", 2)
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        die(f"invalid JSON in {path}: {e}", 2)
    if not isinstance(data, dict):
        die(f"root must be object in {path}", 2)
    return data


def validate_hex_index(path: Path) -> int:
    data = load_index(path)
    entries = data.get("entries")
    if entries is None:
        die("'entries' key required", 2)
    if not isinstance(entries, dict):
        die("'entries' must be an object", 2)

    n = 0
    for key, row in entries.items():
        n += 1
        if not ENTRY_KEY.match(key):
            die(f"bad entry key {key!r} (want 0x + 3 hex digits)", 2)
        if not isinstance(row, dict):
            die(f"entry {key!r} must be object", 2)
        for field in ("code", "owner"):
            if field not in row:
                die(f"entry {key!r} missing {field!r}", 2)
            val = row[field]
            if not isinstance(val, str) or not val.strip():
                die(f"entry {key!r} {field!r} must be non-empty string", 2)
        if row["code"] != key:
            die(f"entry {key!r} code field must equal key (got {row['code']!r})", 2)

    size = data.get("codebook_size", 4096)
    if size != 4096:
        die(f"codebook_size must be 4096 (got {size!r})", 2)

    print(f"ok: {path.relative_to(ROOT)} — {n} entr{'y' if n == 1 else 'ies'}, keys and rows valid")
    return 0


def validate_doc_chip(path: Path) -> int:
    if not path.is_file():
        die(f"missing doc: {path}", 2)
    text = path.read_text(encoding="utf-8")
    first = text.split("\n", 1)[0] if text else ""
    m = CHIP_IN_TEXT.search(first)
    if not m:
        die(f"line 1 has no ::0xHHH:: chip: {path}", 2)
    print(f"ok: doc {path.relative_to(ROOT)} — chip 0x{m.group(1).upper()} on line 1")
    return 0


def main() -> int:
    p = argparse.ArgumentParser(description="Validate encoder hex index and optional Gensing line-1 chip.")
    p.add_argument(
        "--hex-index",
        type=Path,
        default=DEFAULT_HEX_INDEX,
        help=f"path to hex.index.json (default: {DEFAULT_HEX_INDEX})",
    )
    p.add_argument("--doc", type=Path, metavar="PATH", help="markdown/text: line 1 must contain ::0xHHH::")
    args = p.parse_args()

    hex_path = args.hex_index.resolve()
    if args.doc:
        validate_doc_chip(args.doc.resolve())
    validate_hex_index(hex_path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
