<!-- Tokens: ~300 | Lines: 40 | Compatibility: Claude Code 2.1+ -->
# Go Hook Rules

Extends `common/hooks.md` with Go-specific hook configurations.

An event maps to matcher groups; the `matcher` is a tool name (not an
expression), and each group nests a `hooks` array of handlers. Scope on the
edited file inside the command (or with a handler-level `if`).

## PostToolUse Hooks

### Auto-Format
Run gofmt and goimports after editing Go files:
```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "FILE=$(cat | jq -r '.tool_input.file_path'); case \"$FILE\" in *.go) gofmt -w \"$FILE\" && goimports -w \"$FILE\" 2>/dev/null;; esac",
    "async": true
  }]
}
```

### Vet Check
Run go vet after edits:
```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "if": "Edit(*.go)",
    "command": "go vet ./... 2>&1 | head -20",
    "async": true
  }]
}
```

### Static Analysis
Run staticcheck after edits:
```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "if": "Edit(*.go)",
    "command": "staticcheck ./... 2>&1 | head -20",
    "async": true
  }]
}
```

## References
- See `skills/patterns/golang-patterns/SKILL.md` for comprehensive patterns
- See `skills/development/golang-testing/SKILL.md` for testing patterns
