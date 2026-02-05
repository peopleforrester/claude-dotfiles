<!-- Tokens: ~400 | Lines: 55 | Compatibility: Claude Code 2.1+ -->
# Agents System

Agents are specialized personas with deep expertise in specific domains. They can be
invoked explicitly via slash commands or delegated to as subagents for complex tasks.

## How Agents Work

Place agent `.md` files in `~/.claude/agents/` (global) or `.claude/agents/` (project).
Each agent defines its expertise, process, and output format. Invoke them via the
corresponding slash command or reference them in subagent delegation.

## Available Agents

| Agent | Expertise | Command | Recommended Model |
|-------|-----------|---------|-------------------|
| `planner` | Implementation planning | `/plan` | Opus |
| `architect` | System design, ADRs | `/architect` | Opus |
| `code-reviewer` | Quality and style review | `/code-review` | Sonnet |
| `security-reviewer` | Vulnerability analysis | `/security-review` | Opus |
| `tdd-guide` | Test-driven development | `/tdd` | Sonnet |
| `build-resolver` | Build error diagnosis | `/build-fix` | Sonnet |
| `doc-updater` | Documentation maintenance | `/update-docs` | Haiku |
| `refactor-cleaner` | Dead code removal | `/refactor-clean` | Sonnet |

## Agent Structure

Every agent file follows this template:

```markdown
---
name: agent-name
description: What this agent specializes in.
tools: ["Read", "Grep", "Glob", "Bash"]
model: sonnet
---

# Agent Name

[System prompt defining expertise]

## Expertise
What this agent knows deeply.

## Process
How this agent approaches problems (step by step).

## Output Format
What the agent produces as deliverables.
```

## When to Use Agents

- **planner**: Starting new features, breaking down complex tasks
- **architect**: Making structural decisions, evaluating trade-offs
- **code-reviewer**: After writing code, before PR
- **security-reviewer**: After code touching auth, input, or data
- **tdd-guide**: Implementing features with test-first approach
- **build-resolver**: When CI/CD or local builds fail
- **doc-updater**: After significant code changes
- **refactor-cleaner**: Periodically or after feature completion

## Creating Custom Agents

See `rules/agents.md` for delegation patterns and best practices.
