---
name: continuous-learning-v2
description: |
  Instinct-based learning system that observes development patterns via hooks
  and builds a knowledge base of reusable instincts with confidence scoring.
  Instincts evolve from observations into skills, commands, and agents.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "2.0.0"
  tags: [learning, automation, hooks, patterns]
---

# Continuous Learning v2: Instinct-Based System

Learn from development sessions automatically using hook-based observation
and confidence-scored instincts.

## Why v2?

v1 used skills for learning (probabilistic activation, 50-80% reliability).
v2 uses hooks (deterministic, 100% reliability) with structured instincts.

## Core Concepts

### Instincts
Atomic units of learned behavior with confidence scoring:

```yaml
---
id: prefer-const-assertions
trigger: "when defining constant arrays or objects in TypeScript"
confidence: 0.7
domain: "code-style"
source: "session-observation"
---
# Use `as const` for constant definitions

TypeScript `as const` assertions provide literal types and readonly guarantees.

## Pattern
```typescript
const ROLES = ['admin', 'user', 'guest'] as const;
type Role = typeof ROLES[number];
```

## Evidence
- Applied in 3 sessions
- Approved by reviewer each time
- Matches TypeScript best practices
```

### Confidence Levels

| Score | Level | Behavior |
|-------|-------|----------|
| 0.3 | Tentative | Suggested, not enforced |
| 0.5 | Moderate | Applied when context matches |
| 0.7 | Strong | Auto-applied, can be overridden |
| 0.9 | Near-certain | Core behavior, always applied |

### Confidence Evolution
- New observation: starts at 0.3
- Repeated application without correction: +0.1 per session
- User correction/rejection: -0.2
- Maximum: 0.9 (never fully automatic)

## Observation Hooks

### PreToolUse Observer
Before tool execution, check if any instincts apply:
```json
{
  "matcher": "tool == \"Write\" || tool == \"Edit\"",
  "type": "message",
  "message": "Check instincts for applicable patterns before writing code."
}
```

### PostToolUse Observer
After tool execution, look for learnable patterns:
```json
{
  "matcher": "tool == \"Edit\" && result.success == true",
  "type": "command",
  "command": "echo 'Pattern observed: successful edit to $CLAUDE_FILE_PATH'",
  "async": true
}
```

## Instinct Lifecycle

```
Observation → Instinct (0.3) → Strengthened (0.5-0.7) → Evolved (0.9)
                    ↓                                        ↓
              Weakened/Removed                    Promoted to Skill/Rule
```

## Commands

| Command | Purpose |
|---------|---------|
| `/learn` | Extract patterns from current session |
| `/checkpoint` | Save state including instinct observations |

## Storage

Instincts stored in `~/.claude/instincts/` as markdown files:
```
~/.claude/instincts/
  prefer-const-assertions.md
  use-errgroup-for-goroutines.md
  validate-inputs-with-zod.md
```

## Evolution Path

When instincts cluster around a domain, they can be promoted:
- **3+ related instincts** → candidate for a Skill
- **5+ high-confidence instincts** → candidate for a Rule
- **Domain-specific cluster** → candidate for an Agent prompt

## Best Practices

- Review instincts periodically (monthly)
- Export instincts when switching projects to preserve learning
- Share instincts with team members for consistency
- Prune instincts that haven't been triggered in 30+ days
