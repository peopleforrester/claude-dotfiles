<!-- Tokens: ~300 | Lines: 40 | Compatibility: Claude Code 2.1+ -->
# Go Hook Rules

Extends `common/hooks.md` with Go-specific hook configurations.

## PostToolUse Hooks

### Auto-Format
Run gofmt and goimports after editing Go files:
```json
{
  "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\.go$\"",
  "type": "command",
  "command": "gofmt -w \"$CLAUDE_FILE_PATH\" && goimports -w \"$CLAUDE_FILE_PATH\" 2>/dev/null",
  "async": true
}
```

### Vet Check
Run go vet after edits:
```json
{
  "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\.go$\"",
  "type": "command",
  "command": "go vet ./... 2>&1 | head -20",
  "async": true
}
```

### Static Analysis
Run staticcheck after edits:
```json
{
  "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\.go$\"",
  "type": "command",
  "command": "staticcheck ./... 2>&1 | head -20",
  "async": true
}
```

## References
- See `skills/patterns/golang-patterns/SKILL.md` for comprehensive patterns
- See `skills/development/golang-testing/SKILL.md` for testing patterns
