#!/usr/bin/env python3
"""B0 metadata resolver proof: nested and sibling roots, no runtime mutation."""
import argparse
import os
from pathlib import Path
import subprocess
import tempfile

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--b0", type=Path, required=True)
    p.add_argument("--elixir", type=Path, required=True)
    p.add_argument("--erl-bin", type=Path, required=True)
    p.add_argument("--identity", type=Path, default=None)
    args = p.parse_args()
    env = dict(os.environ)
    env["PATH"] = str(args.elixir.parent) + ":" + str(args.erl_bin) + ":" + env.get("PATH", "")
    checks = []

    def invoke(identity, edge="main"):
        return subprocess.run(
            [str(args.elixir), str(args.b0), "b0", "meta", str(identity), edge],
            env=env, text=True, capture_output=True, timeout=15,
        )

    def assert_case(name, outcome, positive, fragment):
        stream = outcome.stdout + outcome.stderr
        ok = (outcome.returncode == 0 if positive else outcome.returncode == 2) and fragment in stream
        print(("PASS" if ok else "FAIL") + " " + name + " exit=" + str(outcome.returncode))
        checks.append(ok)
        if not ok:
            raise RuntimeError(name + " failed: " + stream[-1000:])

    with tempfile.TemporaryDirectory(prefix="boxd-b0-meta-") as temp:
        root = Path(temp)
        ident = root / "FAKE.ID"
        nested = root / ".3ox" / "_meta" / "edges" / "main"
        nested.mkdir(parents=True)
        (nested / "pid").write_text("")
        ident.write_text('entity_id "fake"\nmeta_root ".3ox/_meta/"\n')
        assert_case("nested-layout", invoke(ident), True, "binding=unbound")
        assert_case("nested-exact-path", invoke(ident), True, str(nested / "pid"))

        sibling = root / "_meta" / "edges" / "main"
        sibling.mkdir(parents=True)
        (sibling / "pid").write_text("")
        ident.write_text('entity_id "fake"\nmeta_root "_meta/"\n')
        assert_case("sibling-layout", invoke(ident), True, str(sibling / "pid"))

        ident.write_text('entity_id "fake"\n')
        assert_case("missing-declaration", invoke(ident), False, "metadata_root_undeclared")

        ident.write_text('meta_root "_meta/"\nmeta_root ".3ox/_meta/"\n')
        assert_case("ambiguous-declaration", invoke(ident), False, "ambiguous_metadata_declaration")

        ident.write_text('meta_root "../_meta/"\n')
        assert_case("parent-escape", invoke(ident), False, "unsafe_metadata_root")

        ident.write_text('meta_root "/tmp/_meta/"\n')
        assert_case("absolute-escape", invoke(ident), False, "unsafe_metadata_root")

        ident.write_text('meta_root "_meta/"\n')
        assert_case("invalid-edge", invoke(ident, "../main"), False, "invalid_edge")
        assert_case("absent-edge", invoke(ident, "absent"), False, "missing_or_linked_metadata_directory")

        (sibling / "pid").unlink()
        (sibling / "pid").symlink_to(ident)
        assert_case("linked-pid-refusal", invoke(ident), False, "missing_or_linked_file")

        # Separate disposable identity and linked metadata dir.
        linked = root / "linked"
        linked.mkdir()
        (linked / "R.ID").write_text('meta_root "_meta/"\n')
        (linked / "_meta").symlink_to(root / "_meta", target_is_directory=True)
        assert_case("linked-root-refusal", invoke(linked / "R.ID"), False,
                    "missing_or_linked_metadata_directory")

    if args.identity:
        # Read-only verification of the declared root and existing main edge.
        r = invoke(args.identity)
        assert_case("real-declaration", r, True, "binding=unbound")

    if not all(checks):
        raise SystemExit(2)
    print("BOXD_B0_META_PROOF status=ok checks=" + str(len(checks)))

if __name__ == "__main__":
    main()
