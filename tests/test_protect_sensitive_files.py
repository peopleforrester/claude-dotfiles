#!/usr/bin/env python3
# ABOUTME: Unit tests for hooks/validators/protect-sensitive-files.py
# ABOUTME: Verifies stdin JSON reading and fail-closed behavior on missing paths.

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPT = ROOT / "hooks" / "validators" / "protect-sensitive-files.py"


def run(stdin: str) -> tuple[int, str]:
    """Invoke the hook, returning (exit_code, stderr)."""
    result = subprocess.run(
        ["python3", str(SCRIPT)],
        input=stdin,
        text=True,
        capture_output=True,
        timeout=10,
    )
    return result.returncode, result.stderr


def expect(label: str, got_exit: int, want_exit: int):
    if got_exit != want_exit:
        print(f"FAIL: {label}: expected exit {want_exit}, got {got_exit}")
        sys.exit(1)
    print(f"  {label}: PASS (exit {got_exit})")


def test_sensitive_file_blocked():
    stdin = json.dumps({"tool_input": {"file_path": "/home/user/.env"}})
    code, _ = run(stdin)
    expect("sensitive .env blocked", code, 1)


def test_ssh_key_blocked():
    stdin = json.dumps({"tool_input": {"file_path": "/home/user/.ssh/id_rsa"}})
    code, _ = run(stdin)
    expect(".ssh/id_rsa blocked", code, 1)


def test_safe_file_allowed():
    stdin = json.dumps({"tool_input": {"file_path": "/home/user/project/main.py"}})
    code, _ = run(stdin)
    expect("safe path allowed", code, 0)


def test_empty_path_fails_closed():
    stdin = json.dumps({"tool_input": {"file_path": ""}})
    code, _ = run(stdin)
    expect("empty path fails closed", code, 1)


def test_missing_tool_input_fails_closed():
    stdin = json.dumps({})
    code, _ = run(stdin)
    expect("missing tool_input fails closed", code, 1)


def test_malformed_stdin_fails_closed():
    code, _ = run("not valid json")
    expect("malformed stdin fails closed", code, 1)


def test_no_stdin_fails_closed():
    result = subprocess.run(
        ["python3", str(SCRIPT)],
        input="",
        text=True,
        capture_output=True,
        timeout=10,
    )
    if result.returncode != 1:
        print(f"FAIL: empty stdin should fail closed, got {result.returncode}")
        sys.exit(1)
    print("  empty stdin fails closed: PASS (exit 1)")


if __name__ == "__main__":
    print("tests/test_protect_sensitive_files.py")
    test_sensitive_file_blocked()
    test_ssh_key_blocked()
    test_safe_file_allowed()
    test_empty_path_fails_closed()
    test_missing_tool_input_fails_closed()
    test_malformed_stdin_fails_closed()
    test_no_stdin_fails_closed()
    print("  all: PASS")
