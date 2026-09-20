#!/usr/bin/env python3
"""Check that the publishing guard asks or allows as intended.

Cases live in cases.tsv as "expected<TAB>command". "ask" means the guard must
stop the command for review; "allow" means it must pass through untouched.

The last check builds a throwaway repository whose branch tracks a remote other
than origin, because that case cannot be expressed as a string: the guard has to
resolve the upstream to see where a bare git push would land.
"""

import json
import pathlib
import shutil
import subprocess
import sys
import tempfile

HERE = pathlib.Path(__file__).resolve().parent
GUARD = HERE.parent / "gh-publish-guard.sh"
CASES = HERE / "cases.tsv"

GIT = "git"
PUSH = "push"


def decision(command: str, cwd: str) -> str:
    """Run the guard over one command and return its permission decision."""
    payload = json.dumps(
        {"tool_name": "Bash", "cwd": cwd, "tool_input": {"command": command}}
    )
    out = subprocess.run(
        [str(GUARD)], input=payload, capture_output=True, text=True
    ).stdout.strip()
    if not out:
        return "allow"
    return json.loads(out)["hookSpecificOutput"]["permissionDecision"]


def run_table_cases() -> list[str]:
    failures = []
    for line in CASES.read_text().splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        expected, command = line.split("\t", 1)
        got = decision(command, str(pathlib.Path.home()))
        if got != expected:
            failures.append(f"expected {expected}, got {got}: {command}")
    return failures


def run_upstream_case() -> list[str]:
    """A bare push on a branch tracking a non-origin remote must be stopped."""
    tmp = pathlib.Path(tempfile.mkdtemp(prefix="guard-fixture-"))
    try:
        remote, work = tmp / "fork.git", tmp / "wc"
        work.mkdir()
        quiet = {"capture_output": True, "text": True}
        subprocess.run([GIT, "init", "--bare", "-q", str(remote)], **quiet)
        subprocess.run([GIT, "init", "-q", "-b", "work", str(work)], **quiet)
        for key, value in [
            ("user.email", "test@example.com"),
            ("user.name", "Test"),
            ("commit.gpgsign", "false"),
        ]:
            subprocess.run([GIT, "-C", str(work), "config", key, value], **quiet)
        (work / "f.txt").write_text("x\n")
        subprocess.run([GIT, "-C", str(work), "add", "f.txt"], **quiet)
        subprocess.run([GIT, "-C", str(work), "commit", "-qm", "init"], **quiet)
        subprocess.run(
            [GIT, "-C", str(work), "remote", "add", "contributor", str(remote)], **quiet
        )
        subprocess.run(
            [GIT, "-C", str(work), PUSH, "-q", "-u", "contributor", "work"], **quiet
        )

        upstream = subprocess.run(
            [GIT, "-C", str(work), "rev-parse", "--abbrev-ref", "@{u}"], **quiet
        ).stdout.strip()
        if upstream != "contributor/work":
            return [f"fixture did not set a non-origin upstream (got {upstream!r})"]

        got = decision(f"{GIT} {PUSH}", str(work))
        if got != "ask":
            return [f"bare push to a fork upstream: expected ask, got {got}"]
        return []
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def main() -> int:
    if not GUARD.exists():
        print(f"guard not found at {GUARD}", file=sys.stderr)
        return 1

    failures = run_table_cases() + run_upstream_case()
    total = len(CASES.read_text().splitlines()) + 1

    for failure in failures:
        print(f"FAIL {failure}")
    print(f"{total} checks, {len(failures)} failures")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
