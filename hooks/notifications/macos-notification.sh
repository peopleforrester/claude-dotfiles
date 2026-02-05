#!/usr/bin/env bash
# ABOUTME: macOS desktop notification using osascript
# ABOUTME: Shows notification when Claude completes a task

# =============================================================================
# macOS Notification Hook for Claude Code
# =============================================================================
#
# PURPOSE:
# This script displays a native macOS notification when Claude Code completes
# a task. It uses osascript (AppleScript) which is built into every Mac,
# requiring no additional software installation.
#
# HOW IT WORKS:
# 1. Claude Code triggers this script via the "Stop" hook
# 2. The script runs AppleScript to display a notification
# 3. macOS Notification Center shows the notification
# 4. The notification includes an optional sound
#
# WHY APPLESCRIPT?
# macOS doesn't have a simple command-line notification tool like Linux's
# notify-send. AppleScript is the native way to interact with macOS system
# features. The osascript command allows running AppleScript from the shell.
#
# ALTERNATIVES:
# - terminal-notifier: A third-party tool with more features
#   Install: brew install terminal-notifier
#   More options: custom icons, click actions, grouping
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
# HOOK TYPES IN CLAUDE CODE:
# - Stop: Triggered when Claude finishes its response (used here)
# - PreToolUse: Before a tool is executed (can block it)
# - PostToolUse: After a tool completes
#
# PARAMETERS:
#   $1 - Title (default: "Claude Code")
#   $2 - Message (default: "Task completed")
#   $3 - Sound name (default: "default")
#
# AVAILABLE SOUNDS:
# macOS includes these system sounds (use the name without extension):
# - default, Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping,
#   Pop, Purr, Sosumi, Submarine, Tink
#
# Sound files are located in: /System/Library/Sounds/
#
# EXAMPLES:
#   ./macos-notification.sh
#   ./macos-notification.sh "Build Done" "Tests passed"
#   ./macos-notification.sh "Alert" "Check this" "Funk"
# =============================================================================

# =============================================================================
# PARAMETER HANDLING
# =============================================================================
# Assign command-line arguments to variables with sensible defaults.
#
# The ${N:-default} syntax provides a fallback value:
# - If $N is set and non-empty, use $N
# - Otherwise, use "default"
# =============================================================================

# Title for the notification (appears in bold at the top)
TITLE="${1:-Claude Code}"

# Body message of the notification
MESSAGE="${2:-Task completed}"

# System sound to play with the notification
# "default" uses the system's default notification sound
# Other options: Ping, Pop, Glass, Funk, etc.
SOUND="${3:-default}"

# =============================================================================
# DISPLAY NOTIFICATION USING OSASCRIPT
# =============================================================================
# osascript executes AppleScript code from the command line.
# The -e flag passes a one-line script to execute.
#
# APPLESCRIPT BREAKDOWN:
# display notification "..." with title "..." sound name "..."
#
# - display notification: AppleScript command to show a notification
# - "body text": The main content of the notification
# - with title "...": The bold header text
# - sound name "...": Which system sound to play
#
# QUOTING NOTES:
# The outer quotes are for bash, the inner escaped quotes are for AppleScript.
# We use \"${VAR}\" to:
# 1. Escape the quotes for bash (so they become part of the string)
# 2. Include the variable value
# 3. Create proper AppleScript string syntax
#
# EXAMPLE OF WHAT'S EXECUTED:
# If TITLE="Claude" and MESSAGE="Done", the AppleScript becomes:
#   display notification "Done" with title "Claude" sound name "default"
# =============================================================================
osascript -e "display notification \"${MESSAGE}\" with title \"${TITLE}\" sound name \"${SOUND}\""

# =============================================================================
# ALTERNATIVE: TERMINAL-NOTIFIER
# =============================================================================
# terminal-notifier is a more feature-rich notification tool for macOS.
# It's not built-in but can be installed via Homebrew.
#
# INSTALLATION:
#   brew install terminal-notifier
#
# ADVANTAGES OVER OSASCRIPT:
# - Custom application icons
# - Click actions (open URL, run command)
# - Notification grouping
# - Subtitle support
# - Works better in some edge cases
#
# USAGE EXAMPLE (uncomment to use instead of osascript):
# terminal-notifier -title "${TITLE}" -message "${MESSAGE}" -sound "${SOUND}"
#
# ADVANCED EXAMPLE:
# terminal-notifier \
#   -title "Claude Code" \
#   -subtitle "Task completed" \
#   -message "Build successful" \
#   -sound "Pop" \
#   -group "claude-code" \
#   -open "http://localhost:3000"
# =============================================================================
