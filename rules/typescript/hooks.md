<!-- Tokens: ~300 | Lines: 40 | Compatibility: Claude Code 2.1+ -->
# TypeScript Hook Rules

Extends `common/hooks.md` with TypeScript-specific hook configurations.

## PostToolUse Hooks

### Auto-Format
Run Prettier after editing JS/TS files:
```json
{
  "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\.(ts|tsx|js|jsx)$\"",
  "type": "command",
  "command": "npx prettier --write \"$CLAUDE_FILE_PATH\"",
  "async": true
}
```

### Type Checking
Run TypeScript compiler after edits:
```json
{
  "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\.(ts|tsx)$\"",
  "type": "command",
  "command": "npx tsc --noEmit --pretty 2>&1 | head -20",
  "async": true
}
```

### Console.log Warning
Flag console.log statements in modified files:
```json
{
  "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\.(ts|tsx)$\"",
  "type": "command",
  "command": "grep -n 'console\\.log' \"$CLAUDE_FILE_PATH\" && echo 'WARNING: console.log found'",
  "async": true
}
```

## Stop Hooks

### Console.log Audit
Check all modified files for console.log before session ends:
```json
{
  "type": "command",
  "command": "git diff --name-only --diff-filter=M '*.ts' '*.tsx' | xargs grep -l 'console.log' 2>/dev/null"
}
```
