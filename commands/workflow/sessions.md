---
description: Manage and review session history and state
---

# /sessions

View, search, and manage saved session states and checkpoints.

## Arguments
- `$ARGUMENTS` — Subcommand: `list`, `show <id>`, `resume <id>`, or `clean`

## Subcommands

### list
Show recent sessions with status and summary.

```markdown
| # | Date | Branch | Status | Summary |
|---|------|--------|--------|---------|
| 1 | 2026-02-05 | staging | clean | Added auth middleware |
| 2 | 2026-02-04 | feature/api | dirty | WIP: API rate limiting |
```

### show <id>
Display full details of a saved session including:
- Checkpoint state
- Pending tasks
- Context notes
- Uncommitted changes

### resume <id>
Restore session context and continue work:
1. Check out the session's branch
2. Load pending tasks
3. Display context and next steps
4. Begin work

### clean
Remove sessions older than 30 days after confirmation.

## Session Storage
Sessions are stored as markdown files in `.claude/sessions/` or
`~/.claude/sessions/` with naming convention:
`session_YYYY-MM-DD_<slug>.md`
