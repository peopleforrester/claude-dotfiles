<!-- Tokens: ~300 | Lines: 40 | Compatibility: Claude Code 2.1+ -->
# TypeScript Hook Rules

Extends `common/hooks.md` with TypeScript-specific hook configurations.

An event maps to matcher groups; the `matcher` is a tool name (not an
expression), and each group nests a `hooks` array of handlers. Scope on the
edited file inside the command (or with a handler-level `if`).

## PostToolUse Hooks

### Auto-Format
Run Prettier after editing JS/TS files:
```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "FILE=$(cat | jq -r '.tool_input.file_path'); case \"$FILE\" in *.ts|*.tsx|*.js|*.jsx) npx prettier --write \"$FILE\";; esac",
    "async": true
  }]
}
```

### Type Checking
Run the TypeScript compiler after edits:
```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "FILE=$(cat | jq -r '.tool_input.file_path'); case \"$FILE\" in *.ts|*.tsx) npx tsc --noEmit --pretty 2>&1 | head -20;; esac",
    "async": true
  }]
}
```

### Console.log Warning
Flag console.log statements in modified files:
```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "FILE=$(cat | jq -r '.tool_input.file_path'); case \"$FILE\" in *.ts|*.tsx) grep -n 'console\\.log' \"$FILE\" && echo 'WARNING: console.log found';; esac",
    "async": true
  }]
}
```

## Stop Hooks

### Console.log Audit
Check all modified files for console.log before session ends:
```json
{
  "hooks": [{
    "type": "command",
    "command": "git diff --name-only --diff-filter=M '*.ts' '*.tsx' | xargs grep -l 'console.log' 2>/dev/null"
  }]
}
```
