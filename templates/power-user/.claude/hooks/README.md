# Hooks Directory

This directory contains hook scripts that can be referenced from `settings.json`.

## Available Hooks

Hooks are configured in the parent `settings.json` file. The PostToolUse hooks
automatically format files after Claude writes or edits them.

## Adding Custom Hooks

1. Create a script in this directory (e.g., `my-hook.sh`)
2. Make it executable: `chmod +x my-hook.sh`
3. Reference it in `settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(*.py)|Edit(*.py)",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/my-hook.sh \"$CLAUDE_FILE_PATH\""
          }
        ]
      }
    ]
  }
}
```

## Available Variables

- `$CLAUDE_FILE_PATH` - Path of the file that was written/edited (PostToolUse only)
- `$CLAUDE_TOOL_NAME` - Name of the tool that was used

## Hook Types

- `PreToolUse` - Runs before a tool executes
- `PostToolUse` - Runs after a tool completes
- `Stop` - Runs when Claude finishes a task
