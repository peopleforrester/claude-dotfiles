#!/usr/bin/env python3
# ABOUTME: Unit tests for scripts/token-count.py helper functions.
# ABOUTME: Verifies that comma-formatted token counts are parsed correctly.

import importlib.util
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPT = ROOT / "scripts" / "token-count.py"

spec = importlib.util.spec_from_file_location("token_count", SCRIPT)
tc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(tc)


def assert_eq(label, actual, expected):
    if actual != expected:
        print(f"FAIL: {label}: expected {expected!r}, got {actual!r}")
        sys.exit(1)
    print(f"  {label}: PASS")


def test_plain_integer():
    content = "<!-- Tokens: ~749 | Lines: 80 -->\n# Doc"
    assert_eq("plain integer", tc.extract_existing_token_comment(content), 749)


def test_comma_formatted():
    content = "<!-- Tokens: ~1,400 | Lines: 120 -->\n# Doc"
    assert_eq("comma-formatted ~1,400", tc.extract_existing_token_comment(content), 1400)


def test_comma_formatted_large():
    content = "<!-- Tokens: ~15,238 -->\n# Doc"
    assert_eq("comma-formatted ~15,238", tc.extract_existing_token_comment(content), 15238)


def test_no_tilde():
    content = "<!-- Tokens: 500 -->\n# Doc"
    assert_eq("no tilde", tc.extract_existing_token_comment(content), 500)


def test_absent():
    content = "# Doc with no token header"
    assert_eq("absent header", tc.extract_existing_token_comment(content), None)


if __name__ == "__main__":
    print("tests/test_token_count.py")
    test_plain_integer()
    test_comma_formatted()
    test_comma_formatted_large()
    test_no_tilde()
    test_absent()
    print("  all: PASS")
