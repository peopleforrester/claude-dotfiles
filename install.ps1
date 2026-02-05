# ABOUTME: Interactive installer for claude-dotfiles configurations (Windows)
# ABOUTME: PowerShell equivalent of install.sh for Windows users

<#
# =============================================================================
# Claude-Dotfiles Interactive Installer for Windows
# =============================================================================

.SYNOPSIS
    Interactive installer for claude-dotfiles configurations (Windows)

.DESCRIPTION
    This PowerShell script is the Windows equivalent of install.sh. It provides
    an interactive installer for setting up Claude Code configurations,
    including settings, skills, hooks, and MCP server configurations.

    WHAT GETS INSTALLED:
    - settings.json: Permission profiles and preferences
    - skills/: SKILL.md files for custom Claude behaviors
    - hooks/: Automation scripts (formatters, validators, notifications)
    - MCP servers/: Model Context Protocol server configurations

    INSTALLATION MODES:
    - Interactive: Guided walkthrough with prompts
    - All (-All): Install everything at once
    - Minimal (-Minimal): Settings only
    - Custom: Install individual components with switches

.PARAMETER All
    Install everything: settings, skills, hooks, and MCP configurations.
    Best for new users who want a complete setup.

.PARAMETER Minimal
    Install settings only. Use this for a lightweight setup.

.PARAMETER Skills
    Install only the skills collection.

.PARAMETER Hooks
    Install only the hooks collection.

.PARAMETER MCP
    Install only the MCP server configurations.

.PARAMETER Settings
    Install only the settings.json file.

.PARAMETER Profile
    Permission profile to use. Determines how much autonomy Claude has.
    - conservative: Ask before most actions (safest)
    - balanced: Auto-accept edits, ask for bash commands (recommended)
    - autonomous: Minimal interruptions (for experienced users)
    Default: balanced

.PARAMETER Template
    Install a CLAUDE.md template to the current directory.
    Options: minimal, standard, power-user

.PARAMETER Symlink
    Use symbolic links instead of copying files.
    Note: Requires admin rights or Developer Mode on Windows.

.PARAMETER NoBackup
    Skip backup of existing configuration.
    By default, existing ~/.claude is backed up before installation.

.PARAMETER DryRun
    Preview what would be installed without making changes.
    Use this to understand what the installer will do.

.EXAMPLE
    .\install.ps1

    Run in interactive mode with guided prompts.

.EXAMPLE
    .\install.ps1 -All

    Install everything with default settings.

.EXAMPLE
    .\install.ps1 -All -Profile autonomous

    Install everything with autonomous permission profile.

.EXAMPLE
    .\install.ps1 -Template standard

    Install the standard CLAUDE.md template to current directory.

.EXAMPLE
    .\install.ps1 -DryRun -All

    Preview what -All would install without making changes.

.NOTES
    REQUIREMENTS:
    - PowerShell 5.1 or later (included in Windows 10)
    - Works with PowerShell 7+ (PowerShell Core)

    FILE LOCATIONS:
    - Claude config: %USERPROFILE%\.claude\
    - MCP config: %APPDATA%\Claude\

    DEVELOPER MODE (for -Symlink):
    To use symlinks without admin rights, enable Developer Mode:
    Settings > Update & Security > For Developers > Developer Mode
#>

# =============================================================================
# POWERSHELL VERSION REQUIREMENT
# =============================================================================
# #Requires specifies minimum PowerShell version.
# Version 5.1 ships with Windows 10 and includes all features we need.
# =============================================================================
#Requires -Version 5.1

# =============================================================================
# CMDLETBINDING AND PARAMETER DEFINITIONS
# =============================================================================
# [CmdletBinding()]: Enables advanced function features like -Verbose.
#
# param(): Defines all script parameters with types, defaults, and validation.
#
# SWITCH PARAMETERS:
# [switch]: Boolean flag that's $false by default, $true when specified.
# Example: -All sets $All to $true
#
# VALIDATESET:
# Restricts parameter to specific allowed values.
# PowerShell provides tab completion for these values.
# =============================================================================
[CmdletBinding()]
param(
    # Install everything (settings, skills, hooks, MCP)
    [switch]$All,

    # Minimal installation (settings only)
    [switch]$Minimal,

    # Install skills only
    [switch]$Skills,

    # Install hooks only
    [switch]$Hooks,

    # Install MCP configurations only
    [switch]$MCP,

    # Install settings only
    [switch]$Settings,

    # Install rules only (always-follow constraints)
    [switch]$Rules,

    # Install agents only (specialized personas)
    [switch]$Agents,

    # Install commands only (slash commands)
    [switch]$Commands,

    # Permission profile selection with validation
    [ValidateSet("conservative", "balanced", "autonomous")]
    [string]$Profile = "balanced",

    # Template to install to current directory
    [string]$Template,

    # Use symlinks instead of copying
    [switch]$Symlink,

    # Skip backup of existing configuration
    [switch]$NoBackup,

    # Preview mode - show what would happen
    [switch]$DryRun,

    # Show help
    [switch]$Help,

    # Show version
    [switch]$Version
)

# =============================================================================
# SCRIPT-SCOPED CONFIGURATION VARIABLES
# =============================================================================
# $Script: prefix creates variables scoped to the script.
# These are accessible from all functions but not from external scripts.
#
# Using script scope instead of global scope:
# - Prevents pollution of the user's PowerShell session
# - Allows consistent access across functions
# - Variables are cleaned up when script exits
# =============================================================================

# Version number following Semantic Versioning (MAJOR.MINOR.PATCH)
$Script:VERSION = "0.1.0"

# Directory where this script is located
# $PSScriptRoot is an automatic variable containing the script's directory
$Script:SCRIPT_DIR = $PSScriptRoot

# Target directory for Claude configuration
# Join-Path creates platform-appropriate paths
$Script:CLAUDE_DIR = Join-Path $env:USERPROFILE ".claude"

# Backup directory path (set during backup if needed)
$Script:BACKUP_DIR = ""

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================
# These functions provide consistent, formatted output throughout the script.
# Using functions instead of raw Write-Host provides:
# - Consistent styling across all messages
# - Single point of change for formatting
# - Semantic clarity in the code
# =============================================================================

# =============================================================================
# WRITE-HEADER
# =============================================================================
# Displays the script banner with name and version.
# Uses colored output to make the header stand out.
# =============================================================================
function Write-Header {
    Write-Host ""
    # -NoNewline: Continue on same line for next Write-Host
    Write-Host "claude-dotfiles" -ForegroundColor Blue -NoNewline
    Write-Host " v$Script:VERSION"
    Write-Host "Production-ready configurations for Claude Code"
    Write-Host ""
}

# =============================================================================
# STATUS MESSAGE FUNCTIONS
# =============================================================================
# Each function displays a message with a colored prefix indicating status.
#
# Write-Host parameters:
# -ForegroundColor: Text color (Green, Yellow, Red, Cyan, White)
# -NoNewline: Don't add newline after text
#
# Note: We define our own Write-Success/Write-Warning/Write-Error because:
# - They provide consistent formatting
# - Built-in Write-Warning/Write-Error have different output streams
# =============================================================================

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[!] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-Error {
    param([string]$Message)
    Write-Host "[X] " -ForegroundColor Red -NoNewline
    Write-Host $Message
}

function Write-Info {
    param([string]$Message)
    Write-Host "[>] " -ForegroundColor Cyan -NoNewline
    Write-Host $Message
}

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host $Message -ForegroundColor White
}

# =============================================================================
# SHOW-PROGRESS
# =============================================================================
# Displays a progress bar for multi-step operations.
# Uses PowerShell's built-in Write-Progress cmdlet.
#
# This provides visual feedback during installation of multiple skills/hooks.
# =============================================================================
function Show-Progress {
    param(
        [int]$Current,   # Current item number
        [int]$Total,     # Total number of items
        [string]$Task    # Description of current task
    )
    # Calculate percentage complete
    $percent = [math]::Round(($Current / $Total) * 100)
    # Display progress bar
    Write-Progress -Activity "Installing" -Status "$Task" -PercentComplete $percent
}

# =============================================================================
# NEW-BACKUP
# =============================================================================
# Creates a timestamped backup of existing Claude configuration.
# This is a safety measure - users can restore if something goes wrong.
# =============================================================================
function New-Backup {
    # Skip if user specified -NoBackup
    if ($NoBackup) {
        return
    }

    # Only backup if .claude directory exists
    if (Test-Path $Script:CLAUDE_DIR) {
        # Create timestamp for unique backup name
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $Script:BACKUP_DIR = Join-Path $env:USERPROFILE ".claude-backup-$timestamp"

        Write-Info "Backing up existing config to $Script:BACKUP_DIR"

        # Copy-Item -Recurse: Copy directory and all contents
        Copy-Item -Path $Script:CLAUDE_DIR -Destination $Script:BACKUP_DIR -Recurse

        Write-Success "Backup created"
    }
}

# =============================================================================
# CONFIRM-DIRECTORY
# =============================================================================
# Ensures a directory exists, creating it if necessary.
# Wraps New-Item with error suppression for cleaner code.
#
# -Force: Don't error if directory already exists
# | Out-Null: Suppress output (we don't need it)
# =============================================================================
function Confirm-Directory {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

# =============================================================================
# COPY-ORLINK
# =============================================================================
# Copies or symlinks a file/directory based on user preference.
# Handles the complexity of symlinks on Windows.
#
# WINDOWS SYMLINK NOTES:
# Windows treats symlinks differently than Unix:
# - Requires admin rights OR Developer Mode enabled
# - Uses New-Item -ItemType SymbolicLink
# - May fail on older Windows versions
# =============================================================================
function Copy-OrLink {
    param(
        [string]$Source,       # Source path
        [string]$Destination   # Destination path
    )

    # Dry run mode - just show what would happen
    if ($DryRun) {
        Write-Host "  Would copy: $Source -> $Destination"
        return
    }

    # Ensure destination directory exists
    $destDir = Split-Path -Parent $Destination
    Confirm-Directory -Path $destDir

    if ($Symlink) {
        # Attempt to create symbolic link
        try {
            # New-Item -ItemType SymbolicLink: Create a symbolic link
            # -Target: What the symlink points to
            # -Force: Overwrite if exists
            New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -Force | Out-Null
        }
        catch {
            # Symlink failed - likely permission issue
            Write-Warning "Symlink failed (may need admin), falling back to copy"
            Copy-Item -Path $Source -Destination $Destination -Recurse -Force
        }
    }
    else {
        # Simple copy operation
        # -Recurse: Copy directories and contents
        # -Force: Overwrite existing files
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
    }
}

# =============================================================================
# INSTALLATION FUNCTIONS
# =============================================================================
# Each function installs a specific component of claude-dotfiles.
# They follow a consistent pattern:
# 1. Display step message
# 2. Locate source files
# 3. Copy/link to destination
# 4. Report success
# =============================================================================

# =============================================================================
# INSTALL-SETTINGS
# =============================================================================
# Installs the settings.json file with the selected permission profile.
# Also creates a settings.local.json template for user customization.
# =============================================================================
function Install-Settings {
    Write-Step "Installing settings ($Profile profile)..."

    # Build paths to source and destination
    $settingsSrc = Join-Path $Script:SCRIPT_DIR "settings\permissions\$Profile.json"
    $settingsDest = Join-Path $Script:CLAUDE_DIR "settings.json"

    # Handle missing profile gracefully
    if (-not (Test-Path $settingsSrc)) {
        Write-Warning "Profile '$Profile' not found, using balanced"
        $settingsSrc = Join-Path $Script:SCRIPT_DIR "settings\permissions\balanced.json"
    }

    # Copy the settings file
    if (Test-Path $settingsSrc) {
        Copy-OrLink -Source $settingsSrc -Destination $settingsDest
        Write-Success "Installed settings.json ($Profile)"
    }
    else {
        Write-Warning "Settings file not found: $settingsSrc"
    }

    # Create local settings template for user overrides
    # This file is intended for personal customizations and should be gitignored
    $localTemplate = Join-Path $Script:CLAUDE_DIR "settings.local.json"
    if (-not (Test-Path $localTemplate) -and -not $DryRun) {
        # Here-string for multi-line JSON content
        @'
{
  "// NOTE": "Personal overrides - this file is gitignored",
  "// ADD": "Your custom settings below"
}
'@ | Out-File -FilePath $localTemplate -Encoding UTF8
        Write-Success "Created settings.local.json template"
    }
}

# =============================================================================
# INSTALL-SKILLS
# =============================================================================
# Installs all SKILL.md files from the skills directory.
# Each skill is a subdirectory containing a SKILL.md file.
# =============================================================================
function Install-Skills {
    Write-Step "Installing skills..."

    $skillsSrc = Join-Path $Script:SCRIPT_DIR "skills"
    $skillsDest = Join-Path $Script:CLAUDE_DIR "skills"

    # Verify source exists
    if (-not (Test-Path $skillsSrc)) {
        Write-Warning "Skills directory not found: $skillsSrc"
        return
    }

    Confirm-Directory -Path $skillsDest

    # Find all directories that contain a SKILL.md file
    # Get-ChildItem -Directory: List only directories
    # -Recurse -Depth 1: Look one level deep into subdirectories
    # Where-Object: Filter to only those with SKILL.md
    $skillDirs = Get-ChildItem -Path $skillsSrc -Directory -Recurse -Depth 1 |
        Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") }

    if ($skillDirs.Count -eq 0) {
        Write-Warning "No skills found to install"
        return
    }

    # Install each skill with progress indicator
    $count = 0
    foreach ($skillDir in $skillDirs) {
        $count++
        Show-Progress -Current $count -Total $skillDirs.Count -Task "Installing $($skillDir.Name)"
        Copy-OrLink -Source $skillDir.FullName -Destination (Join-Path $skillsDest $skillDir.Name)
    }

    # Clear progress bar
    Write-Progress -Activity "Installing" -Completed
    Write-Success "Installed $($skillDirs.Count) skills"
}

# =============================================================================
# INSTALL-HOOKS
# =============================================================================
# Installs hook scripts: formatters, validators, and notifications.
# Hooks are scripts that run in response to Claude actions.
# =============================================================================
function Install-Hooks {
    Write-Step "Installing hooks..."

    $hooksSrc = Join-Path $Script:SCRIPT_DIR "hooks"
    $hooksDest = Join-Path $Script:CLAUDE_DIR "hooks"

    if (-not (Test-Path $hooksSrc)) {
        Write-Warning "Hooks directory not found: $hooksSrc"
        return
    }

    Confirm-Directory -Path $hooksDest

    # Install formatter hook configurations (JSON files)
    $formattersDir = Join-Path $hooksSrc "formatters"
    if (Test-Path $formattersDir) {
        # Get-ChildItem -Filter "*.json": Only JSON files
        # ForEach-Object: Process each file
        Get-ChildItem -Path $formattersDir -Filter "*.json" | ForEach-Object {
            Copy-OrLink -Source $_.FullName -Destination (Join-Path $hooksDest $_.Name)
        }
        Write-Success "Installed formatter hooks"
    }

    # Install Windows-specific notification script
    $notifyScript = Join-Path $hooksSrc "notifications\windows-toast.ps1"
    if (Test-Path $notifyScript) {
        Copy-OrLink -Source $notifyScript -Destination (Join-Path $hooksDest "notify.ps1")
        Write-Success "Installed Windows notification hook"
    }

    # Install validator scripts (lint before commit, etc.)
    $validatorsDir = Join-Path $hooksSrc "validators"
    if (Test-Path $validatorsDir) {
        Get-ChildItem -Path $validatorsDir | ForEach-Object {
            Copy-OrLink -Source $_.FullName -Destination (Join-Path $hooksDest $_.Name)
        }
        Write-Success "Installed validator hooks"
    }
}

# =============================================================================
# INSTALL-RULES
# =============================================================================
# Installs rule files to ~/.claude/rules/
# Rules are declarative constraint files that Claude Code loads automatically.
# =============================================================================
function Install-Rules {
    Write-Step "Installing rules..."

    $rulesSrc = Join-Path $Script:SCRIPT_DIR "rules"
    $rulesDest = Join-Path $Script:CLAUDE_DIR "rules"

    if (-not (Test-Path $rulesSrc)) {
        Write-Warning "Rules directory not found: $rulesSrc"
        return
    }

    Confirm-Directory -Path $rulesDest

    $ruleFiles = Get-ChildItem -Path $rulesSrc -Filter "*.md"
    $count = 0
    foreach ($ruleFile in $ruleFiles) {
        Copy-OrLink -Source $ruleFile.FullName -Destination (Join-Path $rulesDest $ruleFile.Name)
        $count++
    }

    Write-Success "Installed $count rules"
}

# =============================================================================
# INSTALL-AGENTS
# =============================================================================
# Installs agent definitions to ~/.claude/agents/
# Agents are specialized personas with expertise, tools, and model settings.
# =============================================================================
function Install-Agents {
    Write-Step "Installing agents..."

    $agentsSrc = Join-Path $Script:SCRIPT_DIR "agents"
    $agentsDest = Join-Path $Script:CLAUDE_DIR "agents"

    if (-not (Test-Path $agentsSrc)) {
        Write-Warning "Agents directory not found: $agentsSrc"
        return
    }

    Confirm-Directory -Path $agentsDest

    $agentFiles = Get-ChildItem -Path $agentsSrc -Filter "*.md"
    $count = 0
    foreach ($agentFile in $agentFiles) {
        Copy-OrLink -Source $agentFile.FullName -Destination (Join-Path $agentsDest $agentFile.Name)
        $count++
    }

    Write-Success "Installed $count agents"
}

# =============================================================================
# INSTALL-COMMANDS
# =============================================================================
# Installs command files to ~/.claude/commands/
# Commands define slash commands organized by category (workflow, quality, etc.).
# =============================================================================
function Install-Commands {
    Write-Step "Installing commands..."

    $commandsSrc = Join-Path $Script:SCRIPT_DIR "commands"
    $commandsDest = Join-Path $Script:CLAUDE_DIR "commands"

    if (-not (Test-Path $commandsSrc)) {
        Write-Warning "Commands directory not found: $commandsSrc"
        return
    }

    Confirm-Directory -Path $commandsDest

    # Copy entire directory structure preserving subdirectories
    $cmdFiles = Get-ChildItem -Path $commandsSrc -Filter "*.md" -Recurse
    foreach ($cmdFile in $cmdFiles) {
        # Preserve subdirectory structure
        $relativePath = $cmdFile.FullName.Substring($commandsSrc.Length + 1)
        $destPath = Join-Path $commandsDest $relativePath
        $destDir = Split-Path -Parent $destPath
        Confirm-Directory -Path $destDir
        Copy-OrLink -Source $cmdFile.FullName -Destination $destPath
    }

    Write-Success "Installed $($cmdFiles.Count) commands"
}

# =============================================================================
# INSTALL-MCP
# =============================================================================
# Installs Model Context Protocol (MCP) server configurations.
# MCP servers extend Claude's capabilities with external tools and data.
#
# NOTE: MCP configs go in %APPDATA%\Claude\, not ~/.claude/
# Claude Desktop reads them from there on Windows.
# =============================================================================
function Install-MCP {
    Write-Step "Installing MCP configurations..."

    $mcpSrc = Join-Path $Script:SCRIPT_DIR "mcp"
    # MCP config location on Windows: %APPDATA%\Claude\
    $mcpDest = Join-Path $env:APPDATA "Claude"

    if (-not (Test-Path $mcpSrc)) {
        Write-Warning "MCP directory not found: $mcpSrc"
        return
    }

    Confirm-Directory -Path $mcpDest

    # Copy MCP server configuration files
    $serversDir = Join-Path $mcpSrc "servers"
    if (Test-Path $serversDir) {
        $mcpServersDir = Join-Path $mcpDest "mcp-servers"
        Confirm-Directory -Path $mcpServersDir
        Get-ChildItem -Path $serversDir -Filter "*.json" | ForEach-Object {
            Copy-OrLink -Source $_.FullName -Destination (Join-Path $mcpServersDir $_.Name)
        }
        Write-Success "Installed MCP server configurations"
    }

    # Remind user to restart Claude Desktop
    Write-Info "Note: Restart Claude Desktop to load MCP servers"
}

# =============================================================================
# INSTALL-TEMPLATE
# =============================================================================
# Installs a CLAUDE.md template and .claude directory to the current project.
# This is for setting up a new project with Claude Code configurations.
# =============================================================================
function Install-Template {
    param([string]$TemplateName)

    Write-Step "Installing $TemplateName template to current directory..."

    $templateSrc = Join-Path $Script:SCRIPT_DIR "templates\$TemplateName"

    # Verify template exists
    if (-not (Test-Path $templateSrc)) {
        Write-Error "Template not found: $TemplateName"
        return
    }

    # Copy CLAUDE.md file
    $claudeMdSrc = Join-Path $templateSrc "CLAUDE.md"
    if (Test-Path $claudeMdSrc) {
        # Get-Location: Current directory (equivalent to $PWD)
        $claudeMdDest = Join-Path (Get-Location) "CLAUDE.md"

        # Check if file already exists
        if (Test-Path $claudeMdDest) {
            Write-Warning "CLAUDE.md already exists in current directory"
            # Read-Host: Prompt for user input
            $response = Read-Host "Overwrite? [y/N]"
            # -notmatch: Regex comparison (returns $true if no match)
            if ($response -notmatch "^[Yy]$") {
                Write-Info "Skipping CLAUDE.md"
            }
            else {
                Copy-Item -Path $claudeMdSrc -Destination $claudeMdDest -Force
                Write-Success "Installed CLAUDE.md"
            }
        }
        else {
            Copy-Item -Path $claudeMdSrc -Destination $claudeMdDest
            Write-Success "Installed CLAUDE.md"
        }
    }

    # Copy .claude directory (project-specific settings)
    $claudeDirSrc = Join-Path $templateSrc ".claude"
    if (Test-Path $claudeDirSrc) {
        $claudeDirDest = Join-Path (Get-Location) ".claude"

        if (Test-Path $claudeDirDest) {
            Write-Warning ".claude directory already exists"
            $response = Read-Host "Merge? [y/N]"
            if ($response -match "^[Yy]$") {
                # Copy contents into existing directory
                Copy-Item -Path "$claudeDirSrc\*" -Destination $claudeDirDest -Recurse -Force
                Write-Success "Merged .claude directory"
            }
        }
        else {
            Copy-Item -Path $claudeDirSrc -Destination $claudeDirDest -Recurse
            Write-Success "Installed .claude directory"
        }
    }
}

# =============================================================================
# INTERACTIVE MODE
# =============================================================================
# Provides a guided installation experience with prompts.
# This is the default mode when no switches are specified.
# =============================================================================
function Start-Interactive {
    Write-Header

    Write-Host "What would you like to install?"
    Write-Host ""
    Write-Host "  1) Everything (recommended for new users)"
    Write-Host "  2) Minimal (CLAUDE.md template + settings only)"
    Write-Host "  3) Custom (choose components)"
    Write-Host "  4) Template only (copy to current project)"
    Write-Host ""

    $choice = Read-Host "Choice [1-4]"

    # Process user choice
    # $script: prefix accesses script-scoped variables
    switch ($choice) {
        "1" { $script:All = $true }
        "2" { $script:Minimal = $true }
        "3" {
            # Custom component selection
            $yn = Read-Host "Install settings? [Y/n]"
            if ($yn -notmatch "^[Nn]$") { $script:Settings = $true }

            $yn = Read-Host "Install skills? [Y/n]"
            if ($yn -notmatch "^[Nn]$") { $script:Skills = $true }

            $yn = Read-Host "Install hooks? [Y/n]"
            if ($yn -notmatch "^[Nn]$") { $script:Hooks = $true }

            $yn = Read-Host "Install rules? [Y/n]"
            if ($yn -notmatch "^[Nn]$") { $script:Rules = $true }

            $yn = Read-Host "Install agents? [Y/n]"
            if ($yn -notmatch "^[Nn]$") { $script:Agents = $true }

            $yn = Read-Host "Install commands? [Y/n]"
            if ($yn -notmatch "^[Nn]$") { $script:Commands = $true }

            $yn = Read-Host "Install MCP configs? [y/N]"
            if ($yn -match "^[Yy]$") { $script:MCP = $true }
        }
        "4" {
            # Template installation
            Write-Host ""
            Write-Host "Available templates:"
            Write-Host "  1) minimal    - Bare essentials (~30 lines)"
            Write-Host "  2) standard   - Recommended baseline (~80 lines)"
            Write-Host "  3) power-user - Full featured (~100 lines)"
            Write-Host ""

            $templateChoice = Read-Host "Template [1-3]"
            switch ($templateChoice) {
                "1" { Install-Template -TemplateName "minimal" }
                "2" { Install-Template -TemplateName "standard" }
                "3" { Install-Template -TemplateName "power-user" }
                default { Write-Error "Invalid choice"; exit 1 }
            }
            exit 0
        }
        default {
            Write-Error "Invalid choice"
            exit 1
        }
    }

    # Choose permission profile
    Write-Host ""
    Write-Host "Permission profile:"
    Write-Host "  1) conservative - Ask before most actions"
    Write-Host "  2) balanced     - Auto-accept edits, ask for bash (recommended)"
    Write-Host "  3) autonomous   - Minimal interruptions"
    Write-Host ""

    $profileChoice = Read-Host "Profile [1-3, default=2]"
    switch ($profileChoice) {
        "1" { $script:Profile = "conservative" }
        "3" { $script:Profile = "autonomous" }
        default { $script:Profile = "balanced" }
    }

    # Symlink option
    Write-Host ""
    $yn = Read-Host "Use symlinks instead of copying? [y/N]"
    if ($yn -match "^[Yy]$") { $script:Symlink = $true }
}

# =============================================================================
# MAIN INSTALLATION
# =============================================================================
# Orchestrates the installation based on selected options.
# =============================================================================
function Start-Install {
    Write-Header

    # Display detected configuration
    Write-Info "Detected OS: Windows"
    Write-Info "Profile: $Profile"
    # Ternary-like expression in PowerShell
    Write-Info "Install method: $(if ($Symlink) { 'symlink' } else { 'copy' })"

    # Create backup of existing configuration
    New-Backup

    # Ensure .claude directory exists
    Confirm-Directory -Path $Script:CLAUDE_DIR

    # Install components based on selected mode
    if ($All) {
        Install-Settings
        Install-Skills
        Install-Hooks
        Install-Rules
        Install-Agents
        Install-Commands
        Install-MCP
    }
    elseif ($Minimal) {
        Install-Settings
        Write-Info "Run '.\install.ps1 -Template standard' to install CLAUDE.md template"
    }
    else {
        # Install individual components as selected
        if ($Settings) { Install-Settings }
        if ($Skills) { Install-Skills }
        if ($Hooks) { Install-Hooks }
        if ($Rules) { Install-Rules }
        if ($Agents) { Install-Agents }
        if ($Commands) { Install-Commands }
        if ($MCP) { Install-MCP }
    }

    # Display completion message and next steps
    Write-Step "Installation complete!"
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Copy a CLAUDE.md template to your project:"
    Write-Host "     Copy-Item $Script:SCRIPT_DIR\templates\standard\CLAUDE.md .\CLAUDE.md"
    Write-Host ""
    Write-Host "  2. Customize settings in ~/.claude/settings.local.json"
    Write-Host ""
    Write-Host "  3. Start Claude Code in your project:"
    Write-Host "     claude"
    Write-Host ""

    # Show backup location if a backup was created
    if ($Script:BACKUP_DIR) {
        Write-Host "Your previous config was backed up to: $Script:BACKUP_DIR"
        Write-Host ""
    }
}

# =============================================================================
# SHOW-USAGE
# =============================================================================
# Displays comprehensive help information.
# Uses a here-string for clean multi-line formatting.
# =============================================================================
function Show-Usage {
    @"
Usage: .\install.ps1 [OPTIONS]

Options:
  -All              Install everything (settings, skills, hooks, rules, agents, commands, MCP)
  -Minimal          Install settings only
  -Skills           Install skills only
  -Hooks            Install hooks only
  -Rules            Install rules only (always-follow constraints)
  -Agents           Install agents only (specialized personas)
  -Commands         Install commands only (slash commands)
  -MCP              Install MCP configurations only
  -Settings         Install settings only

  -Profile PROFILE  Permission profile: conservative, balanced, autonomous
                    (default: balanced)

  -Template NAME    Install template to current directory
                    (minimal, standard, power-user)

  -Symlink          Use symlinks instead of copying files
  -NoBackup         Skip backup of existing configuration
  -DryRun           Show what would be installed without making changes

  -Help             Show this help message
  -Version          Show version

Examples:
  .\install.ps1                       # Interactive mode
  .\install.ps1 -All                  # Install everything
  .\install.ps1 -Minimal              # Just settings
  .\install.ps1 -Profile autonomous -All
  .\install.ps1 -Template standard
"@
}

# =============================================================================
# SCRIPT ENTRY POINT
# =============================================================================
# Process command-line arguments and run the appropriate installation mode.
# =============================================================================

# Handle -Help flag
if ($Help) {
    Show-Usage
    exit 0
}

# Handle -Version flag
if ($Version) {
    Write-Host "claude-dotfiles v$Script:VERSION"
    exit 0
}

# Handle -Template flag (direct template installation)
if ($Template) {
    Install-Template -TemplateName $Template
    exit 0
}

# Determine if we should run in interactive mode
# Interactive mode runs when no installation switches are specified
$isInteractive = -not ($All -or $Minimal -or $Skills -or $Hooks -or $MCP -or $Settings -or $Rules -or $Agents -or $Commands)

if ($isInteractive) {
    Start-Interactive
}

# Run the installation
Start-Install
