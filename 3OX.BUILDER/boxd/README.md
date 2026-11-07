# boxd · B0 first (isolated prototype)

## Purpose

One host-level B0 Supervisor is the foundation for separately supervised
3OX cube services. The intended later integration order is:

    SysGen → 3OX CLI selection + static/daemon/dependency checks
           → boxd → B0 ready → B1…B8 per cube requirements

**Milestone 1 is B0 only.** This folder provides an Elixir source-controlled,
zero-dependency B0 supervisor candidate and a real SysGen start/status/stop
acceptance test. Production integration with existing Box.Application remains open.

## Files

- b0.exs: Boxd.B0 OTP root (unique Registry and DynamicSupervisor);
  synthetic cube children demonstrate per-cube isolation.
- prove_b0_sysgen.py: portable isolated SysGen → B0 start/status/stop proof,
  including ten B0 lifecycle assertions and a durable JSON receipt.

## Behavior verified

- Start the singleton B0 root, refuse a second B0 in the same VM.
- Admit two distinct cube IDs as supervised children.
- Reject empty and duplicate cube IDs.
- Survive idle time; restart a killed child without disturbing its peer.
- Shut down the root and its children cleanly.
- Start B0 via a SysGen command-file petition; receive success and PID.
- Verify B0 remains alive, query status, and stop it via SysGen.
- Remove the disposable SysGen root and preserve live daemons.

This proof establishes an isolated B0 prototype. It leaves six-face static
checks and B1–B8 startup for later milestones. The actual Box.Application
on Corbato has a distinct nine-child boot path; the prototype creates
neither a second production K9 nor a replacement Box.Application.

## Explicit commands

Run just the B0 OTP lifecycle with Elixir and Erlang on PATH:

    elixir 3OX.BUILDER/boxd/b0.exs b0 proof

B0's isolated service entry:

    elixir 3OX.BUILDER/boxd/b0.exs b0 run --isolated

The --isolated flag prevents accidental invocation as an approved
full production Box runtime.

Exercise SysGen dispatch, receipt, status and stop:

    python3 3OX.BUILDER/boxd/prove_b0_sysgen.py \
      --sysgend /absolute/path/to/isolated/sysgend-b0fix \
      --elixir /absolute/path/to/elixir \
      --erl-bin /absolute/path/to/erlang/bin \
      --receipt /existing/parent/new-receipt.json

The script creates a temporary SYSGEN_ROOT, exercises its command-file
queue, then removes it. A receipt's parent directory must already exist;
previous receipts are preserved.

## Minsky acceptance · 2026-11-06 (local)

- Erlang 27.3.4.6, Elixir 1.18.6.
- B0's 10/10 lifecycle assertions passed.
- SysGen candidate v0.1.1-b0fix1 launched and stopped isolated B0
  through command-file start/status/stop receipts.
- Found a SysGen stop issue: a child awaiting SIGCHLD reaping became a
  zombie; the old stop path returned would-not-die. MARDUK's B0 branch
  now treats that child state as stopped.
- The corrected SysGen candidate passed its existing 8/8 tests.
- Isolated B0 dispatch and cleanup passed.
- Minsky production sysgend v0.1.4 and Corbato user K9 were preserved.

Receipts are retained under Minsky 3OX.Ai/_meta/proof, including the
initial HOLD and later PASS results.

## Next admission gate

Reconcile Boxd B0 with the real Box.Application and the CLI's
multi-cube discovery. Validate six faces, daemon declarations and
dependencies for each selected cube before live B0 admission.
Only then enable B1–B8 under B0 ownership.

:: ∎
