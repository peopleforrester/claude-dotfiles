---
description: Evaluate code or implementation against specific criteria
---

# /eval

Evaluate the current implementation against defined criteria, standards,
or a rubric. Produces a structured assessment with scores.

## Arguments
- `$ARGUMENTS` — Criteria to evaluate against, or "default" for standard quality gate

## Default Criteria

| Category | Weight | Checks |
|----------|--------|--------|
| Correctness | 30% | Tests pass, edge cases handled, no regressions |
| Security | 20% | OWASP checks, input validation, secrets management |
| Performance | 15% | No N+1 queries, efficient algorithms, caching |
| Maintainability | 15% | Readability, modularity, naming clarity |
| Testing | 10% | Coverage ≥80%, edge cases, test quality |
| Documentation | 10% | API docs current, README accurate, comments useful |

## Process

### 1. Gather Evidence
For each category, collect evidence:
- Run tests and capture results
- Run linters and type checkers
- Review code changes
- Check documentation accuracy

### 2. Score Each Category
Rate each category: 1 (Poor) to 5 (Excellent)

### 3. Generate Report

```markdown
## Evaluation Report

### Overall Score: X.X / 5.0

| Category | Score | Weight | Weighted |
|----------|-------|--------|----------|
| Correctness | 4/5 | 30% | 1.20 |
| Security | 3/5 | 20% | 0.60 |
| Performance | 4/5 | 15% | 0.60 |
| Maintainability | 5/5 | 15% | 0.75 |
| Testing | 3/5 | 10% | 0.30 |
| Documentation | 4/5 | 10% | 0.40 |
| **Total** | | | **3.85** |

### Detailed Findings
[Per-category evidence and recommendations]

### Verdict
**SHIP IT** (≥4.0) | **IMPROVE** (3.0-3.9) | **REWORK** (<3.0)
```

## Custom Criteria
When `$ARGUMENTS` specifies custom criteria, use those instead of defaults.
Format each criterion as: `name: description (weight%)`.
