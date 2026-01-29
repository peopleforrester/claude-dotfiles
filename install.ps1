# ABOUTME: Interactive installer for claude-dotfiles configurations (Windows)
# ABOUTME: PowerShell equivalent of install.sh for Windows users

#Requires -Version 5.1

[CmdletBinding()]
param(
    [switch]$All,
    [switch]$Minimal,
    [switch]$Skills,
    [switch]$Hooks,
    [switch]$MCP,
    [switch]$Settings,
    [ValidateSet("conservative", "balanced", "autonomous")]
    [string]$Profile = "balanced",
    [string]$Template,
    [switch]$Symlink,
    [switch]$NoBackup,
    [switch]$DryRun,
    [switch]$Help,
    [switch]$Version
)

# =============================================================================
# Configuration
# =============================================================================

$Script:VERSION = "0.1.0"
$Script:SCRIPT_DIR = $PSScriptRoot
$Script:CLAUDE_DIR = Join-Path $env:USERPROFILE ".claude"
$Script:BACKUP_DIR = ""

# =============================================================================
# Helper Functions
# =============================================================================

function Write-Header {
    Write-Host ""
    Write-Host "claude-dotfiles" -ForegroundColor Blue -NoNewline
    Write-Host " v$Script:VERSION"
    Write-Host "Production-ready configurations for Claude Code"
    Write-Host ""
}

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

function Show-Progress {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Task
    )
    $percent = [math]::Round(($Current / $Total) * 100)
    Write-Progress -Activity "Installing" -Status "$Task" -PercentComplete $percent
}

function New-Backup {
    if ($NoBackup) {
        return
    }

    if (Test-Path $Script:CLAUDE_DIR) {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $Script:BACKUP_DIR = Join-Path $env:USERPROFILE ".claude-backup-$timestamp"
        Write-Info "Backing up existing config to $Script:BACKUP_DIR"
        Copy-Item -Path $Script:CLAUDE_DIR -Destination $Script:BACKUP_DIR -Recurse
        Write-Success "Backup created"
    }
}

function Confirm-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Copy-OrLink {
    param(
        [string]$Source,
        [string]$Destination
    )

    if ($DryRun) {
        Write-Host "  Would copy: $Source -> $Destination"
        return
    }

    $destDir = Split-Path -Parent $Destination
    Confirm-Directory -Path $destDir

    if ($Symlink) {
        # Note: Creating symlinks requires admin rights or developer mode on Windows
        try {
            New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -Force | Out-Null
        }
        catch {
            Write-Warning "Symlink failed (may need admin), falling back to copy"
            Copy-Item -Path $Source -Destination $Destination -Recurse -Force
        }
    }
    else {
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
    }
}

# =============================================================================
# Installation Functions
# =============================================================================

function Install-Settings {
    Write-Step "Installing settings ($Profile profile)..."

    $settingsSrc = Join-Path $Script:SCRIPT_DIR "settings\permissions\$Profile.json"
    $settingsDest = Join-Path $Script:CLAUDE_DIR "settings.json"

    if (-not (Test-Path $settingsSrc)) {
        Write-Warning "Profile '$Profile' not found, using balanced"
        $settingsSrc = Join-Path $Script:SCRIPT_DIR "settings\permissions\balanced.json"
    }

    if (Test-Path $settingsSrc) {
        Copy-OrLink -Source $settingsSrc -Destination $settingsDest
        Write-Success "Installed settings.json ($Profile)"
    }
    else {
        Write-Warning "Settings file not found: $settingsSrc"
    }

    # Create local settings template
    $localTemplate = Join-Path $Script:CLAUDE_DIR "settings.local.json"
    if (-not (Test-Path $localTemplate) -and -not $DryRun) {
        @'
{
  "// NOTE": "Personal overrides - this file is gitignored",
  "// ADD": "Your custom settings below"
}
'@ | Out-File -FilePath $localTemplate -Encoding UTF8
        Write-Success "Created settings.local.json template"
    }
}

function Install-Skills {
    Write-Step "Installing skills..."

    $skillsSrc = Join-Path $Script:SCRIPT_DIR "skills"
    $skillsDest = Join-Path $Script:CLAUDE_DIR "skills"

    if (-not (Test-Path $skillsSrc)) {
        Write-Warning "Skills directory not found: $skillsSrc"
        return
    }

    Confirm-Directory -Path $skillsDest

    $skillDirs = Get-ChildItem -Path $skillsSrc -Directory -Recurse -Depth 1 |
        Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") }

    if ($skillDirs.Count -eq 0) {
        Write-Warning "No skills found to install"
        return
    }

    $count = 0
    foreach ($skillDir in $skillDirs) {
        $count++
        Show-Progress -Current $count -Total $skillDirs.Count -Task "Installing $($skillDir.Name)"
        Copy-OrLink -Source $skillDir.FullName -Destination (Join-Path $skillsDest $skillDir.Name)
    }

    Write-Progress -Activity "Installing" -Completed
    Write-Success "Installed $($skillDirs.Count) skills"
}

function Install-Hooks {
    Write-Step "Installing hooks..."

    $hooksSrc = Join-Path $Script:SCRIPT_DIR "hooks"
    $hooksDest = Join-Path $Script:CLAUDE_DIR "hooks"

    if (-not (Test-Path $hooksSrc)) {
        Write-Warning "Hooks directory not found: $hooksSrc"
        return
    }

    Confirm-Directory -Path $hooksDest

    # Install formatters
    $formattersDir = Join-Path $hooksSrc "formatters"
    if (Test-Path $formattersDir) {
        Get-ChildItem -Path $formattersDir -Filter "*.json" | ForEach-Object {
            Copy-OrLink -Source $_.FullName -Destination (Join-Path $hooksDest $_.Name)
        }
        Write-Success "Installed formatter hooks"
    }

    # Install Windows notification
    $notifyScript = Join-Path $hooksSrc "notifications\windows-toast.ps1"
    if (Test-Path $notifyScript) {
        Copy-OrLink -Source $notifyScript -Destination (Join-Path $hooksDest "notify.ps1")
        Write-Success "Installed Windows notification hook"
    }

    # Install validators
    $validatorsDir = Join-Path $hooksSrc "validators"
    if (Test-Path $validatorsDir) {
        Get-ChildItem -Path $validatorsDir | ForEach-Object {
            Copy-OrLink -Source $_.FullName -Destination (Join-Path $hooksDest $_.Name)
        }
        Write-Success "Installed validator hooks"
    }
}

function Install-MCP {
    Write-Step "Installing MCP configurations..."

    $mcpSrc = Join-Path $Script:SCRIPT_DIR "mcp"
    $mcpDest = Join-Path $env:APPDATA "Claude"

    if (-not (Test-Path $mcpSrc)) {
        Write-Warning "MCP directory not found: $mcpSrc"
        return
    }

    Confirm-Directory -Path $mcpDest

    # Copy MCP server configs
    $serversDir = Join-Path $mcpSrc "servers"
    if (Test-Path $serversDir) {
        $mcpServersDir = Join-Path $mcpDest "mcp-servers"
        Confirm-Directory -Path $mcpServersDir
        Get-ChildItem -Path $serversDir -Filter "*.json" | ForEach-Object {
            Copy-OrLink -Source $_.FullName -Destination (Join-Path $mcpServersDir $_.Name)
        }
        Write-Success "Installed MCP server configurations"
    }

    Write-Info "Note: Restart Claude Desktop to load MCP servers"
}

function Install-Template {
    param([string]$TemplateName)

    Write-Step "Installing $TemplateName template to current directory..."

    $templateSrc = Join-Path $Script:SCRIPT_DIR "templates\$TemplateName"

    if (-not (Test-Path $templateSrc)) {
        Write-Error "Template not found: $TemplateName"
        return
    }

    # Copy CLAUDE.md
    $claudeMdSrc = Join-Path $templateSrc "CLAUDE.md"
    if (Test-Path $claudeMdSrc) {
        $claudeMdDest = Join-Path (Get-Location) "CLAUDE.md"
        if (Test-Path $claudeMdDest) {
            Write-Warning "CLAUDE.md already exists in current directory"
            $response = Read-Host "Overwrite? [y/N]"
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

    # Copy .claude directory
    $claudeDirSrc = Join-Path $templateSrc ".claude"
    if (Test-Path $claudeDirSrc) {
        $claudeDirDest = Join-Path (Get-Location) ".claude"
        if (Test-Path $claudeDirDest) {
            Write-Warning ".claude directory already exists"
            $response = Read-Host "Merge? [y/N]"
            if ($response -match "^[Yy]$") {
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
# Interactive Mode
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

    switch ($choice) {
        "1" { $script:All = $true }
        "2" { $script:Minimal = $true }
        "3" {
            $yn = Read-Host "Install settings? [Y/n]"
            if ($yn -notmatch "^[Nn]$") { $script:Settings = $true }

            $yn = Read-Host "Install skills? [Y/n]"
            if ($yn -notmatch "^[Nn]$") { $script:Skills = $true }

            $yn = Read-Host "Install hooks? [Y/n]"
            if ($yn -notmatch "^[Nn]$") { $script:Hooks = $true }

            $yn = Read-Host "Install MCP configs? [y/N]"
            if ($yn -match "^[Yy]$") { $script:MCP = $true }
        }
        "4" {
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

    # Choose profile
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
# Main Installation
# =============================================================================

function Start-Install {
    Write-Header

    Write-Info "Detected OS: Windows"
    Write-Info "Profile: $Profile"
    Write-Info "Install method: $(if ($Symlink) { 'symlink' } else { 'copy' })"

    # Create backup
    New-Backup

    # Ensure .claude directory exists
    Confirm-Directory -Path $Script:CLAUDE_DIR

    if ($All) {
        Install-Settings
        Install-Skills
        Install-Hooks
        Install-MCP
    }
    elseif ($Minimal) {
        Install-Settings
        Write-Info "Run '.\install.ps1 -Template standard' to install CLAUDE.md template"
    }
    else {
        if ($Settings) { Install-Settings }
        if ($Skills) { Install-Skills }
        if ($Hooks) { Install-Hooks }
        if ($MCP) { Install-MCP }
    }

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

    if ($Script:BACKUP_DIR) {
        Write-Host "Your previous config was backed up to: $Script:BACKUP_DIR"
        Write-Host ""
    }
}

# =============================================================================
# Usage
# =============================================================================

function Show-Usage {
    @"
Usage: .\install.ps1 [OPTIONS]

Options:
  -All              Install everything (settings, skills, hooks, MCP)
  -Minimal          Install settings only
  -Skills           Install skills only
  -Hooks            Install hooks only
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
# Entry Point
# =============================================================================

if ($Help) {
    Show-Usage
    exit 0
}

if ($Version) {
    Write-Host "claude-dotfiles v$Script:VERSION"
    exit 0
}

if ($Template) {
    Install-Template -TemplateName $Template
    exit 0
}

# Determine if interactive mode
$isInteractive = -not ($All -or $Minimal -or $Skills -or $Hooks -or $MCP -or $Settings)

if ($isInteractive) {
    Start-Interactive
}

Start-Install
