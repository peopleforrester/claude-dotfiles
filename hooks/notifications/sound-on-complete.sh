#!/usr/bin/env bash
# ABOUTME: Cross-platform audio notification on task completion
# ABOUTME: Plays a sound when Claude finishes a task

# =============================================================================
# Sound Notification Hook
#
# Plays an audio cue when Claude completes a task.
# Works on macOS, Linux, and Windows (via WSL).
#
# Usage in settings.json:
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
# =============================================================================

# Custom sound file (optional - set to your preferred sound)
CUSTOM_SOUND="${CLAUDE_NOTIFICATION_SOUND:-}"

play_sound() {
    local sound_file="$1"

    # macOS
    if command -v afplay &> /dev/null; then
        afplay "$sound_file" 2>/dev/null &
        return 0
    fi

    # Linux (PulseAudio)
    if command -v paplay &> /dev/null; then
        paplay "$sound_file" 2>/dev/null &
        return 0
    fi

    # Linux (ALSA)
    if command -v aplay &> /dev/null; then
        aplay -q "$sound_file" 2>/dev/null &
        return 0
    fi

    # mpv (cross-platform)
    if command -v mpv &> /dev/null; then
        mpv --no-video --really-quiet "$sound_file" 2>/dev/null &
        return 0
    fi

    # ffplay (from ffmpeg)
    if command -v ffplay &> /dev/null; then
        ffplay -nodisp -autoexit -loglevel quiet "$sound_file" 2>/dev/null &
        return 0
    fi

    return 1
}

play_system_sound() {
    # macOS system sounds
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local sounds=(
            "/System/Library/Sounds/Glass.aiff"
            "/System/Library/Sounds/Ping.aiff"
            "/System/Library/Sounds/Pop.aiff"
            "/System/Library/Sounds/Purr.aiff"
        )
        for sound in "${sounds[@]}"; do
            if [ -f "$sound" ]; then
                afplay "$sound" 2>/dev/null &
                return 0
            fi
        done
    fi

    # Linux system sounds
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        local sounds=(
            "/usr/share/sounds/freedesktop/stereo/complete.oga"
            "/usr/share/sounds/gnome/default/alerts/glass.ogg"
            "/usr/share/sounds/ubuntu/notifications/Mallet.ogg"
            "/usr/share/sounds/sound-icons/prompt.wav"
        )
        for sound in "${sounds[@]}"; do
            if [ -f "$sound" ]; then
                play_sound "$sound"
                return 0
            fi
        done
    fi

    return 1
}

generate_beep() {
    # Terminal bell
    printf '\a'

    # macOS: Use say command for audio feedback
    if command -v say &> /dev/null; then
        say -v "Samantha" "Done" 2>/dev/null &
        return 0
    fi

    # Linux: Use speaker-test for a beep
    if command -v speaker-test &> /dev/null; then
        speaker-test -t sine -f 800 -l 1 2>/dev/null &
        sleep 0.2
        pkill -9 speaker-test 2>/dev/null
        return 0
    fi
}

# Main
main() {
    # Try custom sound first
    if [ -n "$CUSTOM_SOUND" ] && [ -f "$CUSTOM_SOUND" ]; then
        play_sound "$CUSTOM_SOUND" && exit 0
    fi

    # Try system sounds
    play_system_sound && exit 0

    # Fallback to beep
    generate_beep
}

main
