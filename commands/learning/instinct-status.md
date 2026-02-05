---
description: View learned instincts grouped by domain with confidence levels
---

# /instinct-status

Display all learned instincts with their confidence scores, grouped by domain.

## Arguments
- `$ARGUMENTS` — Optional filter: domain name or confidence threshold (e.g., "code-style" or ">0.5")

## Process

### 1. Load Instincts
Read all instinct files from `~/.claude/instincts/`:

```
~/.claude/instincts/
  prefer-const-assertions.md      (0.7, code-style)
  use-errgroup-for-goroutines.md   (0.5, concurrency)
  validate-inputs-with-zod.md      (0.9, security)
```

### 2. Display

```markdown
## Learned Instincts

### code-style (3 instincts)
  [=======   ] 0.7  prefer-const-assertions
  [=====     ] 0.5  use-named-exports
  [===       ] 0.3  prefer-early-return

### security (2 instincts)
  [=========•] 0.9  validate-inputs-with-zod
  [=======   ] 0.7  check-auth-on-endpoints

### concurrency (1 instinct)
  [=====     ] 0.5  use-errgroup-for-goroutines

### Summary
Total: 6 instincts across 3 domains
Strong (≥0.7): 3 | Moderate (0.5-0.6): 2 | Tentative (<0.5): 1
```

### 3. Filters

- `/instinct-status code-style` — Show only code-style domain
- `/instinct-status >0.7` — Show only strong instincts
- `/instinct-status inherited` — Show only imported instincts

## Confidence Legend

| Bar | Score | Level |
|-----|-------|-------|
| `[===       ]` | 0.3 | Tentative — suggested, not enforced |
| `[=====     ]` | 0.5 | Moderate — applied when relevant |
| `[=======   ]` | 0.7 | Strong — auto-applied |
| `[=========•]` | 0.9 | Near-certain — core behavior |
