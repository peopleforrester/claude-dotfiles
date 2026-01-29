# MCP Server Configuration Guide

Model Context Protocol (MCP) servers extend Claude Desktop with external capabilities
like file access, database queries, and API integrations.

## What is MCP?

MCP is an open protocol that allows Claude to interact with external systems:

- **Filesystem** - Read and write local files
- **Databases** - Query PostgreSQL, SQLite, etc.
- **APIs** - GitHub, Slack, Notion, etc.
- **Search** - Web search capabilities

## Quick Start

1. Find your config file (see [Config Location](#config-location))
2. Choose a [bundle](#bundles) or [individual server](#servers)
3. Copy the `mcpServers` section to your config
4. Add your credentials
5. Restart Claude Desktop

## Config Location

| Platform | Path |
|----------|------|
| macOS | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| Windows | `%APPDATA%\Claude\claude_desktop_config.json` |
| Linux | `~/.config/Claude/claude_desktop_config.json` |

### Create Config File

If the file doesn't exist:

```bash
# macOS
mkdir -p ~/Library/Application\ Support/Claude
touch ~/Library/Application\ Support/Claude/claude_desktop_config.json
echo '{"mcpServers":{}}' > ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

## Servers

Individual server configurations:

| Server | Purpose | Credentials Needed |
|--------|---------|-------------------|
| [filesystem](./servers/filesystem.json) | Local file access | None |
| [github](./servers/github.json) | GitHub repos, issues, PRs | Personal Access Token |
| [slack](./servers/slack.json) | Slack messages, channels | Bot Token + Team ID |
| [notion](./servers/notion.json) | Notion pages, databases | Integration Token |
| [postgres](./servers/postgres.json) | PostgreSQL queries | Connection string |
| [sqlite](./servers/sqlite.json) | SQLite database access | File path |
| [brave-search](./servers/brave-search.json) | Web search | API Key |

## Bundles

Pre-configured server combinations:

| Bundle | Servers | Use Case |
|--------|---------|----------|
| [developer-essentials](./bundles/developer-essentials.json) | Filesystem, GitHub, Brave Search | Software development |
| [knowledge-worker](./bundles/knowledge-worker.json) | Notion, Slack, Brave Search, Filesystem | Research & documentation |
| [data-engineer](./bundles/data-engineer.json) | PostgreSQL, SQLite, Filesystem, Brave Search | Data analysis |

## Installation

### Using a Bundle

1. Open the bundle JSON file
2. Copy the entire `mcpServers` object
3. Paste into your `claude_desktop_config.json`
4. Replace placeholder credentials with real ones
5. Restart Claude Desktop

### Example Config

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/michael/Projects"
      ]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxx"
      }
    }
  }
}
```

## Credential Setup

### GitHub

1. Go to https://github.com/settings/tokens
2. Generate new token (classic)
3. Select scopes: `repo`, `read:org`, `read:user`
4. Copy token to config

### Slack

1. Go to https://api.slack.com/apps
2. Create new app from scratch
3. Add Bot Token Scopes: `channels:history`, `channels:read`, `chat:write`, `users:read`
4. Install to workspace
5. Copy Bot Token (`xoxb-...`) to config
6. Find Team ID from Slack URL (`T01XXXXXX`)

### Notion

1. Go to https://www.notion.so/my-integrations
2. Create new integration
3. Copy Internal Integration Token
4. **Important**: Share each page/database with your integration

### Brave Search

1. Go to https://brave.com/search/api/
2. Create account and subscribe (free tier available)
3. Generate and copy API key

### PostgreSQL

1. Create a read-only user (recommended)
2. Format connection string: `postgresql://user:pass@host:5432/db`
3. Never use production credentials

## Security Best Practices

### Do

- Use read-only database users
- Create dedicated API tokens with minimal scopes
- Limit filesystem access to specific directories
- Rotate credentials periodically
- Use environment variables for sensitive data

### Don't

- Grant access to `~/` (entire home directory)
- Include `~/.ssh`, `~/.aws`, or credential directories
- Use production database credentials
- Commit credentials to version control
- Share tokens across multiple integrations

## Environment Variables

Instead of hardcoding credentials, use environment variables:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

Set in your shell profile:
```bash
export GITHUB_TOKEN="ghp_xxxx"
```

## Troubleshooting

### Server Not Loading

1. Check config file syntax (valid JSON?)
2. Verify file path is correct for your OS
3. Restart Claude Desktop completely
4. Check for npx in PATH

### "Command not found" Error

Ensure Node.js is installed:
```bash
node --version  # Should be 18+
npx --version
```

### Permission Denied

For filesystem server:
- Check directory paths exist
- Verify read/write permissions

For database servers:
- Verify credentials are correct
- Check network connectivity
- Confirm user has required permissions

### Server Crashes

Check Claude Desktop logs:
- macOS: `~/Library/Logs/Claude/`
- Windows: `%APPDATA%\Claude\logs\`

### Slow Startup

MCP servers start on demand. First use may be slow as npm downloads packages.
Subsequent uses are faster due to caching.

## Multiple Configurations

You can have multiple instances of the same server type:

```json
{
  "mcpServers": {
    "postgres-prod": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://...prod..."]
    },
    "postgres-staging": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://...staging..."]
    }
  }
}
```

## Finding More Servers

- **Official servers**: https://github.com/modelcontextprotocol/servers
- **Community servers**: https://github.com/punkpeye/awesome-mcp-servers
- **MCP specification**: https://modelcontextprotocol.io

## Updating Servers

Servers are installed via npx and auto-update. To force update:

```bash
# Clear npx cache
npx clear-npx-cache

# Or specify version
"args": ["-y", "@modelcontextprotocol/server-filesystem@latest", "/path"]
```
