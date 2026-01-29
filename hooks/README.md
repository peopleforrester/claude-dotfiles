# Hooks System Guide

Hooks are automation scripts that run in response to Claude Code events.
This directory contains ready-to-use hook configurations.

## Available Hooks

### Formatters (`formatters/`)

Auto-format code after Claude writes or edits files.

| Hook | Language | Formatter |
|------|----------|-----------|
| [prettier-on-save.json](./formatters/prettier-on-save.json) | JS/TS/CSS/JSON | Prettier |
| [black-on-save.json](./formatters/black-on-save.json) | Python | Black + Ruff |
| [rustfmt-on-save.json](./formatters/rustfmt-on-save.json) | Rust | rustfmt |
| [gofmt-on-save.json](./formatters/gofmt-on-save.json) | Go | gofmt/goimports |

### Validators (`validators/`)

Validate or protect files before/after operations.

| Hook | Purpose |
|------|---------|
| [protect-sensitive-files.py](./validators/protect-sensitive-files.py) | Block access to .env, secrets |
| [lint-before-commit.sh](./validators/lint-before-commit.sh) | Run linters before git commit |
| [type-check-on-save.json](./validators/type-check-on-save.json) | TypeScript type checking |

### Notifications (`notifications/`)

Desktop notifications when Claude completes tasks.

| Hook | Platform |
|------|----------|
| [macos-notification.sh](./notifications/macos-notification.sh) | macOS |
| [linux-notify-send.sh](./notifications/linux-notify-send.sh) | Linux |
| [windows-toast.ps1](./notifications/windows-toast.ps1) | Windows |
| [sound-on-complete.sh](./notifications/sound-on-complete.sh) | Cross-platform audio |

### Integrations (`integrations/`)

Integration with external tools.

| Hook | Tool |
|------|------|
| [gitbutler-hooks.json](./integrations/gitbutler-hooks.json) | GitButler |
| [husky-integration.json](./integrations/husky-integration.json) | Husky Git hooks |

## Hook Types

| Type | When It Runs | Use Case |
|------|--------------|----------|
| `PreToolUse` | Before any tool executes | Validation, blocking |
| `PostToolUse` | After tool completes | Formatting, logging |
| `Stop` | When Claude finishes | Notifications |
| `Notification` | On notification request | Alerts |
| `SubagentStop` | When subagent completes | Aggregation |

## Using Hooks

### Method 1: Copy Hook Configuration

Copy the hook configuration into your `settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(*.ts)|Edit(*.ts)",
        "hooks": [{
          "type": "command",
          "command": "npx prettier --write \"$CLAUDE_FILE_PATH\""
        }]
      }
    ]
  }
}
```

### Method 2: Reference External Script

Copy scripts to `~/.claude/hooks/` and reference them:

```json
{
  "hooks": {
    "Stop": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/hooks/macos-notification.sh"
      }]
    }]
  }
}
```

## Matcher Patterns

The `matcher` field uses patterns to filter which tools trigger the hook:

```
Read(*.ts)           # Read operations on .ts files
Write(*.py)          # Write operations on .py files
Edit(*.js)           # Edit operations on .js files
Write(*)|Edit(*)     # Write OR Edit on any file
Bash(git commit *)   # Bash commands starting with "git commit"
```

### Pattern Examples

| Pattern | Matches |
|---------|---------|
| `Write(*.ts)` | Writing TypeScript files |
| `Write(src/*.js)` | Writing JS files in src/ |
| `Edit(*.py)\|Edit(*.pyi)` | Editing Python files |
| `Bash(npm *)` | npm commands |
| `""` (empty) | All operations |

## Available Variables

| Variable | Context | Value |
|----------|---------|-------|
| `$CLAUDE_FILE_PATH` | PostToolUse (Write/Edit) | Path of modified file |
| `$CLAUDE_TOOL_NAME` | All hooks | Name of tool used |

## Creating Custom Hooks

### Shell Script Hook

```bash
#!/usr/bin/env bash
# my-hook.sh

FILE_PATH="$1"  # or use $CLAUDE_FILE_PATH

# Your logic here
echo "Processing: $FILE_PATH"

# Exit 0 for success, non-zero to block (PreToolUse)
exit 0
```

### Python Hook

```python
#!/usr/bin/env python3
import sys

file_path = sys.argv[1] if len(sys.argv) > 1 else None

# Your logic here
print(f"Processing: {file_path}")

# sys.exit(0) for success, non-zero to block
sys.exit(0)
```

## Hook Best Practices

### Do

- End commands with `|| true` to prevent blocking on failure
- Use `2>/dev/null` to suppress error output
- Run background tasks with `&` for non-blocking operations
- Test hooks manually before adding to settings

### Don't

- Block on long-running operations
- Modify files in PreToolUse hooks
- Forget to make scripts executable (`chmod +x`)
- Use hooks for security-critical validation (use permissions instead)

## Combining Hooks

Multiple hooks can run for the same event:

```json
{
  "PostToolUse": [
    {
      "matcher": "Write(*.ts)|Edit(*.ts)",
      "hooks": [
        {
          "type": "command",
          "command": "npx prettier --write \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
        },
        {
          "type": "command",
          "command": "npx eslint --fix \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
        }
      ]
    }
  ]
}
```

## Debugging Hooks

### Test Manually

```bash
# Test a formatter
echo 'const x=1' > test.ts
npx prettier --write test.ts

# Test a notification
./hooks/notifications/macos-notification.sh "Test" "It works!"
```

### Check Hook Output

Hooks write to stderr. Check Claude Code's output for errors.

### Verbose Mode

Add logging to your hook scripts:

```bash
#!/usr/bin/env bash
echo "Hook triggered: $CLAUDE_FILE_PATH" >> /tmp/claude-hooks.log
# ... rest of hook
```

## Platform-Specific Notes

### macOS

- Use `osascript` for notifications
- Use `afplay` for sounds
- Scripts need `chmod +x`

### Linux

- Install `libnotify-bin` for `notify-send`
- Use `paplay` or `aplay` for sounds
- Check `$XDG_CURRENT_DESKTOP` for DE-specific features

### Windows

- Use PowerShell scripts (`.ps1`)
- May need `Set-ExecutionPolicy RemoteSigned`
- Consider BurntToast module for better notifications

## Troubleshooting

### Hook Not Running

1. Check matcher pattern matches the tool
2. Verify script is executable
3. Check script path is correct
4. Look for errors in Claude Code output

### Hook Blocking Operations

1. Ensure exit code is 0 for success
2. Add `|| true` to commands that might fail
3. Check for syntax errors in script

### Formatter Not Working

1. Verify formatter is installed
2. Check if project has formatter config
3. Test formatter command manually
