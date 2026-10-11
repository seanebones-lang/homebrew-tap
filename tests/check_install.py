#!/usr/bin/env python3
"""Validate an actual Homebrew installation using only disposable state."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def require(value, message):
    if not value:
        raise RuntimeError(message)


def run(args, **kwargs):
    return subprocess.run([str(x) for x in args], check=True, capture_output=True,
                          text=True, timeout=90, **kwargs)


def check(token, brew_env=None):
    release = json.loads((ROOT / "releases.json").read_text())[token]
    arch = platform.machine()
    expected = release["macos"][arch]
    prefix = Path(run(["brew", "--prefix"]).stdout.strip())
    link = prefix / "bin/deadbolt"
    binary = link.resolve(strict=True)
    caskroom = Path(run(["brew", "--caskroom"]).stdout.strip())
    require(binary.is_relative_to(caskroom / token / release["version"]),
            "deadbolt command does not belong to the selected installed cask")
    require(hashlib.sha256(binary.read_bytes()).hexdigest() == expected["binary_sha256"],
            "installed executable differs from the reviewed signed release")
    run(["codesign", "--verify", "--strict", binary])
    identity = subprocess.run(["codesign", "-dv", "--verbose=4", str(binary)],
                              capture_output=True, text=True, timeout=30).stderr
    require("Authority=Developer ID Application:" in identity and
            "TeamIdentifier=L35VLYNTLK" in identity, "unexpected signing identity")
    info = json.loads(run(["brew", "info", "--json=v2", "--cask", token], env=brew_env).stdout)["casks"][0]
    require(info["version"] == release["version"], "wrong installed cask version")
    require(info["sha256"] == expected["archive_sha256"], "wrong cask archive hash")
    require(info["url"].endswith("/" + expected["archive"]), "wrong archive selection")

    # Never inherit an operator connection, admission token or production store.
    env = {k: v for k, v in os.environ.items()
           if not k.startswith("DEADBOLT_") and k not in ("PYTHONPATH", "PYTHONHOME", "OPENAI_API_KEY")}
    with tempfile.TemporaryDirectory(prefix="deadbolt-brew-acceptance-") as temp:
        env.update(DEADBOLT_DB=str(Path(temp) / "state.db"),
                   DEADBOLT_EVENTS=str(Path(temp) / "events.jsonl"),
                   DEADBOLT_SOCK=str(Path(temp) / "sidecar.sock"))
        version = run([binary, "--version"], env=env).stdout.strip()
        require(version == "deadbolt " + release["version"], "wrong executable version")
        require("deadbolt drill ok" in run([binary, "drill"], env=env).stdout, "drill failed")
        evaluation = binary.parent / "examples/evaluate.py"
        require(evaluation.is_file(), "release evaluation was not retained in the cask")
        report = json.loads(run([sys.executable, evaluation, "--binary", binary], env=env).stdout)
        require(report.get("passed") is True and len(report["checks"]) == 11,
                "installed file-effect evaluation did not pass all eleven cases")
        require(report["binary_sha256"] == expected["binary_sha256"], "evaluation used another binary")
    return {"cask": token, "version": release["version"], "architecture": arch,
            "archive_sha256": expected["archive_sha256"], "binary_sha256": expected["binary_sha256"],
            "signature": "strict verification and expected Developer ID passed",
            "version_and_drill": "passed", "file_effect_evaluation": report,
            "provider_requests": 0}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("cask", choices=("n11-deadbolt", "n11-deadbolt-preview"))
    args = parser.parse_args()
    print(json.dumps(check(args.cask), indent=2))
