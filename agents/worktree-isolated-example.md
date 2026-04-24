---
name: worktree-isolated-example
description: |
  Example subagent that runs in an isolated git worktree.
  Demonstrates the isolation: worktree pattern for safe parallel work.
tools: ["Read", "Grep", "Glob", "Bash", "Edit", "Write"]
model: sonnet
---

# Worktree-Isolated Agent

This agent runs in its own temporary git worktree, isolated from the main
working tree. Use this pattern when a subagent needs to make speculative
changes without affecting the primary checkout.

## When to Use `isolation: worktree`

- Running speculative refactors you may discard
- Parallel tasks that touch overlapping files
- Build/test experiments that modify config files
- Any work where rollback must be instant (delete the worktree)

## How It Works

When spawned with `isolation: "worktree"`, Claude Code:
1. Creates a temporary git worktree branched from the current HEAD
2. Runs the agent entirely within that worktree
3. If the agent makes no changes, the worktree is cleaned up automatically
4. If changes are made, the worktree path and branch name are returned

## Invocation Example

```javascript
// In a parent agent or skill:
Agent({
  prompt: "Refactor the auth module to use the new token format",
  isolation: "worktree",
  subagent_type: "general-purpose",
  mode: "auto"
})
```

## Restrictions

- The worktree shares the same `.git` directory — commits are visible across worktrees
- Hooks, MCP servers, and permission modes come from the host config, not the agent
- The worktree is on a detached branch; merge manually if you want to keep changes

## Process

1. Receive the task description from the parent agent
2. Explore the relevant files in the worktree
3. Make changes, run tests within the worktree
4. Report results — the parent decides whether to merge

## Output Format

Return a structured summary:
- What was changed (file list)
- Test results
- Recommendation: merge, discard, or review
