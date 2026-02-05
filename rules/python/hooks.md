<!-- Tokens: ~300 | Lines: 40 | Compatibility: Claude Code 2.1+ -->
# Python Hook Rules

Extends `common/hooks.md` with Python-specific hook configurations.

## PostToolUse Hooks

### Auto-Format
Run ruff for linting and formatting after editing Python files:
```json
{
  "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\.py$\"",
  "type": "command",
  "command": "ruff check --fix \"$CLAUDE_FILE_PATH\" && ruff format \"$CLAUDE_FILE_PATH\"",
  "async": true
}
```

### Type Checking
Run mypy or pyright after edits:
```json
{
  "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\.py$\"",
  "type": "command",
  "command": "mypy \"$CLAUDE_FILE_PATH\" --ignore-missing-imports 2>&1 | head -20",
  "async": true
}
```

### Print Statement Warning
Flag print() statements (use logging module instead):
```json
{
  "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\.py$\"",
  "type": "command",
  "command": "grep -n 'print(' \"$CLAUDE_FILE_PATH\" | grep -v '# noqa' && echo 'WARNING: print() found, use logging instead'",
  "async": true
}
```

## References
- See `skills/patterns/python-patterns/SKILL.md` for comprehensive patterns
- See `skills/development/python-testing/SKILL.md` for testing patterns
