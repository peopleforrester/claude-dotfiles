---
name: continuous-learning
description: |
  Patterns for Claude Code to learn from project context and improve over time.
  Covers CLAUDE.md refinement, error pattern recognition, codebase conventions
  discovery, and feedback incorporation. Use to optimize Claude Code's
  effectiveness across sessions.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - optimization
    - learning
    - workflow
---

# Continuous Learning

Strategies for Claude Code to build and maintain project knowledge across sessions.

## Knowledge Sources

### 1. CLAUDE.md as Living Memory

CLAUDE.md is the primary mechanism for persisting knowledge between sessions.
Update it when you discover project-specific patterns.

```markdown
## Discovered Patterns

### Error Handling
- This project uses Result<T, AppError> everywhere — never throw
- All API errors return { error: string, code: string } format

### Testing
- Integration tests require Docker: `docker compose up -d` first
- Test DB resets between suites via `beforeAll` in conftest

### Gotchas
- The `user.status` field is a string enum, not a boolean
- Migrations must be generated with `--name` flag or CI rejects them
```

### 2. Convention Discovery

Before writing code, scan the codebase for patterns:

```
Step 1: Check imports     → How does this project import modules?
Step 2: Check error style → Custom errors? Result types? Try/catch?
Step 3: Check naming      → camelCase? snake_case? What prefixes?
Step 4: Check test style  → describe/it? test()? What assertions?
Step 5: Check structure    → Feature folders? Layer folders? Flat?
```

**Match what exists.** Don't introduce a new pattern unless asked.

### 3. Git History as Context

Recent commits reveal current development focus:

```bash
# What changed recently?
git log --oneline -20

# Who changed this file and why?
git log --oneline -5 -- path/to/file.ts

# What does the team's commit style look like?
git log --format="%s" -10
```

## Error Pattern Recognition

### Build Recurring Error Log

When the same error appears multiple times, document the fix:

```markdown
## Common Errors

### "Module not found: @/components/..."
**Cause**: Path alias not configured in tsconfig
**Fix**: Add `"@/*": ["./src/*"]` to tsconfig paths

### "ECONNREFUSED 127.0.0.1:5432"
**Cause**: PostgreSQL not running
**Fix**: `docker compose up -d postgres`
```

### Resolution Strategy

```
1. Search CLAUDE.md for known error     → Apply documented fix
2. Search git log for similar errors    → Check how it was fixed before
3. Search codebase for error message    → Find error origin
4. Search dependencies for breaking     → Check changelogs
5. Minimal reproduction                 → Isolate the problem
```

## Feedback Incorporation

### When the User Corrects You

If the user says "we don't do it that way" or corrects your approach:

1. **Understand** — Ask why if the reason isn't clear
2. **Apply** — Fix the current code immediately
3. **Record** — Add the convention to CLAUDE.md for future sessions
4. **Verify** — Confirm the updated approach matches expectations

### When Tests Reveal Patterns

```
Test failure → Read full output → Identify pattern → Document in CLAUDE.md
```

Examples of test-revealed patterns:
- "Tests expect ISO 8601 dates, not Unix timestamps"
- "API tests need auth header: `Authorization: Bearer test-token`"
- "Snapshot tests must be updated with `--update` flag"

## Session Handoff

### Start of Session Checklist

```
1. Read CLAUDE.md                    → Understand project context
2. Read recent git log               → Understand current work
3. Check for open issues/PRs         → Understand priorities
4. Check CI status                   → Know if builds are passing
```

### End of Session Updates

Before the session ends, consider updating CLAUDE.md with:

- New gotchas discovered during this session
- Patterns that were unclear and are now understood
- Commands that were useful (build, test, deploy)
- Environment setup steps that were non-obvious

## Anti-Patterns

| Anti-Pattern | Better Approach |
|--------------|-----------------|
| Guessing project conventions | Scan 3-5 existing files first |
| Ignoring test failures | Read full output, fix root cause |
| Repeating the same mistake | Document fix in CLAUDE.md |
| Overloading CLAUDE.md | Keep under 2000 tokens, be concise |
| Assuming stack/tools | Check package.json, Cargo.toml, etc. |

## Checklist

- [ ] CLAUDE.md reviewed at session start
- [ ] Codebase conventions discovered before writing code
- [ ] Errors documented with cause and fix
- [ ] User corrections recorded in CLAUDE.md
- [ ] Session discoveries summarized before handoff
