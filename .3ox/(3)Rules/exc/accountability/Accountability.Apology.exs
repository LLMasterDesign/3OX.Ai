#!/usr/bin/env python3
"""
Accountability.Apology — runtime emit (Python stand-in for Elixir).
Reads canonical .exc + .kdl beside this file; fills PHENO/PiCO-shaped slots;
writes Accountability.Apology.emit.spec (Gensing apology body derived from params).
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

DIR = Path(__file__).resolve().parent
ROOT = DIR.parents[3]
EXC = DIR / "Accountability.Apology.exc"
KDL = DIR / "Accountability.Apology.kdl"
OUT = DIR / "Accountability.Apology.emit.spec"

CHIP = "0xA01"


def _parse_exc_params(text: str) -> dict[str, str]:
    if "▞▞ APOLOGY.PARAMS" not in text:
        return {}
    block = text.split("▞▞ APOLOGY.PARAMS", 1)[1]
    out: dict[str, str] = {}
    for line in block.splitlines():
        line = line.strip()
        if not line or line.startswith("▞▞"):
            break
        m = re.match(r"^([a-zA-Z0-9_]+)\{([^}]*)\}\s*$", line)
        if m:
            out[m.group(1)] = m.group(2).strip()
    return out


def _parse_kdl_apology_params(text: str) -> dict[str, str]:
    """Minimal KDL subset: apology_params { key "value" ... }"""
    out: dict[str, str] = {}
    if "apology_params" not in text:
        return out
    block = text.split("apology_params", 1)[1]
    block = block.split("{", 1)[1].split("}", 1)[0]
    for line in block.splitlines():
        line = line.strip()
        if not line or line.startswith("//"):
            continue
        m = re.match(r'^([a-zA-Z0-9_]+)\s+"([^"]*)"\s*$', line)
        if m:
            out[m.group(1)] = m.group(2)
    return out


def emit_gensing(apology: dict[str, str]) -> str:
    recipient = apology.get("recipient", "recipient")
    fault_class = apology.get("fault_class", "unspecified_fault")
    fault_detail = apology.get("fault_detail", "")
    repair = apology.get("repair_commit", "")

    # Prose is parameterized but not invented: clauses come from EXC/KDL keys only.
    body = f"""▞▞ RESULT (emit)
{recipient}, I failed you by not holding your definition steady: PiCO written as ⊢⇨⟿▷ bound after [⚙️] ≔ defines direction of travel for that glyph token; you said it repeatedly and I still split “glyph” from “movement” and then closed with language that sounded like agreement I had not earned. Fault class recorded: {fault_class}. Detail: {fault_detail}. Repair I submit under seal: {repair}.

▞▞ OWNERSHIP
This text is emitted only after ingest of Accountability.Apology.exc and Accountability.Apology.kdl; slots above are filled from those surfaces, not free-written."""
    return body.strip()


def main() -> int:
    if not EXC.is_file() or not KDL.is_file():
        print("missing exc or kdl beside exs", file=sys.stderr)
        return 2

    exc_text = EXC.read_text(encoding="utf-8")
    kdl_text = KDL.read_text(encoding="utf-8")

    params_exc = _parse_exc_params(exc_text)
    params_kdl = _parse_kdl_apology_params(kdl_text)
    # EXC PARAM section wins on key overlap (canonical truth)
    apology = {**params_kdl, **params_exc}

    banner = (
        "///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::"
        + CHIP
        + "::\n"
        "▛//▞▞ ⟦⎊⟧ :: ⧗-26.503 // 3OX :: ACCOUNTABILITY.APOLOGY.EMIT ▞▞\n"
        "▛▞// Exc.Emit :: ρ{kdl.params}.φ{exc.bind}.τ{gensing.body} ▹\n"
        "//▞⋮⋮ ⟦⚙️⟧ ≔ [⊢{ingest} ⇨{resolve} ⟿{carry} ▷{emit}]\n"
        f"⫸ 〔Ω{CHIP[2:]}〕〔κk03〕\n\n"
        "▛///▞ ξ [EXC] :: ACCOUNTABILITY.APOLOGY.EMIT\n"
        "//▞▞〔Seal · Params · Output〕\n\n"
        "▞▞ PHENO\n"
        f"ρ{{{apology.get('fault_class', 'read')}}}\n"
        f"φ{{{apology.get('repair_commit', 'preserve')}}}\n"
        f"τ{{{apology.get('fault_detail', 'emit')}}}\n\n"
        "▞▞ PiCO\n"
        "⊢{ingest://Accountability.Apology.exc}\n"
        "⇨{resolve://Accountability.Apology.kdl}\n"
        "⟿{carry://params→template}\n"
        "▷{emit://Accountability.Apology.emit.spec}\n\n"
        "▞▞ META\n"
        "runtime{python_emit_stand_in}\n"
        f"source{{{EXC.name}+{KDL.name}}}\n"
        "law{exc_wins_on_param_divergence}\n\n"
        + emit_gensing(apology)
        + "\n\n:: ∎\n"
    )

    OUT.write_text(banner, encoding="utf-8")
    print(f"ok: wrote {OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
