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


def test_estimator_matches_current_tokenizer():
    """The fallback estimator should track the tokenizer Claude actually uses.

    Anthropic's model overview (fetched 2026-09-17) states that on the current
    tokenizer, introduced with Claude Opus 4.7, 1M tokens is roughly 555k words
    or 2.5M Unicode characters. That is ~1.80 tokens per word and ~2.5
    characters per token. An estimator calibrated to an older tokenizer reports
    a CLAUDE.md as comfortably inside a budget it actually exceeds.
    """
    # Ordinary English prose, just under 5 characters per word including the
    # separator. A single repeated long word would skew the character half of
    # the estimate and test nothing about the calibration.
    sample = "the build runs a set of checks on every commit and reports what it found " * 120
    words = len(sample.split())
    chars = len(sample)
    est = tc.count_tokens_estimate(sample)

    assert_eq(
        "estimator implies 1.6-2.0 tokens per word",
        1.6 <= est / words <= 2.0,
        True,
    )
    assert_eq(
        "estimator implies 2.2-2.9 characters per token",
        2.2 <= chars / est <= 2.9,
        True,
    )


if __name__ == "__main__":
    print("tests/test_token_count.py")
    test_plain_integer()
    test_comma_formatted()
    test_comma_formatted_large()
    test_no_tilde()
    test_absent()
    test_estimator_matches_current_tokenizer()
    print("  all: PASS")
