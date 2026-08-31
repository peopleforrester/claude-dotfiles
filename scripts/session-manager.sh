#!/usr/bin/env bash
# ABOUTME: Session state persistence for Claude Code sessions.
# ABOUTME: Saves and restores session context across conversations.

set -euo pipefail

SESSIONS_DIR="${HOME}/.claude/sessions"
mkdir -p "$SESSIONS_DIR"

save_session() {
    local label="${1:-$(date +%Y-%m-%d_%H%M%S)}"
    local branch
    branch=$(git branch --show-current 2>/dev/null || echo "no-repo")
    local commit
    commit=$(git rev-parse --short HEAD 2>/dev/null || echo "none")
    local changes
    changes=$(git diff --stat 2>/dev/null || echo "no changes")

    local session_file="${SESSIONS_DIR}/session_${label}.md"

    cat > "$session_file" << EOF
# Session: ${label}

**Date**: $(date +%Y-%m-%d)
**Branch**: \`${branch}\`
**Commit**: \`${commit}\`

## Uncommitted Changes
\`\`\`
${changes}
\`\`\`

## Notes
[Add context about what was in progress]
EOF

    echo "Session saved: ${session_file}"
}

list_sessions() {
    echo "Available sessions:"
    echo ""
    # Newest first by mtime. Parsing `ls` breaks on unusual filenames (SC2012),
    # so sort on a numeric mtime that find prints and cut the path back off.
    find "${SESSIONS_DIR}" -maxdepth 1 -name 'session_*.md' -printf '%T@ %p\n' 2>/dev/null \
        | sort -rn | cut -d' ' -f2- | while read -r file; do
        local name
        name=$(basename "$file" .md)
        local date
        date=$(head -5 "$file" | grep "Date" | sed 's/.*: //')
        local branch
        # shellcheck disable=SC2016  # backticks are literal markdown, not expansion
        branch=$(head -5 "$file" | grep "Branch" | sed 's/.*`\(.*\)`.*/\1/')
        printf "  %-40s  %s  %s\n" "$name" "${date:-unknown}" "${branch:-unknown}"
    done

    if [ ! "$(ls -A "${SESSIONS_DIR}"/session_*.md 2>/dev/null)" ]; then
        echo "  No sessions found."
    fi
}

clean_sessions() {
    local days="${1:-30}"
    find "$SESSIONS_DIR" -name "session_*.md" -mtime "+${days}" -print
    echo ""
    read -rp "Delete sessions older than ${days} days? [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        find "$SESSIONS_DIR" -name "session_*.md" -mtime "+${days}" -delete
        echo "Cleaned."
    else
        echo "Cancelled."
    fi
}

case "${1:-help}" in
    save)
        save_session "${2:-}"
        ;;
    list)
        list_sessions
        ;;
    clean)
        clean_sessions "${2:-30}"
        ;;
    *)
        echo "Usage: session-manager.sh {save|list|clean} [args]"
        echo ""
        echo "Commands:"
        echo "  save [label]    Save current session state"
        echo "  list            List saved sessions"
        echo "  clean [days]    Remove sessions older than N days (default: 30)"
        ;;
esac
