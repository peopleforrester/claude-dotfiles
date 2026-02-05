# ABOUTME: Windows toast notification using PowerShell
# ABOUTME: Shows notification when Claude completes a task

<#
# =============================================================================
# Windows Toast Notification Hook for Claude Code
# =============================================================================

.SYNOPSIS
    Windows Toast Notification Hook

    Displays a Windows 10/11 toast notification when Claude Code completes
    a task. Works with the native Windows notification system.

.DESCRIPTION
    This PowerShell script displays a toast notification through Windows'
    built-in notification center. It tries multiple methods in order of
    preference:

    1. BurntToast module (if installed) - most features
    2. Windows.UI.Notifications API - built into Windows 10/11
    3. Console beep - fallback for older systems

    Toast notifications appear in the Windows Action Center and can include:
    - Title text (bold)
    - Body message
    - Sound effect
    - Custom icons (with BurntToast)
    - Click actions (with BurntToast)

.PARAMETER Title
    The notification title (displayed in bold at the top)
    Default: "Claude Code"

.PARAMETER Message
    The notification body text
    Default: "Task completed"

.EXAMPLE
    .\windows-toast.ps1

    Displays a notification with default title and message.

.EXAMPLE
    .\windows-toast.ps1 -Title "Build Complete" -Message "Your project has been built successfully"

    Displays a notification with custom title and message.

.NOTES
    INSTALLATION OF BURNTTOAST (Optional but recommended):

    BurntToast is a PowerShell module that provides more notification features.
    Install it from PowerShell Gallery:

        Install-Module -Name BurntToast -Scope CurrentUser

    CONFIGURATION:

    Add this hook to your settings.json or ~/.claude/settings.json:

    {
      "hooks": {
        "Stop": [
          {
            "matcher": "",
            "hooks": [{
              "type": "command",
              "command": "powershell -ExecutionPolicy Bypass -File ~/.claude/hooks/windows-toast.ps1"
            }]
          }
        ]
      }
    }

    EXECUTION POLICY NOTE:

    The -ExecutionPolicy Bypass flag allows this script to run without
    modifying the system's script execution policy. This is necessary because
    Windows restricts script execution by default for security reasons.

    WINDOWS NOTIFICATION REQUIREMENTS:

    - Windows 10 version 1607 (Anniversary Update) or later
    - Focus Assist settings may hide notifications
    - Notifications must be enabled for the terminal app
#>

# =============================================================================
# POWERSHELL SCRIPT CONFIGURATION
# =============================================================================
# #Requires: Specifies the minimum PowerShell version needed.
# This script uses features available in PowerShell 5.1 (ships with Windows 10)
# and works with PowerShell 7+ as well.
# =============================================================================
#Requires -Version 5.1

# =============================================================================
# CMDLETBINDING AND PARAMETERS
# =============================================================================
# [CmdletBinding()]: Enables advanced function features like -Verbose, -Debug.
# This is a PowerShell best practice for scripts.
#
# param(): Defines the script's input parameters with types and defaults.
# =============================================================================
[CmdletBinding()]
param(
    # Title of the notification (appears in bold)
    [string]$Title = "Claude Code",

    # Body text of the notification
    [string]$Message = "Task completed"
)

# =============================================================================
# METHOD 1: BURNTTOAST MODULE (Recommended)
# =============================================================================
# BurntToast is a PowerShell module specifically for creating Windows toast
# notifications. It provides:
# - Easy to use syntax
# - Custom icons and images
# - Action buttons
# - Progress bars
# - Notification grouping
# - Sound options
#
# INSTALLATION:
#   Install-Module -Name BurntToast -Scope CurrentUser
#
# Get-Module -ListAvailable: Checks if a module is installed without loading it.
# This is more efficient than trying to import and catching errors.
# =============================================================================
if (Get-Module -ListAvailable -Name BurntToast) {
    # BurntToast is installed, use it for the notification
    # New-BurntToastNotification: Creates and displays a toast notification
    # -Text: Array of text lines (first is title, second is body)
    New-BurntToastNotification -Text $Title, $Message
    exit 0
}

# =============================================================================
# METHOD 2: WINDOWS.UI.NOTIFICATIONS API (Built-in)
# =============================================================================
# This uses the WinRT (Windows Runtime) APIs that are built into Windows 10
# and later. It's more complex than BurntToast but requires no installation.
#
# The try/catch ensures we gracefully fall back if this method fails
# (e.g., on older Windows versions or in unusual configurations).
# =============================================================================
try {
    # =========================================================================
    # LOAD WINRT ASSEMBLIES
    # =========================================================================
    # These lines load the Windows Runtime types needed for toast notifications.
    # ContentType = WindowsRuntime tells PowerShell these are WinRT types.
    #
    # | Out-Null: Suppresses the output of the type loading (we don't need it).
    # =========================================================================

    # ToastNotificationManager: Main class for creating and showing toasts
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null

    # XmlDocument: Used to create the XML that defines the notification content
    [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

    # =========================================================================
    # TOAST XML TEMPLATE
    # =========================================================================
    # Toast notifications are defined using XML. This template creates a
    # simple toast with a title and message.
    #
    # @"..."@: PowerShell here-string (preserves formatting and allows variables)
    #
    # XML STRUCTURE:
    # <toast>: Root element
    #   <visual>: Contains the visible content
    #     <binding template="ToastText02">: Layout template (2 text lines)
    #       <text id="1">: First line (title, displayed in bold)
    #       <text id="2">: Second line (body message)
    #   <audio>: Sound to play
    #     src="ms-winsoundevent:...": System notification sound
    #
    # TEMPLATE OPTIONS:
    # - ToastText01: Single text line
    # - ToastText02: Title + body (used here)
    # - ToastText03: Title + wrapped body
    # - ToastText04: Title + two body lines
    # =========================================================================
    $template = @"
<toast>
    <visual>
        <binding template="ToastText02">
            <text id="1">$Title</text>
            <text id="2">$Message</text>
        </binding>
    </visual>
    <audio src="ms-winsoundevent:Notification.Default"/>
</toast>
"@

    # =========================================================================
    # CREATE AND SHOW THE NOTIFICATION
    # =========================================================================

    # Create an XML document and load the template
    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($template)

    # Create a ToastNotification object from the XML
    # ::new() is PowerShell 5+ syntax for calling constructors
    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)

    # Create a notifier for our application
    # The string identifies the app in Windows notification settings
    $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Claude Code")

    # Display the notification
    $notifier.Show($toast)
    exit 0
}
catch {
    # =========================================================================
    # ERROR HANDLING
    # =========================================================================
    # If the Windows notification API fails (older Windows, missing features,
    # permission issues), we silently continue to the fallback method.
    # We don't want a failed notification to cause the hook to report an error.
    # =========================================================================
    # Silently continue if toast notification fails
}

# =============================================================================
# METHOD 3: MESSAGEBOX (Fallback, commented out)
# =============================================================================
# A MessageBox is a simple, blocking dialog that works on all Windows versions.
# However, it requires user interaction to dismiss, which interrupts workflow.
# This is NOT ideal for notifications, so it's commented out by default.
#
# Uncomment if you need a guaranteed visible notification and don't mind the
# interruption.
# =============================================================================
# Add-Type -AssemblyName System.Windows.Forms
# [System.Windows.Forms.MessageBox]::Show($Message, $Title, 'OK', 'Information')

# =============================================================================
# METHOD 4: CONSOLE BEEP (Last Resort)
# =============================================================================
# If all notification methods fail, at least provide an audio cue.
# [Console]::Beep(frequency, duration) plays a simple beep.
#
# We play two ascending tones to create a recognizable "completion" sound:
# - First beep: 800 Hz for 200 ms
# - Second beep: 1000 Hz for 200 ms
#
# This should work on any Windows system with a speaker.
# =============================================================================
[Console]::Beep(800, 200)   # Lower tone
[Console]::Beep(1000, 200)  # Higher tone (gives "success" feeling)

# Also print to console as a text notification
# This is visible if the user is looking at the terminal
Write-Host "Notification: $Title - $Message"
