# ABOUTME: Shared terminal formatting utilities for CLI scripts.
# ABOUTME: Provides ANSI color codes and TTY-aware text colorization.

import sys


class Colors:
    """ANSI escape codes for terminal text formatting."""
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    END = '\033[0m'


def color(text: str, c: str) -> str:
    """Apply ANSI color codes to text if running in a terminal.

    When stdout is piped or redirected, color codes are disabled to
    prevent escape sequences from appearing in output files.

    Args:
        text: The text to colorize
        c: Color code from Colors class

    Returns:
        Colorized text (if TTY) or plain text (if not TTY)
    """
    if sys.stdout.isatty():
        return f"{c}{text}{Colors.END}"
    return text
