# Scripts & Utilities

Utility scripts for validating, counting tokens, syncing, and backing up configurations.

## Available Scripts

| Script | Purpose | Language |
|--------|---------|----------|
| [validate.py](#validatepy) | Validate JSON, YAML, SKILL.md files | Python 3.10+ |
| [token-count.py](#token-countpy) | Count tokens in CLAUDE.md files | Python 3.10+ |
| [sync-configs.sh](#sync-configssh) | Sync configs across machines | Bash |
| [backup-claude.sh](#backup-claudesh) | Backup ~/.claude directory | Bash |

## validate.py

Validates all configuration files in the repository.

### Usage

```bash
# Validate entire repository
python scripts/validate.py

# Validate specific directory
python scripts/validate.py skills/

# Validate specific file
python scripts/validate.py skills/tdd-workflow/SKILL.md
```

### Checks Performed

- **JSON files**: Syntax validation
- **SKILL.md files**: YAML frontmatter, required fields (name, description)
- **Markdown files**: Internal link validation

### Example Output

```
claude-dotfiles validator

→ Validating directory: /path/to/repo

✓ settings/permissions/balanced.json
✓ skills/development/tdd-workflow/SKILL.md
! README.md: Broken link: [some-link](./path/to/missing-file.md)

Summary
  Files checked: 45
  Errors: 0
  Warnings: 1

Validation passed
```

## token-count.py

Counts tokens in CLAUDE.md and SKILL.md files.

### Requirements

```bash
pip install tiktoken  # Optional but recommended
```

Without tiktoken, uses word-based estimation.

### Usage

```bash
# Count all templates
python scripts/token-count.py

# Count specific directory
python scripts/token-count.py templates/

# Count specific file
python scripts/token-count.py templates/standard/CLAUDE.md
```

### Token Budgets

| Template Type | Target | Maximum |
|---------------|--------|---------|
| Minimal | 500 | 1,000 |
| Standard | 1,500 | 2,500 |
| Power User | 2,000 | 3,500 |

### Example Output

```
claude-dotfiles token counter

Found 12 file(s)

  templates/minimal/CLAUDE.md
    Tokens: 423 (target: 500, max: 1000)
    Lines:  28 (target: 30, max: 50)

  templates/standard/CLAUDE.md
    Tokens: 1342 (target: 1500, max: 2500)
    Lines:  72 (target: 80, max: 100)

Summary
  Files analyzed: 12
  Over budget: 0
  Total tokens: 15,432

All files within budget
```

## sync-configs.sh

Syncs Claude configurations across machines.

### Supported Methods

| Method | Requirements |
|--------|--------------|
| chezmoi | [chezmoi](https://www.chezmoi.io/) installed |
| GNU Stow | `stow` installed, `~/.dotfiles/` exists |
| rsync | `CLAUDE_SYNC_REMOTE` env var set |
| git-bare | Initialized with `--method git-bare` |

### Usage

```bash
# Push local config to remote
./scripts/sync-configs.sh push

# Pull config from remote
./scripts/sync-configs.sh pull

# Check sync status
./scripts/sync-configs.sh status

# Initialize git-bare method
./scripts/sync-configs.sh init --method git-bare

# Force specific method
./scripts/sync-configs.sh push --method chezmoi
```

### Environment Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `CLAUDE_SYNC_REMOTE` | rsync destination | `user@host:~/.claude-sync/` |
| `CLAUDE_GIT_DIR` | Git bare repo path | `~/.claude-git` |
| `STOW_DIR` | Stow directory | `~/.dotfiles` |

## backup-claude.sh

Creates timestamped backups of `~/.claude`.

### Usage

```bash
# Create backup
./scripts/backup-claude.sh

# List available backups
./scripts/backup-claude.sh --list

# Restore from latest backup
./scripts/backup-claude.sh --restore

# Restore from specific backup
./scripts/backup-claude.sh --restore --file ~/.claude-backups/backup.tar.gz

# Delete all backups
./scripts/backup-claude.sh --clean
```

### Features

- Compressed tar.gz backups
- Automatic rotation (keeps last 10 by default)
- Pre-restore backup of current config
- Excludes session data and logs

### Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_BACKUP_DIR` | `~/.claude-backups` | Backup location |
| `CLAUDE_MAX_BACKUPS` | `10` | Max backups to keep |

### Example Output

```
Claude Config Backup v1.0.0

→ Backing up /home/user/.claude (2.3M)...
✓ Backup created: /home/user/.claude-backups/claude-backup-20260128-143052.tar.gz (156K)
```

## CI/CD Integration

### GitHub Actions

The repository includes workflows for:

- **validate.yml**: Runs on PRs to validate all configs
- **release.yml**: Creates releases on tag push

### Pre-commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
python scripts/validate.py
python scripts/token-count.py
```

## Tips

- Run `validate.py` before committing changes
- Use `token-count.py` to ensure CLAUDE.md files stay within budget
- Set up `backup-claude.sh` as a cron job for regular backups
- Use `sync-configs.sh` with chezmoi for seamless multi-machine sync
