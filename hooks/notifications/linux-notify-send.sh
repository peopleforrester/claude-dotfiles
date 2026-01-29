#!/usr/bin/env bash
# ABOUTME: Linux desktop notification using notify-send
# ABOUTME: Shows notification when Claude completes a task

# =============================================================================
# Linux Notification Hook
#
# Requires: libnotify-bin (sudo apt install libnotify-bin)
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
URGENCY="${3:-normal}"  # low, normal, critical
TIMEOUT="${4:-5000}"    # milliseconds

# Check if notify-send is available
if ! command -v notify-send &> /dev/null; then
    echo "notify-send not found. Install with: sudo apt install libnotify-bin" >&2
    exit 0  # Don't fail the hook
fi

# Display notification
notify-send \
    --urgency="${URGENCY}" \
    --expire-time="${TIMEOUT}" \
    --app-name="Claude Code" \
    "${TITLE}" \
    "${MESSAGE}"

# Alternative: Play a sound if available
if command -v paplay &> /dev/null; then
    # Try common notification sounds
    for sound in \
        /usr/share/sounds/freedesktop/stereo/complete.oga \
        /usr/share/sounds/gnome/default/alerts/glass.ogg \
        /usr/share/sounds/ubuntu/notifications/Mallet.ogg
    do
        if [ -f "$sound" ]; then
            paplay "$sound" 2>/dev/null &
            break
        fi
    done
fi
