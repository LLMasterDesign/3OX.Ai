#!/usr/bin/env python3
# status:[ACTIVE] ver:[1.0.0] created:[26.05.03]
# doc:[PARTIAL] auth:[3OX.AI]
# Minimal EXC v1 boundary check (normative .exc text). Aligns with ENCODER handoff + routes exc_boundary when present.

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

# Fixed v1 literals (see research handoff / exc_boundary)
XI_INNER = "verify.source ∙ re-validate{ρ φ τ}"
PRISM_TOKEN = "PRISM"

SYMS = {
    "rho": "\u03c1",
    "phi": "\u03c6",
    "tau": "\u03c4",
    "ingest": "\u22a2",
    "validate": "\u21e8",
    "carry": "\u27ff",
    "emit": "\u25b7",
    "nu": "\u03bd",
    "xi": "\u039e",
}


def normalize(text: str) -> str:
    lines = text.replace("\r\n", "\n").replace("\r", "\n").split("\n")
    lines = [ln.strip() for ln in lines]
    return "\n".join(ln for ln in lines if ln)


def die(msg: str, code: int = 2) -> None:
    print(f"exc_validate: {msg}", file=sys.stderr)
    raise SystemExit(code)


def body_after_sym(lines: list[str], sym: str) -> str | None:
    pat = re.compile("^" + re.escape(sym) + r"\{(.+)\}\s*$")
    for ln in lines:
        m = pat.match(ln)
        if m:
            return m.group(1).strip()
    return None


def parse_exc(path: Path) -> tuple[list[str], str | None]:
    raw = path.read_text(encoding="utf-8")
    lines = [ln.strip() for ln in raw.replace("\r\n", "\n").replace("\r", "\n").split("\n")]
    lines = [ln for ln in lines if ln]
    if not lines:
        die("empty file")
    m = re.match(r"^EXC\[(.+)\]\s*$", lines[0])
    if not m:
        die(f"first line must be EXC[id], got: {lines[0]!r}")
    return lines, m.group(1).strip()


def validate(lines: list[str], canonical_path: Path | None) -> tuple[str, dict[str, bool], list[str]]:
    issues: list[str] = []
    s = SYMS

    structural = None
    xi_nu_line = None
    for ln in lines[1:4]:
        if PRISM_TOKEN in ln and "\u2297" in ln:  # ⊗
            structural = ln
        if "\u2261" in ln and s["xi"] in ln and s["nu"] in ln:  # ≡
            xi_nu_line = ln

    checks: dict[str, bool] = {}

    checks["verify_source"] = True
    if canonical_path is not None:
        ctext = canonical_path.read_text(encoding="utf-8")
        checks["verify_source"] = normalize(ctext) == normalize("\n".join(lines))

    rho = body_after_sym(lines, s["rho"])
    phi = body_after_sym(lines, s["phi"])
    tau = body_after_sym(lines, s["tau"])
    checks["revalidate_pheno"] = all(bool(x and x.strip()) for x in (rho, phi, tau))
    if not checks["revalidate_pheno"]:
        issues.append("pheno_incomplete")

    ing = body_after_sym(lines, s["ingest"])
    val = body_after_sym(lines, s["validate"])
    car = body_after_sym(lines, s["carry"])
    emi = body_after_sym(lines, s["emit"])
    checks["check_pico"] = all(bool(x and x.strip()) for x in (ing, val, car, emi))
    if not checks["check_pico"]:
        issues.append("pico_incomplete")

    checks["check_prism"] = bool(
        structural
        and PRISM_TOKEN in structural
        and "\u2297" in structural
        and "\u27ff" in structural
        and "\u21e8" in structural
        and "\u22a2" in structural
        and "\u25b7" in structural
    )
    if not checks["check_prism"]:
        issues.append("prism_invalid")

    xi_ok = xi_nu_line is not None and XI_INNER in xi_nu_line
    checks["check_xi"] = xi_ok
    if not xi_ok:
        issues.append("xi_invalid")

    nu_body = body_after_sym(lines, s["nu"])
    checks["check_nu"] = bool(nu_body and nu_body.strip())
    if not checks["check_nu"]:
        issues.append("nu_missing")

    ok = all(checks[k] for k in checks)
    if ok:
        outcome = "PASS"
    elif checks["check_nu"]:
        outcome = "FALLBACK"
    else:
        outcome = "FAIL"

    return outcome, checks, issues


def main() -> int:
    ap = argparse.ArgumentParser(description="Validate minimal EXC v1 boundary text.")
    ap.add_argument("exc_path", type=Path, help="path to .exc file")
    ap.add_argument(
        "--canonical",
        type=Path,
        metavar="PATH",
        help="if set, require byte-normalized equality with exc file (verify_source)",
    )
    args = ap.parse_args()
    path = args.exc_path.resolve()
    if not path.is_file():
        die(f"not found: {path}")

    lines, eid = parse_exc(path)
    outcome, checks, issues = validate(lines, args.canonical)

    print(f"id: {eid}")
    print(f"outcome: {outcome}")
    for k, v in checks.items():
        print(f"  {k}: {v}")
    if issues:
        print("issues:", ", ".join(issues))

    if outcome == "PASS":
        return 0
    if outcome == "FALLBACK":
        return 1
    return 2


if __name__ == "__main__":
    sys.exit(main())
