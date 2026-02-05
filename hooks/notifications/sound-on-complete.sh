#!/usr/bin/env bash
# ABOUTME: Cross-platform audio notification on task completion
# ABOUTME: Plays a sound when Claude finishes a task

# =============================================================================
# Cross-Platform Sound Notification Hook for Claude Code
# =============================================================================
#
# PURPOSE:
# This script plays an audio notification when Claude Code completes a task.
# Unlike the platform-specific notification scripts, this one works on:
# - macOS
# - Linux (with various audio systems)
# - Windows (via WSL - Windows Subsystem for Linux)
#
# WHY AUDIO NOTIFICATIONS?
# Audio notifications are useful when:
# - You're working in another window and might miss visual notifications
# - You have a multi-monitor setup
# - You want feedback without looking at the screen
# - You're running long-running tasks and stepped away
#
# HOW IT WORKS:
# The script tries multiple audio playback methods in order of preference,
# using whichever one is available on the current system. It also tries
# to find system sounds before falling back to a simple beep.
#
# CONFIGURATION:
# Add this hook to your settings.json:
#
# {
#   "hooks": {
#     "Stop": [
#       {
#         "matcher": "",
#         "hooks": [{
#           "type": "command",
#           "command": "~/.claude/hooks/sound-on-complete.sh"
#         }]
#       }
#     ]
#   }
# }
#
# CUSTOMIZATION:
# Set CLAUDE_NOTIFICATION_SOUND environment variable to use a custom sound:
#   export CLAUDE_NOTIFICATION_SOUND="/path/to/your/sound.mp3"
#
# Supported audio formats depend on your audio player, but typically:
# - WAV, MP3, OGG, FLAC on Linux
# - WAV, MP3, AAC, AIFF on macOS
# =============================================================================

# =============================================================================
# CUSTOM SOUND CONFIGURATION
# =============================================================================
# Allow users to specify their own notification sound via environment variable.
# If not set, the script will use system sounds or a fallback beep.
#
# The ${VAR:-} syntax returns empty string if VAR is unset, avoiding errors
# when running with `set -u` (unset variable checking).
# =============================================================================
CUSTOM_SOUND="${CLAUDE_NOTIFICATION_SOUND:-}"

# =============================================================================
# PLAY_SOUND FUNCTION
# =============================================================================
# Attempts to play an audio file using whatever audio player is available.
# Tries multiple players in order of preference.
#
# PARAMETERS:
#   $1 - Path to the sound file to play
#
# RETURNS:
#   0 if sound was played successfully
#   1 if no audio player was found
#
# SUPPORTED PLAYERS:
# - afplay (macOS built-in)
# - paplay (PulseAudio on Linux)
# - aplay (ALSA on Linux)
# - mpv (cross-platform media player)
# - ffplay (from FFmpeg)
# =============================================================================
play_sound() {
    local sound_file="$1"

    # =========================================================================
    # macOS: afplay
    # =========================================================================
    # afplay is Apple's built-in audio player, available on all Macs.
    # It's simple and reliable for playing sound files.
    #
    # The & at the end runs it in the background so the script doesn't block.
    # 2>/dev/null suppresses error messages.
    # =========================================================================
    if command -v afplay &> /dev/null; then
        afplay "$sound_file" 2>/dev/null &
        return 0
    fi

    # =========================================================================
    # Linux: PulseAudio (paplay)
    # =========================================================================
    # PulseAudio is the most common Linux sound system.
    # paplay is its command-line player.
    # =========================================================================
    if command -v paplay &> /dev/null; then
        paplay "$sound_file" 2>/dev/null &
        return 0
    fi

    # =========================================================================
    # Linux: ALSA (aplay)
    # =========================================================================
    # ALSA (Advanced Linux Sound Architecture) is the lower-level Linux
    # sound system. Some minimal systems use ALSA directly without PulseAudio.
    # -q: Quiet mode (suppress output)
    # =========================================================================
    if command -v aplay &> /dev/null; then
        aplay -q "$sound_file" 2>/dev/null &
        return 0
    fi

    # =========================================================================
    # Cross-platform: mpv
    # =========================================================================
    # mpv is a powerful, cross-platform media player that can play
    # almost any audio format.
    # --no-video: Don't open a video window
    # --really-quiet: Suppress all output
    # =========================================================================
    if command -v mpv &> /dev/null; then
        mpv --no-video --really-quiet "$sound_file" 2>/dev/null &
        return 0
    fi

    # =========================================================================
    # Cross-platform: ffplay (from FFmpeg)
    # =========================================================================
    # ffplay is part of the FFmpeg suite and can play almost any format.
    # -nodisp: Don't display video (audio only)
    # -autoexit: Exit when playback finishes
    # -loglevel quiet: Suppress all output
    # =========================================================================
    if command -v ffplay &> /dev/null; then
        ffplay -nodisp -autoexit -loglevel quiet "$sound_file" 2>/dev/null &
        return 0
    fi

    # No audio player found
    return 1
}

# =============================================================================
# PLAY_SYSTEM_SOUND FUNCTION
# =============================================================================
# Tries to play a system notification sound based on the current OS.
# Different operating systems store sound files in different locations.
#
# RETURNS:
#   0 if a system sound was found and played
#   1 if no system sound was found
# =============================================================================
play_system_sound() {
    # =========================================================================
    # macOS System Sounds
    # =========================================================================
    # macOS stores system sounds in /System/Library/Sounds/
    # These are AIFF files that work well for notifications.
    # We try several and use the first one found.
    #
    # $OSTYPE is a bash variable that contains the OS type:
    # - darwin* for macOS
    # - linux-gnu* for Linux
    # - msys or cygwin for Windows shells
    # =========================================================================
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local sounds=(
            "/System/Library/Sounds/Glass.aiff"   # Gentle glass sound
            "/System/Library/Sounds/Ping.aiff"    # Classic Mac ping
            "/System/Library/Sounds/Pop.aiff"     # Short pop sound
            "/System/Library/Sounds/Purr.aiff"    # Soft purring sound
        )
        for sound in "${sounds[@]}"; do
            if [ -f "$sound" ]; then
                afplay "$sound" 2>/dev/null &
                return 0
            fi
        done
    fi

    # =========================================================================
    # Linux System Sounds
    # =========================================================================
    # Linux distros typically store sounds in /usr/share/sounds/
    # Different distros have different sound themes (freedesktop, GNOME, Ubuntu)
    # =========================================================================
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        local sounds=(
            # freedesktop.org standard (most compatible)
            "/usr/share/sounds/freedesktop/stereo/complete.oga"
            # GNOME desktop
            "/usr/share/sounds/gnome/default/alerts/glass.ogg"
            # Ubuntu-specific
            "/usr/share/sounds/ubuntu/notifications/Mallet.ogg"
            # Generic sound-icons package
            "/usr/share/sounds/sound-icons/prompt.wav"
        )
        for sound in "${sounds[@]}"; do
            if [ -f "$sound" ]; then
                play_sound "$sound"
                return 0
            fi
        done
    fi

    # No system sound found
    return 1
}

# =============================================================================
# GENERATE_BEEP FUNCTION
# =============================================================================
# Last resort: generate a simple beep when no sound files or players are
# available. This should work on almost any system.
# =============================================================================
generate_beep() {
    # =========================================================================
    # Terminal Bell
    # =========================================================================
    # The simplest possible audio notification - the ASCII BEL character.
    # \a is the bell character (ASCII 7), which causes the terminal to beep.
    #
    # NOTE: Modern terminals often have the bell disabled or muted.
    # You may need to enable it in your terminal settings.
    # =========================================================================
    printf '\a'

    # =========================================================================
    # macOS: Text-to-Speech
    # =========================================================================
    # If we're on macOS and can't find sound files, use the `say` command
    # to speak "Done" as an audio notification.
    #
    # The -v flag selects a voice. "Samantha" is a common US English voice.
    # =========================================================================
    if command -v say &> /dev/null; then
        say -v "Samantha" "Done" 2>/dev/null &
        return 0
    fi

    # =========================================================================
    # Linux: speaker-test
    # =========================================================================
    # speaker-test is part of ALSA and can generate test tones.
    # We use it to generate a brief beep.
    #
    # -t sine: Generate a sine wave (pure tone)
    # -f 800: Frequency of 800 Hz (a pleasant mid-range beep)
    # -l 1: Play once (1 loop)
    #
    # We sleep briefly then kill it because speaker-test doesn't have a
    # built-in duration limit.
    # =========================================================================
    if command -v speaker-test &> /dev/null; then
        speaker-test -t sine -f 800 -l 1 2>/dev/null &
        sleep 0.2
        pkill -9 speaker-test 2>/dev/null
        return 0
    fi
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================
# Orchestrates the sound playback by trying different methods in order:
# 1. Custom sound file (if CLAUDE_NOTIFICATION_SOUND is set)
# 2. System notification sounds
# 3. Fallback beep
# =============================================================================
main() {
    # =========================================================================
    # PRIORITY 1: Custom Sound
    # =========================================================================
    # If the user has specified a custom sound via environment variable,
    # try to play that first.
    #
    # -n: Tests if string is non-empty
    # -f: Tests if path is a regular file
    # && exit 0: If play_sound succeeds (returns 0), exit successfully
    # =========================================================================
    if [ -n "$CUSTOM_SOUND" ] && [ -f "$CUSTOM_SOUND" ]; then
        play_sound "$CUSTOM_SOUND" && exit 0
    fi

    # =========================================================================
    # PRIORITY 2: System Sounds
    # =========================================================================
    # Try to find and play a system notification sound appropriate for
    # the current operating system.
    # =========================================================================
    play_system_sound && exit 0

    # =========================================================================
    # PRIORITY 3: Fallback Beep
    # =========================================================================
    # If all else fails, generate a simple beep or spoken notification.
    # =========================================================================
    generate_beep
}

# =============================================================================
# SCRIPT ENTRY POINT
# =============================================================================
# Call the main function to start execution.
# =============================================================================
main
