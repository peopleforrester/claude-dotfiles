#!/usr/bin/env python3
# ABOUTME: Pre-tool hook to block edits to sensitive files
# ABOUTME: Exits with non-zero status to block the operation

"""
# =============================================================================
# Protect Sensitive Files Hook for Claude Code
# =============================================================================

PURPOSE:
This script is designed to run as a PreToolUse hook to prevent Claude Code
from reading or modifying sensitive files like credentials, API keys,
environment files, and SSH keys.

WHY IS THIS NEEDED?
Claude Code has access to your filesystem through the Read, Write, and Edit
tools. While Claude is designed to be helpful and safe, adding an extra layer
of protection for sensitive files provides defense-in-depth:

1. Prevents accidental exposure of secrets in conversation history
2. Blocks modifications to credential files
3. Protects private keys and certificates
4. Enforces security policies in team environments

HOW IT WORKS:
1. Claude Code calls this script BEFORE reading/writing/editing a file
2. The script checks if the file matches any protected pattern
3. If protected: Exit with code 1 (blocks the operation)
4. If not protected: Exit with code 0 (allows the operation)

CONFIGURATION:
Add this hook to your settings.json:

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

MATCHER EXPLAINED:
"Read(*)|Write(*)|Edit(*)"
- Read(*): Matches any file read operation
- Write(*): Matches any file write operation
- Edit(*): Matches any file edit operation
- | (pipe): OR operator - matches any of these

ENVIRONMENT VARIABLE:
$CLAUDE_FILE_PATH: Set by Claude Code to the path being accessed
This is how the hook knows which file is being operated on.

CUSTOMIZATION:
Modify PROTECTED_PATTERNS and PROTECTED_DIRECTORIES to customize what's blocked.
The default configuration protects common credential and key file locations.
"""

# =============================================================================
# IMPORTS
# =============================================================================
# We use only standard library modules to avoid dependency issues.
# This script must run on any system with Python 3 installed.
# =============================================================================

import sys           # For command-line arguments and exit codes
import os            # For path operations (not used but commonly needed)
from pathlib import Path  # Modern path handling (cross-platform)

# =============================================================================
# PROTECTED FILE PATTERNS
# =============================================================================
# This list defines filename patterns that should be blocked.
# Patterns support simple wildcards:
# - *.extension: Matches files with that extension
# - .env.*: Matches .env.local, .env.production, etc.
#
# CATEGORIES OF PROTECTED FILES:
# 1. Environment files (.env) - Often contain API keys and secrets
# 2. Credential files - JSON/YAML files with "credentials" or "secrets" in name
# 3. Private keys - SSH, TLS certificates, signing keys
# 4. Package manager auth - npm, pip, docker registry credentials
# 5. Cloud provider credentials - AWS, GCP, Azure
# =============================================================================
PROTECTED_PATTERNS = [
    # =========================================================================
    # ENVIRONMENT FILES
    # =========================================================================
    # These files commonly contain sensitive configuration like:
    # - Database passwords
    # - API keys
    # - Secret tokens
    # - Third-party service credentials
    # =========================================================================
    ".env",              # Generic environment file
    ".env.*",            # .env.local, .env.staging, etc.
    ".env.local",        # Local overrides (often contains real credentials)
    ".env.production",   # Production secrets (highly sensitive!)
    ".env.development",  # Development credentials

    # =========================================================================
    # CREDENTIAL FILES
    # =========================================================================
    # Explicit credential storage files used by various applications
    # =========================================================================
    "credentials.json",  # Google Cloud, OAuth tokens
    "credentials.yaml",  # Kubernetes, Ansible secrets
    "credentials.yml",   # YAML variant
    "secrets.json",      # Application secrets
    "secrets.yaml",      # Kubernetes secrets
    "secrets.yml",       # YAML variant
    ".secrets",          # Hidden secrets file

    # =========================================================================
    # CRYPTOGRAPHIC KEY FILES
    # =========================================================================
    # Private keys and certificates should NEVER be shared or exposed
    # Exposing these can lead to:
    # - Unauthorized access to servers
    # - Man-in-the-middle attacks
    # - Identity theft
    # =========================================================================
    "*.pem",             # PEM-encoded certificates/keys
    "*.key",             # Private key files
    "*.p12",             # PKCS#12 archives (certs + keys)
    "*.pfx",             # Windows certificate format
    "id_rsa",            # RSA SSH private key
    "id_ed25519",        # Ed25519 SSH private key (modern)
    "id_ecdsa",          # ECDSA SSH private key

    # =========================================================================
    # PACKAGE MANAGER AUTHENTICATION
    # =========================================================================
    # These files contain tokens for publishing packages or accessing
    # private registries
    # =========================================================================
    ".npmrc",            # npm registry auth tokens
    ".pypirc",           # PyPI publishing credentials
    ".netrc",            # FTP/Git credentials (plaintext!)
    ".docker/config.json",  # Docker registry auth

    # =========================================================================
    # CLOUD PROVIDER CREDENTIALS
    # =========================================================================
    # Cloud credentials provide access to infrastructure, databases,
    # storage, and can incur significant costs if misused
    # =========================================================================
    ".aws/credentials",  # AWS access keys and secret keys
    ".aws/config",       # AWS configuration (may contain role ARNs)
    "gcloud/*.json",     # Google Cloud service account keys
    ".azure/credentials", # Azure credentials
]

# =============================================================================
# PROTECTED DIRECTORIES
# =============================================================================
# These entire directories are considered sensitive.
# Any file within these directories will be blocked.
# =========================================================================
PROTECTED_DIRECTORIES = [
    ".git",         # Git internals - modifying can corrupt repository
    "secrets",      # Convention: secrets directory
    "credentials",  # Convention: credentials directory
    ".aws",         # AWS CLI credentials directory
    ".ssh",         # SSH keys and known hosts
    ".gnupg",       # GPG keys and configuration
]


# =============================================================================
# PATTERN MATCHING FUNCTION
# =============================================================================
def matches_pattern(filepath: str, pattern: str) -> bool:
    """
    Check if a filepath matches the given pattern.

    This function implements simple glob-like pattern matching without
    using the glob module. It handles common patterns used in file
    protection rules.

    SUPPORTED PATTERNS:
    - "*.extension": Matches files ending with .extension
    - "name.*": Matches files starting with name.
    - "exact": Exact filename match
    - "path/component": Matches if pattern appears in path

    Parameters:
        filepath: The full path to the file being checked
        pattern: The pattern to match against

    Returns:
        True if the filepath matches the pattern, False otherwise

    Examples:
        matches_pattern("/home/user/.env", ".env") -> True
        matches_pattern("/app/config.json", "*.json") -> True
        matches_pattern("/app/.aws/credentials", ".aws/credentials") -> True
    """
    # Convert to Path object for easier manipulation
    path = Path(filepath)
    name = path.name  # Just the filename, not the full path

    # =========================================================================
    # PATTERN: *.extension
    # =========================================================================
    # Matches files by extension
    # Example: "*.pem" matches "server.pem", "private.pem", etc.
    # =========================================================================
    if pattern.startswith("*."):
        # Extract extension (including the dot)
        # "*.pem" -> ".pem"
        return name.endswith(pattern[1:])

    # =========================================================================
    # PATTERN: prefix.*
    # =========================================================================
    # Matches files starting with a prefix followed by a dot
    # Example: ".env.*" matches ".env.local", ".env.production"
    # =========================================================================
    if pattern.endswith(".*"):
        # Extract the base name
        # ".env.*" -> ".env"
        base = pattern[:-2]
        return name.startswith(base + ".")

    # =========================================================================
    # PATTERN: prefix*suffix
    # =========================================================================
    # Matches files with specific prefix and suffix
    # This handles patterns like "credential*.json"
    # =========================================================================
    if "*" in pattern:
        # Split on the wildcard
        parts = pattern.split("*")
        if len(parts) == 2:
            return name.startswith(parts[0]) and name.endswith(parts[1])

    # =========================================================================
    # EXACT MATCH OR PATH COMPONENT
    # =========================================================================
    # Check for exact filename match or if the pattern appears
    # anywhere in the path (for patterns like ".aws/credentials")
    # =========================================================================
    return name == pattern or pattern in str(path)


# =============================================================================
# FILE PROTECTION CHECK FUNCTION
# =============================================================================
def is_protected(filepath: str) -> tuple[bool, str]:
    """
    Check if a file is protected from access.

    This function checks both protected directories and protected file patterns.
    It returns a tuple indicating whether the file is protected and why.

    Parameters:
        filepath: The path to check

    Returns:
        Tuple of (is_protected: bool, reason: str)
        - If protected: (True, "reason message")
        - If not protected: (False, "")

    Examples:
        is_protected("/home/user/.ssh/id_rsa") -> (True, "Directory '.ssh' is protected")
        is_protected("/app/src/main.py") -> (False, "")
    """
    # Handle empty or missing filepath
    if not filepath:
        return False, ""

    # Convert to Path and normalize for cross-platform compatibility
    # Replace backslashes with forward slashes (Windows paths)
    path = Path(filepath)
    normalized = str(path).replace("\\", "/")

    # =========================================================================
    # CHECK PROTECTED DIRECTORIES
    # =========================================================================
    # If the file is inside a protected directory, block it regardless
    # of the filename.
    # =========================================================================
    for protected_dir in PROTECTED_DIRECTORIES:
        # Check if the protected directory appears in the path
        # We add slashes to avoid partial matches (e.g., ".github" matching ".git")
        # "/.git/" would match "/project/.git/config" but not "/project/.github/workflows"
        if f"/{protected_dir}/" in f"/{normalized}/" or normalized.startswith(f"{protected_dir}/"):
            return True, f"Directory '{protected_dir}' is protected"

    # =========================================================================
    # CHECK PROTECTED FILE PATTERNS
    # =========================================================================
    # Check if the filename matches any of our protected patterns
    # =========================================================================
    for pattern in PROTECTED_PATTERNS:
        if matches_pattern(filepath, pattern):
            return True, f"File matches protected pattern '{pattern}'"

    # File is not protected
    return False, ""


# =============================================================================
# MAIN FUNCTION
# =============================================================================
def main():
    """
    Main entry point for the protection hook.

    Reads the filepath from command-line arguments, checks if it's protected,
    and exits with appropriate code.

    EXIT CODES:
    - 0: File is not protected, operation is allowed
    - 1: File is protected, operation is blocked

    USAGE:
        python protect-sensitive-files.py /path/to/file

    The filepath is typically passed by Claude Code via $CLAUDE_FILE_PATH
    environment variable, which is substituted in the hook command.
    """
    # =========================================================================
    # ARGUMENT VALIDATION
    # =========================================================================
    # Check that we received a filepath argument
    # =========================================================================
    if len(sys.argv) < 2:
        print("Usage: protect-sensitive-files.py <filepath>", file=sys.stderr)
        # Don't block if no filepath provided - this shouldn't happen
        # but we don't want to break Claude Code if it does
        sys.exit(0)

    filepath = sys.argv[1]

    # =========================================================================
    # HANDLE EMPTY OR PLACEHOLDER VALUES
    # =========================================================================
    # If Claude Code passes an empty string or the literal placeholder,
    # allow the operation (this means no file is being accessed)
    # =========================================================================
    if not filepath or filepath == "$CLAUDE_FILE_PATH":
        sys.exit(0)

    # =========================================================================
    # CHECK PROTECTION STATUS
    # =========================================================================
    # Run the protection check and handle the result
    # =========================================================================
    protected, reason = is_protected(filepath)

    if protected:
        # File is protected - print reason and exit with error
        # This output will be shown to the user explaining why the
        # operation was blocked
        print(f"BLOCKED: {reason}", file=sys.stderr)
        print(f"File: {filepath}", file=sys.stderr)
        sys.exit(1)

    # =========================================================================
    # ALLOW OPERATION
    # =========================================================================
    # File is not protected, allow the operation to proceed
    # =========================================================================
    sys.exit(0)


# =============================================================================
# SCRIPT ENTRY POINT
# =============================================================================
# Standard Python idiom to run main() only when executed directly,
# not when imported as a module
# =============================================================================
if __name__ == "__main__":
    main()
