#!/usr/bin/env bash
# ABOUTME: Creates timestamped backups of the ~/.claude directory
# ABOUTME: Supports compression, rotation, and restoration

set -euo pipefail

# =============================================================================
# Claude Config Backup Script
#
# Creates compressed backups of ~/.claude with automatic rotation.
#
# Usage:
#   ./backup-claude.sh              # Create backup
#   ./backup-claude.sh --restore    # Restore from backup
#   ./backup-claude.sh --list       # List available backups
#   ./backup-claude.sh --clean      # Remove old backups
# =============================================================================

VERSION="1.0.0"
CLAUDE_DIR="${HOME}/.claude"
BACKUP_DIR="${CLAUDE_BACKUP_DIR:-${HOME}/.claude-backups}"
MAX_BACKUPS="${CLAUDE_MAX_BACKUPS:-10}"

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
# Backup Functions
# =============================================================================

create_backup() {
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_name="claude-backup-${timestamp}"
    local backup_path="${BACKUP_DIR}/${backup_name}.tar.gz"

    # Check if source exists
    if [ ! -d "${CLAUDE_DIR}" ]; then
        print_error "Claude directory not found: ${CLAUDE_DIR}"
        exit 1
    fi

    # Create backup directory
    mkdir -p "${BACKUP_DIR}"

    # Calculate size
    local size
    size=$(du -sh "${CLAUDE_DIR}" 2>/dev/null | cut -f1)
    print_info "Backing up ${CLAUDE_DIR} (${size})..."

    # Exclude session data and temporary files
    local exclude_patterns=(
        "--exclude=sessions/*"
        "--exclude=*.log"
        "--exclude=*.tmp"
        "--exclude=.DS_Store"
    )

    # Create compressed backup with progress
    if command -v pv &> /dev/null; then
        tar cf - -C "${HOME}" .claude "${exclude_patterns[@]}" 2>/dev/null | \
            pv -s "$(du -sb "${CLAUDE_DIR}" | cut -f1)" | \
            gzip > "${backup_path}"
    else
        tar czf "${backup_path}" -C "${HOME}" .claude "${exclude_patterns[@]}" 2>/dev/null
    fi

    # Verify backup
    if [ -f "${backup_path}" ]; then
        local backup_size
        backup_size=$(du -sh "${backup_path}" | cut -f1)
        print_success "Backup created: ${backup_path} (${backup_size})"

        # Create latest symlink
        ln -sf "${backup_path}" "${BACKUP_DIR}/claude-backup-latest.tar.gz"

        # Clean old backups
        rotate_backups
    else
        print_error "Backup failed!"
        exit 1
    fi
}

rotate_backups() {
    local backup_count
    backup_count=$(find "${BACKUP_DIR}" -name "claude-backup-*.tar.gz" -type f | wc -l | tr -d ' ')

    if [ "$backup_count" -gt "$MAX_BACKUPS" ]; then
        local to_delete=$((backup_count - MAX_BACKUPS))
        print_info "Rotating backups (keeping ${MAX_BACKUPS} most recent)..."

        find "${BACKUP_DIR}" -name "claude-backup-*.tar.gz" -type f | \
            sort | head -n "$to_delete" | while read -r old_backup; do
            rm -f "$old_backup"
            print_info "Removed: $(basename "$old_backup")"
        done
    fi
}

list_backups() {
    if [ ! -d "${BACKUP_DIR}" ]; then
        print_warning "No backup directory found: ${BACKUP_DIR}"
        return 0
    fi

    local backups
    backups=$(find "${BACKUP_DIR}" -name "claude-backup-*.tar.gz" -type f | sort -r)

    if [ -z "$backups" ]; then
        print_warning "No backups found"
        return 0
    fi

    echo -e "${BOLD}Available Backups${NC}"
    echo ""

    local count=1
    echo "$backups" | while read -r backup; do
        local filename
        filename=$(basename "$backup")
        local size
        size=$(du -sh "$backup" | cut -f1)
        local date_part
        date_part=$(echo "$filename" | grep -oE '[0-9]{8}-[0-9]{6}')
        local formatted_date
        formatted_date=$(echo "$date_part" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)-\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')

        echo "  ${count}. ${filename}"
        echo "     Date: ${formatted_date}"
        echo "     Size: ${size}"
        echo ""
        count=$((count + 1))
    done
}

restore_backup() {
    local backup_file="$1"

    # If no file specified, use latest
    if [ -z "$backup_file" ]; then
        if [ -L "${BACKUP_DIR}/claude-backup-latest.tar.gz" ]; then
            backup_file="${BACKUP_DIR}/claude-backup-latest.tar.gz"
        else
            # Find most recent backup
            backup_file=$(find "${BACKUP_DIR}" -name "claude-backup-*.tar.gz" -type f | sort -r | head -1)
        fi
    fi

    if [ ! -f "$backup_file" ]; then
        print_error "Backup file not found: ${backup_file}"
        list_backups
        exit 1
    fi

    print_warning "This will replace your current ${CLAUDE_DIR}"
    read -rp "Continue? [y/N] " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_info "Restore cancelled"
        exit 0
    fi

    # Create backup of current config first
    if [ -d "${CLAUDE_DIR}" ]; then
        print_info "Creating backup of current config..."
        local temp_backup="${BACKUP_DIR}/claude-pre-restore-$(date +%Y%m%d-%H%M%S).tar.gz"
        tar czf "${temp_backup}" -C "${HOME}" .claude 2>/dev/null || true
        print_info "Current config backed up to: ${temp_backup}"
    fi

    # Remove current config
    print_info "Removing current config..."
    rm -rf "${CLAUDE_DIR}"

    # Restore from backup
    print_info "Restoring from: $(basename "$backup_file")..."
    tar xzf "${backup_file}" -C "${HOME}"

    if [ -d "${CLAUDE_DIR}" ]; then
        print_success "Restore complete!"
    else
        print_error "Restore may have failed - ${CLAUDE_DIR} not found"
        exit 1
    fi
}

clean_backups() {
    if [ ! -d "${BACKUP_DIR}" ]; then
        print_info "No backup directory to clean"
        return 0
    fi

    local backup_count
    backup_count=$(find "${BACKUP_DIR}" -name "claude-backup-*.tar.gz" -type f | wc -l | tr -d ' ')

    if [ "$backup_count" -eq 0 ]; then
        print_info "No backups to clean"
        return 0
    fi

    print_warning "This will delete all ${backup_count} backup(s)"
    read -rp "Continue? [y/N] " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_info "Clean cancelled"
        exit 0
    fi

    find "${BACKUP_DIR}" -name "claude-backup-*.tar.gz" -type f -delete
    rm -f "${BACKUP_DIR}/claude-backup-latest.tar.gz"

    print_success "All backups deleted"
}

show_usage() {
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
# Main
# =============================================================================

main() {
    local command="backup"
    local restore_file=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --restore)
                command="restore"
                shift
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
                restore_file="$2"
                shift 2
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                # Could be a backup file path
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

    echo -e "${BOLD}Claude Config Backup${NC} v${VERSION}"
    echo ""

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

main "$@"
