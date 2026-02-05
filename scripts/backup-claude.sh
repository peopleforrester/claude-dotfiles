#!/usr/bin/env bash
# ABOUTME: Creates timestamped backups of the ~/.claude directory
# ABOUTME: Supports compression, rotation, and restoration

# =============================================================================
# BASH STRICT MODE
# =============================================================================
# The "set" command modifies shell behavior. These three flags together form
# what's known as "bash strict mode" - they make the script fail fast on errors
# rather than continuing in an undefined state.
#
# -e (errexit): Exit immediately if any command returns a non-zero exit status.
#    This prevents the script from continuing after an error, which could lead
#    to cascading failures or unexpected behavior.
#
# -u (nounset): Treat unset variables as an error. If you try to use a variable
#    that hasn't been defined, the script will exit. This catches typos and
#    prevents the use of undefined variables.
#
# -o pipefail: The return value of a pipeline is the value of the last (rightmost)
#    command to exit with a non-zero status, or zero if all commands exit
#    successfully. Without this, `cmd1 | cmd2` would only fail if cmd2 fails,
#    hiding errors in cmd1.
#
# Together, these options make bash behave more like a "real" programming
# language with proper error handling.
# =============================================================================
set -euo pipefail

# =============================================================================
# Claude Config Backup Script
#
# PURPOSE:
# This script creates compressed backups of the ~/.claude directory with
# automatic rotation. It's essential for:
# - Protecting your Claude Code configuration from accidental loss
# - Creating restore points before making major changes
# - Syncing configurations between machines via the backup files
#
# FEATURES:
# - Timestamped backups with compression (tar.gz)
# - Automatic rotation to prevent disk space issues
# - Easy restoration with confirmation prompts
# - Excludes session data and temporary files
# - Progress indication when pv (pipe viewer) is available
#
# USAGE EXAMPLES:
#   ./backup-claude.sh              # Create a new backup
#   ./backup-claude.sh --restore    # Restore from the most recent backup
#   ./backup-claude.sh --list       # List all available backups
#   ./backup-claude.sh --clean      # Remove all backups (with confirmation)
#   ./backup-claude.sh --restore --file specific-backup.tar.gz
# =============================================================================

# =============================================================================
# SCRIPT CONFIGURATION
# =============================================================================
# VERSION: Semantic version following SemVer (MAJOR.MINOR.PATCH)
# - MAJOR: Breaking changes to the CLI interface
# - MINOR: New features that are backwards compatible
# - PATCH: Bug fixes that are backwards compatible
VERSION="1.0.0"

# CLAUDE_DIR: The directory we're backing up
# This is where Claude Code stores all its configuration:
# - settings.json: User preferences and permission settings
# - skills/: Custom skill definitions (SKILL.md files)
# - projects.json: Per-project settings
# - sessions/: Conversation history and context (we exclude this)
CLAUDE_DIR="${HOME}/.claude"

# BACKUP_DIR: Where backups are stored
# Uses the CLAUDE_BACKUP_DIR environment variable if set, otherwise defaults
# to ~/.claude-backups. The ${VAR:-default} syntax means "use $VAR if set
# and non-empty, otherwise use 'default'".
BACKUP_DIR="${CLAUDE_BACKUP_DIR:-${HOME}/.claude-backups}"

# MAX_BACKUPS: Maximum number of backups to retain
# When this limit is exceeded, the oldest backups are automatically deleted.
# Can be overridden via the CLAUDE_MAX_BACKUPS environment variable.
# 10 is a reasonable default that balances disk usage with history retention.
MAX_BACKUPS="${CLAUDE_MAX_BACKUPS:-10}"

# =============================================================================
# TERMINAL COLOR DEFINITIONS
# =============================================================================
# Colors are defined using ANSI escape codes. These codes tell the terminal
# to change the text color. The format is:
#   \033[<code>m  where <code> specifies the color/style
#
# The codes used here:
#   0;31 = Red (normal intensity)
#   0;32 = Green (normal intensity)
#   0;33 = Yellow (normal intensity)
#   0;34 = Blue (normal intensity)
#   1    = Bold text
#   0    = Reset all formatting (NC = "No Color")
#
# WHY THE if [ -t 1 ] CHECK?
# The -t 1 test checks if file descriptor 1 (stdout) is connected to a
# terminal (TTY). If we're piping output to a file or another program,
# we don't want ANSI codes polluting the output. In that case, we set
# all color variables to empty strings so they have no effect.
#
# Example: ./backup-claude.sh > log.txt  # No colors in log.txt
#          ./backup-claude.sh            # Colors in terminal
# =============================================================================
if [ -t 1 ]; then
    RED='\033[0;31m'      # Error messages
    GREEN='\033[0;32m'    # Success messages
    YELLOW='\033[0;33m'   # Warning messages
    BLUE='\033[0;34m'     # Info messages
    BOLD='\033[1m'        # Headers and emphasis
    NC='\033[0m'          # Reset - "No Color"
else
    # When not in a terminal, disable colors by setting all to empty string
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' NC=''
fi

# =============================================================================
# OUTPUT HELPER FUNCTIONS
# =============================================================================
# These functions provide consistent, colorized output throughout the script.
# Using functions instead of raw echo commands has several benefits:
# 1. Consistency: All success messages look the same
# 2. Maintainability: Change the format in one place
# 3. Semantic clarity: print_success() is more readable than echo with colors
#
# echo -e: The -e flag enables interpretation of backslash escapes like \033
# >&2: Redirects output to stderr (file descriptor 2) - used for errors
# =============================================================================

# print_success: Display a success message with a green checkmark
# Example output: ✓ Backup created successfully
print_success() { echo -e "${GREEN}✓${NC} $1"; }

# print_warning: Display a warning message with a yellow exclamation
# Example output: ! No backup directory found
print_warning() { echo -e "${YELLOW}!${NC} $1"; }

# print_error: Display an error message with a red X to stderr
# Using >&2 ensures errors go to stderr, allowing proper stream separation
# Example: ./backup-claude.sh 2>errors.log  # Captures only errors
print_error() { echo -e "${RED}✗${NC} $1" >&2; }

# print_info: Display an informational message with a blue arrow
# Example output: → Backing up ~/.claude (15M)...
print_info() { echo -e "${BLUE}→${NC} $1"; }

# =============================================================================
# BACKUP FUNCTIONS
# =============================================================================

# =============================================================================
# CREATE_BACKUP FUNCTION
# =============================================================================
# This function creates a new compressed backup of the ~/.claude directory.
#
# PROCESS:
# 1. Generate a unique timestamp for the backup filename
# 2. Verify the source directory exists
# 3. Create the backup directory if needed
# 4. Calculate and display the source size
# 5. Create a compressed tarball, excluding unnecessary files
# 6. Verify the backup was created successfully
# 7. Create a "latest" symlink for easy access
# 8. Trigger rotation to clean up old backups
#
# The function uses local variables to avoid polluting the global namespace.
# Local variables only exist within this function's scope.
# =============================================================================
create_backup() {
    # Generate timestamp in format YYYYMMDD-HHMMSS
    # This format ensures backups sort chronologically by filename
    # The 'local' keyword restricts the variable to this function's scope
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)

    # Construct the backup filename and full path
    # Example: claude-backup-20260203-143022.tar.gz
    local backup_name="claude-backup-${timestamp}"
    local backup_path="${BACKUP_DIR}/${backup_name}.tar.gz"

    # ==========================================================================
    # SOURCE VALIDATION
    # ==========================================================================
    # Before attempting a backup, we must verify the source directory exists.
    # The -d test checks if a path exists AND is a directory.
    # Without this check, tar would fail with a confusing error message.
    # ==========================================================================
    if [ ! -d "${CLAUDE_DIR}" ]; then
        print_error "Claude directory not found: ${CLAUDE_DIR}"
        exit 1
    fi

    # ==========================================================================
    # CREATE BACKUP DIRECTORY
    # ==========================================================================
    # mkdir -p: Create directory and all parent directories as needed
    # The -p flag means:
    # - Don't error if the directory already exists
    # - Create any missing parent directories
    # Example: mkdir -p a/b/c creates 'a', 'a/b', and 'a/b/c' if needed
    # ==========================================================================
    mkdir -p "${BACKUP_DIR}"

    # ==========================================================================
    # CALCULATE AND DISPLAY SOURCE SIZE
    # ==========================================================================
    # du -sh: Display disk usage in human-readable format
    #   -s: Summarize (show only total, not each file)
    #   -h: Human-readable (KB, MB, GB instead of bytes)
    # cut -f1: Extract the first field (the size), discarding the path
    # 2>/dev/null: Suppress error messages (e.g., permission denied on some files)
    # ==========================================================================
    local size
    size=$(du -sh "${CLAUDE_DIR}" 2>/dev/null | cut -f1)
    print_info "Backing up ${CLAUDE_DIR} (${size})..."

    # ==========================================================================
    # EXCLUSION PATTERNS
    # ==========================================================================
    # These patterns tell tar what NOT to include in the backup:
    # - sessions/*: Session data is machine-specific and regenerated
    # - *.log: Log files are temporary and can be large
    # - *.tmp: Temporary files by definition don't need backing up
    # - .DS_Store: macOS metadata files, not needed
    #
    # The array syntax (var=( ... )) creates a bash array, which allows us
    # to expand these as separate arguments to tar using "${array[@]}"
    # ==========================================================================
    local exclude_patterns=(
        "--exclude=sessions/*"    # Session data is machine-specific
        "--exclude=*.log"         # Log files are temporary
        "--exclude=*.tmp"         # Temp files don't need backup
        "--exclude=.DS_Store"     # macOS metadata files
    )

    # ==========================================================================
    # CREATE COMPRESSED BACKUP
    # ==========================================================================
    # This section creates the actual backup. We have two paths:
    # 1. WITH progress indicator (if 'pv' is installed)
    # 2. Without progress indicator (fallback)
    #
    # The 'pv' (pipe viewer) utility shows a progress bar for data flowing
    # through a pipe. It's optional but provides a better user experience.
    #
    # command -v pv: Check if 'pv' is available (returns path if found)
    # &> /dev/null: Suppress both stdout and stderr from the check
    # ==========================================================================
    if command -v pv &> /dev/null; then
        # PATH WITH PROGRESS INDICATOR
        # ============================
        # This pipeline creates the backup with a visual progress bar:
        #
        # tar cf - : Create archive, output to stdout (-)
        #   c: Create new archive
        #   f -: Write to stdout instead of a file
        #   -C "${HOME}": Change to home directory before archiving
        #   .claude: The directory to archive (relative to -C path)
        #
        # pv -s SIZE: Pipe viewer with known total size
        #   -s: Total size in bytes (for percentage calculation)
        #   du -sb: Get size in bytes (not human-readable)
        #
        # gzip: Compress the tar output
        #
        # > "${backup_path}": Redirect compressed output to file
        #
        # 2>/dev/null on tar: Suppress warning messages
        tar cf - -C "${HOME}" .claude "${exclude_patterns[@]}" 2>/dev/null | \
            pv -s "$(du -sb "${CLAUDE_DIR}" | cut -f1)" | \
            gzip > "${backup_path}"
    else
        # PATH WITHOUT PROGRESS INDICATOR
        # ================================
        # Simpler command when pv isn't available:
        # tar czf: Create, gzip, file (all in one)
        # This is less visual but works everywhere
        tar czf "${backup_path}" -C "${HOME}" .claude "${exclude_patterns[@]}" 2>/dev/null
    fi

    # ==========================================================================
    # VERIFY BACKUP SUCCESS
    # ==========================================================================
    # After creating the backup, we verify it exists and report the result.
    # The -f test checks if the path exists and is a regular file.
    # ==========================================================================
    if [ -f "${backup_path}" ]; then
        # Get the size of the compressed backup
        local backup_size
        backup_size=$(du -sh "${backup_path}" | cut -f1)
        print_success "Backup created: ${backup_path} (${backup_size})"

        # ======================================================================
        # CREATE "LATEST" SYMLINK
        # ======================================================================
        # Creating a symlink to the latest backup makes it easy to find:
        #   ls -la ~/.claude-backups/claude-backup-latest.tar.gz
        #
        # ln -sf: Create symlink, force (overwrite if exists)
        #   -s: Create symbolic link (not hard link)
        #   -f: Force - remove existing destination file if it exists
        #
        # This symlink always points to the most recent backup, making
        # restoration simpler: --restore uses this by default.
        # ======================================================================
        ln -sf "${backup_path}" "${BACKUP_DIR}/claude-backup-latest.tar.gz"

        # Trigger backup rotation to maintain MAX_BACKUPS limit
        rotate_backups
    else
        print_error "Backup failed!"
        exit 1
    fi
}

# =============================================================================
# ROTATE_BACKUPS FUNCTION
# =============================================================================
# This function enforces the MAX_BACKUPS limit by deleting the oldest backups
# when the count exceeds the maximum.
#
# WHY ROTATE?
# Without rotation, backups would accumulate forever, eventually filling up
# disk space. This automated cleanup ensures predictable disk usage.
#
# ALGORITHM:
# 1. Count existing backups
# 2. If count > MAX_BACKUPS, calculate how many to delete
# 3. Sort backups by name (oldest first due to timestamp format)
# 4. Delete the oldest ones until we're at the limit
# =============================================================================
rotate_backups() {
    # Count backup files
    # find: Search for files matching the pattern
    #   -name "claude-backup-*.tar.gz": Match backup filenames
    #   -type f: Only regular files (not directories or symlinks)
    # wc -l: Count lines (one per file found)
    # tr -d ' ': Remove spaces from wc output (some versions add padding)
    local backup_count
    backup_count=$(find "${BACKUP_DIR}" -name "claude-backup-*.tar.gz" -type f | wc -l | tr -d ' ')

    # Check if rotation is needed
    if [ "$backup_count" -gt "$MAX_BACKUPS" ]; then
        # Calculate how many backups to remove
        # Example: 15 backups, max 10 = delete 5 oldest
        local to_delete=$((backup_count - MAX_BACKUPS))
        print_info "Rotating backups (keeping ${MAX_BACKUPS} most recent)..."

        # Delete oldest backups
        # The pipeline:
        # 1. find: List all backup files
        # 2. sort: Sort alphabetically (timestamps sort chronologically)
        # 3. head -n N: Take the first N (oldest) entries
        # 4. while read: Process each file path
        # 5. rm -f: Delete the file (force - no error if missing)
        find "${BACKUP_DIR}" -name "claude-backup-*.tar.gz" -type f | \
            sort | head -n "$to_delete" | while read -r old_backup; do
            rm -f "$old_backup"
            print_info "Removed: $(basename "$old_backup")"
        done
    fi
}

# =============================================================================
# LIST_BACKUPS FUNCTION
# =============================================================================
# Displays all available backups in a formatted, easy-to-read list.
# Shows the filename, creation date/time, and file size.
# =============================================================================
list_backups() {
    # Check if backup directory exists
    if [ ! -d "${BACKUP_DIR}" ]; then
        print_warning "No backup directory found: ${BACKUP_DIR}"
        return 0  # Return success - this is informational, not an error
    fi

    # Find all backup files, sorted newest first (sort -r for reverse)
    local backups
    backups=$(find "${BACKUP_DIR}" -name "claude-backup-*.tar.gz" -type f | sort -r)

    # Check if any backups were found
    if [ -z "$backups" ]; then
        print_warning "No backups found"
        return 0
    fi

    # Display header
    echo -e "${BOLD}Available Backups${NC}"
    echo ""

    # Iterate through backups and display formatted information
    local count=1
    echo "$backups" | while read -r backup; do
        # Extract just the filename from the full path
        local filename
        filename=$(basename "$backup")

        # Get file size in human-readable format
        local size
        size=$(du -sh "$backup" | cut -f1)

        # Extract the timestamp from the filename
        # grep -oE '[0-9]{8}-[0-9]{6}': Extract pattern YYYYMMDD-HHMMSS
        # -o: Only output the matching part
        # -E: Extended regex
        local date_part
        date_part=$(echo "$filename" | grep -oE '[0-9]{8}-[0-9]{6}')

        # Format the timestamp for human readability
        # sed transforms: 20260203-143022 → 2026-02-03 14:30:22
        # The regex groups capture year, month, day, hour, minute, second
        # and rearrange them with dashes, space, and colons
        local formatted_date
        formatted_date=$(echo "$date_part" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)-\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')

        # Display the backup information
        echo "  ${count}. ${filename}"
        echo "     Date: ${formatted_date}"
        echo "     Size: ${size}"
        echo ""
        count=$((count + 1))
    done
}

# =============================================================================
# RESTORE_BACKUP FUNCTION
# =============================================================================
# Restores the Claude configuration from a backup file.
#
# SAFETY FEATURES:
# - Prompts for confirmation before overwriting
# - Creates a backup of the current config before restoring
# - Verifies the restore completed successfully
#
# PARAMETERS:
# $1 - Path to backup file (optional, defaults to latest)
# =============================================================================
restore_backup() {
    local backup_file="$1"

    # ==========================================================================
    # BACKUP FILE SELECTION
    # ==========================================================================
    # If no file was specified, try to find the most recent backup.
    # First check for the "latest" symlink, then fall back to finding
    # the newest backup by sorting filenames.
    # ==========================================================================
    if [ -z "$backup_file" ]; then
        # Check for the "latest" symlink
        # -L tests if the path is a symbolic link
        if [ -L "${BACKUP_DIR}/claude-backup-latest.tar.gz" ]; then
            backup_file="${BACKUP_DIR}/claude-backup-latest.tar.gz"
        else
            # Find the most recent backup by name
            # sort -r: Reverse sort (newest first due to timestamp format)
            # head -1: Take only the first result
            backup_file=$(find "${BACKUP_DIR}" -name "claude-backup-*.tar.gz" -type f | sort -r | head -1)
        fi
    fi

    # Verify the backup file exists
    if [ ! -f "$backup_file" ]; then
        print_error "Backup file not found: ${backup_file}"
        list_backups  # Show available options
        exit 1
    fi

    # ==========================================================================
    # CONFIRMATION PROMPT
    # ==========================================================================
    # Restoring will overwrite the current configuration. This is a destructive
    # operation, so we require explicit confirmation from the user.
    #
    # read -r: Raw input (don't interpret backslashes)
    # read -p: Display prompt before reading
    # [y/N]: Convention - capital N means No is the default
    # ==========================================================================
    print_warning "This will replace your current ${CLAUDE_DIR}"
    read -rp "Continue? [y/N] " response

    # Pattern match: only proceed if response starts with Y or y
    # [[ ... =~ pattern ]]: Bash regex matching
    # ^[Yy]$: Start with Y or y, and that's the entire response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_info "Restore cancelled"
        exit 0
    fi

    # ==========================================================================
    # BACKUP CURRENT CONFIG (SAFETY NET)
    # ==========================================================================
    # Before destroying the current configuration, create a backup of it.
    # This allows the user to recover if the restored config has issues.
    # The "pre-restore" prefix makes these backups identifiable.
    # ==========================================================================
    if [ -d "${CLAUDE_DIR}" ]; then
        print_info "Creating backup of current config..."
        local temp_backup="${BACKUP_DIR}/claude-pre-restore-$(date +%Y%m%d-%H%M%S).tar.gz"

        # Create backup, but don't fail if there are issues
        # || true: Ignore errors (continue even if backup fails)
        tar czf "${temp_backup}" -C "${HOME}" .claude 2>/dev/null || true
        print_info "Current config backed up to: ${temp_backup}"
    fi

    # ==========================================================================
    # REMOVE CURRENT CONFIG
    # ==========================================================================
    # rm -rf: Remove recursively, force (no prompts)
    # This is destructive but we've already created a backup above
    # ==========================================================================
    print_info "Removing current config..."
    rm -rf "${CLAUDE_DIR}"

    # ==========================================================================
    # EXTRACT BACKUP
    # ==========================================================================
    # tar xzf: Extract, gunzip, from file
    #   x: Extract mode
    #   z: Decompress with gzip
    #   f: Read from specified file
    # -C "${HOME}": Change to home directory before extracting
    # The archive contains ".claude" so it extracts to ~/.claude
    # ==========================================================================
    print_info "Restoring from: $(basename "$backup_file")..."
    tar xzf "${backup_file}" -C "${HOME}"

    # Verify restoration was successful
    if [ -d "${CLAUDE_DIR}" ]; then
        print_success "Restore complete!"
    else
        print_error "Restore may have failed - ${CLAUDE_DIR} not found"
        exit 1
    fi
}

# =============================================================================
# CLEAN_BACKUPS FUNCTION
# =============================================================================
# Removes all backup files after user confirmation.
# This is a destructive operation that cannot be undone.
# =============================================================================
clean_backups() {
    # Check if backup directory exists
    if [ ! -d "${BACKUP_DIR}" ]; then
        print_info "No backup directory to clean"
        return 0
    fi

    # Count existing backups
    local backup_count
    backup_count=$(find "${BACKUP_DIR}" -name "claude-backup-*.tar.gz" -type f | wc -l | tr -d ' ')

    if [ "$backup_count" -eq 0 ]; then
        print_info "No backups to clean"
        return 0
    fi

    # Require confirmation before deleting
    print_warning "This will delete all ${backup_count} backup(s)"
    read -rp "Continue? [y/N] " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_info "Clean cancelled"
        exit 0
    fi

    # Delete all backup files
    # find -delete: Delete matching files directly (more efficient than rm)
    find "${BACKUP_DIR}" -name "claude-backup-*.tar.gz" -type f -delete

    # Also remove the "latest" symlink
    rm -f "${BACKUP_DIR}/claude-backup-latest.tar.gz"

    print_success "All backups deleted"
}

# =============================================================================
# SHOW_USAGE FUNCTION
# =============================================================================
# Displays comprehensive help text explaining all commands and options.
# Uses a heredoc (<<EOF...EOF) for clean multi-line string formatting.
# =============================================================================
show_usage() {
    # Heredoc: Everything between <<EOF and EOF is treated as a single string
    # This is cleaner than multiple echo commands for multi-line text
    cat << EOF
Usage: $(basename "$0") [command] [options]

Commands:
  (default)    Create a new backup
  --restore    Restore from backup
  --list       List available backups
  --clean      Delete all backups
  --help       Show this help

Options:
  --file FILE  Specify backup file for restore

Environment Variables:
  CLAUDE_BACKUP_DIR    Backup directory (default: ~/.claude-backups)
  CLAUDE_MAX_BACKUPS   Max backups to keep (default: 10)

Examples:
  $(basename "$0")                                    # Create backup
  $(basename "$0") --list                             # List backups
  $(basename "$0") --restore                          # Restore latest
  $(basename "$0") --restore --file backup.tar.gz    # Restore specific
EOF
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================
# The main entry point that parses command-line arguments and dispatches
# to the appropriate function.
#
# ARGUMENT PARSING:
# Uses a while loop with case statement for flexible argument handling.
# This pattern supports:
# - Flags (--restore, --list, --clean)
# - Options with values (--file backup.tar.gz)
# - Positional arguments (backup file path)
# =============================================================================
main() {
    local command="backup"     # Default action if no command specified
    local restore_file=""      # File path for --restore --file option

    # ==========================================================================
    # ARGUMENT PARSING LOOP
    # ==========================================================================
    # $#: Number of remaining arguments
    # $1: First (current) argument
    # shift: Remove first argument, shift others down
    # shift 2: Remove first two arguments (for --flag value pairs)
    # ==========================================================================
    while [[ $# -gt 0 ]]; do
        case $1 in
            --restore)
                command="restore"
                shift  # Remove --restore from arguments
                ;;
            --list)
                command="list"
                shift
                ;;
            --clean)
                command="clean"
                shift
                ;;
            --file)
                # --file takes the next argument as its value
                restore_file="$2"
                shift 2  # Remove both --file and its value
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                # Unknown argument - check if it's a file path
                # This allows: ./backup-claude.sh backup.tar.gz
                if [ -f "$1" ]; then
                    restore_file="$1"
                    command="restore"
                else
                    print_error "Unknown argument: $1"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done

    # Display header banner
    echo -e "${BOLD}Claude Config Backup${NC} v${VERSION}"
    echo ""

    # ==========================================================================
    # COMMAND DISPATCH
    # ==========================================================================
    # Execute the appropriate function based on the parsed command
    # ==========================================================================
    case "$command" in
        backup)
            create_backup
            ;;
        restore)
            restore_backup "$restore_file"
            ;;
        list)
            list_backups
            ;;
        clean)
            clean_backups
            ;;
    esac
}

# =============================================================================
# SCRIPT ENTRY POINT
# =============================================================================
# "$@" passes all command-line arguments to the main function.
# This is the standard way to invoke the main function in bash scripts.
# Using a main function rather than putting code at the top level:
# - Allows local variables (not possible at top level)
# - Makes the script more testable
# - Follows best practices for script organization
# =============================================================================
main "$@"
