#!/usr/bin/env python3
# ABOUTME: Counts tokens in CLAUDE.md and SKILL.md files using tiktoken
# ABOUTME: Reports token usage and warns when files exceed recommended budgets

"""
Token Counter for claude-dotfiles

============================================================================
SCRIPT OVERVIEW
============================================================================
This script analyzes CLAUDE.md and SKILL.md files to count their tokens and
lines, comparing them against recommended budgets for each file type.

Why token counting matters:
  - Claude has context window limits (how much text it can process at once)
  - CLAUDE.md files are loaded into context for every interaction
  - Large CLAUDE.md files waste tokens and leave less room for actual work
  - Different file types have different optimal sizes

Token budgets by template type:
  - Minimal: 500-1000 tokens (bare essentials)
  - Standard: 1500-2500 tokens (recommended baseline)
  - Power User: 2000-3500 tokens (full-featured)
  - Skills: 1500-3000 tokens (detailed guides)
  - Documentation: 2000-4000 tokens (READMEs, examples)

Usage:
    python scripts/token-count.py [path]
    python scripts/token-count.py                    # Count all templates
    python scripts/token-count.py templates/         # Count specific directory
    python scripts/token-count.py CLAUDE.md          # Count specific file

Requirements:
    pip install tiktoken  (optional - falls back to estimation without it)

Exit codes:
    0 = All files within budget
    1 = One or more files exceed budget

============================================================================
"""

# =============================================================================
# IMPORTS
# =============================================================================

import os            # Operating system interface (environment, paths)
import re            # Regular expressions for pattern matching
import sys           # System-specific parameters (argv, exit, stdout)
from pathlib import Path              # Object-oriented filesystem paths
from typing import List, Tuple, Optional  # Type hints for documentation


# =============================================================================
# TIKTOKEN IMPORT (OPTIONAL DEPENDENCY)
# =============================================================================
# tiktoken is OpenAI's fast tokenizer library. We use it for accurate token
# counts, but it requires installation (pip install tiktoken).
#
# If tiktoken isn't available, we fall back to a rough estimation algorithm.
# The estimation is less accurate but allows the script to run anywhere.
# =============================================================================

try:
    import tiktoken
    TIKTOKEN_AVAILABLE = True
except ImportError:
    # tiktoken not installed - will use estimation instead
    TIKTOKEN_AVAILABLE = False


# =============================================================================
# TOKEN AND LINE BUDGETS
# =============================================================================
# These dictionaries define the recommended sizes for different file types.
# Each has a 'target' (ideal size) and 'max' (upper limit before warning).
#
# Why these numbers?
# - Minimal templates should be quick to read and parse
# - Standard templates balance detail with brevity
# - Power-user templates can have more features but still need limits
# - Skills are reference guides and can be longer
# - Documentation files (READMEs) naturally need more space
# =============================================================================

# Token budgets by template type
# 'target' = ideal token count (green in output)
# 'max' = maximum before warning (yellow -> red above this)
BUDGETS = {
    'minimal': {'target': 500, 'max': 1000},       # Bare essentials
    'standard': {'target': 1500, 'max': 2500},     # Recommended baseline
    'power-user': {'target': 2000, 'max': 3500},   # Full-featured setup
    'skill': {'target': 1500, 'max': 3000},        # Skill reference guides
    'documentation': {'target': 2000, 'max': 4000}, # READMEs, examples
    'default': {'target': 1500, 'max': 3000},      # Fallback for unknown types
}

# Line count guidelines (non-empty lines)
# Similar structure: 'target' = ideal, 'max' = upper limit
LINE_LIMITS = {
    'minimal': {'target': 30, 'max': 50},          # ~30 lines for minimal
    'standard': {'target': 80, 'max': 100},        # ~80 lines recommended
    'power-user': {'target': 100, 'max': 150},     # ~100 lines for power users
    'skill': {'target': 200, 'max': 350},          # Skills can be detailed
    'documentation': {'target': 150, 'max': 300},  # Docs need more space
    'default': {'target': 80, 'max': 150},         # Default limits
}


# =============================================================================
# TERMINAL COLORS
# =============================================================================
# ANSI escape codes for colorful terminal output.
# Makes it easy to spot issues at a glance:
#   - Green = within target
#   - Yellow = between target and max
#   - Red = exceeds max
# =============================================================================

class Colors:
    """
    ANSI escape codes for terminal text formatting.

    These codes tell the terminal to change text color/style.
    Format: \033[XXm where XX is the code number.

    Standard color codes:
      91 = Bright Red
      92 = Bright Green
      93 = Bright Yellow
      94 = Bright Blue
      1  = Bold
      2  = Dim (faint)
      0  = Reset all formatting
    """
    RED = '\033[91m'      # Errors, over-budget warnings
    GREEN = '\033[92m'    # Success, within target
    YELLOW = '\033[93m'   # Warnings, between target and max
    BLUE = '\033[94m'     # Info messages
    BOLD = '\033[1m'      # Headers and emphasis
    DIM = '\033[2m'       # Reduced emphasis (like "(est)" marker)
    END = '\033[0m'       # Reset to default formatting


def color(text: str, c: str) -> str:
    """
    Apply ANSI color codes to text if running in a terminal.

    When stdout is piped or redirected, color codes are disabled to
    prevent escape sequences from appearing in output files.

    Args:
        text: The text to colorize
        c: Color code from Colors class

    Returns:
        Colorized text (if TTY) or plain text (if not TTY)

    Example:
        print(color("Success!", Colors.GREEN))
    """
    if sys.stdout.isatty():
        return f"{c}{text}{Colors.END}"
    return text


# =============================================================================
# TOKEN COUNTING FUNCTIONS
# =============================================================================
# Two methods for counting tokens:
# 1. tiktoken (accurate) - uses the actual tokenizer
# 2. estimation (fallback) - rough approximation without dependencies
# =============================================================================

def count_tokens_tiktoken(text: str) -> int:
    """
    Count tokens using the tiktoken library (accurate method).

    tiktoken is the tokenizer library used by OpenAI models. While Claude
    uses a different tokenizer, cl100k_base provides a reasonable approximation
    for token counting purposes.

    Args:
        text: The text to tokenize

    Returns:
        Exact token count according to cl100k_base encoding

    Technical details:
        - cl100k_base is the encoding used by GPT-4 and ChatGPT
        - It handles Unicode, code, and special characters well
        - Actual Claude token counts may differ slightly but this is close
    """
    # Get the cl100k_base encoding (GPT-4's tokenizer)
    enc = tiktoken.get_encoding("cl100k_base")

    # encode() returns a list of token IDs; len() gives us the count
    return len(enc.encode(text))


def count_tokens_estimate(text: str) -> int:
    """
    Estimate token count without tiktoken (fallback method).

    When tiktoken isn't installed, we use a rough heuristic based on
    word and character counts. This is less accurate but requires no
    external dependencies.

    The algorithm:
        1. Count words (split on whitespace)
        2. Count characters
        3. Average two different estimation methods:
           - Words * 1.3 (most words are 1+ tokens)
           - Characters / 4 (rough chars-per-token ratio)

    Args:
        text: The text to estimate tokens for

    Returns:
        Estimated token count (marked with "(est)" in output)

    Accuracy notes:
        - Tends to underestimate for code (special characters)
        - Tends to overestimate for simple prose
        - Within ~20% for typical CLAUDE.md content
    """
    # Count words by splitting on whitespace
    words = len(text.split())

    # Count total characters
    chars = len(text)

    # Average two estimation methods:
    # - words * 1.3: Most English words are 1-2 tokens
    # - chars / 4: Roughly 4 characters per token on average
    # Dividing by 2 gives us the average of both estimates
    return int((words * 1.3 + chars / 4) / 2)


def count_tokens(text: str) -> Tuple[int, bool]:
    """
    Count tokens using the best available method.

    Automatically chooses between tiktoken (if available) and estimation.
    Returns both the count and whether it's exact.

    Args:
        text: The text to count tokens for

    Returns:
        A tuple of (token_count, is_exact):
          - is_exact=True if using tiktoken
          - is_exact=False if using estimation
    """
    if TIKTOKEN_AVAILABLE:
        return count_tokens_tiktoken(text), True
    else:
        return count_tokens_estimate(text), False


# =============================================================================
# FILE TYPE DETECTION
# =============================================================================
# Determines which budget to apply based on file path and name.
# =============================================================================

def get_template_type(file_path: Path) -> str:
    """
    Determine the template type from a file's path.

    Different types of files have different token budgets. This function
    analyzes the file path to determine which category it belongs to.

    Detection logic (in priority order):
        1. SKILL.md files or files in /skills/ -> 'skill'
        2. README.md or files in /examples/ -> 'documentation'
        3. Path contains 'minimal' -> 'minimal'
        4. Path contains 'power-user' or 'power_user' -> 'power-user'
        5. Path contains 'standard' -> 'standard'
        6. Everything else -> 'default'

    Args:
        file_path: Path to the file being analyzed

    Returns:
        Template type string: 'skill', 'documentation', 'minimal',
        'power-user', 'standard', or 'default'
    """
    # Convert path to lowercase string for case-insensitive matching
    path_str = str(file_path).lower()
    file_name = file_path.name

    # Check for SKILL.md files first (highest priority)
    # These are Claude Code skill definitions
    if file_name == 'SKILL.md' or '/skills/' in path_str:
        return 'skill'

    # Documentation files (READMEs and examples)
    # These naturally need more space for explanation
    elif file_name == 'README.md' or '/examples/' in path_str:
        return 'documentation'

    # Template types based on directory name
    elif 'minimal' in path_str:
        return 'minimal'
    elif 'power-user' in path_str or 'power_user' in path_str:
        return 'power-user'
    elif 'standard' in path_str:
        return 'standard'

    # Default for anything else
    else:
        return 'default'


# =============================================================================
# HEADER COMMENT EXTRACTION
# =============================================================================
# CLAUDE.md files can include a token count in their header comment.
# This function extracts it for comparison with actual counts.
# =============================================================================

def extract_existing_token_comment(content: str) -> Optional[int]:
    """
    Extract token count from an existing header comment in the file.

    CLAUDE.md templates often include a header comment like:
        <!-- Tokens: ~1500 | Lines: 80 | Compatibility: Claude Code 2.1+ -->

    This function extracts the token count so we can compare it with
    the actual count and warn if they're significantly different.

    Args:
        content: The full file content

    Returns:
        The token count from the header, or None if not found

    Regex explanation:
        <!--          = HTML comment start
        \s*           = Optional whitespace
        Tokens:       = Literal text
        \s*           = Optional whitespace
        ~?            = Optional tilde (approximate marker)
        (\d+)         = Capture one or more digits (the count)
    """
    match = re.search(r'<!--\s*Tokens:\s*~?(\d+)', content)
    if match:
        return int(match.group(1))
    return None


# =============================================================================
# LINE COUNTING
# =============================================================================

def count_lines(content: str) -> int:
    """
    Count non-empty lines in content.

    Empty lines (or lines with only whitespace) are excluded from the
    count. This gives a better measure of actual content density.

    Args:
        content: The file content to count lines in

    Returns:
        Number of non-empty lines

    Implementation:
        Split on newlines, filter to non-empty (after stripping whitespace),
        return the count.
    """
    # List comprehension with filter:
    # 1. content.split('\n') - Split into lines
    # 2. if l.strip() - Only keep lines that have content after stripping
    # 3. len() - Count the filtered list
    return len([l for l in content.split('\n') if l.strip()])


# =============================================================================
# FILE ANALYSIS
# =============================================================================
# Core analysis function that brings together all the counting and detection.
# =============================================================================

def analyze_file(file_path: Path) -> dict:
    """
    Analyze a markdown file for tokens, lines, and budget compliance.

    Performs comprehensive analysis of a file:
        1. Read the file content
        2. Count tokens (exact or estimated)
        3. Count non-empty lines
        4. Determine file type for budget lookup
        5. Extract any existing token count from header
        6. Look up appropriate budgets

    Args:
        file_path: Path to the file to analyze

    Returns:
        A dictionary with analysis results:
        {
            'path': Path object,
            'tokens': int,           # Token count
            'is_exact': bool,        # True if using tiktoken
            'lines': int,            # Non-empty line count
            'template_type': str,    # 'minimal', 'standard', etc.
            'token_target': int,     # Target token count
            'token_max': int,        # Maximum token count
            'line_target': int,      # Target line count
            'line_max': int,         # Maximum line count
            'existing_count': int,   # From header comment (if any)
        }

        Or if there's an error:
        {
            'error': str  # Error message
        }
    """
    # -------------------------------------------------------------------------
    # Read the file
    # -------------------------------------------------------------------------
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        # Return error dict if we can't read the file
        return {'error': str(e)}

    # -------------------------------------------------------------------------
    # Perform analysis
    # -------------------------------------------------------------------------
    tokens, is_exact = count_tokens(content)      # Get token count
    lines = count_lines(content)                   # Get line count
    template_type = get_template_type(file_path)   # Determine type
    existing_count = extract_existing_token_comment(content)  # Header check

    # Look up appropriate budgets for this file type
    budget = BUDGETS.get(template_type, BUDGETS['default'])
    line_limit = LINE_LIMITS.get(template_type, LINE_LIMITS['default'])

    # -------------------------------------------------------------------------
    # Return complete analysis
    # -------------------------------------------------------------------------
    return {
        'path': file_path,
        'tokens': tokens,
        'is_exact': is_exact,
        'lines': lines,
        'template_type': template_type,
        'token_target': budget['target'],
        'token_max': budget['max'],
        'line_target': line_limit['target'],
        'line_max': line_limit['max'],
        'existing_count': existing_count,
    }


# =============================================================================
# OUTPUT FORMATTING
# =============================================================================

def format_status(value: int, target: int, max_val: int) -> str:
    """
    Format a value with color based on how it compares to thresholds.

    Color coding:
        - Green: At or below target (good)
        - Yellow: Above target but at or below max (acceptable)
        - Red: Above max (needs attention)

    Args:
        value: The actual value (tokens or lines)
        target: The target/ideal value
        max_val: The maximum acceptable value

    Returns:
        The value as a colored string

    Example:
        format_status(80, 100, 150)  # Green "80" (under target)
        format_status(120, 100, 150) # Yellow "120" (over target, under max)
        format_status(200, 100, 150) # Red "200" (over max)
    """
    if value <= target:
        return color(str(value), Colors.GREEN)
    elif value <= max_val:
        return color(str(value), Colors.YELLOW)
    else:
        return color(str(value), Colors.RED)


def print_result(result: dict) -> None:
    """
    Print the analysis result for a single file.

    Displays the file path, token count, line count, and any warnings
    in a formatted, color-coded output.

    Args:
        result: Analysis dictionary from analyze_file()

    Output format:
        path/to/file.md
          Tokens: 1234 (est) (target: 1500, max: 2500)
          Lines:  80 (target: 80, max: 100)
          ! Header comment says ~1000 tokens, actual is 1234
          ⚠ Exceeds maximum line count!
    """
    # Handle error case
    if 'error' in result:
        print(f"  {color('✗', Colors.RED)} {result.get('path', 'Unknown')}: {result['error']}")
        return

    # Extract values from result dict
    path = result['path']
    tokens = result['tokens']
    lines = result['lines']
    template_type = result['template_type']
    is_exact = result['is_exact']

    # Format token and line counts with color
    token_status = format_status(tokens, result['token_target'], result['token_max'])
    line_status = format_status(lines, result['line_target'], result['line_max'])

    # Add "(est)" marker if using estimation instead of tiktoken
    exact_marker = "" if is_exact else color(" (est)", Colors.DIM)

    # -------------------------------------------------------------------------
    # Print main output
    # -------------------------------------------------------------------------
    print(f"  {path}")
    print(f"    Tokens: {token_status}{exact_marker} (target: {result['token_target']}, max: {result['token_max']})")
    print(f"    Lines:  {line_status} (target: {result['line_target']}, max: {result['line_max']})")

    # -------------------------------------------------------------------------
    # Show discrepancy with existing header comment
    # -------------------------------------------------------------------------
    # If the file has a token count in its header and it differs significantly
    # from our calculated count, warn the user
    if result['existing_count'] and abs(result['existing_count'] - tokens) > 50:
        print(f"    {color('!', Colors.YELLOW)} Header comment says ~{result['existing_count']} tokens, actual is {tokens}")

    # -------------------------------------------------------------------------
    # Show warnings for over-budget files
    # -------------------------------------------------------------------------
    if tokens > result['token_max']:
        print(f"    {color('⚠', Colors.RED)} Exceeds maximum token budget!")
    if lines > result['line_max']:
        print(f"    {color('⚠', Colors.RED)} Exceeds maximum line count!")


def generate_header_comment(tokens: int, lines: int, target: int) -> str:
    """
    Generate a standard header comment for a CLAUDE.md file.

    This can be used to add or update the token count comment in files.
    The format matches what extract_existing_token_comment() looks for.

    Args:
        tokens: Current token count
        lines: Current line count
        target: Target token count for this file type

    Returns:
        HTML comment string with token info

    Example output:
        <!-- Tokens: ~1500 (target: 1500) | Lines: 80 | Compatibility: Claude Code 2.1+ -->
    """
    return f"<!-- Tokens: ~{tokens} (target: {target}) | Lines: {lines} | Compatibility: Claude Code 2.1+ -->"


# =============================================================================
# FILE DISCOVERY
# =============================================================================

def find_markdown_files(path: Path) -> List[Path]:
    """
    Find CLAUDE.md, SKILL.md, and template markdown files.

    Searches for files that should be analyzed:
        - CLAUDE.md files (project configuration)
        - SKILL.md files (skill definitions)
        - Markdown files in claude-md/ directory (templates)

    Args:
        path: Directory or file to search

    Returns:
        Sorted, deduplicated list of file paths

    Excludes:
        - node_modules/ (npm dependencies)
        - .git/ (git internals)
    """
    files = []

    if path.is_file():
        # Single file mode - just check if it's a relevant markdown file
        if path.name in ('CLAUDE.md', 'SKILL.md') or path.suffix == '.md':
            files.append(path)
    else:
        # Directory mode - find all relevant files

        # Find all CLAUDE.md files (main project configs)
        files.extend(path.rglob('CLAUDE.md'))

        # Find template markdown files in claude-md/ directory
        claude_md_dir = path / 'claude-md'
        if claude_md_dir.exists():
            files.extend(claude_md_dir.rglob('*.md'))

        # Find all SKILL.md files (skill definitions)
        files.extend(path.rglob('SKILL.md'))

    # Filter out files in excluded directories
    files = [f for f in files if 'node_modules' not in str(f) and '.git' not in str(f)]

    # Return sorted, deduplicated list
    # set() removes duplicates, sorted() ensures consistent order
    return sorted(set(files))


# =============================================================================
# MAIN ENTRY POINT
# =============================================================================

def main():
    """
    Main entry point for the token counter script.

    Flow:
        1. Print header
        2. Warn if tiktoken not available
        3. Determine target path from args
        4. Find relevant markdown files
        5. Analyze each file
        6. Print results with color coding
        7. Print summary
        8. Exit with appropriate code

    Exit codes:
        0 = All files within budget
        1 = One or more files exceed budget (or path not found)
    """
    # Print header
    print(f"\n{color('claude-dotfiles token counter', Colors.BOLD)}")

    # Warn about estimation mode if tiktoken not available
    if not TIKTOKEN_AVAILABLE:
        print(f"\n{color('Note:', Colors.YELLOW)} tiktoken not installed, using estimation.")
        print(f"  Install for accurate counts: pip install tiktoken\n")
    else:
        print()  # Just a blank line for spacing

    # -------------------------------------------------------------------------
    # Determine target path
    # -------------------------------------------------------------------------
    if len(sys.argv) > 1:
        # User specified a path as command-line argument
        target = Path(sys.argv[1])
    else:
        # Default: script's parent's parent (repo root)
        # scripts/token-count.py -> scripts/ -> repo root
        target = Path(__file__).parent.parent

    # Verify path exists
    if not target.exists():
        print(f"{color('✗', Colors.RED)} Path not found: {target}")
        sys.exit(1)

    # -------------------------------------------------------------------------
    # Find and analyze files
    # -------------------------------------------------------------------------
    files = find_markdown_files(target)

    if not files:
        print(f"No CLAUDE.md or SKILL.md files found in {target}")
        sys.exit(0)

    print(f"Found {len(files)} file(s)\n")

    # Analyze each file
    results = []
    over_budget = 0  # Count of files exceeding limits

    for file_path in files:
        result = analyze_file(file_path)
        results.append(result)
        print_result(result)

        # Count over-budget files
        if 'error' not in result:
            if result['tokens'] > result['token_max'] or result['lines'] > result['line_max']:
                over_budget += 1

        print()  # Blank line between files

    # -------------------------------------------------------------------------
    # Print summary
    # -------------------------------------------------------------------------
    print(f"{color('Summary', Colors.BOLD)}")
    print(f"  Files analyzed: {len(results)}")
    print(f"  Over budget: {color(str(over_budget), Colors.RED if over_budget else Colors.GREEN)}")

    # Calculate total tokens across all files
    total_tokens = sum(r.get('tokens', 0) for r in results if 'error' not in r)
    print(f"  Total tokens: {total_tokens}")

    # Reminder about tiktoken if using estimation
    if not TIKTOKEN_AVAILABLE:
        print(f"\n  {color('Install tiktoken for accurate counts:', Colors.DIM)}")
        print(f"  {color('pip install tiktoken', Colors.DIM)}")

    # -------------------------------------------------------------------------
    # Exit with appropriate code
    # -------------------------------------------------------------------------
    if over_budget > 0:
        print(f"\n{color('Warning:', Colors.YELLOW)} {over_budget} file(s) exceed budget")
        sys.exit(1)  # Failure - used by CI to fail the build
    else:
        print(f"\n{color('All files within budget', Colors.GREEN)}")
        sys.exit(0)  # Success


# =============================================================================
# SCRIPT EXECUTION
# =============================================================================
# This block runs only when the script is executed directly.
# It won't run if the script is imported as a module.
# =============================================================================

if __name__ == '__main__':
    main()
