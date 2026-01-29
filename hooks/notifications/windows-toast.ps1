# ABOUTME: Windows toast notification using PowerShell
# ABOUTME: Shows notification when Claude completes a task

<#
.SYNOPSIS
    Windows Toast Notification Hook

.DESCRIPTION
    Displays a Windows toast notification when Claude completes a task.

.PARAMETER Title
    The notification title (default: "Claude Code")

.PARAMETER Message
    The notification message (default: "Task completed")

.EXAMPLE
    .\windows-toast.ps1
    .\windows-toast.ps1 -Title "Build Complete" -Message "Your project has been built successfully"

.NOTES
    Usage in settings.json:
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
#>

param(
    [string]$Title = "Claude Code",
    [string]$Message = "Task completed"
)

# Method 1: Using BurntToast module (recommended, more features)
if (Get-Module -ListAvailable -Name BurntToast) {
    New-BurntToastNotification -Text $Title, $Message
    exit 0
}

# Method 2: Using Windows.UI.Notifications (built-in)
try {
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

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

    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($template)

    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
    $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Claude Code")
    $notifier.Show($toast)
    exit 0
}
catch {
    # Silently continue if toast notification fails
}

# Method 3: Fallback to simple MessageBox (blocking, less ideal)
# Uncomment if you want a fallback:
# Add-Type -AssemblyName System.Windows.Forms
# [System.Windows.Forms.MessageBox]::Show($Message, $Title, 'OK', 'Information')

# Method 4: Console beep as last resort
[Console]::Beep(800, 200)
[Console]::Beep(1000, 200)

Write-Host "Notification: $Title - $Message"
