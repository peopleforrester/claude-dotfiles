#!/usr/bin/env bash
# ABOUTME: macOS desktop notification using osascript
# ABOUTME: Shows notification when Claude completes a task

# =============================================================================
# macOS Notification Hook
#
# Usage in settings.json:
# {
#   "hooks": {
#     "Stop": [
#       {
#         "matcher": "",
#         "hooks": [{
#           "type": "command",
#           "command": "~/.claude/hooks/notify.sh"
#         }]
#       }
#     ]
#   }
# }
# =============================================================================

TITLE="${1:-Claude Code}"
MESSAGE="${2:-Task completed}"
SOUND="${3:-default}"

# Display notification using osascript
osascript -e "display notification \"${MESSAGE}\" with title \"${TITLE}\" sound name \"${SOUND}\""

# Alternative: Use terminal-notifier if installed (more features)
# terminal-notifier -title "${TITLE}" -message "${MESSAGE}" -sound "${SOUND}"
