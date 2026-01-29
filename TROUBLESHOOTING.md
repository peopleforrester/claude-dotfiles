# Troubleshooting

Common issues and solutions for claude-dotfiles.

## Installation Issues

### "Permission denied" when running install.sh

```bash
chmod +x install.sh
./install.sh
```

### Install script not found after curl

```bash
# The script might be in a different location
ls -la ~/.claude-dotfiles/
cd ~/.claude-dotfiles && ./install.sh
```

### PowerShell execution policy error (Windows)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Configuration Issues

### Settings not taking effect

1. Check file location:
   - Global: `~/.claude/settings.json`
   - Project: `.claude/settings.json`

2. Verify JSON syntax:
   ```bash
   python -c "import json; json.load(open('~/.claude/settings.json'))"
   ```

3. Restart Claude Code after changes

### Skills not loading

1. Check skill location:
   - Global: `~/.claude/skills/skill-name/SKILL.md`
   - Project: `.claude/skills/skill-name/SKILL.md`

2. Verify SKILL.md frontmatter:
   ```yaml
   ---
   name: skill-name
   description: |
     Description here
   ---
   ```

3. Ensure `name` matches directory name

### Hooks not running

1. Check matcher pattern matches the tool being used
2. Verify script is executable: `chmod +x script.sh`
3. Check script path is correct
4. Add `|| true` to prevent blocking on errors

## MCP Issues

### MCP servers not appearing in Claude Desktop

1. Check config file location:
   - macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
   - Windows: `%APPDATA%\Claude\claude_desktop_config.json`
   - Linux: `~/.config/Claude/claude_desktop_config.json`

2. Verify JSON syntax

3. **Restart Claude Desktop completely** (not just close window)

### "Command not found" for MCP server

Ensure Node.js 18+ is installed:
```bash
node --version
npx --version
```

### GitHub MCP "authentication failed"

1. Check token has required scopes (`repo`, `read:org`)
2. Verify token isn't expired
3. Regenerate token if needed

### Notion MCP "page not found"

Integration must be explicitly shared with pages:
1. Open page in Notion
2. Click "..." → "Add connections"
3. Select your integration

## Validation Issues

### validate.py "module not found"

```bash
# Run with Python 3
python3 scripts/validate.py
```

### token-count.py inaccurate counts

Install tiktoken for accurate counts:
```bash
pip install tiktoken
```

## Common Errors

### "JSON parse error" in settings

Check for:
- Trailing commas (not allowed in JSON)
- Missing quotes around strings
- Unescaped characters in strings

### "Pattern doesn't match" for hooks

Patterns use glob-style matching:
- `*.ts` matches TypeScript files
- `**/*.ts` matches files in subdirectories
- `Write(*.ts)|Edit(*.ts)` for OR conditions

### Formatter hook fails silently

Add error handling:
```json
{
  "command": "npx prettier --write \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
}
```

## Getting Help

- Check [README.md](./README.md) for documentation links
- Open an issue: https://github.com/michaelrishiforrester/claude-dotfiles/issues
- Review Claude Code docs: https://docs.anthropic.com/claude-code

## Debug Mode

Enable verbose output for scripts:
```bash
bash -x ./install.sh
```

Check Claude Code logs:
- macOS: `~/Library/Logs/Claude/`
- Windows: `%APPDATA%\Claude\logs\`
