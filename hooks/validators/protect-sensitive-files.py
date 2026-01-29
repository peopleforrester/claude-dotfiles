#!/usr/bin/env python3
# ABOUTME: Pre-tool hook to block edits to sensitive files
# ABOUTME: Exits with non-zero status to block the operation

"""
Protect Sensitive Files Hook

This script is designed to run as a PreToolUse hook to prevent
Claude from reading or modifying sensitive files.

Usage in settings.json:
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read(*)|Write(*)|Edit(*)",
        "hooks": [{
          "type": "command",
          "command": "python3 ~/.claude/hooks/protect-sensitive-files.py \"$CLAUDE_FILE_PATH\""
        }]
      }
    ]
  }
}
"""

import sys
import os
from pathlib import Path

# Files and patterns to protect
PROTECTED_PATTERNS = [
    # Environment files
    ".env",
    ".env.*",
    ".env.local",
    ".env.production",
    ".env.development",

    # Credential files
    "credentials.json",
    "credentials.yaml",
    "credentials.yml",
    "secrets.json",
    "secrets.yaml",
    "secrets.yml",
    ".secrets",

    # Key files
    "*.pem",
    "*.key",
    "*.p12",
    "*.pfx",
    "id_rsa",
    "id_ed25519",
    "id_ecdsa",

    # Config files with potential secrets
    ".npmrc",
    ".pypirc",
    ".netrc",
    ".docker/config.json",

    # Cloud credentials
    ".aws/credentials",
    ".aws/config",
    "gcloud/*.json",
    ".azure/credentials",
]

# Directories to protect entirely
PROTECTED_DIRECTORIES = [
    ".git",
    "secrets",
    "credentials",
    ".aws",
    ".ssh",
    ".gnupg",
]


def matches_pattern(filepath: str, pattern: str) -> bool:
    """Check if filepath matches the given pattern."""
    path = Path(filepath)
    name = path.name

    # Handle wildcard patterns
    if pattern.startswith("*."):
        return name.endswith(pattern[1:])

    if pattern.endswith(".*"):
        base = pattern[:-2]
        return name.startswith(base + ".")

    if "*" in pattern:
        # Simple glob matching
        parts = pattern.split("*")
        if len(parts) == 2:
            return name.startswith(parts[0]) and name.endswith(parts[1])

    # Exact match or path component match
    return name == pattern or pattern in str(path)


def is_protected(filepath: str) -> tuple[bool, str]:
    """Check if a file is protected."""
    if not filepath:
        return False, ""

    path = Path(filepath)
    normalized = str(path).replace("\\", "/")

    # Check protected directories
    for protected_dir in PROTECTED_DIRECTORIES:
        if f"/{protected_dir}/" in f"/{normalized}/" or normalized.startswith(f"{protected_dir}/"):
            return True, f"Directory '{protected_dir}' is protected"

    # Check protected patterns
    for pattern in PROTECTED_PATTERNS:
        if matches_pattern(filepath, pattern):
            return True, f"File matches protected pattern '{pattern}'"

    return False, ""


def main():
    if len(sys.argv) < 2:
        print("Usage: protect-sensitive-files.py <filepath>", file=sys.stderr)
        sys.exit(0)  # Don't block if no filepath provided

    filepath = sys.argv[1]

    # Skip if empty or placeholder
    if not filepath or filepath == "$CLAUDE_FILE_PATH":
        sys.exit(0)

    protected, reason = is_protected(filepath)

    if protected:
        print(f"BLOCKED: {reason}", file=sys.stderr)
        print(f"File: {filepath}", file=sys.stderr)
        sys.exit(1)

    # File is not protected, allow the operation
    sys.exit(0)


if __name__ == "__main__":
    main()
