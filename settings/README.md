# Settings Reference

This directory contains `settings.json` profiles for different use cases.

## Permission Profiles

| Profile | File | Use Case |
|---------|------|----------|
| **Conservative** | `permissions/conservative.json` | Learning, sensitive projects |
| **Balanced** | `permissions/balanced.json` | Daily development (recommended) |
| **Autonomous** | `permissions/autonomous.json` | Trusted automation |

## File Locations

Claude Code loads settings from these locations (in order of priority):

1. **Project settings**: `.claude/settings.json` (highest priority)
2. **Project local**: `.claude/settings.local.json` (gitignored overrides)
3. **Global settings**: `~/.claude/settings.json` (lowest priority)

## Profile Comparison

| Setting | Conservative | Balanced | Autonomous |
|---------|-------------|----------|------------|
| `defaultMode` | `prompt` | `acceptEdits` | `acceptEdits` |
| Auto-allow reads | Yes | Yes | Yes |
| Auto-allow writes | No | No | Yes |
| Auto-allow edits | No | Yes | Yes |
| Auto-allow npm/pnpm | No | Yes | Yes |
| Auto-allow git status | No | Yes | Yes |
| Auto-allow git commit | No | No | Yes |
| Auto-allow git push | No | No | No (ask) |
| Sandbox enabled | Yes | Yes | Yes |
| Auto-allow sandboxed bash | No | Yes | Yes |

## Security Defaults

All profiles include these security defaults in the `deny` list:

```json
"deny": [
  "Read(./.env)",           // Environment variables
  "Read(./.env.*)",         // Environment variants
  "Read(./secrets/**)",     // Secrets directory
  "Read(~/.aws/**)",        // AWS credentials
  "Read(~/.ssh/**)",        // SSH keys
  "Read(~/.gnupg/**)",      // GPG keys
  "Bash(rm -rf *)",         // Destructive deletion
  "Bash(curl * | bash)",    // Remote code execution
  "Bash(sudo *)"            // Privilege escalation
]
```

## Customization

Create a `settings.local.json` file for personal overrides that won't be committed:

```json
{
  "// NOTE": "Personal overrides - gitignored",
  "permissions": {
    "allow": [
      "Bash(my-custom-script *)"
    ]
  }
}
```

## Hooks Configuration

Hooks can be added to any profile. See the power-user template for examples:

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

## Sandbox Configuration

The sandbox provides container-based isolation for bash commands:

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "excludedCommands": ["git", "docker"],
    "network": {
      "allowLocalBinding": true
    }
  }
}
```

- `enabled`: Enable sandbox for bash commands
- `autoAllowBashIfSandboxed`: Skip permission prompts for sandboxed commands
- `excludedCommands`: Commands that run outside the sandbox
- `network.allowLocalBinding`: Allow binding to localhost ports
