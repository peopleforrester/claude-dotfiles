#!/usr/bin/env bash
# ABOUTME: Syncs Claude configurations across machines
# ABOUTME: Compatible with chezmoi, GNU Stow, and manual management

# =============================================================================
# BASH STRICT MODE
# =============================================================================
# These flags make bash behave more predictably and catch errors early:
#
# -e (errexit): Exit immediately if any command fails. Without this, a script
#    would continue after errors, potentially causing cascading failures.
#
# -u (nounset): Treat references to undefined variables as errors. This catches
#    typos and missing variable definitions that would otherwise silently fail.
#
# -o pipefail: In a pipeline (cmd1 | cmd2 | cmd3), the exit code is normally
#    from the last command. With pipefail, the pipeline fails if ANY command
#    fails, making errors in earlier commands visible.
# =============================================================================
set -euo pipefail

# =============================================================================
# Claude Config Sync Script
#
# PURPOSE:
# This script synchronizes Claude Code configurations between multiple machines.
# It supports several popular dotfile management approaches, automatically
# detecting which one is in use on your system.
#
# SUPPORTED SYNC METHODS:
#
# 1. CHEZMOI (Recommended)
#    - Modern dotfile manager with templating and encryption
#    - Website: https://www.chezmoi.io/
#    - Stores dotfiles in a git repository
#    - Supports secrets management
#
# 2. GNU STOW
#    - Simple symlink farm manager
#    - Package-based organization (one directory per program)
#    - Uses symbolic links to deploy configuration
#
# 3. RSYNC
#    - Direct file synchronization over SSH
#    - Requires a remote server or another machine
#    - Good for direct machine-to-machine sync
#
# 4. GIT BARE REPOSITORY
#    - Uses a bare git repo to version control $HOME directly
#    - No symlinks needed - files stay in place
#    - Popular approach described in many dotfile tutorials
#
# USAGE EXAMPLES:
#   ./sync-configs.sh push              # Upload local config to remote/repo
#   ./sync-configs.sh pull              # Download config from remote/repo
#   ./sync-configs.sh status            # Show sync status
#   ./sync-configs.sh push --method chezmoi   # Force specific method
# =============================================================================

# =============================================================================
# SCRIPT CONFIGURATION
# =============================================================================
VERSION="1.0.0"

# CLAUDE_DIR: The directory containing Claude Code configuration
# This is what we're synchronizing between machines
CLAUDE_DIR="${HOME}/.claude"

# SCRIPT_DIR: Directory where this script is located
# Used to find related files and configurations
#
# HOW THIS WORKS:
# ${BASH_SOURCE[0]}: Path to this script (works even when sourced)
# dirname: Extract the directory portion of the path
# cd ... && pwd: Change to that directory and print absolute path
# $(...): Command substitution - captures the output
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# TERMINAL COLOR DEFINITIONS
# =============================================================================
# ANSI escape codes for colorized terminal output.
#
# FORMAT: \033[<attribute>;<color>m
# - \033[: Escape sequence start (ESC + [)
# - 0;XX: Normal intensity, color XX
# - 1: Bold
# - 0m: Reset (NC = No Color)
#
# The [ -t 1 ] test checks if stdout (file descriptor 1) is a terminal.
# If we're piping to a file or another program, we disable colors to
# avoid polluting the output with escape codes.
# =============================================================================
if [ -t 1 ]; then
    RED='\033[0;31m'      # Errors
    GREEN='\033[0;32m'    # Success
    YELLOW='\033[0;33m'   # Warnings
    BLUE='\033[0;34m'     # Information
    BOLD='\033[1m'        # Emphasis
    NC='\033[0m'          # No Color (reset)
else
    # Disable colors when not outputting to terminal
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' NC=''
fi

# =============================================================================
# OUTPUT HELPER FUNCTIONS
# =============================================================================
# Standardized output functions for consistent messaging throughout the script.
# Using functions provides:
# - Consistent formatting across all messages
# - Single point of change for styling
# - Semantic clarity (print_success vs raw echo)
# =============================================================================

# Green checkmark for successful operations
print_success() { echo -e "${GREEN}✓${NC} $1"; }

# Yellow exclamation for warnings (non-fatal issues)
print_warning() { echo -e "${YELLOW}!${NC} $1"; }

# Red X for errors, output to stderr
# >&2 redirects to stderr for proper stream separation
print_error() { echo -e "${RED}✗${NC} $1" >&2; }

# Blue arrow for informational messages
print_info() { echo -e "${BLUE}→${NC} $1"; }

# =============================================================================
# SYNC METHODS
# =============================================================================
# Each sync method is implemented as a separate function that handles
# push, pull, and status operations. This modular design makes it easy
# to add new sync methods in the future.
# =============================================================================

# =============================================================================
# CHEZMOI SYNC
# =============================================================================
# Chezmoi is a modern dotfile manager that:
# - Stores dotfiles in ~/.local/share/chezmoi (a git repo)
# - Supports templating for machine-specific configuration
# - Has built-in encryption for secrets
# - Handles file permissions, symlinks, and scripts
#
# Learn more: https://www.chezmoi.io/
#
# PARAMETERS:
# $1 - action: "push", "pull", or "status"
# =============================================================================
sync_chezmoi() {
    local action="$1"

    # Verify chezmoi is installed
    # command -v: Returns the path to a command, or fails if not found
    # &> /dev/null: Suppress all output (stdout and stderr)
    if ! command -v chezmoi &> /dev/null; then
        print_error "chezmoi not found. Install: https://www.chezmoi.io/install/"
        return 1
    fi

    # Perform the requested action
    case "$action" in
        push)
            # ================================================================
            # PUSH: Add local changes to chezmoi and push to remote
            # ================================================================
            # chezmoi add: Track a file/directory in chezmoi's source state
            # chezmoi git: Run git commands in the chezmoi repo
            # ================================================================
            print_info "Adding Claude config to chezmoi..."
            chezmoi add "${CLAUDE_DIR}"       # Add/update in source state
            chezmoi git add .                 # Stage all changes
            chezmoi git commit -m "Update Claude config"  # Commit
            chezmoi git push                  # Push to remote
            print_success "Config pushed to chezmoi repository"
            ;;
        pull)
            # ================================================================
            # PULL: Update local config from chezmoi repository
            # ================================================================
            # chezmoi update: Pull changes and apply them to $HOME
            # This is equivalent to: git pull + chezmoi apply
            # ================================================================
            print_info "Pulling config from chezmoi..."
            chezmoi update
            print_success "Config pulled and applied"
            ;;
        status)
            # ================================================================
            # STATUS: Show what would change
            # ================================================================
            # chezmoi status: Show files that differ from source
            # chezmoi diff: Show detailed differences
            # ================================================================
            print_info "Chezmoi status:"
            chezmoi status
            chezmoi diff
            ;;
    esac
}

# =============================================================================
# GNU STOW SYNC
# =============================================================================
# GNU Stow is a symlink farm manager. The concept:
# - You have a "stow directory" (e.g., ~/.dotfiles)
# - Inside are "packages" (e.g., claude/, vim/, zsh/)
# - Each package mirrors the structure it should have relative to $HOME
# - Running `stow package` creates symlinks from $HOME to the package
#
# Example structure:
#   ~/.dotfiles/claude/.claude/settings.json
#   → stow creates: ~/.claude/settings.json → ~/.dotfiles/claude/.claude/settings.json
#
# Learn more: https://www.gnu.org/software/stow/
#
# PARAMETERS:
# $1 - action: "push", "pull", or "status"
# =============================================================================
sync_stow() {
    local action="$1"

    # STOW_DIR: Where stow packages are stored
    # Default is ~/.dotfiles, can be overridden via environment variable
    local stow_dir="${STOW_DIR:-${HOME}/.dotfiles}"

    # Verify stow is installed
    if ! command -v stow &> /dev/null; then
        print_error "GNU Stow not found. Install via package manager."
        return 1
    fi

    # Path to the claude package within the stow directory
    local claude_stow="${stow_dir}/claude/.claude"

    case "$action" in
        push)
            # ================================================================
            # PUSH: Copy local config to stow directory
            # ================================================================
            # Unlike chezmoi, stow doesn't track changes automatically.
            # We manually copy files to the stow directory, then the user
            # commits and pushes their dotfiles repo.
            # ================================================================
            print_info "Copying config to stow directory..."
            mkdir -p "${claude_stow}"              # Create package structure
            cp -r "${CLAUDE_DIR}"/* "${claude_stow}/"  # Copy config files
            print_info "Commit and push your dotfiles repository manually"
            print_success "Config copied to ${stow_dir}/claude/"
            ;;
        pull)
            # ================================================================
            # PULL: Apply config from stow package
            # ================================================================
            # stow -R: Restow - unlink then relink (handles updates)
            # This creates symlinks from $HOME pointing to the package
            # ================================================================
            print_info "Applying config from stow..."
            cd "${stow_dir}"       # Stow requires running from the stow directory
            stow -R claude         # -R = restow (update symlinks)
            print_success "Config applied via stow"
            ;;
        status)
            # ================================================================
            # STATUS: Show stow package contents
            # ================================================================
            print_info "Stow directory: ${stow_dir}/claude/"
            if [ -d "${claude_stow}" ]; then
                ls -la "${claude_stow}"
            else
                print_warning "No claude stow package found"
            fi
            ;;
    esac
}

# =============================================================================
# RSYNC SYNC
# =============================================================================
# Rsync is a versatile file synchronization tool that can:
# - Sync files locally or over SSH
# - Transfer only changed portions of files (efficient)
# - Preserve permissions, timestamps, and symlinks
# - Exclude specific files or patterns
#
# This method requires CLAUDE_SYNC_REMOTE to be set to a destination
# like "user@server:~/.claude-sync/" or another machine on your network.
#
# PARAMETERS:
# $1 - action: "push", "pull", or "status"
# =============================================================================
sync_rsync() {
    local action="$1"

    # Get the remote destination from environment variable
    local remote="${CLAUDE_SYNC_REMOTE:-}"

    # Require the remote to be configured
    if [ -z "$remote" ]; then
        print_error "Set CLAUDE_SYNC_REMOTE environment variable"
        print_info "Example: export CLAUDE_SYNC_REMOTE=user@host:~/.claude-sync/"
        return 1
    fi

    case "$action" in
        push)
            # ================================================================
            # PUSH: Upload local config to remote
            # ================================================================
            # rsync options:
            #   -a: Archive mode (preserves permissions, times, symlinks, etc.)
            #   -v: Verbose (show files being transferred)
            #   -z: Compress data during transfer
            #   --delete: Remove files on destination that don't exist locally
            #
            # --exclude: Skip these files (machine-specific data)
            #   - projects.json: Contains local project paths
            #   - sessions/: Contains session data specific to this machine
            #
            # Note the trailing slash on source: "${CLAUDE_DIR}/"
            # This means "contents of directory" not "directory itself"
            # ================================================================
            print_info "Pushing config to ${remote}..."
            rsync -avz --delete \
                --exclude 'projects.json' \
                --exclude 'sessions/' \
                "${CLAUDE_DIR}/" "${remote}"
            print_success "Config pushed to remote"
            ;;
        pull)
            # ================================================================
            # PULL: Download config from remote
            # ================================================================
            # Same options as push, but source and destination reversed
            # ================================================================
            print_info "Pulling config from ${remote}..."
            rsync -avz --delete \
                --exclude 'projects.json' \
                --exclude 'sessions/' \
                "${remote}" "${CLAUDE_DIR}/"
            print_success "Config pulled from remote"
            ;;
        status)
            # ================================================================
            # STATUS: Show what would be transferred
            # ================================================================
            # rsync -n: Dry run (show what would happen, don't do it)
            # head -20: Limit output to first 20 lines
            # ================================================================
            print_info "Remote: ${remote}"
            print_info "Local: ${CLAUDE_DIR}"
            rsync -avzn --delete "${CLAUDE_DIR}/" "${remote}" 2>/dev/null | head -20
            ;;
    esac
}

# =============================================================================
# GIT BARE REPOSITORY SYNC
# =============================================================================
# This approach uses a "bare" git repository to track dotfiles in $HOME.
# Unlike a regular git repo, the .git directory is stored elsewhere
# (like ~/.claude-git) to avoid conflicts with other git repositories.
#
# HOW IT WORKS:
# - Initialize a bare repo: git init --bare ~/.claude-git
# - Use an alias: alias cfg='git --git-dir=~/.claude-git --work-tree=$HOME'
# - Add files: cfg add ~/.claude/settings.json
# - Commit/push as normal
#
# This is a popular approach because:
# - No symlinks needed (files stay in place)
# - Full git history for your config
# - Works with any git remote (GitHub, GitLab, etc.)
#
# Learn more: Search "dotfiles bare git repository"
#
# PARAMETERS:
# $1 - action: "push", "pull", "status", or "init"
# =============================================================================
sync_git_bare() {
    local action="$1"

    # CLAUDE_GIT_DIR: Location of the bare git repository
    local git_dir="${CLAUDE_GIT_DIR:-${HOME}/.claude-git}"

    # work_tree: The directory git operates on (usually $HOME for dotfiles)
    local work_tree="${HOME}"

    # =========================================================================
    # GIT_CMD HELPER
    # =========================================================================
    # This function wraps git commands to use our bare repository.
    #
    # --git-dir: Where the .git directory is (our bare repo)
    # --work-tree: Where the actual files are ($HOME)
    #
    # Without this wrapper, every git command would need these flags.
    # =========================================================================
    git_cmd() {
        git --git-dir="${git_dir}" --work-tree="${work_tree}" "$@"
    }

    case "$action" in
        init)
            # ================================================================
            # INIT: Set up a new bare git repository
            # ================================================================
            # This is a one-time setup step for new installations
            # ================================================================
            print_info "Initializing git bare repository..."

            # Create the bare repository
            # --bare: Create a bare repo (no working directory)
            git init --bare "${git_dir}"

            # Hide untracked files by default
            # Without this, `git status` would show everything in $HOME
            git_cmd config status.showUntrackedFiles no

            # Add a shell alias for convenience
            # After sourcing .bashrc, user can run: claude-config status
            echo "alias claude-config='git --git-dir=${git_dir} --work-tree=${work_tree}'" >> ~/.bashrc

            print_success "Initialized. Add files with: claude-config add ~/.claude/..."
            ;;
        push)
            # ================================================================
            # PUSH: Commit and push changes
            # ================================================================
            print_info "Pushing to git remote..."
            git_cmd add "${CLAUDE_DIR}"
            git_cmd commit -m "Update Claude config $(date +%Y-%m-%d)"
            git_cmd push
            print_success "Config pushed to git"
            ;;
        pull)
            # ================================================================
            # PULL: Fetch and apply changes from remote
            # ================================================================
            print_info "Pulling from git remote..."
            git_cmd pull
            print_success "Config pulled"
            ;;
        status)
            # ================================================================
            # STATUS: Show git status
            # ================================================================
            print_info "Git status:"
            git_cmd status
            ;;
    esac
}

# =============================================================================
# AUTO-DETECT SYNC METHOD
# =============================================================================
# This function examines the system to determine which sync method is
# configured and available. It checks in order of preference:
# 1. Chezmoi (if installed and initialized)
# 2. GNU Stow (if installed and claude package exists)
# 3. Rsync (if CLAUDE_SYNC_REMOTE is set)
# 4. Git bare (if the bare repo exists)
# 5. None (no sync method detected)
#
# RETURN VALUE:
# Prints the method name to stdout: "chezmoi", "stow", "rsync", "git-bare", or "none"
# =============================================================================
detect_method() {
    # Check for chezmoi
    # - Command must exist
    # - Source directory must exist (indicates chezmoi is initialized)
    if command -v chezmoi &> /dev/null && [ -d "${HOME}/.local/share/chezmoi" ]; then
        echo "chezmoi"

    # Check for GNU Stow
    # - Command must exist
    # - Claude package directory must exist
    elif command -v stow &> /dev/null && [ -d "${HOME}/.dotfiles/claude" ]; then
        echo "stow"

    # Check for rsync
    # - CLAUDE_SYNC_REMOTE environment variable must be set
    # ${VAR:-} syntax: Use empty string if VAR is unset (avoids error with -u)
    elif [ -n "${CLAUDE_SYNC_REMOTE:-}" ]; then
        echo "rsync"

    # Check for git bare repository
    # - The bare repo directory must exist
    elif [ -d "${CLAUDE_GIT_DIR:-${HOME}/.claude-git}" ]; then
        echo "git-bare"

    # No sync method detected
    else
        echo "none"
    fi
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

# =============================================================================
# SHOW_USAGE FUNCTION
# =============================================================================
# Displays comprehensive help text for the script.
# Uses a heredoc (<<EOF...EOF) for clean multi-line formatting.
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

# =============================================================================
# MAIN ENTRY POINT
# =============================================================================
# Parses command-line arguments and dispatches to the appropriate sync method.
# =============================================================================
main() {
    local command=""   # The action to perform (push, pull, status, init)
    local method=""    # The sync method to use (auto-detected if not specified)

    # =========================================================================
    # ARGUMENT PARSING
    # =========================================================================
    # Process command-line arguments using a while loop with case statement.
    # This pattern is flexible and handles various argument formats.
    # =========================================================================
    while [[ $# -gt 0 ]]; do
        case $1 in
            # Commands: push, pull, status, init
            push|pull|status|init)
                command="$1"
                shift  # Remove this argument, move to next
                ;;
            # --method option with value
            --method)
                method="$2"   # Next argument is the method name
                shift 2       # Remove both --method and its value
                ;;
            # Help options
            --help|-h)
                show_usage
                exit 0
                ;;
            # Unknown argument
            *)
                print_error "Unknown argument: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Require a command
    if [ -z "$command" ]; then
        show_usage
        exit 1
    fi

    # =========================================================================
    # METHOD DETECTION
    # =========================================================================
    # If no method was specified via --method, auto-detect it
    # =========================================================================
    if [ -z "$method" ]; then
        method=$(detect_method)
    fi

    # Display header
    echo -e "${BOLD}Claude Config Sync${NC} v${VERSION}"
    echo ""

    # =========================================================================
    # HANDLE "NO METHOD" CASE
    # =========================================================================
    # If no sync method is available, show helpful setup instructions
    # =========================================================================
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

    # =========================================================================
    # DISPATCH TO SYNC METHOD
    # =========================================================================
    # Call the appropriate sync function based on the detected/specified method
    # =========================================================================
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

# =============================================================================
# SCRIPT ENTRY POINT
# =============================================================================
# Pass all command-line arguments to main function.
# Using main() rather than inline code allows for:
# - Local variables (not possible at top level)
# - Better organization and readability
# - Easier testing of individual functions
# =============================================================================
main "$@"
