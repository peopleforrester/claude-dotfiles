<!-- Tokens: ~500 | Lines: 75 | Compatibility: Claude Code 2.1+ -->
# Rules System

Rules are declarative constraints Claude Code applies automatically to every interaction.
Unlike skills (which define workflows) or agents (which provide expertise), rules define
boundaries and standards that are always enforced.

## How Rules Work

Place `.md` files in `~/.claude/rules/` (global) or `.claude/rules/` (project-specific).
Claude Code loads and applies them automatically without explicit invocation.

## Structure

```
rules/
  common/              # Language-agnostic (ALWAYS install)
    security.md        # OWASP Top 10, secrets, input validation
    coding-style.md    # Immutability, file organization, naming
    testing.md         # TDD workflow, 80% coverage target
    git-workflow.md    # Conventional commits, PR process
    performance.md     # Model selection, context management
    agents.md          # Subagent delegation patterns
  typescript/          # TypeScript/JavaScript specific
    coding-style.md    # Strict mode, branded types, Zod
    testing.md         # Vitest/Jest, Testing Library, MSW
    security.md        # XSS prevention, CSP, npm audit
  python/              # Python specific
    coding-style.md    # Type hints, Protocols, dataclasses
    testing.md         # pytest, fixtures, parametrize
    security.md        # Pydantic validation, pip-audit
  golang/              # Go specific
    coding-style.md    # Error wrapping, interfaces, errgroup
    testing.md         # Table-driven tests, httptest, benchmarks
    security.md        # govulncheck, crypto/rand, html/template
```

## Precedence

1. **Project rules** (`.claude/rules/`) - highest priority, project-specific
2. **Global rules** (`~/.claude/rules/`) - apply to all projects
3. **Built-in rules** - Claude's default behavior baseline

## Installation

```bash
# Install common rules (REQUIRED for all projects)
cp rules/common/*.md ~/.claude/rules/

# Add language-specific rules for your stack
cp rules/typescript/*.md ~/.claude/rules/   # For TS/JS projects
cp rules/python/*.md ~/.claude/rules/       # For Python projects
cp rules/golang/*.md ~/.claude/rules/       # For Go projects

# Or install per-project
mkdir -p .claude/rules/
cp rules/common/*.md .claude/rules/
cp rules/python/*.md .claude/rules/         # Add your language
```

## Rules vs Skills vs Agents

| Concept | Purpose | Loaded | Example |
|---------|---------|--------|---------|
| **Rule** | Constraint/boundary | Automatically | "Never hardcode secrets" |
| **Skill** | Workflow/process | On context match | "TDD red-green-refactor cycle" |
| **Agent** | Expertise/persona | Explicit command | "Security reviewer specialist" |

## Creating Custom Rules

Rules follow a simple declarative format:

```markdown
# Rule Name

## Always
- Constraint that must be followed

## Never
- Behavior to avoid

## When [Context]
- Conditional constraint for specific situations
```

Language-specific rules should reference the common rule they extend
(e.g., "Extends `common/security.md` with Python-specific constraints").
