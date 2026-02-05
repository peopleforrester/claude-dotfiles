#!/usr/bin/env bash
# ABOUTME: Linux desktop notification using notify-send
# ABOUTME: Shows notification when Claude completes a task

# =============================================================================
# Linux Notification Hook for Claude Code
# =============================================================================
#
# PURPOSE:
# This script displays a desktop notification on Linux systems when Claude
# Code completes a task. It uses the freedesktop.org notification standard,
# which is supported by most Linux desktop environments (GNOME, KDE, XFCE,
# Cinnamon, MATE, etc.).
#
# HOW IT WORKS:
# 1. Claude Code triggers this script via the "Stop" hook
# 2. The script calls notify-send to display a notification
# 3. Optionally plays a sound if PulseAudio is available
#
# REQUIREMENTS:
# - libnotify-bin package (provides notify-send)
# - A running notification daemon (usually started by your desktop environment)
#
# INSTALLATION (Debian/Ubuntu):
#   sudo apt install libnotify-bin
#
# INSTALLATION (Fedora):
#   sudo dnf install libnotify
#
# INSTALLATION (Arch Linux):
#   sudo pacman -S libnotify
#
# CONFIGURATION:
# Add this hook to your settings.json or ~/.claude/settings.json:
#
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
#
# HOOK TYPES EXPLAINED:
# - PreToolUse: Runs BEFORE Claude uses a tool (can block the tool)
# - PostToolUse: Runs AFTER Claude uses a tool
# - Stop: Runs when Claude finishes its response
#
# The "matcher" field filters which operations trigger the hook:
# - "": Empty string matches everything (used here for Stop events)
# - "Write|Edit": Would match file write or edit operations
# - "Bash(git commit *)": Would match git commit commands
#
# PARAMETERS:
# You can customize the notification by passing arguments:
#   $1 - Title (default: "Claude Code")
#   $2 - Message (default: "Task completed")
#   $3 - Urgency: "low", "normal", or "critical" (default: "normal")
#   $4 - Timeout in milliseconds (default: 5000)
#
# EXAMPLES:
#   ./linux-notify-send.sh
#   ./linux-notify-send.sh "Build Complete" "All tests passed"
#   ./linux-notify-send.sh "Error" "Something went wrong" critical
# =============================================================================

# =============================================================================
# PARAMETER HANDLING
# =============================================================================
# These lines assign command-line arguments to variables with sensible defaults.
#
# The ${1:-default} syntax means:
# - Use $1 if it's set and non-empty
# - Otherwise use "default"
#
# This is called "parameter expansion with default value" in bash.
# =============================================================================

# Title for the notification (appears in bold)
TITLE="${1:-Claude Code}"

# Body text of the notification
MESSAGE="${2:-Task completed}"

# Urgency level affects how the notification is displayed:
# - low: May be shown in a less prominent way, or grouped with others
# - normal: Standard notification display
# - critical: May persist until dismissed, and may make a sound
URGENCY="${3:-normal}"

# How long the notification stays visible (in milliseconds)
# 5000ms = 5 seconds is a reasonable default
# Note: Some notification daemons ignore this and use their own timeout
TIMEOUT="${4:-5000}"

# =============================================================================
# DEPENDENCY CHECK
# =============================================================================
# Before attempting to show a notification, verify that notify-send is
# available. This prevents confusing error messages.
#
# command -v <cmd>: Returns the path to <cmd> if it exists, or fails
# &> /dev/null: Suppress all output (both stdout and stderr)
# =============================================================================
if ! command -v notify-send &> /dev/null; then
    # Print helpful installation instructions to stderr
    echo "notify-send not found. Install with: sudo apt install libnotify-bin" >&2

    # Exit with 0 (success) rather than error
    # WHY? Hook failures can be confusing for users. A missing optional
    # tool shouldn't prevent Claude from working. We've informed the user
    # via stderr, so they can fix it if they want notifications.
    exit 0  # Don't fail the hook
fi

# =============================================================================
# DISPLAY NOTIFICATION
# =============================================================================
# notify-send is the standard command-line tool for sending desktop
# notifications on Linux systems following the freedesktop.org specification.
#
# OPTIONS:
# --urgency=LEVEL   Set the urgency level (low, normal, critical)
# --expire-time=MS  Notification timeout in milliseconds
# --app-name=NAME   Application name (shown in notification history)
#
# The remaining arguments are the title and body text.
#
# DESKTOP ENVIRONMENT SPECIFICS:
# - GNOME: Notifications appear in the top center, slide down
# - KDE: Notifications appear in the corner (configurable)
# - XFCE: Depends on the notification daemon (xfce4-notifyd)
# =============================================================================
notify-send \
    --urgency="${URGENCY}" \
    --expire-time="${TIMEOUT}" \
    --app-name="Claude Code" \
    "${TITLE}" \
    "${MESSAGE}"

# =============================================================================
# OPTIONAL: PLAY NOTIFICATION SOUND
# =============================================================================
# In addition to the visual notification, we can play an audio cue.
# This is especially helpful when:
# - You're working in another window and might miss the visual notification
# - You have a multi-monitor setup and notifications are on another screen
# - You want immediate feedback without looking at the screen
#
# paplay: PulseAudio sound player (standard on most Linux desktops)
# We try several common notification sound paths since different distros
# store them in different locations.
# =============================================================================
if command -v paplay &> /dev/null; then
    # Array of possible notification sound locations
    # Try them in order until we find one that exists
    for sound in \
        /usr/share/sounds/freedesktop/stereo/complete.oga \
        /usr/share/sounds/gnome/default/alerts/glass.ogg \
        /usr/share/sounds/ubuntu/notifications/Mallet.ogg
    do
        # Check if this sound file exists
        if [ -f "$sound" ]; then
            # Play the sound in the background (&)
            # This prevents the hook from blocking while sound plays
            # 2>/dev/null suppresses any error messages
            paplay "$sound" 2>/dev/null &

            # Exit the loop after finding and playing a sound
            # We only want to play one sound, not all of them
            break
        fi
    done
fi
