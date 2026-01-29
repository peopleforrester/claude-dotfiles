#!/usr/bin/env python3
# ABOUTME: Counts tokens in CLAUDE.md and SKILL.md files using tiktoken
# ABOUTME: Reports token usage and warns when files exceed recommended budgets

"""
Token Counter for claude-dotfiles

Counts tokens in CLAUDE.md and other markdown files using tiktoken
with cl100k_base encoding (used by Claude).

Usage:
    python scripts/token-count.py [path]
    python scripts/token-count.py                    # Count all templates
    python scripts/token-count.py templates/         # Count specific directory
    python scripts/token-count.py CLAUDE.md          # Count specific file

Requirements:
    pip install tiktoken

If tiktoken is not installed, falls back to word-based estimation.
"""

import os
import re
import sys
from pathlib import Path
from typing import List, Tuple, Optional

# Try to import tiktoken
try:
    import tiktoken
    TIKTOKEN_AVAILABLE = True
except ImportError:
    TIKTOKEN_AVAILABLE = False


# Token budgets by template type
BUDGETS = {
    'minimal': {'target': 500, 'max': 1000},
    'standard': {'target': 1500, 'max': 2500},
    'power-user': {'target': 2000, 'max': 3500},
    'default': {'target': 1500, 'max': 3000},
}

# Line count guidelines
LINE_LIMITS = {
    'minimal': {'target': 30, 'max': 50},
    'standard': {'target': 80, 'max': 100},
    'power-user': {'target': 100, 'max': 150},
    'default': {'target': 80, 'max': 150},
}


# Colors for terminal output
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    END = '\033[0m'


def color(text: str, c: str) -> str:
    """Apply color to text if terminal supports it."""
    if sys.stdout.isatty():
        return f"{c}{text}{Colors.END}"
    return text


def count_tokens_tiktoken(text: str) -> int:
    """Count tokens using tiktoken."""
    enc = tiktoken.get_encoding("cl100k_base")
    return len(enc.encode(text))


def count_tokens_estimate(text: str) -> int:
    """Estimate tokens without tiktoken (rough approximation)."""
    # Rough estimate: ~4 characters per token for English text
    # This is a fallback and less accurate
    words = len(text.split())
    chars = len(text)
    # Average of word-based and char-based estimates
    return int((words * 1.3 + chars / 4) / 2)


def count_tokens(text: str) -> Tuple[int, bool]:
    """Count tokens, returning (count, is_exact)."""
    if TIKTOKEN_AVAILABLE:
        return count_tokens_tiktoken(text), True
    else:
        return count_tokens_estimate(text), False


def get_template_type(file_path: Path) -> str:
    """Determine template type from path."""
    path_str = str(file_path).lower()

    if 'minimal' in path_str:
        return 'minimal'
    elif 'power-user' in path_str or 'power_user' in path_str:
        return 'power-user'
    elif 'standard' in path_str:
        return 'standard'
    else:
        return 'default'


def extract_existing_token_comment(content: str) -> Optional[int]:
    """Extract token count from existing header comment."""
    match = re.search(r'<!--\s*Tokens:\s*~?(\d+)', content)
    if match:
        return int(match.group(1))
    return None


def count_lines(content: str) -> int:
    """Count non-empty lines."""
    return len([l for l in content.split('\n') if l.strip()])


def analyze_file(file_path: Path) -> dict:
    """Analyze a markdown file for tokens and lines."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return {'error': str(e)}

    tokens, is_exact = count_tokens(content)
    lines = count_lines(content)
    template_type = get_template_type(file_path)
    existing_count = extract_existing_token_comment(content)

    budget = BUDGETS.get(template_type, BUDGETS['default'])
    line_limit = LINE_LIMITS.get(template_type, LINE_LIMITS['default'])

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


def format_status(value: int, target: int, max_val: int) -> str:
    """Format value with color based on thresholds."""
    if value <= target:
        return color(str(value), Colors.GREEN)
    elif value <= max_val:
        return color(str(value), Colors.YELLOW)
    else:
        return color(str(value), Colors.RED)


def print_result(result: dict) -> None:
    """Print analysis result for a file."""
    if 'error' in result:
        print(f"  {color('✗', Colors.RED)} {result.get('path', 'Unknown')}: {result['error']}")
        return

    path = result['path']
    tokens = result['tokens']
    lines = result['lines']
    template_type = result['template_type']
    is_exact = result['is_exact']

    token_status = format_status(tokens, result['token_target'], result['token_max'])
    line_status = format_status(lines, result['line_target'], result['line_max'])

    exact_marker = "" if is_exact else color(" (est)", Colors.DIM)

    print(f"  {path}")
    print(f"    Tokens: {token_status}{exact_marker} (target: {result['token_target']}, max: {result['token_max']})")
    print(f"    Lines:  {line_status} (target: {result['line_target']}, max: {result['line_max']})")

    # Show discrepancy with existing count
    if result['existing_count'] and abs(result['existing_count'] - tokens) > 50:
        print(f"    {color('!', Colors.YELLOW)} Header comment says ~{result['existing_count']} tokens, actual is {tokens}")

    # Warnings
    if tokens > result['token_max']:
        print(f"    {color('⚠', Colors.RED)} Exceeds maximum token budget!")
    if lines > result['line_max']:
        print(f"    {color('⚠', Colors.RED)} Exceeds maximum line count!")


def generate_header_comment(tokens: int, lines: int, target: int) -> str:
    """Generate the header comment for a CLAUDE.md file."""
    return f"<!-- Tokens: ~{tokens} (target: {target}) | Lines: {lines} | Compatibility: Claude Code 2.1+ -->"


def find_markdown_files(path: Path) -> List[Path]:
    """Find CLAUDE.md and SKILL.md files."""
    files = []

    if path.is_file():
        if path.name in ('CLAUDE.md', 'SKILL.md') or path.suffix == '.md':
            files.append(path)
    else:
        # Find CLAUDE.md files
        files.extend(path.rglob('CLAUDE.md'))

        # Find template .md files in claude-md/
        claude_md_dir = path / 'claude-md'
        if claude_md_dir.exists():
            files.extend(claude_md_dir.rglob('*.md'))

        # Find SKILL.md files
        files.extend(path.rglob('SKILL.md'))

    # Filter out node_modules, .git, etc.
    files = [f for f in files if 'node_modules' not in str(f) and '.git' not in str(f)]

    return sorted(set(files))


def main():
    """Main entry point."""
    print(f"\n{color('claude-dotfiles token counter', Colors.BOLD)}")

    if not TIKTOKEN_AVAILABLE:
        print(f"\n{color('Note:', Colors.YELLOW)} tiktoken not installed, using estimation.")
        print(f"  Install for accurate counts: pip install tiktoken\n")
    else:
        print()

    # Determine what to analyze
    if len(sys.argv) > 1:
        target = Path(sys.argv[1])
    else:
        # Default to script's parent directory (repo root)
        target = Path(__file__).parent.parent

    if not target.exists():
        print(f"{color('✗', Colors.RED)} Path not found: {target}")
        sys.exit(1)

    # Find files
    files = find_markdown_files(target)

    if not files:
        print(f"No CLAUDE.md or SKILL.md files found in {target}")
        sys.exit(0)

    print(f"Found {len(files)} file(s)\n")

    # Analyze files
    results = []
    over_budget = 0

    for file_path in files:
        result = analyze_file(file_path)
        results.append(result)
        print_result(result)

        if 'error' not in result:
            if result['tokens'] > result['token_max'] or result['lines'] > result['line_max']:
                over_budget += 1

        print()

    # Summary
    print(f"{color('Summary', Colors.BOLD)}")
    print(f"  Files analyzed: {len(results)}")
    print(f"  Over budget: {color(str(over_budget), Colors.RED if over_budget else Colors.GREEN)}")

    total_tokens = sum(r.get('tokens', 0) for r in results if 'error' not in r)
    print(f"  Total tokens: {total_tokens}")

    if not TIKTOKEN_AVAILABLE:
        print(f"\n  {color('Install tiktoken for accurate counts:', Colors.DIM)}")
        print(f"  {color('pip install tiktoken', Colors.DIM)}")

    if over_budget > 0:
        print(f"\n{color('Warning:', Colors.YELLOW)} {over_budget} file(s) exceed budget")
        sys.exit(1)
    else:
        print(f"\n{color('All files within budget', Colors.GREEN)}")
        sys.exit(0)


if __name__ == '__main__':
    main()
