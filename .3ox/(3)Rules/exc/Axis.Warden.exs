#!/usr/bin/env python3
# Axis.Warden.exs — shim: Elixir is canonical for .exs; Pulse may invoke via python3 until Elixir is wired.
# Validates limits.toml structure + optional round-trip check against sibling .exc (read-only).

from __future__ import annotations

import re
import sys
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
    for sec in ("[limits]", "[write_policy]", "[scope]", "[hashing]"):
        if sec not in text:
            fail(f"limits.toml missing section {sec}")
    if "internal_frame" not in text or "external_boundary" not in text:
        fail("limits.toml [hashing] must name internal_frame and external_boundary")

    if EXC.is_file():
        body = EXC.read_text(encoding="utf-8")
        if "verify.source ∙ re-validate{ρ φ τ}" not in body:
            fail("Axis.Warden.exc missing fixed Xi inner text")

    print("warden_exs: PASS limits.toml + Axis.Warden.exc sanity")
    return 0


if __name__ == "__main__":
    sys.exit(main())
