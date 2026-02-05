---
description: Comprehensive code review for quality, security, and maintainability. Invokes the code-reviewer agent.
---

# /code-review - Comprehensive Code Review

Invoke the **code-reviewer** agent to perform a thorough code review.

## Usage

```
/code-review                    # Review staged/recent changes
/code-review src/auth/          # Review specific directory
/code-review --pr               # Review current PR diff
/code-review --commit HEAD~3    # Review last 3 commits
```

## Review Dimensions

1. **Correctness** - Does it work? Edge cases handled?
2. **Security** - No secrets, inputs validated, auth checked?
3. **Performance** - Efficient queries, no N+1, caching used?
4. **Maintainability** - Readable, focused, no duplication?
5. **Testing** - Tests cover changes? Edge cases tested?
6. **Style** - Follows conventions? No debug code?

## Severity Levels

| Level | Meaning | Action |
|-------|---------|--------|
| CRITICAL | Must fix before merge | Blocks approval |
| WARNING | Should fix before merge | Strongly recommended |
| SUGGESTION | Nice to have improvement | Optional |
| QUESTION | Need clarification | Discussion needed |
| PRAISE | Highlight good work | Recognition |

## Output

Produces a structured review with:
- Summary assessment
- Issues organized by severity
- Specific code suggestions with diffs
- Verdict: APPROVE / REQUEST CHANGES / NEEDS DISCUSSION
