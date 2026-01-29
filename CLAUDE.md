<!-- Tokens: ~1,600 (target: 1,500) | Lines: 85 | Compatibility: Claude Code 2.1+ -->
# claude-dotfiles

Production-ready configurations, skills, and templates for Claude Code optimization.

## Stack

- **Language**: Markdown, JSON, YAML, Bash, Python (scripts only)
- **Target**: Claude Code 2.1+, Claude Desktop, Cursor, OpenAI Codex CLI
- **Package Manager**: None (copy-based installation)

## Commands

```bash
./install.sh              # Interactive installation
./install.sh --all        # Install everything
./install.sh --minimal    # Settings only
./scripts/validate.py     # Validate all configs
./scripts/token-count.py  # Count tokens in CLAUDE.md files
```

## Key Directories

```
templates/          # Starter configs (minimal, standard, power-user)
claude-md/          # CLAUDE.md templates by language/framework/domain
skills/             # Curated SKILL.md implementations
hooks/              # Hook configurations (formatters, validators)
settings/           # settings.json profiles
mcp/                # MCP server configurations
scripts/            # Utility scripts
```

## Code Standards

- CLAUDE.md templates: 60-100 lines optimal, max 150
- SKILL.md files: YAML frontmatter with name, description required
- JSON configs: Use `"// KEY":` comment pattern
- Bash scripts: POSIX-compliant, work on macOS + Linux
- Python scripts: 3.10+, minimal external dependencies

## Implementation Patterns

### CLAUDE.md Templates
- Header comment with token count: `<!-- Tokens: ~X | Lines: Y -->`
- Required sections: Stack, Commands, Key Directories
- Include Gotchas section for non-obvious behaviors

### SKILL.md Files
```yaml
---
name: lowercase-with-hyphens   # Required, 64 chars max
description: |                  # Required, 1024 chars max
  Multi-line description
---
```

### settings.json
- Use `"// SECTION":` for documentation comments
- Always include security deny list
- Three profiles: conservative, balanced, autonomous

## Gotchas

- settings.json: `~/.claude/` (global) vs `.claude/` (project)
- Skills: `~/.claude/skills/` (global) vs `.claude/skills/` (project)
- CLAUDE.md inheritance: reads from repo root AND parent directories
- Hooks `$CLAUDE_FILE_PATH`: only available in PostToolUse
- MCP servers: require Claude Desktop restart after config changes

## Validation

Before committing:
- [ ] JSON parses without errors
- [ ] SKILL.md frontmatter is valid YAML
- [ ] Bash scripts work on macOS and Linux
- [ ] Token counts documented for CLAUDE.md templates

## Testing

```bash
mkdir /tmp/test-project && cd /tmp/test-project
cp -r ~/.claude-dotfiles/templates/standard/* .
claude  # Ask Claude to describe the setup
```

## References

- Skills Spec: https://github.com/anthropics/skills
- Claude Code Docs: https://docs.anthropic.com/claude-code
- MCP Spec: https://modelcontextprotocol.io
