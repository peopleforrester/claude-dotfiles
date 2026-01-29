#!/usr/bin/env bash
# ABOUTME: Syncs Claude configurations across machines
# ABOUTME: Compatible with chezmoi, GNU Stow, and manual management

set -euo pipefail

# =============================================================================
# Claude Config Sync Script
#
# Syncs Claude Code configurations between machines.
# Supports multiple sync methods:
#   - chezmoi (recommended)
#   - GNU Stow
#   - rsync
#   - Git bare repository
#
# Usage:
#   ./sync-configs.sh push    # Push local config to remote
#   ./sync-configs.sh pull    # Pull config from remote
#   ./sync-configs.sh status  # Show sync status
# =============================================================================

VERSION="1.0.0"
CLAUDE_DIR="${HOME}/.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' NC=''
fi

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1" >&2; }
print_info() { echo -e "${BLUE}→${NC} $1"; }

# =============================================================================
# Sync Methods
# =============================================================================

sync_chezmoi() {
    local action="$1"

    if ! command -v chezmoi &> /dev/null; then
        print_error "chezmoi not found. Install: https://www.chezmoi.io/install/"
        return 1
    fi

    case "$action" in
        push)
            print_info "Adding Claude config to chezmoi..."
            chezmoi add "${CLAUDE_DIR}"
            chezmoi git add .
            chezmoi git commit -m "Update Claude config"
            chezmoi git push
            print_success "Config pushed to chezmoi repository"
            ;;
        pull)
            print_info "Pulling config from chezmoi..."
            chezmoi update
            print_success "Config pulled and applied"
            ;;
        status)
            print_info "Chezmoi status:"
            chezmoi status
            chezmoi diff
            ;;
    esac
}

sync_stow() {
    local action="$1"
    local stow_dir="${STOW_DIR:-${HOME}/.dotfiles}"

    if ! command -v stow &> /dev/null; then
        print_error "GNU Stow not found. Install via package manager."
        return 1
    fi

    local claude_stow="${stow_dir}/claude/.claude"

    case "$action" in
        push)
            print_info "Copying config to stow directory..."
            mkdir -p "${claude_stow}"
            cp -r "${CLAUDE_DIR}"/* "${claude_stow}/"
            print_info "Commit and push your dotfiles repository manually"
            print_success "Config copied to ${stow_dir}/claude/"
            ;;
        pull)
            print_info "Applying config from stow..."
            cd "${stow_dir}"
            stow -R claude
            print_success "Config applied via stow"
            ;;
        status)
            print_info "Stow directory: ${stow_dir}/claude/"
            if [ -d "${claude_stow}" ]; then
                ls -la "${claude_stow}"
            else
                print_warning "No claude stow package found"
            fi
            ;;
    esac
}

sync_rsync() {
    local action="$1"
    local remote="${CLAUDE_SYNC_REMOTE:-}"

    if [ -z "$remote" ]; then
        print_error "Set CLAUDE_SYNC_REMOTE environment variable"
        print_info "Example: export CLAUDE_SYNC_REMOTE=user@host:~/.claude-sync/"
        return 1
    fi

    case "$action" in
        push)
            print_info "Pushing config to ${remote}..."
            rsync -avz --delete \
                --exclude 'projects.json' \
                --exclude 'sessions/' \
                "${CLAUDE_DIR}/" "${remote}"
            print_success "Config pushed to remote"
            ;;
        pull)
            print_info "Pulling config from ${remote}..."
            rsync -avz --delete \
                --exclude 'projects.json' \
                --exclude 'sessions/' \
                "${remote}" "${CLAUDE_DIR}/"
            print_success "Config pulled from remote"
            ;;
        status)
            print_info "Remote: ${remote}"
            print_info "Local: ${CLAUDE_DIR}"
            rsync -avzn --delete "${CLAUDE_DIR}/" "${remote}" 2>/dev/null | head -20
            ;;
    esac
}

sync_git_bare() {
    local action="$1"
    local git_dir="${CLAUDE_GIT_DIR:-${HOME}/.claude-git}"
    local work_tree="${HOME}"

    git_cmd() {
        git --git-dir="${git_dir}" --work-tree="${work_tree}" "$@"
    }

    case "$action" in
        init)
            print_info "Initializing git bare repository..."
            git init --bare "${git_dir}"
            git_cmd config status.showUntrackedFiles no
            echo "alias claude-config='git --git-dir=${git_dir} --work-tree=${work_tree}'" >> ~/.bashrc
            print_success "Initialized. Add files with: claude-config add ~/.claude/..."
            ;;
        push)
            print_info "Pushing to git remote..."
            git_cmd add "${CLAUDE_DIR}"
            git_cmd commit -m "Update Claude config $(date +%Y-%m-%d)"
            git_cmd push
            print_success "Config pushed to git"
            ;;
        pull)
            print_info "Pulling from git remote..."
            git_cmd pull
            print_success "Config pulled"
            ;;
        status)
            print_info "Git status:"
            git_cmd status
            ;;
    esac
}

# =============================================================================
# Auto-detect sync method
# =============================================================================

detect_method() {
    if command -v chezmoi &> /dev/null && [ -d "${HOME}/.local/share/chezmoi" ]; then
        echo "chezmoi"
    elif command -v stow &> /dev/null && [ -d "${HOME}/.dotfiles/claude" ]; then
        echo "stow"
    elif [ -n "${CLAUDE_SYNC_REMOTE:-}" ]; then
        echo "rsync"
    elif [ -d "${CLAUDE_GIT_DIR:-${HOME}/.claude-git}" ]; then
        echo "git-bare"
    else
        echo "none"
    fi
}

# =============================================================================
# Main
# =============================================================================

show_usage() {
    cat << EOF
Usage: $(basename "$0") [command] [options]

Commands:
  push      Push local config to remote/repository
  pull      Pull config from remote/repository
  status    Show sync status
  init      Initialize sync (for git-bare method)

Options:
  --method METHOD   Force sync method (chezmoi, stow, rsync, git-bare)
  --help            Show this help

Environment Variables:
  CLAUDE_SYNC_REMOTE   Remote destination for rsync (user@host:path)
  CLAUDE_GIT_DIR       Git bare repository directory
  STOW_DIR             GNU Stow directory (default: ~/.dotfiles)

Examples:
  $(basename "$0") push                    # Auto-detect and push
  $(basename "$0") pull --method chezmoi   # Pull using chezmoi
  $(basename "$0") status                  # Show current status
EOF
}

main() {
    local command=""
    local method=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            push|pull|status|init)
                command="$1"
                shift
                ;;
            --method)
                method="$2"
                shift 2
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown argument: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    if [ -z "$command" ]; then
        show_usage
        exit 1
    fi

    # Detect or use specified method
    if [ -z "$method" ]; then
        method=$(detect_method)
    fi

    echo -e "${BOLD}Claude Config Sync${NC} v${VERSION}"
    echo ""

    if [ "$method" = "none" ]; then
        print_warning "No sync method detected."
        echo ""
        echo "Set up sync with one of these methods:"
        echo "  1. Install chezmoi: https://www.chezmoi.io/install/"
        echo "  2. Use GNU Stow: Create ~/.dotfiles/claude/"
        echo "  3. Use rsync: Set CLAUDE_SYNC_REMOTE=user@host:path"
        echo "  4. Use git bare: Run '$0 init --method git-bare'"
        exit 1
    fi

    print_info "Using sync method: ${method}"
    echo ""

    case "$method" in
        chezmoi)
            sync_chezmoi "$command"
            ;;
        stow)
            sync_stow "$command"
            ;;
        rsync)
            sync_rsync "$command"
            ;;
        git-bare)
            sync_git_bare "$command"
            ;;
        *)
            print_error "Unknown method: $method"
            exit 1
            ;;
    esac
}

main "$@"
