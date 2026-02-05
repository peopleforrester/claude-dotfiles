#!/usr/bin/env bash
# ABOUTME: Interactive installer for claude-dotfiles configurations
# ABOUTME: Supports macOS, Linux with backup, symlink, and profile options
#
# ============================================================================
# SCRIPT OVERVIEW
# ============================================================================
# This is the main installation script for claude-dotfiles. It handles:
# - Interactive or command-line installation of Claude Code configurations
# - Support for macOS, Linux, and Windows (via Git Bash/WSL)
# - Automatic backup of existing configurations before installation
# - Multiple installation modes: full, minimal, or component-by-component
# - Three permission profiles: conservative, balanced, autonomous
# - Symlink or copy-based installation methods
#
# Usage examples:
#   ./install.sh                    # Interactive mode (prompts for choices)
#   ./install.sh --all              # Install everything non-interactively
#   ./install.sh --minimal          # Just settings.json
#   ./install.sh --template standard # Copy template to current project
#   ./install.sh --dry-run --all    # Preview what would be installed
#
# ============================================================================

# -----------------------------------------------------------------------------
# BASH STRICT MODE
# -----------------------------------------------------------------------------
# These flags make the script safer and easier to debug:
#   -e: Exit immediately if any command fails (non-zero exit status)
#   -u: Treat unset variables as an error (prevents typos in variable names)
#   -o pipefail: If any command in a pipeline fails, the whole pipeline fails
# Together, these prevent silent failures and catch bugs early.
# -----------------------------------------------------------------------------
set -euo pipefail

# =============================================================================
# CONFIGURATION VARIABLES
# =============================================================================
# These are the core variables that control the script's behavior.
# They're defined at the top for easy modification and visibility.
# =============================================================================

# VERSION: Semantic version of the install script, shown in --version output
VERSION="0.1.0"

# SCRIPT_DIR: Absolute path to the directory containing this script.
# This is computed dynamically so the script works regardless of where
# it's called from. The technique uses:
#   ${BASH_SOURCE[0]} - The path to this script file
#   dirname           - Extracts the directory portion of the path
#   cd ... && pwd     - Changes to that directory and prints absolute path
# This ensures we can reliably find templates, skills, etc. relative to the script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# CLAUDE_DIR: Where Claude Code stores its global configuration.
# This is ~/.claude by default, following Claude Code's conventions.
CLAUDE_DIR="${HOME}/.claude"

# BACKUP_DIR: Will be set to the backup location if a backup is created.
# Initially empty; populated by create_backup() if needed.
BACKUP_DIR=""

# -----------------------------------------------------------------------------
# TERMINAL COLORS
# -----------------------------------------------------------------------------
# ANSI escape codes for colorizing terminal output. These make the script's
# output more readable by using:
#   - RED for errors
#   - GREEN for success messages
#   - YELLOW for warnings
#   - BLUE for info/progress
#   - BOLD for emphasis
#   - NC (No Color) to reset formatting
#
# The `[ -t 1 ]` test checks if stdout (file descriptor 1) is a terminal.
# If we're not running in a terminal (e.g., output is piped to a file),
# we disable colors to avoid polluting the output with escape codes.
# -----------------------------------------------------------------------------
if [ -t 1 ]; then
    # We're in a terminal - enable colors
    RED='\033[0;31m'     # Errors, failures
    GREEN='\033[0;32m'   # Success messages
    YELLOW='\033[0;33m'  # Warnings
    BLUE='\033[0;34m'    # Info, progress
    BOLD='\033[1m'       # Emphasis
    NC='\033[0m'         # No Color - resets formatting
else
    # Not a terminal (piped output) - disable colors
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    BOLD=''
    NC=''
fi

# =============================================================================
# INSTALLATION OPTIONS (FLAGS)
# =============================================================================
# These boolean flags control what gets installed. They're set by command-line
# arguments or interactive prompts. Default is all false (nothing selected).
# =============================================================================

INSTALL_ALL=false       # --all: Install everything (settings, skills, hooks, MCP, rules, agents, commands)
INSTALL_MINIMAL=false   # --minimal: Install only settings.json
INSTALL_SKILLS=false    # --skills: Install skills library
INSTALL_HOOKS=false     # --hooks: Install hook configurations
INSTALL_MCP=false       # --mcp: Install MCP server configurations
INSTALL_SETTINGS=false  # --settings: Install settings.json
INSTALL_RULES=false     # --rules: Install rules (always-follow constraints)
INSTALL_AGENTS=false    # --agents: Install agents (specialized personas)
INSTALL_COMMANDS=false  # --commands: Install commands (slash commands)

# PROFILE: Which permission profile to use. Options are:
#   - conservative: Maximum safety, asks before most actions
#   - balanced (default): Auto-accepts edits, asks for bash commands
#   - autonomous: Minimal interruptions, for experienced users
PROFILE="balanced"

# USE_SYMLINK: If true, create symlinks instead of copying files.
# Symlinks mean changes to the source repo are immediately reflected.
# Useful for developers who want to modify and test configurations.
USE_SYMLINK=false

# NO_BACKUP: If true, skip creating a backup of existing ~/.claude directory.
# Not recommended unless you're sure you don't need the old config.
NO_BACKUP=false

# INTERACTIVE: If true, prompt the user for choices. Set to false when
# any command-line flag is provided (e.g., --all, --minimal).
INTERACTIVE=true

# DRY_RUN: If true, show what would be done without actually doing it.
# Useful for previewing changes before committing to them.
DRY_RUN=false

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================
# These functions provide reusable utilities for output formatting,
# OS detection, progress display, backup creation, and file operations.
# =============================================================================

# -----------------------------------------------------------------------------
# print_header()
# -----------------------------------------------------------------------------
# Displays the script's header/banner with version information.
# Called at the start of both interactive mode and installation.
# -----------------------------------------------------------------------------
print_header() {
    echo ""
    echo -e "${BLUE}${BOLD}claude-dotfiles${NC} v${VERSION}"
    echo -e "Production-ready configurations for Claude Code"
    echo ""
}

# -----------------------------------------------------------------------------
# print_success(message)
# -----------------------------------------------------------------------------
# Prints a success message with a green checkmark prefix.
# Used to confirm successful operations like file installs.
#
# Arguments:
#   $1 - The message to display
# -----------------------------------------------------------------------------
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# -----------------------------------------------------------------------------
# print_warning(message)
# -----------------------------------------------------------------------------
# Prints a warning message with a yellow exclamation prefix.
# Used for non-fatal issues like missing optional files.
#
# Arguments:
#   $1 - The warning message to display
# -----------------------------------------------------------------------------
print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

# -----------------------------------------------------------------------------
# print_error(message)
# -----------------------------------------------------------------------------
# Prints an error message with a red X prefix to stderr.
# Used for fatal errors that will cause the script to exit.
# Outputs to stderr (>&2) so errors can be separated from normal output.
#
# Arguments:
#   $1 - The error message to display
# -----------------------------------------------------------------------------
print_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

# -----------------------------------------------------------------------------
# print_info(message)
# -----------------------------------------------------------------------------
# Prints an informational message with a blue arrow prefix.
# Used for progress updates and helpful information.
#
# Arguments:
#   $1 - The info message to display
# -----------------------------------------------------------------------------
print_info() {
    echo -e "${BLUE}→${NC} $1"
}

# -----------------------------------------------------------------------------
# print_step(message)
# -----------------------------------------------------------------------------
# Prints a step header in bold, with leading newline for spacing.
# Used to mark major phases of the installation process.
#
# Arguments:
#   $1 - The step description to display
# -----------------------------------------------------------------------------
print_step() {
    echo -e "\n${BOLD}$1${NC}"
}

# -----------------------------------------------------------------------------
# detect_os()
# -----------------------------------------------------------------------------
# Detects the current operating system and outputs a normalized name.
# Uses `uname -s` which returns the kernel name:
#   - Darwin = macOS
#   - Linux = Linux
#   - CYGWIN/MINGW/MSYS = Windows (Git Bash, MSYS2, Cygwin)
#
# Returns (echoes):
#   "macos", "linux", "windows", or "unknown"
#
# Usage:
#   os=$(detect_os)
#   if [ "$os" = "macos" ]; then ...
# -----------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            # These are Windows environments with bash-like shells
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# -----------------------------------------------------------------------------
# show_progress(current, total, task)
# -----------------------------------------------------------------------------
# Displays a progress bar for long-running operations (like installing skills).
# Uses \r (carriage return) to overwrite the same line, creating animation.
#
# Arguments:
#   $1 (current) - Current item number (e.g., 5)
#   $2 (total)   - Total number of items (e.g., 14)
#   $3 (task)    - Description of current task (e.g., "Installing tdd-workflow")
#
# Output format: [#########...........] 45% Installing skill-name
#
# Note: The progress bar is 20 characters wide (each # = 5%)
# -----------------------------------------------------------------------------
show_progress() {
    local current=$1    # Current progress count
    local total=$2      # Total items to process
    local task=$3       # Current task description

    # Calculate percentage complete
    local percent=$((current * 100 / total))

    # Calculate how many # and . characters to show (20-char bar)
    local filled=$((percent / 5))      # Each # represents 5%
    local empty=$((20 - filled))       # Remaining spaces get dots

    # Print the progress bar, overwriting the previous line with \r
    # The printf format:
    #   %s - string (the # and . characters)
    #   %3d - 3-digit number right-aligned (percentage)
    printf "\r  [%s%s] %3d%% %s" \
        "$(printf '#%.0s' $(seq 1 $filled 2>/dev/null) 2>/dev/null || echo "")" \
        "$(printf '.%.0s' $(seq 1 $empty 2>/dev/null) 2>/dev/null || echo "")" \
        "$percent" \
        "$task"
}

# -----------------------------------------------------------------------------
# create_backup()
# -----------------------------------------------------------------------------
# Creates a timestamped backup of the existing ~/.claude directory.
# This preserves the user's previous configuration in case they need to
# restore it or reference their old settings.
#
# The backup is stored at: ~/.claude-backup-YYYYMMDD-HHMMSS
#
# Behavior:
#   - If NO_BACKUP is true, does nothing (returns immediately)
#   - If ~/.claude doesn't exist, does nothing (no backup needed)
#   - Creates a full recursive copy of the directory
#   - Sets BACKUP_DIR global variable for later reference
# -----------------------------------------------------------------------------
create_backup() {
    # Skip backup if user specified --no-backup flag
    if [ "$NO_BACKUP" = true ]; then
        return 0
    fi

    # Only backup if there's something to backup
    if [ -d "$CLAUDE_DIR" ]; then
        # Create a timestamped backup directory name
        # Format: ~/.claude-backup-20260203-143052
        BACKUP_DIR="${HOME}/.claude-backup-$(date +%Y%m%d-%H%M%S)"

        print_info "Backing up existing config to ${BACKUP_DIR}"

        # Copy entire directory recursively
        cp -r "$CLAUDE_DIR" "$BACKUP_DIR"

        print_success "Backup created"
    fi
}

# -----------------------------------------------------------------------------
# ensure_dir(directory)
# -----------------------------------------------------------------------------
# Creates a directory if it doesn't already exist.
# Uses mkdir -p which:
#   - Creates parent directories as needed
#   - Doesn't error if directory already exists
#
# Arguments:
#   $1 - Path to the directory to create
#
# Usage:
#   ensure_dir "${HOME}/.claude/skills"
# -----------------------------------------------------------------------------
ensure_dir() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
}

# -----------------------------------------------------------------------------
# copy_or_link(source, destination)
# -----------------------------------------------------------------------------
# Copies a file/directory OR creates a symlink, depending on USE_SYMLINK flag.
# This is the core file installation function used throughout the script.
#
# Arguments:
#   $1 (src)  - Source file or directory path
#   $2 (dest) - Destination path
#
# Behavior:
#   - If DRY_RUN is true: Just prints what would happen, doesn't do anything
#   - If USE_SYMLINK is true: Creates a symbolic link (ln -sf)
#   - Otherwise: Copies the file/directory (cp -r)
#
# The function also ensures the destination's parent directory exists.
#
# Why symlinks?
#   Symlinks are useful for developers who want changes to the source
#   repository to be immediately reflected in their ~/.claude config
#   without re-running the installer.
# -----------------------------------------------------------------------------
copy_or_link() {
    local src=$1
    local dest=$2

    # In dry-run mode, just show what would happen
    if [ "$DRY_RUN" = true ]; then
        echo "  Would copy: $src -> $dest"
        return 0
    fi

    # Make sure the destination directory exists
    ensure_dir "$(dirname "$dest")"

    if [ "$USE_SYMLINK" = true ]; then
        # Create symbolic link
        # -s: Create symbolic (not hard) link
        # -f: Force - remove existing file if it exists
        ln -sf "$src" "$dest"
    else
        # Copy file or directory recursively
        # -r: Recursive (for directories)
        cp -r "$src" "$dest"
    fi
}

# =============================================================================
# INSTALLATION FUNCTIONS
# =============================================================================
# These functions handle installing specific components of claude-dotfiles.
# Each is responsible for one type of configuration:
#   - install_settings: Permission profiles (settings.json)
#   - install_skills: The skills library (SKILL.md files)
#   - install_hooks: Automation hooks (formatters, validators, notifications)
#   - install_mcp: MCP server configurations for Claude Desktop
#   - install_template: Copy a CLAUDE.md template to current directory
# =============================================================================

# -----------------------------------------------------------------------------
# install_settings()
# -----------------------------------------------------------------------------
# Installs the settings.json file with the selected permission profile.
#
# The profile is determined by the PROFILE variable, which can be:
#   - conservative: settings/permissions/conservative.json
#   - balanced: settings/permissions/balanced.json
#   - autonomous: settings/permissions/autonomous.json
#
# Also creates a settings.local.json template for personal overrides.
# This file is meant to be gitignored and contain user-specific settings.
# -----------------------------------------------------------------------------
install_settings() {
    print_step "Installing settings (${PROFILE} profile)..."

    # Build paths to source and destination
    local settings_src="${SCRIPT_DIR}/settings/permissions/${PROFILE}.json"
    local settings_dest="${CLAUDE_DIR}/settings.json"

    # Fall back to balanced profile if requested profile doesn't exist
    if [ ! -f "$settings_src" ]; then
        print_warning "Profile '${PROFILE}' not found, using balanced"
        settings_src="${SCRIPT_DIR}/settings/permissions/balanced.json"
    fi

    # Copy or symlink the settings file
    if [ -f "$settings_src" ]; then
        copy_or_link "$settings_src" "$settings_dest"
        print_success "Installed settings.json (${PROFILE})"
    else
        print_warning "Settings file not found: ${settings_src}"
    fi

    # Create a local settings template for user customization
    # This file is for personal overrides and should be gitignored
    local local_template="${CLAUDE_DIR}/settings.local.json"
    if [ ! -f "$local_template" ] && [ "$DRY_RUN" = false ]; then
        # Create a minimal JSON file with helpful comments
        # Using the // KEY: value pattern for JSON "comments"
        echo '{
  "// NOTE": "Personal overrides - this file is gitignored",
  "// ADD": "Your custom settings below"
}' > "$local_template"
        print_success "Created settings.local.json template"
    fi
}

# -----------------------------------------------------------------------------
# install_skills()
# -----------------------------------------------------------------------------
# Installs the skills library to ~/.claude/skills/
#
# Skills are directories containing SKILL.md files that provide Claude with
# specialized capabilities. The installer:
#   1. Finds all skill directories (those containing SKILL.md)
#   2. Copies each skill directory to ~/.claude/skills/[skill-name]/
#   3. Shows progress as it installs each skill
#
# Directory structure expected:
#   skills/
#     development/
#       tdd-workflow/
#         SKILL.md        <- This is what we look for
#       code-reviewer/
#         SKILL.md
#     git/
#       commit-helper/
#         SKILL.md
# -----------------------------------------------------------------------------
install_skills() {
    print_step "Installing skills..."

    local skills_src="${SCRIPT_DIR}/skills"
    local skills_dest="${CLAUDE_DIR}/skills"

    # Check if skills directory exists in the source
    if [ ! -d "$skills_src" ]; then
        print_warning "Skills directory not found: ${skills_src}"
        return 0  # Not a fatal error - skills are optional
    fi

    # Ensure destination directory exists
    ensure_dir "$skills_dest"

    # Count total skills for progress display
    local skill_count=0
    local total_skills
    # Find all SKILL.md files, count them, remove whitespace from wc output
    total_skills=$(find "$skills_src" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')

    if [ "$total_skills" -eq 0 ]; then
        print_warning "No skills found to install"
        return 0
    fi

    # Find and install each skill directory
    # -mindepth 2 -maxdepth 2: Only look 2 levels deep (category/skill-name)
    find "$skills_src" -type d -mindepth 2 -maxdepth 2 | while read -r skill_dir; do
        # Only process directories that contain a SKILL.md file
        if [ -f "${skill_dir}/SKILL.md" ]; then
            # Extract just the skill name (last part of path)
            local skill_name
            skill_name=$(basename "$skill_dir")

            # Copy the entire skill directory
            copy_or_link "$skill_dir" "${skills_dest}/${skill_name}"

            # Update progress
            skill_count=$((skill_count + 1))
            show_progress "$skill_count" "$total_skills" "Installing ${skill_name}"
        fi
    done

    # Newline after progress bar
    echo ""
    print_success "Installed ${total_skills} skills"
}

# -----------------------------------------------------------------------------
# install_hooks()
# -----------------------------------------------------------------------------
# Installs hook configurations to ~/.claude/hooks/
#
# Hooks are shell scripts or JSON configs that run in response to Claude's
# actions. The installer handles:
#   1. Formatters: Auto-format code after Claude edits (prettier, black, etc.)
#   2. Notifications: Platform-specific notifications when tasks complete
#   3. Validators: Run linters or type-checkers on changed files
#
# Platform-specific behavior:
#   - macOS gets macos-notification.sh
#   - Linux gets linux-notify-send.sh
#   - Windows notifications are handled by install.ps1 instead
# -----------------------------------------------------------------------------
install_hooks() {
    print_step "Installing hooks..."

    # Detect OS for platform-specific hook installation
    local os
    os=$(detect_os)

    local hooks_src="${SCRIPT_DIR}/hooks"
    local hooks_dest="${CLAUDE_DIR}/hooks"

    if [ ! -d "$hooks_src" ]; then
        print_warning "Hooks directory not found: ${hooks_src}"
        return 0
    fi

    ensure_dir "$hooks_dest"

    # -------------------------------------------------------------------------
    # FORMATTERS
    # -------------------------------------------------------------------------
    # These are JSON files that configure auto-formatting hooks.
    # Example: prettier-on-save.json runs prettier after Write/Edit operations.
    if [ -d "${hooks_src}/formatters" ]; then
        for hook_file in "${hooks_src}/formatters"/*.json; do
            # Check file exists (glob might return literal string if no matches)
            if [ -f "$hook_file" ]; then
                copy_or_link "$hook_file" "${hooks_dest}/$(basename "$hook_file")"
            fi
        done
        print_success "Installed formatter hooks"
    fi

    # -------------------------------------------------------------------------
    # NOTIFICATIONS (Platform-Specific)
    # -------------------------------------------------------------------------
    # Install the appropriate notification script for the current OS.
    # The script is renamed to "notify.sh" for consistent hook configuration.
    if [ -d "${hooks_src}/notifications" ]; then
        case "$os" in
            macos)
                # macOS: Uses osascript for native notifications
                if [ -f "${hooks_src}/notifications/macos-notification.sh" ]; then
                    copy_or_link "${hooks_src}/notifications/macos-notification.sh" "${hooks_dest}/notify.sh"
                    # Make executable (skip in dry-run mode)
                    [ "$DRY_RUN" = false ] && chmod +x "${hooks_dest}/notify.sh"
                    print_success "Installed macOS notification hook"
                fi
                ;;
            linux)
                # Linux: Uses notify-send (part of libnotify)
                if [ -f "${hooks_src}/notifications/linux-notify-send.sh" ]; then
                    copy_or_link "${hooks_src}/notifications/linux-notify-send.sh" "${hooks_dest}/notify.sh"
                    [ "$DRY_RUN" = false ] && chmod +x "${hooks_dest}/notify.sh"
                    print_success "Installed Linux notification hook"
                fi
                ;;
            # Note: Windows uses PowerShell for notifications (install.ps1 handles this)
        esac
    fi

    # -------------------------------------------------------------------------
    # VALIDATORS
    # -------------------------------------------------------------------------
    # These are scripts that validate code, run linters, etc.
    # They can be shell scripts (.sh) or Python scripts (.py).
    if [ -d "${hooks_src}/validators" ]; then
        for validator in "${hooks_src}/validators"/*; do
            if [ -f "$validator" ]; then
                copy_or_link "$validator" "${hooks_dest}/$(basename "$validator")"
                # Preserve executability from source file
                [ "$DRY_RUN" = false ] && [ -x "$validator" ] && chmod +x "${hooks_dest}/$(basename "$validator")"
            fi
        done
        print_success "Installed validator hooks"
    fi
}

# -----------------------------------------------------------------------------
# install_rules()
# -----------------------------------------------------------------------------
# Installs rule files to ~/.claude/rules/
#
# Rules are declarative constraint files that Claude Code loads automatically.
# They define always-follow behaviors like security practices, coding style,
# testing requirements, and git workflow conventions.
# -----------------------------------------------------------------------------
install_rules() {
    print_step "Installing rules..."

    local rules_src="${SCRIPT_DIR}/rules"
    local rules_dest="${CLAUDE_DIR}/rules"

    if [ ! -d "$rules_src" ]; then
        print_warning "Rules directory not found: ${rules_src}"
        return 0
    fi

    ensure_dir "$rules_dest"

    local rule_count=0
    for rule_file in "${rules_src}"/*.md; do
        if [ -f "$rule_file" ]; then
            copy_or_link "$rule_file" "${rules_dest}/$(basename "$rule_file")"
            rule_count=$((rule_count + 1))
        fi
    done

    print_success "Installed ${rule_count} rules"
}

# -----------------------------------------------------------------------------
# install_agents()
# -----------------------------------------------------------------------------
# Installs agent definitions to ~/.claude/agents/
#
# Agents are specialized personas with YAML frontmatter that define expertise,
# tools, and recommended models. They can be invoked via slash commands.
# -----------------------------------------------------------------------------
install_agents() {
    print_step "Installing agents..."

    local agents_src="${SCRIPT_DIR}/agents"
    local agents_dest="${CLAUDE_DIR}/agents"

    if [ ! -d "$agents_src" ]; then
        print_warning "Agents directory not found: ${agents_src}"
        return 0
    fi

    ensure_dir "$agents_dest"

    local agent_count=0
    for agent_file in "${agents_src}"/*.md; do
        if [ -f "$agent_file" ]; then
            copy_or_link "$agent_file" "${agents_dest}/$(basename "$agent_file")"
            agent_count=$((agent_count + 1))
        fi
    done

    print_success "Installed ${agent_count} agents"
}

# -----------------------------------------------------------------------------
# install_commands()
# -----------------------------------------------------------------------------
# Installs command files to ~/.claude/commands/
#
# Commands define slash commands that users can invoke in Claude Code.
# They are organized in subdirectories by category (workflow, quality, etc.).
# -----------------------------------------------------------------------------
install_commands() {
    print_step "Installing commands..."

    local commands_src="${SCRIPT_DIR}/commands"
    local commands_dest="${CLAUDE_DIR}/commands"

    if [ ! -d "$commands_src" ]; then
        print_warning "Commands directory not found: ${commands_src}"
        return 0
    fi

    ensure_dir "$commands_dest"

    local cmd_count=0
    # Copy entire subdirectory structure
    find "$commands_src" -name "*.md" | while read -r cmd_file; do
        # Preserve subdirectory structure (workflow/, quality/, etc.)
        local rel_path="${cmd_file#$commands_src/}"
        local dest_path="${commands_dest}/${rel_path}"
        ensure_dir "$(dirname "$dest_path")"
        copy_or_link "$cmd_file" "$dest_path"
        cmd_count=$((cmd_count + 1))
    done

    # Count files for display
    local total_cmds
    total_cmds=$(find "$commands_src" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    print_success "Installed ${total_cmds} commands"
}

# -----------------------------------------------------------------------------
# install_mcp()
# -----------------------------------------------------------------------------
# Installs MCP (Model Context Protocol) server configurations.
#
# MCP servers give Claude Desktop access to external tools and data sources
# like GitHub, Slack, databases, etc. The configurations are JSON files
# that specify how to launch and configure each server.
#
# Platform-specific config locations:
#   - macOS: ~/Library/Application Support/Claude/
#   - Linux: ~/.config/Claude/
#   - Windows: %APPDATA%/Claude/
#
# Note: Claude Desktop must be restarted after installing MCP configs.
# -----------------------------------------------------------------------------
install_mcp() {
    print_step "Installing MCP configurations..."

    local os
    os=$(detect_os)
    local mcp_src="${SCRIPT_DIR}/mcp"
    local mcp_dest

    # Determine Claude Desktop's config location based on OS
    case "$os" in
        macos)
            # macOS uses ~/Library/Application Support/ for app data
            mcp_dest="${HOME}/Library/Application Support/Claude"
            ;;
        linux)
            # Linux follows XDG spec: ~/.config/ for configuration
            mcp_dest="${HOME}/.config/Claude"
            ;;
        windows)
            # Windows uses %APPDATA% (usually C:\Users\Name\AppData\Roaming)
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

    # Copy individual server configuration files
    if [ -d "${mcp_src}/servers" ]; then
        ensure_dir "${mcp_dest}/mcp-servers"
        for server_config in "${mcp_src}/servers"/*.json; do
            if [ -f "$server_config" ]; then
                copy_or_link "$server_config" "${mcp_dest}/mcp-servers/$(basename "$server_config")"
            fi
        done
        print_success "Installed MCP server configurations"
    fi

    # Remind user to restart Claude Desktop
    print_info "Note: Restart Claude Desktop to load MCP servers"
}

# -----------------------------------------------------------------------------
# install_template(template_name)
# -----------------------------------------------------------------------------
# Installs a CLAUDE.md template to the CURRENT working directory.
# Unlike other install functions, this doesn't install to ~/.claude/
# but to wherever the user ran the script from.
#
# Arguments:
#   $1 (template_name) - Name of template: minimal, standard, or power-user
#
# This is useful for quickly setting up a new project with Claude Code.
# The function will prompt before overwriting existing files.
# -----------------------------------------------------------------------------
install_template() {
    local template_name=$1
    print_step "Installing ${template_name} template to current directory..."

    local template_src="${SCRIPT_DIR}/templates/${template_name}"

    # Verify template exists
    if [ ! -d "$template_src" ]; then
        print_error "Template not found: ${template_name}"
        return 1
    fi

    # -------------------------------------------------------------------------
    # Install CLAUDE.md
    # -------------------------------------------------------------------------
    # This is the main project instruction file for Claude Code.
    if [ -f "${template_src}/CLAUDE.md" ]; then
        if [ -f "./CLAUDE.md" ]; then
            # File exists - ask before overwriting
            print_warning "CLAUDE.md already exists in current directory"
            read -rp "Overwrite? [y/N] " response
            # Only overwrite if user explicitly says yes
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                print_info "Skipping CLAUDE.md"
            else
                cp "${template_src}/CLAUDE.md" "./CLAUDE.md"
                print_success "Installed CLAUDE.md"
            fi
        else
            # No existing file - just copy
            cp "${template_src}/CLAUDE.md" "./CLAUDE.md"
            print_success "Installed CLAUDE.md"
        fi
    fi

    # -------------------------------------------------------------------------
    # Install .claude directory
    # -------------------------------------------------------------------------
    # Some templates include project-specific settings in .claude/
    if [ -d "${template_src}/.claude" ]; then
        if [ -d "./.claude" ]; then
            # Directory exists - ask to merge
            print_warning ".claude directory already exists"
            read -rp "Merge? [y/N] " response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                # Merge: copy contents into existing directory
                cp -r "${template_src}/.claude"/* "./.claude/"
                print_success "Merged .claude directory"
            fi
        else
            # No existing directory - copy the whole thing
            cp -r "${template_src}/.claude" "./.claude"
            print_success "Installed .claude directory"
        fi
    fi
}

# =============================================================================
# INTERACTIVE MODE
# =============================================================================
# When the script is run without arguments, it enters interactive mode.
# This guides users through installation choices with prompts.
# =============================================================================

# -----------------------------------------------------------------------------
# run_interactive()
# -----------------------------------------------------------------------------
# Presents an interactive menu for users to choose installation options.
# Sets the appropriate flags based on user input, then installation proceeds.
#
# Menu options:
#   1) Everything - Sets INSTALL_ALL=true
#   2) Minimal - Sets INSTALL_MINIMAL=true (settings only)
#   3) Custom - Prompts for each component individually
#   4) Template only - Copies a template to current directory and exits
# -----------------------------------------------------------------------------
run_interactive() {
    print_header

    # Display main menu
    echo "What would you like to install?"
    echo ""
    echo "  1) Everything (recommended for new users)"
    echo "  2) Minimal (CLAUDE.md template + settings only)"
    echo "  3) Custom (choose components)"
    echo "  4) Template only (copy to current project)"
    echo ""

    # Read user choice
    # -r: Don't treat backslashes specially
    # -p: Prompt string would go here, but we printed it above
    read -rp "Choice [1-4]: " choice

    case $choice in
        1)
            # Install everything
            INSTALL_ALL=true
            ;;
        2)
            # Minimal installation
            INSTALL_MINIMAL=true
            ;;
        3)
            # Custom: ask about each component
            echo ""

            # Settings - default yes (just press enter)
            read -rp "Install settings? [Y/n] " yn
            [[ ! "$yn" =~ ^[Nn]$ ]] && INSTALL_SETTINGS=true

            # Skills - default yes
            read -rp "Install skills? [Y/n] " yn
            [[ ! "$yn" =~ ^[Nn]$ ]] && INSTALL_SKILLS=true

            # Hooks - default yes
            read -rp "Install hooks? [Y/n] " yn
            [[ ! "$yn" =~ ^[Nn]$ ]] && INSTALL_HOOKS=true

            # Rules - default yes
            read -rp "Install rules? [Y/n] " yn
            [[ ! "$yn" =~ ^[Nn]$ ]] && INSTALL_RULES=true

            # Agents - default yes
            read -rp "Install agents? [Y/n] " yn
            [[ ! "$yn" =~ ^[Nn]$ ]] && INSTALL_AGENTS=true

            # Commands - default yes
            read -rp "Install commands? [Y/n] " yn
            [[ ! "$yn" =~ ^[Nn]$ ]] && INSTALL_COMMANDS=true

            # MCP - default no (requires more setup)
            read -rp "Install MCP configs? [y/N] " yn
            [[ "$yn" =~ ^[Yy]$ ]] && INSTALL_MCP=true
            ;;
        4)
            # Template-only mode: show template choices
            echo ""
            echo "Available templates:"
            echo "  1) minimal    - Bare essentials (~30 lines)"
            echo "  2) standard   - Recommended baseline (~80 lines)"
            echo "  3) power-user - Full featured (~100 lines)"
            echo ""
            read -rp "Template [1-3]: " template_choice

            # Install selected template and exit
            case $template_choice in
                1) install_template "minimal" ;;
                2) install_template "standard" ;;
                3) install_template "power-user" ;;
                *) print_error "Invalid choice"; exit 1 ;;
            esac
            exit 0  # Exit after template installation
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac

    # -------------------------------------------------------------------------
    # Permission Profile Selection
    # -------------------------------------------------------------------------
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
        *) PROFILE="balanced" ;;  # Default for 2 or any other input
    esac

    # -------------------------------------------------------------------------
    # Symlink Option
    # -------------------------------------------------------------------------
    echo ""
    read -rp "Use symlinks instead of copying? [y/N] " yn
    [[ "$yn" =~ ^[Yy]$ ]] && USE_SYMLINK=true
}

# =============================================================================
# MAIN INSTALLATION LOGIC
# =============================================================================
# This is the core installation routine that runs after options are set
# (either via command-line arguments or interactive prompts).
# =============================================================================

# -----------------------------------------------------------------------------
# run_install()
# -----------------------------------------------------------------------------
# Performs the actual installation based on the flags that have been set.
# This function is called after all options are configured.
#
# Steps:
#   1. Print header with detected configuration
#   2. Create backup of existing configuration
#   3. Ensure ~/.claude directory exists
#   4. Install selected components
#   5. Print completion message with next steps
# -----------------------------------------------------------------------------
run_install() {
    print_header

    # Detect and display current configuration
    local os
    os=$(detect_os)
    print_info "Detected OS: ${os}"
    print_info "Profile: ${PROFILE}"
    print_info "Install method: $([ "$USE_SYMLINK" = true ] && echo "symlink" || echo "copy")"

    # Create backup before making any changes
    create_backup

    # Ensure the Claude configuration directory exists
    ensure_dir "$CLAUDE_DIR"

    # -------------------------------------------------------------------------
    # Install Components Based on Flags
    # -------------------------------------------------------------------------
    if [ "$INSTALL_ALL" = true ]; then
        # Full installation: everything
        install_settings
        install_skills
        install_hooks
        install_rules
        install_agents
        install_commands
        install_mcp
    elif [ "$INSTALL_MINIMAL" = true ]; then
        # Minimal: just settings
        install_settings
        print_info "Run './install.sh --template standard' to install CLAUDE.md template"
    else
        # Custom: only what was selected
        [ "$INSTALL_SETTINGS" = true ] && install_settings
        [ "$INSTALL_SKILLS" = true ] && install_skills
        [ "$INSTALL_HOOKS" = true ] && install_hooks
        [ "$INSTALL_RULES" = true ] && install_rules
        [ "$INSTALL_AGENTS" = true ] && install_agents
        [ "$INSTALL_COMMANDS" = true ] && install_commands
        [ "$INSTALL_MCP" = true ] && install_mcp
    fi

    # -------------------------------------------------------------------------
    # Completion Message
    # -------------------------------------------------------------------------
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

    # Remind about backup location if one was created
    if [ -n "$BACKUP_DIR" ]; then
        echo "Your previous config was backed up to: ${BACKUP_DIR}"
        echo ""
    fi
}

# =============================================================================
# USAGE / HELP
# =============================================================================

# -----------------------------------------------------------------------------
# show_usage()
# -----------------------------------------------------------------------------
# Displays help text showing all available command-line options.
# Uses a heredoc (<<EOF) for cleaner multi-line string formatting.
# Called when -h or --help is passed.
# -----------------------------------------------------------------------------
show_usage() {
    # Heredoc: Everything between <<EOF and EOF is printed literally
    # $(basename "$0") inserts the script name (install.sh)
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --all              Install everything (settings, skills, hooks, rules, agents, commands, MCP)
  --minimal          Install settings only
  --skills           Install skills only
  --hooks            Install hooks only
  --rules            Install rules only (always-follow constraints)
  --agents           Install agents only (specialized personas)
  --commands         Install commands only (slash commands)
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
# ARGUMENT PARSING
# =============================================================================
# This section processes command-line arguments using a while loop.
# Each argument sets appropriate flags or performs immediate actions.
# =============================================================================

# Process arguments one at a time
# $# is the number of remaining arguments
# shift removes the first argument, moving subsequent ones down
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            INSTALL_ALL=true
            INTERACTIVE=false    # Disable interactive mode when using CLI flags
            shift               # Move to next argument
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
        --rules)
            INSTALL_RULES=true
            INTERACTIVE=false
            shift
            ;;
        --agents)
            INSTALL_AGENTS=true
            INTERACTIVE=false
            shift
            ;;
        --commands)
            INSTALL_COMMANDS=true
            INTERACTIVE=false
            shift
            ;;
        --profile)
            # This option takes an argument, so we use $2
            PROFILE="$2"
            shift 2             # Skip both --profile and its value
            ;;
        --template)
            # Immediately install template and exit
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
            # Unknown option - show error and usage
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# =============================================================================
# ENTRY POINT
# =============================================================================
# This is where execution actually begins after all function definitions
# and argument parsing is complete.
# =============================================================================

# If no CLI flags were provided, run interactive mode first
if [ "$INTERACTIVE" = true ]; then
    run_interactive
fi

# Perform the installation with configured options
run_install
