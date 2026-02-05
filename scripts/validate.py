#!/usr/bin/env python3
# ABOUTME: Validates JSON, YAML, and SKILL.md files in the repository
# ABOUTME: Checks syntax, frontmatter, and required fields

"""
Configuration Validator for claude-dotfiles

============================================================================
SCRIPT OVERVIEW
============================================================================
This script validates the configuration files in the claude-dotfiles repository
to ensure they're syntactically correct and follow the required format.

What it validates:
  - JSON files: Valid JSON syntax (our configs use a "// KEY": pattern for comments)
  - SKILL.md files: YAML frontmatter with required 'name' and 'description' fields
  - Markdown files: Internal links point to files that actually exist

Why this matters:
  - Invalid JSON will cause Claude Code to fail silently or ignore configs
  - Malformed SKILL.md files won't be recognized by Claude
  - Broken links frustrate users trying to navigate documentation

Usage examples:
    python scripts/validate.py                    # Validate entire repo
    python scripts/validate.py skills/            # Validate specific directory
    python scripts/validate.py skills/tdd/SKILL.md  # Validate specific file

Exit codes:
    0 = All validations passed
    1 = One or more errors found

============================================================================
"""

# =============================================================================
# IMPORTS
# =============================================================================
# Standard library imports only - no external dependencies required.
# This ensures the script can run on any system with Python 3.6+.
# =============================================================================

import json          # For parsing and validating JSON files
import os            # For environment variable access (not heavily used)
import re            # Regular expressions for pattern matching
import sys           # For command-line arguments and exit codes
from pathlib import Path  # Modern path handling (better than os.path)
from typing import List, Tuple, Optional  # Type hints for documentation


# =============================================================================
# TERMINAL COLORS
# =============================================================================
# ANSI escape codes for colorful terminal output.
# These make validation results easier to scan at a glance:
#   - Green for success
#   - Red for errors
#   - Yellow for warnings
#   - Blue for info
# =============================================================================

class Colors:
    """
    ANSI escape codes for terminal colors.

    These are special character sequences that terminals interpret as
    formatting instructions. The format is: \033[XXm where XX is a code:
      - 91 = Bright Red
      - 92 = Bright Green
      - 93 = Bright Yellow
      - 94 = Bright Blue
      - 1  = Bold
      - 0  = Reset all formatting

    Example usage:
        print(f"{Colors.RED}Error!{Colors.END}")  # Prints "Error!" in red
    """
    RED = '\033[91m'      # For errors and failures
    GREEN = '\033[92m'    # For success messages
    YELLOW = '\033[93m'   # For warnings
    BLUE = '\033[94m'     # For informational messages
    BOLD = '\033[1m'      # For emphasis
    END = '\033[0m'       # Resets formatting to default


def color(text: str, c: str) -> str:
    """
    Apply color to text if running in a terminal.

    This function wraps text with ANSI color codes, but only if stdout
    is connected to a terminal (TTY). This prevents color codes from
    polluting output when the script's output is redirected to a file
    or piped to another command.

    Args:
        text: The text to colorize
        c: The color code (one of Colors.RED, Colors.GREEN, etc.)

    Returns:
        The text wrapped with color codes (if TTY) or unchanged (if not TTY)

    Example:
        print(color("Success!", Colors.GREEN))  # Green if TTY, plain if not
    """
    # sys.stdout.isatty() returns True if stdout is a terminal
    if sys.stdout.isatty():
        return f"{c}{text}{Colors.END}"
    return text


# =============================================================================
# OUTPUT HELPER FUNCTIONS
# =============================================================================
# These functions provide a consistent way to print different types of
# messages. Using dedicated functions ensures consistent formatting and
# makes it easy to change the format in one place.
# =============================================================================

def success(msg: str) -> None:
    """
    Print a success message with a green checkmark prefix.

    Used to indicate that a file passed validation.

    Args:
        msg: The message to display (typically a file path)

    Output format: ✓ filename.json
    """
    print(f"{color('✓', Colors.GREEN)} {msg}")


def warning(msg: str) -> None:
    """
    Print a warning message with a yellow exclamation prefix.

    Used for non-critical issues that don't fail validation but
    should be reviewed, like broken internal links.

    Args:
        msg: The warning message to display

    Output format: ! Warning description
    """
    print(f"{color('!', Colors.YELLOW)} {msg}")


def error(msg: str) -> None:
    """
    Print an error message with a red X prefix.

    Used to indicate validation failures that need to be fixed.

    Args:
        msg: The error message to display

    Output format: ✗ Error description
    """
    print(f"{color('✗', Colors.RED)} {msg}")


def info(msg: str) -> None:
    """
    Print an informational message with a blue arrow prefix.

    Used for status updates and general information.

    Args:
        msg: The info message to display

    Output format: → Information
    """
    print(f"{color('→', Colors.BLUE)} {msg}")


# =============================================================================
# JSON VALIDATION
# =============================================================================
# Validates JSON file syntax. Note that our JSON files use a special
# "// KEY": "value" pattern for comments, which is valid JSON syntax
# (just a string key starting with "//").
# =============================================================================

def validate_json(file_path: Path) -> Tuple[bool, Optional[str]]:
    """
    Validate that a file contains valid JSON syntax.

    This function attempts to parse a JSON file and reports any syntax
    errors. It handles our convention of using "// KEY": "value" for
    comments, which is valid JSON (the key is just a string starting
    with "//").

    Args:
        file_path: Path to the JSON file to validate

    Returns:
        A tuple of (is_valid, error_message):
          - (True, None) if the file is valid JSON
          - (False, "error description") if validation failed

    Common JSON errors:
      - Trailing commas: {"a": 1,} - comma before closing brace
      - Missing quotes: {key: "value"} - keys must be quoted
      - Single quotes: {'key': 'value'} - must use double quotes
    """
    try:
        # Read the file with UTF-8 encoding to handle any special characters
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Note: Our JSON files use "// KEY": "description" for comments.
        # This is actually valid JSON - it's just a key that starts with "//".
        # We don't need to strip these; json.loads() handles them fine.
        #
        # The code below processes lines but doesn't actually modify anything.
        # It's preserved for potential future use (e.g., if we wanted to
        # strip actual // comments which are NOT valid JSON).
        lines = content.split('\n')
        cleaned_lines = []
        for line in lines:
            # Currently just keeps all lines as-is
            stripped = line.strip()
            if stripped.startswith('"//'):
                # This is our comment pattern - valid JSON, keep it
                cleaned_lines.append(line)
            else:
                cleaned_lines.append(line)

        cleaned_content = '\n'.join(cleaned_lines)

        # json.loads() parses JSON and returns Python objects.
        # If the JSON is invalid, it raises json.JSONDecodeError.
        json.loads(cleaned_content)

        return True, None

    except json.JSONDecodeError as e:
        # JSONDecodeError includes helpful info: line number, column, message
        return False, f"JSON syntax error: {e}"
    except Exception as e:
        # Catch other errors like file not found or permission denied
        return False, f"Error reading file: {e}"


# =============================================================================
# YAML FRONTMATTER VALIDATION
# =============================================================================
# SKILL.md files use YAML frontmatter (the section between --- markers).
# This parser handles simple YAML without requiring external libraries.
# =============================================================================

def validate_yaml_frontmatter(content: str) -> Tuple[bool, Optional[str], dict]:
    """
    Extract and parse YAML frontmatter from a Markdown file.

    YAML frontmatter is a common convention for adding metadata to Markdown:

        ---
        name: my-skill
        description: |
          A multi-line description
          that spans multiple lines.
        ---

        # Rest of the markdown document...

    This function implements a simple YAML parser that handles the subset
    of YAML we use in SKILL.md files:
      - Simple key: value pairs
      - Multi-line strings with | or > indicators
      - Nested keys under 'metadata'

    Args:
        content: The full content of the markdown file

    Returns:
        A tuple of (is_valid, error_message, parsed_data):
          - (True, None, {...}) if frontmatter is valid
          - (False, "error", {}) if validation failed

    Why not use PyYAML?
        We want this script to work without any pip dependencies.
        Our YAML usage is simple enough for a minimal parser.
    """
    # -------------------------------------------------------------------------
    # Check for opening delimiter
    # -------------------------------------------------------------------------
    # Frontmatter must start at the very beginning of the file with ---
    if not content.startswith('---'):
        return False, "Missing YAML frontmatter (file should start with ---)", {}

    # -------------------------------------------------------------------------
    # Find closing delimiter
    # -------------------------------------------------------------------------
    # Look for the closing --- after the opening one
    # We search starting from position 3 (after the opening ---)
    # The pattern \n---\s*\n matches a line containing only ---
    end_match = re.search(r'\n---\s*\n', content[3:])
    if not end_match:
        return False, "Missing closing --- for frontmatter", {}

    # Extract the frontmatter text (between the --- markers)
    frontmatter_text = content[3:end_match.start() + 3]

    # -------------------------------------------------------------------------
    # Parse the YAML content
    # -------------------------------------------------------------------------
    try:
        data = {}                    # Will hold the parsed key-value pairs
        current_key = None           # Current key for multi-line values
        current_value = []           # Lines of current multi-line value
        in_multiline = False         # Are we in a multi-line value?

        for line in frontmatter_text.split('\n'):
            # Skip empty lines (but include them in multi-line values)
            if not line.strip():
                if in_multiline:
                    current_value.append('')
                continue

            # ----------------------------------------------------------------
            # Check if this line starts a new key: value pair
            # ----------------------------------------------------------------
            # A line that doesn't start with a space and contains ':' is a key
            if not line.startswith(' ') and ':' in line:
                # Save the previous multi-line value if there was one
                if current_key and in_multiline:
                    data[current_key] = '\n'.join(current_value).strip()

                # Split the line into key and value at the first ':'
                # partition() returns (before, separator, after)
                key, _, value = line.partition(':')
                key = key.strip()
                value = value.strip()

                # Check for multi-line indicators: | (literal) or > (folded)
                if value == '|' or value == '>':
                    # Start collecting multi-line value
                    in_multiline = True
                    current_key = key
                    current_value = []
                elif value:
                    # Simple single-line value
                    data[key] = value
                    in_multiline = False
                    current_key = None
                else:
                    # Empty value
                    data[key] = ''
                    in_multiline = False

            # ----------------------------------------------------------------
            # Continuation of multi-line value
            # ----------------------------------------------------------------
            elif in_multiline and current_key:
                # This line is part of the multi-line value
                # Strip leading whitespace (YAML multi-line values are indented)
                current_value.append(line.strip())

        # Save the last multi-line value if the file ended during one
        if current_key and in_multiline:
            data[current_key] = '\n'.join(current_value).strip()

        return True, None, data

    except Exception as e:
        return False, f"YAML parsing error: {e}", {}


# =============================================================================
# SKILL.md VALIDATION
# =============================================================================
# Validates SKILL.md files according to the Claude Code skills specification.
# =============================================================================

def validate_skill_md(file_path: Path) -> List[str]:
    """
    Validate a SKILL.md file for required format and fields.

    According to the Claude Code skills specification, SKILL.md files must:
      1. Have YAML frontmatter (between --- delimiters)
      2. Include a 'name' field (max 64 chars, lowercase with hyphens)
      3. Include a 'description' field (max 1024 chars)
      4. Have meaningful body content after the frontmatter

    Args:
        file_path: Path to the SKILL.md file to validate

    Returns:
        A list of error messages (empty list if valid)

    Validation rules:
      - name: Required, max 64 chars, matches ^[a-z][a-z0-9-]*$
      - description: Required, max 1024 chars
      - body: Should be at least 100 characters (warning-level)
    """
    errors = []

    # -------------------------------------------------------------------------
    # Read the file
    # -------------------------------------------------------------------------
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return [f"Cannot read file: {e}"]

    # -------------------------------------------------------------------------
    # Validate frontmatter exists and is parseable
    # -------------------------------------------------------------------------
    valid, err, data = validate_yaml_frontmatter(content)
    if not valid:
        errors.append(err)
        return errors  # Can't continue validation without frontmatter

    # -------------------------------------------------------------------------
    # Validate 'name' field
    # -------------------------------------------------------------------------
    if 'name' not in data:
        errors.append("Missing required field: name")
    else:
        name = data['name']

        # Check length constraint (64 chars max per spec)
        if len(name) > 64:
            errors.append(f"name exceeds 64 characters: {len(name)}")

        # Check format: lowercase letters and hyphens only
        # ^        = start of string
        # [a-z]    = must start with lowercase letter
        # [a-z0-9-]* = followed by any combo of lowercase, numbers, hyphens
        # $        = end of string
        if not re.match(r'^[a-z][a-z0-9-]*$', name):
            errors.append(f"name must be lowercase with hyphens: {name}")

    # -------------------------------------------------------------------------
    # Validate 'description' field
    # -------------------------------------------------------------------------
    if 'description' not in data:
        errors.append("Missing required field: description")
    else:
        desc = data['description']

        # Check length constraint (1024 chars max per spec)
        if len(desc) > 1024:
            errors.append(f"description exceeds 1024 characters: {len(desc)}")

    # -------------------------------------------------------------------------
    # Validate body content
    # -------------------------------------------------------------------------
    # Find where the frontmatter ends (after the closing ---)
    frontmatter_end = content.find('\n---\n', 3)
    if frontmatter_end > 0:
        # Extract the body (everything after the frontmatter)
        body = content[frontmatter_end + 5:].strip()

        # Check that there's meaningful content
        # 100 chars is a low bar - a good skill should have much more
        if len(body) < 100:
            errors.append("SKILL.md body seems too short (< 100 chars)")

    return errors


# =============================================================================
# RULE FILE VALIDATION
# =============================================================================
# Rules are markdown files in the rules/ directory that define constraints
# Claude Code should always follow. They don't require frontmatter but must
# have meaningful content.
# =============================================================================

def validate_rule_md(file_path: Path) -> List[str]:
    """
    Validate a rule markdown file in the rules/ directory.

    Rules are declarative constraint files that Claude Code loads
    automatically. They must:
      1. Have a top-level heading (# Title)
      2. Contain meaningful content (at least 200 chars)
      3. Not be a README.md (those are documentation, not rules)

    Args:
        file_path: Path to the rule markdown file

    Returns:
        A list of error messages (empty list if valid)
    """
    errors = []

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return [f"Cannot read file: {e}"]

    # Skip README files - they're documentation, not rules
    if file_path.name == 'README.md':
        return errors

    # Check for a top-level heading
    if not re.search(r'^#\s+\S', content, re.MULTILINE):
        errors.append("Rule file should have a top-level heading (# Title)")

    # Check minimum content length
    if len(content.strip()) < 200:
        errors.append("Rule file seems too short (< 200 chars)")

    return errors


# =============================================================================
# AGENT FILE VALIDATION
# =============================================================================
# Agents are markdown files with YAML frontmatter that define specialized
# personas for Claude Code. They require specific frontmatter fields.
# =============================================================================

def validate_agent_md(file_path: Path) -> List[str]:
    """
    Validate an agent markdown file in the agents/ directory.

    Agent files define specialized personas and must:
      1. Have YAML frontmatter with required fields
      2. Include 'name' field
      3. Include 'description' field
      4. Have meaningful body content with instructions

    Args:
        file_path: Path to the agent markdown file

    Returns:
        A list of error messages (empty list if valid)
    """
    errors = []

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return [f"Cannot read file: {e}"]

    # Skip README files
    if file_path.name == 'README.md':
        return errors

    # Agents should have YAML frontmatter
    if not content.startswith('---'):
        errors.append("Agent file should have YAML frontmatter (---)")
        return errors

    valid, err, data = validate_yaml_frontmatter(content)
    if not valid:
        errors.append(err)
        return errors

    # Check required fields
    if 'name' not in data:
        errors.append("Missing required field: name")

    if 'description' not in data:
        errors.append("Missing required field: description")

    # Check body content
    frontmatter_end = content.find('\n---\n', 3)
    if frontmatter_end > 0:
        body = content[frontmatter_end + 5:].strip()
        if len(body) < 100:
            errors.append("Agent body seems too short (< 100 chars)")

    return errors


# =============================================================================
# COMMAND FILE VALIDATION
# =============================================================================
# Commands are markdown files that define slash commands for Claude Code.
# They should have a heading and meaningful instructions.
# =============================================================================

def validate_command_md(file_path: Path) -> List[str]:
    """
    Validate a command markdown file in the commands/ directory.

    Command files define slash commands and must:
      1. Have a top-level heading (# /command-name)
      2. Contain meaningful instructions (at least 100 chars)

    Args:
        file_path: Path to the command markdown file

    Returns:
        A list of error messages (empty list if valid)
    """
    errors = []

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return [f"Cannot read file: {e}"]

    # Check for a top-level heading
    if not re.search(r'^#\s+\S', content, re.MULTILINE):
        errors.append("Command file should have a top-level heading")

    # Check minimum content length
    if len(content.strip()) < 100:
        errors.append("Command file seems too short (< 100 chars)")

    return errors


# =============================================================================
# MARKDOWN LINK VALIDATION
# =============================================================================
# Checks that internal links in markdown files point to files that exist.
# =============================================================================

def validate_markdown_links(file_path: Path, repo_root: Path) -> List[str]:
    """
    Validate internal links in a markdown file.

    Finds all markdown links [text](path) and verifies that internal
    links (not http/https URLs) point to files that actually exist.

    Args:
        file_path: Path to the markdown file to check
        repo_root: Root directory of the repository (for resolving absolute paths)

    Returns:
        A list of error messages for broken links

    Link types handled:
        - External (http/https): Skipped (not validated)
        - Anchors (#section): Skipped (complex to validate)
        - Relative (./path or path): Resolved from file's directory
        - Absolute (/path): Resolved from repo root

    Examples of links we check:
        [README](./README.md)           -> Check if ./README.md exists
        [Guide](/docs/guide.md)         -> Check if /docs/guide.md exists
        [Section](#setup)               -> Skip (anchor link)
        [Website](https://example.com)  -> Skip (external link)
    """
    errors = []

    # Read the file
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception:
        return errors  # Can't check links if we can't read the file

    # -------------------------------------------------------------------------
    # Skip template files (their links are relative to where they'll be placed)
    # -------------------------------------------------------------------------
    if 'TEMPLATE' in file_path.name or 'SPEC' in file_path.name:
        return errors

    # -------------------------------------------------------------------------
    # Strip fenced code blocks before checking links
    # -------------------------------------------------------------------------
    # Links inside code blocks (```...```) are examples, not real references.
    # Remove them to avoid false positive warnings.
    content_no_codeblocks = re.sub(r'```[\s\S]*?```', '', content)

    # -------------------------------------------------------------------------
    # Find all markdown links
    # -------------------------------------------------------------------------
    # Pattern: [text](url)
    #   \[([^\]]+)\]  = [text] - capture the link text
    #   \(([^)]+)\)   = (url)  - capture the URL/path
    links = re.findall(r'\[([^\]]+)\]\(([^)]+)\)', content_no_codeblocks)

    for text, link in links:
        # ---------------------------------------------------------------------
        # Skip external links (http, https, mailto)
        # ---------------------------------------------------------------------
        if link.startswith(('http://', 'https://', 'mailto:')):
            continue

        # ---------------------------------------------------------------------
        # Skip anchor-only links (#section)
        # ---------------------------------------------------------------------
        if link.startswith('#'):
            continue

        # ---------------------------------------------------------------------
        # Skip placeholder/example links and GitHub relative links
        # ---------------------------------------------------------------------
        # Example links like (url), (link), (badge) are not real paths
        if link in ('url', 'link', 'badge'):
            continue
        # GitHub relative links like ../../issues work on GitHub, not locally
        if link.startswith('../../'):
            continue

        # ---------------------------------------------------------------------
        # Extract path (remove anchor if present)
        # ---------------------------------------------------------------------
        # A link like "./file.md#section" has path="./file.md"
        path_part = link.split('#')[0]
        if not path_part:
            continue  # Was just an anchor like "#section"

        # ---------------------------------------------------------------------
        # Resolve the path to an absolute path
        # ---------------------------------------------------------------------
        if path_part.startswith('./'):
            # Relative to current file's directory: ./subdir/file.md
            target = file_path.parent / path_part[2:]
        elif path_part.startswith('/'):
            # Absolute from repo root: /docs/file.md
            target = repo_root / path_part[1:]
        else:
            # Relative without ./ prefix: subdir/file.md
            target = file_path.parent / path_part

        # ---------------------------------------------------------------------
        # Check if the target exists
        # ---------------------------------------------------------------------
        if not target.exists():
            errors.append(f"Broken link: [{text}]({link})")

    return errors


# =============================================================================
# FILE DISCOVERY
# =============================================================================

def find_files(root: Path, pattern: str) -> List[Path]:
    """
    Find all files matching a glob pattern recursively.

    This is a thin wrapper around Path.rglob() for consistent interface.

    Args:
        root: Directory to search in
        pattern: Glob pattern (e.g., "*.json", "SKILL.md")

    Returns:
        List of Path objects for matching files

    Example:
        json_files = find_files(Path("./"), "*.json")
    """
    return list(root.rglob(pattern))


# =============================================================================
# DIRECTORY VALIDATION
# =============================================================================
# Orchestrates validation of all files in a directory.
# =============================================================================

def validate_directory(path: Path) -> Tuple[int, int, int]:
    """
    Validate all configuration files in a directory.

    Recursively finds and validates:
      - All *.json files
      - All SKILL.md files
      - Internal links in all *.md files

    Args:
        path: Directory to validate

    Returns:
        A tuple of (files_checked, error_count, warning_count)

    Skipped paths:
      - node_modules/ - npm dependencies
      - .git/ - git internal files
    """
    errors = 0
    warnings = 0
    files_checked = 0

    repo_root = path  # Used for resolving absolute links

    # -------------------------------------------------------------------------
    # Validate JSON files
    # -------------------------------------------------------------------------
    json_files = find_files(path, '*.json')
    for json_file in json_files:
        # Skip common directories that shouldn't be validated
        if 'node_modules' in str(json_file) or '.git' in str(json_file):
            continue

        files_checked += 1
        valid, err = validate_json(json_file)

        # Get path relative to the root for cleaner output
        rel_path = json_file.relative_to(path)

        if valid:
            success(f"{rel_path}")
        else:
            error(f"{rel_path}: {err}")
            errors += 1

    # -------------------------------------------------------------------------
    # Validate SKILL.md files
    # -------------------------------------------------------------------------
    skill_files = find_files(path, 'SKILL.md')
    for skill_file in skill_files:
        files_checked += 1
        errs = validate_skill_md(skill_file)
        rel_path = skill_file.relative_to(path)

        if not errs:
            success(f"{rel_path}")
        else:
            # A single file can have multiple errors
            for err in errs:
                error(f"{rel_path}: {err}")
            errors += len(errs)

    # -------------------------------------------------------------------------
    # Validate rule files (rules/*.md)
    # -------------------------------------------------------------------------
    rules_dir = path / 'rules'
    if rules_dir.is_dir():
        rule_files = find_files(rules_dir, '*.md')
        for rule_file in rule_files:
            if rule_file.name == 'README.md':
                continue
            files_checked += 1
            errs = validate_rule_md(rule_file)
            rel_path = rule_file.relative_to(path)

            if not errs:
                success(f"{rel_path}")
            else:
                for err in errs:
                    error(f"{rel_path}: {err}")
                errors += len(errs)

    # -------------------------------------------------------------------------
    # Validate agent files (agents/*.md)
    # -------------------------------------------------------------------------
    agents_dir = path / 'agents'
    if agents_dir.is_dir():
        agent_files = find_files(agents_dir, '*.md')
        for agent_file in agent_files:
            if agent_file.name == 'README.md':
                continue
            files_checked += 1
            errs = validate_agent_md(agent_file)
            rel_path = agent_file.relative_to(path)

            if not errs:
                success(f"{rel_path}")
            else:
                for err in errs:
                    error(f"{rel_path}: {err}")
                errors += len(errs)

    # -------------------------------------------------------------------------
    # Validate command files (commands/**/*.md)
    # -------------------------------------------------------------------------
    commands_dir = path / 'commands'
    if commands_dir.is_dir():
        command_files = find_files(commands_dir, '*.md')
        for cmd_file in command_files:
            files_checked += 1
            errs = validate_command_md(cmd_file)
            rel_path = cmd_file.relative_to(path)

            if not errs:
                success(f"{rel_path}")
            else:
                for err in errs:
                    error(f"{rel_path}: {err}")
                errors += len(errs)

    # -------------------------------------------------------------------------
    # Validate markdown links
    # -------------------------------------------------------------------------
    md_files = find_files(path, '*.md')
    for md_file in md_files:
        # Skip common directories
        if 'node_modules' in str(md_file) or '.git' in str(md_file):
            continue

        link_errors = validate_markdown_links(md_file, repo_root)
        rel_path = md_file.relative_to(path)

        # Broken links are warnings, not errors (they don't break functionality)
        for err in link_errors:
            warning(f"{rel_path}: {err}")
            warnings += 1

    return files_checked, errors, warnings


# =============================================================================
# SINGLE FILE VALIDATION
# =============================================================================
# Handles validation of a single specified file.
# =============================================================================

def validate_file(file_path: Path) -> Tuple[int, int]:
    """
    Validate a single file based on its type.

    Determines the file type from its extension/name and runs the
    appropriate validation.

    Args:
        file_path: Path to the file to validate

    Returns:
        A tuple of (error_count, warning_count)

    Supported file types:
      - .json files: JSON syntax validation
      - SKILL.md: Skill specification validation
      - .md files: Internal link validation
    """
    errors = 0
    warnings = 0

    # -------------------------------------------------------------------------
    # JSON validation
    # -------------------------------------------------------------------------
    if file_path.suffix == '.json':
        valid, err = validate_json(file_path)
        if valid:
            success(str(file_path))
        else:
            error(f"{file_path}: {err}")
            errors += 1

    # -------------------------------------------------------------------------
    # SKILL.md validation
    # -------------------------------------------------------------------------
    elif file_path.name == 'SKILL.md':
        errs = validate_skill_md(file_path)
        if not errs:
            success(str(file_path))
        else:
            for err in errs:
                error(f"{file_path}: {err}")
            errors += len(errs)

    # -------------------------------------------------------------------------
    # Other Markdown files (link validation only)
    # -------------------------------------------------------------------------
    elif file_path.suffix == '.md':
        # Try to find the repository root for resolving absolute links
        repo_root = file_path.parent
        current = file_path.parent

        # Walk up the directory tree looking for .git or README.md
        while current != current.parent:
            if (current / '.git').exists() or (current / 'README.md').exists():
                repo_root = current
                break
            current = current.parent

        link_errors = validate_markdown_links(file_path, repo_root)
        if not link_errors:
            success(str(file_path))
        else:
            for err in link_errors:
                warning(f"{file_path}: {err}")
                warnings += 1

    # -------------------------------------------------------------------------
    # Unsupported file types
    # -------------------------------------------------------------------------
    else:
        info(f"Skipping unsupported file type: {file_path}")

    return errors, warnings


# =============================================================================
# MAIN ENTRY POINT
# =============================================================================

def main():
    """
    Main entry point for the validation script.

    Parses command-line arguments, runs validation, and exits with
    appropriate status code.

    Command-line usage:
        python validate.py            # Validate entire repo
        python validate.py path/      # Validate specific directory
        python validate.py file.json  # Validate specific file

    Exit codes:
        0 = Success (no errors, warnings are OK)
        1 = Failure (one or more errors found)
    """
    # Print header
    print(f"\n{color('claude-dotfiles validator', Colors.BOLD)}\n")

    # -------------------------------------------------------------------------
    # Determine validation target
    # -------------------------------------------------------------------------
    if len(sys.argv) > 1:
        # User specified a path
        target = Path(sys.argv[1])
    else:
        # Default: validate the repo root (parent of scripts/ directory)
        target = Path(__file__).parent.parent

    # Verify the target exists
    if not target.exists():
        error(f"Path not found: {target}")
        sys.exit(1)

    # -------------------------------------------------------------------------
    # Run validation
    # -------------------------------------------------------------------------
    if target.is_file():
        info(f"Validating file: {target}")
        errors, warnings = validate_file(target)
        files_checked = 1
    else:
        info(f"Validating directory: {target}")
        files_checked, errors, warnings = validate_directory(target)

    # -------------------------------------------------------------------------
    # Print summary
    # -------------------------------------------------------------------------
    print(f"\n{color('Summary', Colors.BOLD)}")
    print(f"  Files checked: {files_checked}")
    print(f"  Errors: {color(str(errors), Colors.RED if errors else Colors.GREEN)}")
    print(f"  Warnings: {color(str(warnings), Colors.YELLOW if warnings else Colors.GREEN)}")

    # -------------------------------------------------------------------------
    # Exit with appropriate code
    # -------------------------------------------------------------------------
    if errors > 0:
        print(f"\n{color('Validation failed', Colors.RED)}")
        sys.exit(1)  # Failure
    else:
        print(f"\n{color('Validation passed', Colors.GREEN)}")
        sys.exit(0)  # Success


# =============================================================================
# SCRIPT EXECUTION
# =============================================================================
# This block runs only when the script is executed directly (not imported).
# =============================================================================

if __name__ == '__main__':
    main()
