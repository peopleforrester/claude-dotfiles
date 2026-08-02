# Settings Reference

This directory contains `settings.json` profiles for different use cases.

## Permission Profiles

The legacy Conservative / Balanced / Autonomous bundles were removed in 0.5.0.
The current profiles in [`permissions/`](./permissions/) compose two orthogonal
Claude Code primitives — `sandbox.*` isolation and `defaultMode` — rather than
presetting a single dial. See [`permissions/README.md`](./permissions/README.md)
for the full guide.

| Profile | File | Sandbox | Default Mode | Use Case |
|---------|------|---------|--------------|----------|
| **sandbox-on** | `permissions/sandbox-on.json` | yes | `auto` | Trusted automation with strong isolation |
| **sandbox-off** | `permissions/sandbox-off.json` | no | `acceptEdits` | Local trusted dev, no isolation |
| **autoMode-strict** | `permissions/autoMode-strict.json` | yes | `auto` | First time on auto mode; anything mutating escalates |
| **autoMode-permissive** | `permissions/autoMode-permissive.json` | yes | `auto` | Routine work flows through; destructive bash escalates |

## File Locations

Claude Code loads settings from these locations (in order of priority):

1. **Project settings**: `.claude/settings.json` (highest priority)
2. **Project local**: `.claude/settings.local.json` (gitignored overrides)
3. **Global settings**: `~/.claude/settings.json` (lowest priority)

Note: `defaultMode: "auto"` is honored only from user (`~/.claude/settings.json`)
or managed settings, not from project or local settings, so a repository cannot
grant itself auto mode.

## Permission Modes

`defaultMode` accepts: `default` (displayed as **Manual**; `manual` is an accepted
alias in v2.1.200+), `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`.

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

Deny patterns are simple matchers and defense-in-depth, not a sandbox. See
[`../GOTCHAS.md`](../GOTCHAS.md) for their limits.

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

Hooks can be added to any profile. An event maps to an array of matcher groups,
each pairing a `matcher` (a tool name, not an expression) with a nested `hooks`
array of handlers:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{
          "type": "command",
          "if": "Edit(*.ts)",
          "command": "FILE=$(cat | jq -r '.tool_input.file_path') && npx prettier --write \"$FILE\""
        }]
      }
    ]
  }
}
```

See the power-user template and [`../hooks/`](../hooks/) for more examples.

## Sandbox Configuration

The sandbox provides OS-level filesystem and network isolation for bash commands:

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "excludedCommands": ["git", "docker"],
    "network": {
      "allowedDomains": []
    }
  }
}
```

- `enabled`: enable the sandbox for bash commands
- `autoAllowBashIfSandboxed`: skip permission prompts for sandboxed commands
- `excludedCommands`: commands that run outside the sandbox
- `network.allowedDomains`: domains bash may reach. Empty means none are
  pre-allowed; the first access to a new domain prompts. Set
  `network.strictAllowlist: true` (v2.1.219+, user/managed settings) to deny
  non-allowlisted hosts without prompting.
- `filesystem.allowWrite` / `denyWrite` / `denyRead` / `allowRead`: widen or
  narrow filesystem access; `filesystem.disabled: true` (v2.1.216+) keeps network
  isolation while turning filesystem isolation off.
- `credentials.files` / `credentials.envVars`: block credential files and
  secret env vars from sandboxed commands.

There is no `network.allowLocalBinding` or `network.denyExternal` key.
