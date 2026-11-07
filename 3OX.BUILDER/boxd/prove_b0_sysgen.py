#!/usr/bin/env python3
"""B0-first: isolated Boxd BEAM lifecycle plus governed SysGen start/status/stop.

Does not modify active SysGen, Box.Application, user K9, systemd, or _TRON.
Uses a disposable SysGen root and an isolated, source-controlled Boxd B0.
"""
import argparse
import datetime as dt
import json
import os
from pathlib import Path
import signal
import socket
import subprocess
import sys
import tempfile
import time

EXPECTED = (
    "start", "singleton", "reject-invalid", "admit-two",
    "healthy-children", "reject-duplicate", "survive",
    "isolate-and-restart-child", "shutdown-b0", "shutdown-children"
)

def check(condition, name):
    if not condition:
        raise RuntimeError("HOLD:" + name)
    print("B0_SYSgen_PASS stage=" + name, flush=True)

def exec_ok(args, env, timeout=30):
    return subprocess.run(args, env=env, text=True, capture_output=True,
                          timeout=timeout)

def wait_for(predicate, name, seconds=10):
    end = time.monotonic() + seconds
    while time.monotonic() < end:
        outcome = predicate()
        if outcome:
            return outcome
        time.sleep(0.05)
    raise RuntimeError("HOLD:timeout-" + name)

def petition(root, verb, request_id, env, daemon):
    queue = root / "relay/queue"
    dest = queue / (request_id + ".cmd")
    pending = queue / ("." + request_id + ".pending")
    pending.write_text("verb=" + verb + "\nseat=boxd-b0\n")
    pending.rename(dest)

    def find_receipt():
        if daemon.poll() is not None:
            raise RuntimeError("HOLD:isolated-sysgen-exited")
        if not (root / "relay/drained" / dest.name).exists():
            return None
        bus = root / "emit/bus"
        if not bus.is_file():
            return None
        for line in reversed(bus.read_text().splitlines()):
            if ("kind=sysgen.tau" in line and
                "id=" + request_id + " " in line and
                "verb=" + verb + " " in line):
                return line
        return None

    receipt = wait_for(find_receipt, verb + "-receipt", 14)
    if "status=ok" not in receipt:
        raise RuntimeError("HOLD:sysgen-" + verb + ":" + receipt)
    return receipt

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sysgend", type=Path, required=True)
    parser.add_argument("--elixir", type=Path, required=True)
    parser.add_argument("--erl-bin", type=Path, required=True)
    parser.add_argument("--b0", type=Path, default=Path(__file__).with_name("b0.exs"))
    parser.add_argument("--receipt", type=Path, required=True)
    args = parser.parse_args()

    for name, p in (("sysgend", args.sysgend), ("elixir", args.elixir),
                    ("b0", args.b0), ("erl", args.erl_bin / "erl")):
        check(p.is_file() and p.resolve(strict=True).is_file(),
              name + "-present")
    check(args.receipt.parent.is_dir() and
          not args.receipt.parent.is_symlink() and
          not args.receipt.exists(), "receipt-destination-empty")

    env = dict(os.environ)
    env["PATH"] = str(args.elixir.parent) + ":" + str(args.erl_bin) + ":" + env.get("PATH", "")
    data = {
        "schema": "3ox.boxd.b0.sysgen-startup/v1",
        "host": socket.gethostname(),
        "tested_at_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "sysgend_candidate": str(args.sysgend),
        "b0_source": str(args.b0),
        "production_sysgen_replaced": False,
        "live_k9_restarted": False,
        "stages": []
    }
    b0_pid = None
    tmp_path = None
    try:
        stand = exec_ok([str(args.elixir), str(args.b0), "b0", "proof"], env, 30)
        observed = [
            line.split("stage=", 1)[1].strip()
            for line in stand.stdout.splitlines()
            if line.startswith("BOXD_B0_PASS stage=")
        ]
        check(stand.returncode == 0 and tuple(observed) == EXPECTED and
              "BOXD_B0_RESULT status=ok stages=10" in stand.stdout,
              "b0-lifecycle-ten-assertions")
        data["stages"].append({"stage": "b0-lifecycle", "result": "PASS",
                               "assertions": observed})
        with tempfile.TemporaryDirectory(prefix="3ox-boxd-b0-") as dirname:
            tmp_path = Path(dirname)
            root = tmp_path
            (root / "registry/v1").mkdir(parents=True)
            (root / "relay/queue").mkdir(parents=True)
            (root / "relay/drained").mkdir(parents=True)
            (root / "registry/v1/seats.kdl").write_text(
                'seat "boxd-b0" {\n'
                ' name "boxd-b0"\n'
                ' kind "daemon"\n'
                ' box "' + str(args.b0.parent) + '"\n'
                ' run "' + str(args.elixir) + ' ' + str(args.b0) +
                    ' b0 run --isolated"\n'
                ' enabled #true\n'
                ' keep #false\n'
                '}\n'
            )
            env2 = dict(env)
            env2["SYSGEN_ROOT"] = str(root)
            logpath = root / "sysgend.log"
            with logpath.open("w+") as log:
                daemon = subprocess.Popen([str(args.sysgend), "run"],
                                          cwd=root, env=env2, stdout=log,
                                          stderr=subprocess.STDOUT)
                try:
                    def ready():
                        if daemon.poll() is not None:
                            raise RuntimeError("HOLD:isolated-sysgend-exited:" +
                                               logpath.read_text()[-600:])
                        return (root / "load/.sysgend/pid").exists()
                    wait_for(ready, "sysgen-ready", 7)
                    check(True, "sysgen-isolated-ready")
                    data["stages"].append({"stage": "sysgen", "result": "PASS"})
                    start = petition(root, "start", "b0-start", env2, daemon)
                    pid_path = root / "load/boxd-b0/pid"
                    b0_pid = int(wait_for(
                        lambda: pid_path.read_text().strip() if pid_path.is_file() else "",
                        "b0-pid", 5))
                    runlog = root / "load/boxd-b0/log"
                    wait_for(
                        lambda: runlog.is_file() and
                          "BOXD_B0_READY state=isolated" in runlog.read_text(),
                        "b0-ready", 9
                    )
                    check(Path("/proc/" + str(b0_pid)).exists(), "b0-running")
                    time.sleep(0.35)
                    check(Path("/proc/" + str(b0_pid)).exists(),
                          "b0-survives-idle")
                    status = petition(root, "status", "b0-status", env2, daemon)
                    check("pid=" + str(b0_pid) in status,
                          "sysgen-recognizes-b0-pid")
                    stop = petition(root, "stop", "b0-stop", env2, daemon)
                    wait_for(lambda: not pid_path.exists(), "b0-pid-cleared", 6)
                    check(True, "sysgen-stop-and-cleanup")
                    data["stages"].append({
                        "stage": "governed-start-status-stop",
                        "result": "PASS", "pid": b0_pid,
                        "start_tau": start, "status_tau": status, "stop_tau": stop,
                        "ready_witness": "BOXD_B0_READY state=isolated",
                    })
                finally:
                    if b0_pid:
                        cmdline = Path("/proc/" + str(b0_pid) + "/cmdline")
                        try:
                            cmd = cmdline.read_bytes().replace(b"\0", b" ").decode(
                                "utf-8", "replace")
                            # Fallback only for this uniquely sourced isolated B0.
                            if str(args.b0) in cmd and "b0 run --isolated" in cmd:
                                os.kill(b0_pid, signal.SIGTERM)
                        except (FileNotFoundError, ProcessLookupError):
                            pass
                    if daemon.poll() is None:
                        daemon.terminate()
                        try:daemon.wait(timeout=6)
                        except subprocess.TimeoutExpired:
                            daemon.kill()
                            daemon.wait(timeout=3)
        check(tmp_path is not None and not tmp_path.exists(),
              "isolated-root-removed")
        data["stages"].append({"stage": "cleanup", "result": "PASS"})
        data["result"] = "PASS"
    except Exception as exc:
        data["result"] = "HOLD"
        data["error"] = str(exc)
        print(str(exc), file=sys.stderr)
    args.receipt.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
    print("B0_RECEIPT " + str(args.receipt))
    print("B0_RESULT " + data["result"])
    return 0 if data["result"] == "PASS" else 2

if __name__ == "__main__":
    sys.exit(main())
