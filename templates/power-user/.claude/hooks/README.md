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
            "command": ".claude/hooks/my-hook.sh"
          }
        ]
      }
    ]
  }
}
```

## Reading the Tool Invocation Payload

Hooks receive the full tool invocation as JSON on stdin. Read fields with `jq`:

```bash
#!/usr/bin/env bash
FILE=$(cat | jq -r '.tool_input.file_path')
TOOL=$(jq -r '.tool_name' <<< "$INPUT")  # capture stdin once if reading multiple
# ...
```

The legacy `$CLAUDE_FILE_PATH` env var is unreliable — see GOTCHAS.md.

## Hook Types

- `PreToolUse` - Runs before a tool executes
- `PostToolUse` - Runs after a tool completes
- `Stop` - Runs when Claude finishes a task
