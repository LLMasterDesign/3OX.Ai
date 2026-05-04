#!/usr/bin/env python3
# Axis.Warden.exs — shim: Elixir is canonical for .exs; Pulse may invoke via python3 until Elixir is wired.
# Validates limits.toml structure + optional round-trip check against sibling .exc (read-only).

from __future__ import annotations

import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIMITS = ROOT / ".3ox" / "(3)Rules" / "limits.toml"
EXC = Path(__file__).resolve().parent / "Axis.Warden.exc"


def fail(msg: str) -> None:
    print(f"warden_exs: FAIL {msg}", file=sys.stderr)
    raise SystemExit(1)


def main() -> int:
    if not LIMITS.is_file():
        fail(f"missing {LIMITS}")
    text = LIMITS.read_text(encoding="utf-8")
    for sec in ("[limits]", "[write_policy]", "[scope]", "[hashing]", "[warden]"):
        if sec not in text:
            fail(f"limits.toml missing section {sec}")
    if "internal_frame" not in text or "external_boundary" not in text:
        fail("limits.toml [hashing] must name internal_frame and external_boundary")

    try:
        data = tomllib.loads(text)
    except Exception as e:
        fail(f"limits.toml TOML parse error: {e}")
    w = data.get("warden")
    if not isinstance(w, dict):
        fail("limits.toml [warden] must be a table")
    if str(w.get("version", "")).strip() != "1":
        fail("limits.toml [warden] version must be \"1\"")
    fld = w.get("field")
    if not isinstance(fld, dict):
        fail("limits.toml [warden.field] missing")
    if fld.get("kernel_slots") != 27 or fld.get("entity_encoder_slots") != 216 or fld.get("total") != 243:
        fail("limits.toml [warden.field] must be kernel_slots=27, entity_encoder_slots=216, total=243")
    laws = w.get("law")
    if not isinstance(laws, list) or len(laws) != 12:
        fail("limits.toml must contain exactly 12 [[warden.law]] entries")
    seen = set()
    for i, row in enumerate(laws, start=1):
        if not isinstance(row, dict):
            fail(f"warden.law[{i}] must be table")
        rid = row.get("id")
        if rid != i:
            fail(f"warden.law id sequence broken: expected id={i}, got {rid!r}")
        for key in ("code", "summary", "violation"):
            if key not in row or not str(row.get(key, "")).strip():
                fail(f"warden.law[{i}] missing non-empty {key!r}")
        code = row["code"]
        if code in seen:
            fail(f"duplicate warden.law code {code!r}")
        seen.add(code)

    if EXC.is_file():
        body = EXC.read_text(encoding="utf-8")
        if "verify.source ∙ re-validate{ρ φ τ}" not in body:
            fail("Axis.Warden.exc missing fixed Xi inner text")

    print("warden_exs: PASS limits.toml + Axis.Warden.exc sanity")
    return 0


if __name__ == "__main__":
    sys.exit(main())
