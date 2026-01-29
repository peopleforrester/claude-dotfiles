#!/usr/bin/env bash
# ABOUTME: Interactive installer for claude-dotfiles configurations
# ABOUTME: Supports macOS, Linux with backup, symlink, and profile options

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================

VERSION="0.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
BACKUP_DIR=""

# Colors (disabled if not a terminal)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    BOLD=''
    NC=''
fi

# =============================================================================
# Default Options
# =============================================================================

INSTALL_ALL=false
INSTALL_MINIMAL=false
INSTALL_SKILLS=false
INSTALL_HOOKS=false
INSTALL_MCP=false
INSTALL_SETTINGS=false
PROFILE="balanced"
USE_SYMLINK=false
NO_BACKUP=false
INTERACTIVE=true
DRY_RUN=false

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}${BOLD}claude-dotfiles${NC} v${VERSION}"
    echo -e "Production-ready configurations for Claude Code"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

print_step() {
    echo -e "\n${BOLD}$1${NC}"
}

detect_os() {
    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

show_progress() {
    local current=$1
    local total=$2
    local task=$3
    local percent=$((current * 100 / total))
    local filled=$((percent / 5))
    local empty=$((20 - filled))

    printf "\r  [%s%s] %3d%% %s" \
        "$(printf '#%.0s' $(seq 1 $filled 2>/dev/null) 2>/dev/null || echo "")" \
        "$(printf '.%.0s' $(seq 1 $empty 2>/dev/null) 2>/dev/null || echo "")" \
        "$percent" \
        "$task"
}

create_backup() {
    if [ "$NO_BACKUP" = true ]; then
        return 0
    fi

    if [ -d "$CLAUDE_DIR" ]; then
        BACKUP_DIR="${HOME}/.claude-backup-$(date +%Y%m%d-%H%M%S)"
        print_info "Backing up existing config to ${BACKUP_DIR}"
        cp -r "$CLAUDE_DIR" "$BACKUP_DIR"
        print_success "Backup created"
    fi
}

ensure_dir() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
}

copy_or_link() {
    local src=$1
    local dest=$2

    if [ "$DRY_RUN" = true ]; then
        echo "  Would copy: $src -> $dest"
        return 0
    fi

    ensure_dir "$(dirname "$dest")"

    if [ "$USE_SYMLINK" = true ]; then
        ln -sf "$src" "$dest"
    else
        cp -r "$src" "$dest"
    fi
}

# =============================================================================
# Installation Functions
# =============================================================================

install_settings() {
    print_step "Installing settings (${PROFILE} profile)..."

    local settings_src="${SCRIPT_DIR}/settings/permissions/${PROFILE}.json"
    local settings_dest="${CLAUDE_DIR}/settings.json"

    if [ ! -f "$settings_src" ]; then
        print_warning "Profile '${PROFILE}' not found, using balanced"
        settings_src="${SCRIPT_DIR}/settings/permissions/balanced.json"
    fi

    if [ -f "$settings_src" ]; then
        copy_or_link "$settings_src" "$settings_dest"
        print_success "Installed settings.json (${PROFILE})"
    else
        print_warning "Settings file not found: ${settings_src}"
    fi

    # Create local settings template if it doesn't exist
    local local_template="${CLAUDE_DIR}/settings.local.json"
    if [ ! -f "$local_template" ] && [ "$DRY_RUN" = false ]; then
        echo '{
  "// NOTE": "Personal overrides - this file is gitignored",
  "// ADD": "Your custom settings below"
}' > "$local_template"
        print_success "Created settings.local.json template"
    fi
}

install_skills() {
    print_step "Installing skills..."

    local skills_src="${SCRIPT_DIR}/skills"
    local skills_dest="${CLAUDE_DIR}/skills"

    if [ ! -d "$skills_src" ]; then
        print_warning "Skills directory not found: ${skills_src}"
        return 0
    fi

    ensure_dir "$skills_dest"

    local skill_count=0
    local total_skills
    total_skills=$(find "$skills_src" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')

    if [ "$total_skills" -eq 0 ]; then
        print_warning "No skills found to install"
        return 0
    fi

    find "$skills_src" -type d -mindepth 2 -maxdepth 2 | while read -r skill_dir; do
        if [ -f "${skill_dir}/SKILL.md" ]; then
            local skill_name
            skill_name=$(basename "$skill_dir")
            copy_or_link "$skill_dir" "${skills_dest}/${skill_name}"
            skill_count=$((skill_count + 1))
            show_progress "$skill_count" "$total_skills" "Installing ${skill_name}"
        fi
    done

    echo ""
    print_success "Installed ${total_skills} skills"
}

install_hooks() {
    print_step "Installing hooks..."

    local os
    os=$(detect_os)
    local hooks_src="${SCRIPT_DIR}/hooks"
    local hooks_dest="${CLAUDE_DIR}/hooks"

    if [ ! -d "$hooks_src" ]; then
        print_warning "Hooks directory not found: ${hooks_src}"
        return 0
    fi

    ensure_dir "$hooks_dest"

    # Install formatters
    if [ -d "${hooks_src}/formatters" ]; then
        for hook_file in "${hooks_src}/formatters"/*.json; do
            if [ -f "$hook_file" ]; then
                copy_or_link "$hook_file" "${hooks_dest}/$(basename "$hook_file")"
            fi
        done
        print_success "Installed formatter hooks"
    fi

    # Install platform-specific notifications
    if [ -d "${hooks_src}/notifications" ]; then
        case "$os" in
            macos)
                if [ -f "${hooks_src}/notifications/macos-notification.sh" ]; then
                    copy_or_link "${hooks_src}/notifications/macos-notification.sh" "${hooks_dest}/notify.sh"
                    [ "$DRY_RUN" = false ] && chmod +x "${hooks_dest}/notify.sh"
                    print_success "Installed macOS notification hook"
                fi
                ;;
            linux)
                if [ -f "${hooks_src}/notifications/linux-notify-send.sh" ]; then
                    copy_or_link "${hooks_src}/notifications/linux-notify-send.sh" "${hooks_dest}/notify.sh"
                    [ "$DRY_RUN" = false ] && chmod +x "${hooks_dest}/notify.sh"
                    print_success "Installed Linux notification hook"
                fi
                ;;
        esac
    fi

    # Install validators
    if [ -d "${hooks_src}/validators" ]; then
        for validator in "${hooks_src}/validators"/*; do
            if [ -f "$validator" ]; then
                copy_or_link "$validator" "${hooks_dest}/$(basename "$validator")"
                [ "$DRY_RUN" = false ] && [ -x "$validator" ] && chmod +x "${hooks_dest}/$(basename "$validator")"
            fi
        done
        print_success "Installed validator hooks"
    fi
}

install_mcp() {
    print_step "Installing MCP configurations..."

    local os
    os=$(detect_os)
    local mcp_src="${SCRIPT_DIR}/mcp"
    local mcp_dest

    # Determine Claude Desktop config location
    case "$os" in
        macos)
            mcp_dest="${HOME}/Library/Application Support/Claude"
            ;;
        linux)
            mcp_dest="${HOME}/.config/Claude"
            ;;
        windows)
            mcp_dest="${APPDATA}/Claude"
            ;;
        *)
            print_warning "Unknown OS, skipping MCP installation"
            return 0
            ;;
    esac

    if [ ! -d "$mcp_src" ]; then
        print_warning "MCP directory not found: ${mcp_src}"
        return 0
    fi

    ensure_dir "$mcp_dest"

    # Copy MCP server configs
    if [ -d "${mcp_src}/servers" ]; then
        ensure_dir "${mcp_dest}/mcp-servers"
        for server_config in "${mcp_src}/servers"/*.json; do
            if [ -f "$server_config" ]; then
                copy_or_link "$server_config" "${mcp_dest}/mcp-servers/$(basename "$server_config")"
            fi
        done
        print_success "Installed MCP server configurations"
    fi

    print_info "Note: Restart Claude Desktop to load MCP servers"
}

install_template() {
    local template_name=$1
    print_step "Installing ${template_name} template to current directory..."

    local template_src="${SCRIPT_DIR}/templates/${template_name}"

    if [ ! -d "$template_src" ]; then
        print_error "Template not found: ${template_name}"
        return 1
    fi

    # Copy CLAUDE.md
    if [ -f "${template_src}/CLAUDE.md" ]; then
        if [ -f "./CLAUDE.md" ]; then
            print_warning "CLAUDE.md already exists in current directory"
            read -rp "Overwrite? [y/N] " response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                print_info "Skipping CLAUDE.md"
            else
                cp "${template_src}/CLAUDE.md" "./CLAUDE.md"
                print_success "Installed CLAUDE.md"
            fi
        else
            cp "${template_src}/CLAUDE.md" "./CLAUDE.md"
            print_success "Installed CLAUDE.md"
        fi
    fi

    # Copy .claude directory if exists
    if [ -d "${template_src}/.claude" ]; then
        if [ -d "./.claude" ]; then
            print_warning ".claude directory already exists"
            read -rp "Merge? [y/N] " response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                cp -r "${template_src}/.claude"/* "./.claude/"
                print_success "Merged .claude directory"
            fi
        else
            cp -r "${template_src}/.claude" "./.claude"
            print_success "Installed .claude directory"
        fi
    fi
}

# =============================================================================
# Interactive Mode
# =============================================================================

run_interactive() {
    print_header

    echo "What would you like to install?"
    echo ""
    echo "  1) Everything (recommended for new users)"
    echo "  2) Minimal (CLAUDE.md template + settings only)"
    echo "  3) Custom (choose components)"
    echo "  4) Template only (copy to current project)"
    echo ""
    read -rp "Choice [1-4]: " choice

    case $choice in
        1)
            INSTALL_ALL=true
            ;;
        2)
            INSTALL_MINIMAL=true
            ;;
        3)
            echo ""
            read -rp "Install settings? [Y/n] " yn
            [[ ! "$yn" =~ ^[Nn]$ ]] && INSTALL_SETTINGS=true

            read -rp "Install skills? [Y/n] " yn
            [[ ! "$yn" =~ ^[Nn]$ ]] && INSTALL_SKILLS=true

            read -rp "Install hooks? [Y/n] " yn
            [[ ! "$yn" =~ ^[Nn]$ ]] && INSTALL_HOOKS=true

            read -rp "Install MCP configs? [y/N] " yn
            [[ "$yn" =~ ^[Yy]$ ]] && INSTALL_MCP=true
            ;;
        4)
            echo ""
            echo "Available templates:"
            echo "  1) minimal    - Bare essentials (~30 lines)"
            echo "  2) standard   - Recommended baseline (~80 lines)"
            echo "  3) power-user - Full featured (~100 lines)"
            echo ""
            read -rp "Template [1-3]: " template_choice

            case $template_choice in
                1) install_template "minimal" ;;
                2) install_template "standard" ;;
                3) install_template "power-user" ;;
                *) print_error "Invalid choice"; exit 1 ;;
            esac
            exit 0
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac

    # Choose profile
    echo ""
    echo "Permission profile:"
    echo "  1) conservative - Ask before most actions"
    echo "  2) balanced     - Auto-accept edits, ask for bash (recommended)"
    echo "  3) autonomous   - Minimal interruptions"
    echo ""
    read -rp "Profile [1-3, default=2]: " profile_choice

    case $profile_choice in
        1) PROFILE="conservative" ;;
        3) PROFILE="autonomous" ;;
        *) PROFILE="balanced" ;;
    esac

    # Symlink option
    echo ""
    read -rp "Use symlinks instead of copying? [y/N] " yn
    [[ "$yn" =~ ^[Yy]$ ]] && USE_SYMLINK=true
}

# =============================================================================
# Main Installation
# =============================================================================

run_install() {
    print_header

    local os
    os=$(detect_os)
    print_info "Detected OS: ${os}"
    print_info "Profile: ${PROFILE}"
    print_info "Install method: $([ "$USE_SYMLINK" = true ] && echo "symlink" || echo "copy")"

    # Create backup
    create_backup

    # Ensure .claude directory exists
    ensure_dir "$CLAUDE_DIR"

    if [ "$INSTALL_ALL" = true ]; then
        install_settings
        install_skills
        install_hooks
        install_mcp
    elif [ "$INSTALL_MINIMAL" = true ]; then
        install_settings
        print_info "Run './install.sh --template standard' to install CLAUDE.md template"
    else
        [ "$INSTALL_SETTINGS" = true ] && install_settings
        [ "$INSTALL_SKILLS" = true ] && install_skills
        [ "$INSTALL_HOOKS" = true ] && install_hooks
        [ "$INSTALL_MCP" = true ] && install_mcp
    fi

    print_step "Installation complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Copy a CLAUDE.md template to your project:"
    echo "     cp ${SCRIPT_DIR}/templates/standard/CLAUDE.md ./CLAUDE.md"
    echo ""
    echo "  2. Customize settings in ~/.claude/settings.local.json"
    echo ""
    echo "  3. Start Claude Code in your project:"
    echo "     claude"
    echo ""

    if [ -n "$BACKUP_DIR" ]; then
        echo "Your previous config was backed up to: ${BACKUP_DIR}"
        echo ""
    fi
}

# =============================================================================
# Usage
# =============================================================================

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --all              Install everything (settings, skills, hooks, MCP)
  --minimal          Install settings only
  --skills           Install skills only
  --hooks            Install hooks only
  --mcp              Install MCP configurations only
  --settings         Install settings only

  --profile PROFILE  Permission profile: conservative, balanced, autonomous
                     (default: balanced)

  --template NAME    Install template to current directory
                     (minimal, standard, power-user)

  --symlink          Use symlinks instead of copying files
  --no-backup        Skip backup of existing configuration
  --dry-run          Show what would be installed without making changes

  -h, --help         Show this help message
  -v, --version      Show version

Examples:
  $(basename "$0")                    # Interactive mode
  $(basename "$0") --all              # Install everything
  $(basename "$0") --minimal          # Just settings
  $(basename "$0") --profile autonomous --all
  $(basename "$0") --template standard
EOF
}

# =============================================================================
# Argument Parsing
# =============================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            INSTALL_ALL=true
            INTERACTIVE=false
            shift
            ;;
        --minimal)
            INSTALL_MINIMAL=true
            INTERACTIVE=false
            shift
            ;;
        --skills)
            INSTALL_SKILLS=true
            INTERACTIVE=false
            shift
            ;;
        --hooks)
            INSTALL_HOOKS=true
            INTERACTIVE=false
            shift
            ;;
        --mcp)
            INSTALL_MCP=true
            INTERACTIVE=false
            shift
            ;;
        --settings)
            INSTALL_SETTINGS=true
            INTERACTIVE=false
            shift
            ;;
        --profile)
            PROFILE="$2"
            shift 2
            ;;
        --template)
            install_template "$2"
            exit 0
            ;;
        --symlink)
            USE_SYMLINK=true
            shift
            ;;
        --no-backup)
            NO_BACKUP=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--version)
            echo "claude-dotfiles v${VERSION}"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# =============================================================================
# Entry Point
# =============================================================================

if [ "$INTERACTIVE" = true ]; then
    run_interactive
fi

run_install
