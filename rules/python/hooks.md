<!-- Tokens: ~300 | Lines: 40 | Compatibility: Claude Code 2.1+ -->
# Python Hook Rules

Extends `common/hooks.md` with Python-specific hook configurations.

An event maps to matcher groups; the `matcher` is a tool name (not an
expression), and each group nests a `hooks` array of handlers. Scope on the
edited file inside the command (or with a handler-level `if`).

## PostToolUse Hooks

### Auto-Format
Run ruff for linting and formatting after editing Python files:
```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "FILE=$(cat | jq -r '.tool_input.file_path'); case \"$FILE\" in *.py) ruff check --fix \"$FILE\" && ruff format \"$FILE\";; esac",
    "async": true
  }]
}
```

### Type Checking
Run mypy or pyright after edits:
```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "FILE=$(cat | jq -r '.tool_input.file_path'); case \"$FILE\" in *.py) mypy \"$FILE\" --ignore-missing-imports 2>&1 | head -20;; esac",
    "async": true
  }]
}
```

### Print Statement Warning
Flag print() statements (use logging module instead):
```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "FILE=$(cat | jq -r '.tool_input.file_path'); case \"$FILE\" in *.py) grep -n 'print(' \"$FILE\" | grep -v '# noqa' && echo 'WARNING: print() found, use logging instead';; esac",
    "async": true
  }]
}
```

## References
- See `skills/patterns/python-patterns/SKILL.md` for comprehensive patterns
- See `skills/development/python-testing/SKILL.md` for testing patterns
