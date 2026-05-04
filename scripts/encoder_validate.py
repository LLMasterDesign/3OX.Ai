#!/usr/bin/env python3
# Validate .3ox/(5)Links/hex.index.json and optional line-1 ::0xHHH:: chip in a document.

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
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        die(f"invalid JSON in {path}: {e}", 2)


def validate_hex_index(path: Path) -> None:
    data = load_index(path)
    entries = data.get("entries")
    if not isinstance(entries, dict):
        die("'entries' must be an object", 2)
    for key, row in entries.items():
        if not ENTRY_KEY.match(key):
            die(f"bad entry key {key!r} (want 0x + 3 hex digits)", 2)
        if not isinstance(row, dict):
            die(f"entry {key!r} must be object", 2)
        for field in ("code", "owner"):
            if field not in row or not str(row.get(field, "")).strip():
                die(f"entry {key!r} missing non-empty {field!r}", 2)
        if row["code"] != key:
            die(f"entry {key!r} code field must equal key (got {row['code']!r})", 2)
    if data.get("codebook_size", 4096) != 4096:
        die("codebook_size must be 4096", 2)
    n = len(entries)
    print(f"ok: {path.relative_to(ROOT)} — {n} entr{'y' if n == 1 else 'ies'}, keys and rows valid")


def validate_doc_chip(path: Path) -> None:
    if not path.is_file():
        die(f"missing doc: {path}", 2)
    text = path.read_text(encoding="utf-8")
    first = text.split("\n", 1)[0] if text else ""
    m = CHIP_IN_TEXT.search(first)
    if not m:
        die(f"line 1 has no ::0xHHH:: chip: {path}", 2)
    print(f"ok: doc {path.relative_to(ROOT)} — chip 0x{m.group(1).upper()} on line 1")


def main() -> int:
    p = argparse.ArgumentParser(description="Validate encoder hex index and optional Gensing line-1 chip.")
    p.add_argument("--hex-index", type=Path, default=DEFAULT_HEX_INDEX, help="path to hex.index.json")
    p.add_argument("--doc", type=Path, metavar="PATH", help="file whose line 1 must contain ::0xHHH::")
    args = p.parse_args()

    hex_path = args.hex_index.resolve()
    if args.doc:
        validate_doc_chip(args.doc.resolve())
    validate_hex_index(hex_path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
