<!-- Tokens: ~400 | Lines: 55 | Compatibility: Claude Code 2.1+ -->
# Rules System

Rules are declarative constraints Claude Code applies automatically to every interaction.
Unlike skills (which define workflows) or agents (which provide expertise), rules define
boundaries and standards that are always enforced.

## How Rules Work

Place `.md` files in `~/.claude/rules/` (global) or `.claude/rules/` (project-specific).
Claude Code loads and applies them automatically without explicit invocation.

## Precedence

1. **Project rules** (`.claude/rules/`) - highest priority, project-specific
2. **Global rules** (`~/.claude/rules/`) - apply to all projects
3. **Built-in rules** - Claude's default behavior baseline

## Available Rules

| Rule | Purpose | Audience |
|------|---------|----------|
| `security.md` | OWASP Top 10, secrets detection, input validation | All projects |
| `coding-style.md` | Immutability, file organization, naming conventions | All projects |
| `testing.md` | TDD workflow, 80% coverage target, test quality | All projects |
| `git-workflow.md` | Conventional commits, PR process, branching | All projects |
| `performance.md` | Model selection, context management, caching | Claude Code users |
| `agents.md` | When and how to delegate to subagents | Claude Code users |

## Creating Custom Rules

Rules follow a simple declarative format:

```markdown
# Rule Name

## Always
- Constraint that must be followed
- Another mandatory behavior

## Never
- Behavior to avoid
- Anti-pattern to prevent

## When [Context]
- Conditional constraint for specific situations
```

## Rules vs Skills vs Agents

| Concept | Purpose | Loaded | Example |
|---------|---------|--------|---------|
| **Rule** | Constraint/boundary | Automatically | "Never hardcode secrets" |
| **Skill** | Workflow/process | On context match | "TDD red-green-refactor cycle" |
| **Agent** | Expertise/persona | Explicit command | "Security reviewer specialist" |

## Installation

```bash
# Global (all projects)
cp rules/*.md ~/.claude/rules/

# Project-specific
mkdir -p .claude/rules/
cp rules/security.md .claude/rules/
```
