#!/usr/bin/env python3
"""Install, reinstall, reject conflicting channel and remove an owned test cask."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile

from check_install import check, require, run

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("cask", choices=("n11-deadbolt", "n11-deadbolt-preview"))
parser.add_argument("--report", type=Path, required=True)
args = parser.parse_args()
other = "n11-deadbolt-preview" if args.cask == "n11-deadbolt" else "n11-deadbolt"
prefix = Path(run(["brew", "--prefix"]).stdout.strip())
binary_link = prefix / "bin/deadbolt"
require(not binary_link.exists() and not binary_link.is_symlink(),
        "existing deadbolt command must not be overwritten by this test")
before = set(run(["brew", "list", "--cask"]).stdout.splitlines())
require(not before.intersection((args.cask, other)), "existing user cask must not be altered")
env = {k: v for k, v in os.environ.items() if not k.startswith("DEADBOLT_")}
env.update(HOMEBREW_NO_AUTO_UPDATE="1", HOMEBREW_NO_INSTALL_CLEANUP="1")
owned = False
workspace = tempfile.TemporaryDirectory(prefix="deadbolt-brew-lifecycle-")
try:
    temp = workspace.name
    # Trust only these two reviewed casks in a disposable Homebrew config.
    env["XDG_CONFIG_HOME"] = str(Path(temp) / "config")
    run(["brew", "trust", "--cask", "seanebones-lang/tap/" + args.cask,
         "seanebones-lang/tap/" + other], env=env)
    result = subprocess.run(["brew", "install", "--cask", "seanebones-lang/tap/" + args.cask],
                            env=env, text=True, timeout=180)
    owned = args.cask in run(["brew", "list", "--cask"], env=env).stdout.splitlines()
    require(result.returncode == 0, "cask install failed")
    first = check(args.cask, env)
    marker = Path(temp) / "application-state/retain.txt"
    marker.parent.mkdir()
    marker.write_text("application-owned state survives package lifecycle\n")
    state_env = {**env, "DEADBOLT_DB": str(marker.parent / "state.db"),
                 "DEADBOLT_EVENTS": str(marker.parent / "events.jsonl")}
    run([binary_link, "ensure", "--agent", "lifecycle-test"], env=state_env)
    run([binary_link, "kill", "--agent", "lifecycle-test"], env=state_env)
    db = Path(state_env["DEADBOLT_DB"])
    snapshot = db.read_bytes()
    rejected = subprocess.run(["brew", "install", "--cask", "seanebones-lang/tap/" + other],
                              env=env, capture_output=True, text=True, timeout=180)
    require(rejected.returncode != 0 and "conflict" in (rejected.stdout + rejected.stderr).lower(),
            "other channel was not explicitly refused as conflicting")
    require(set(run(["brew", "list", "--cask"], env=env).stdout.splitlines()) == before | {args.cask},
            "conflict attempt changed installed casks")
    subprocess.run(["brew", "reinstall", "--cask", "seanebones-lang/tap/" + args.cask],
                   check=True, env=env, text=True, timeout=180)
    second = check(args.cask, env)
    require(db.read_bytes() == snapshot and marker.read_text().startswith("application-owned"),
            "reinstall modified application-owned state")
    subprocess.run(["brew", "uninstall", "--cask", args.cask],
                   check=True, env=env, text=True, timeout=180)
    owned = False
    require(not binary_link.exists() and not binary_link.is_symlink(), "uninstall left command link")
    require(db.read_bytes() == snapshot and marker.exists(), "uninstall removed private state")
    require(set(run(["brew", "list", "--cask"], env=env).stdout.splitlines()) == before,
            "test altered unrelated installed casks")
    report = {"passed": True, "initial_install": first, "reinstall": second,
              "conflicting_channel": "explicitly refused without changing installed casks",
              "application_state": "database and marker unchanged after reinstall and uninstall",
              "cleanup": "owned cask removed; unrelated casks unchanged; temporary trust removed",
              "limits": "Reinstall tested; no upgrade between distinct stable versions claimed."}
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n")
finally:
    try:
        if owned:
            subprocess.run(["brew", "uninstall", "--cask", args.cask], check=True, env=env, timeout=180)
    finally:
        workspace.cleanup()
