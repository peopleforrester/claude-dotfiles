---
name: strategic-compact
description: |
  Context window optimization strategies for Claude Code. Covers token budgets,
  CLAUDE.md sizing, skill organization, tool selection, and techniques for
  maximizing productive output within context limits. Use when optimizing
  Claude Code configurations or managing large projects.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - optimization
    - performance
    - context
---

# Strategic Compact

Techniques for optimizing Claude Code's context window usage.

## Context Window Budget

Claude Code loads several sources into context at session start:

| Source | Target Budget | Max Budget |
|--------|---------------|------------|
| CLAUDE.md (global) | 500 tokens | 1,000 |
| CLAUDE.md (project) | 1,500 tokens | 2,500 |
| Active skills | 1,500 per skill | 3,000 |
| Rules (all loaded) | 500 per rule | 1,000 |
| Agent definitions | 500 per agent | 1,000 |
| **Total passive load** | **< 10,000** | **< 20,000** |

The remaining context budget is for conversation, code, and tool results.

## CLAUDE.md Optimization

### Size Guidelines

```
60-100 lines  → Optimal (loads fast, leaves room for code)
100-150 lines → Acceptable (for complex projects)
150+ lines    → Too large (move details to skills or docs)
```

### What Belongs in CLAUDE.md

```
✓ Stack and language versions
✓ Build/test/deploy commands
✓ Key directory structure
✓ Critical gotchas (non-obvious behaviors)
✓ Project-specific conventions
```

### What Does NOT Belong in CLAUDE.md

```
✗ Language tutorials or syntax guides    → Use skills
✗ General best practices                 → Use rules
✗ Long code examples                     → Use skills
✗ Documentation that exists elsewhere    → Link to it
✗ Change history                         → Use CHANGELOG.md
```

### Token-Efficient Writing

```markdown
# Bad (verbose): 45 tokens
## Testing
To run the tests for this project, you should use the following command
which will discover and execute all test files:
`pytest tests/ -v`

# Good (concise): 12 tokens
## Commands
- **Test**: `pytest tests/ -v`
```

## Skill Organization

### When to Create a Skill vs. Inline in CLAUDE.md

| Signal | Location |
|--------|----------|
| Used in every session | CLAUDE.md |
| Used occasionally | Skill |
| Language-specific patterns | Skill |
| Framework-specific patterns | Skill |
| One-time workflow | Command |

### Skill Loading Strategy

Skills are loaded on demand. Organize so that:

1. **Frequently used** skills have clear, searchable names
2. **Related patterns** are grouped in one skill (not scattered)
3. **Each skill** is self-contained (no cross-skill dependencies)

## Tool Budget Management

MCP tools consume context tokens. Fewer active tools = more room for code.

| Tool Count | Impact |
|------------|--------|
| < 10 | Minimal overhead |
| 10-20 | Optimal range |
| 20-40 | Noticeable context cost |
| 40-80 | Significant — disable unused tools |
| 80+ | Performance degradation likely |

### Optimization Steps

1. **Audit** — List all configured MCP servers and tools
2. **Measure** — Count total tools across all servers
3. **Prune** — Disable tools you haven't used in 2+ weeks
4. **Group** — Use one multi-purpose tool over many single-purpose ones

## Conversation Efficiency

### Reduce Round Trips

```
Bad:  "Read file A" → result → "Read file B" → result → "Now edit both"
Good: "Read file A and file B" → results → "Edit both"
```

### Batch Independent Operations

Launch parallel operations when results don't depend on each other:

```
✓ Read 3 files simultaneously
✓ Run lint + type-check + test in parallel
✓ Search for pattern across multiple directories at once
```

### Avoid Context Pollution

```
✗ Pasting entire file contents into chat when a path reference suffices
✗ Asking Claude to "explain this code" without specifying what's unclear
✗ Requesting verbose output when a summary would work
```

## Large Project Strategies

### Monorepo Navigation

```
1. Use Glob to find files by pattern (not ls -R)
2. Use Grep to search content (not reading files sequentially)
3. Delegate exploration to subagents (preserves main context)
4. Focus on one package/module per task
```

### Context Recovery After Compaction

When a conversation is compacted (summarized to save space):

1. Re-read CLAUDE.md to restore project context
2. Re-read the specific file(s) you're working on
3. Check git status for current change state
4. Continue from the task summary, not from scratch

## Checklist

- [ ] CLAUDE.md under 150 lines / 2,000 tokens
- [ ] Token count documented in CLAUDE.md header comment
- [ ] Patterns moved to skills, not inlined in CLAUDE.md
- [ ] MCP tool count under 40 active tools
- [ ] Parallel tool calls used where possible
- [ ] Subagents used for exploration (preserves main context)
- [ ] Rules are concise (under 500 tokens each)
