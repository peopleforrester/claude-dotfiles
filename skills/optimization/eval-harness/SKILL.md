---
name: eval-harness
description: |
  Structured evaluation framework for measuring code quality across
  multiple dimensions. Provides repeatable, scored assessments with
  evidence-based ratings.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags: [quality, evaluation, metrics, verification]
---

# Evaluation Harness

Structured framework for evaluating code quality with repeatable,
evidence-based scoring.

## Evaluation Dimensions

### Default Rubric

| Dimension | Weight | Description |
|-----------|--------|-------------|
| Correctness | 30% | Tests pass, logic correct, edge cases handled |
| Security | 20% | OWASP compliance, input validation, secrets |
| Performance | 15% | Efficient queries, algorithms, caching |
| Maintainability | 15% | Readability, modularity, naming |
| Testing | 10% | Coverage, test quality, isolation |
| Documentation | 10% | Accuracy, completeness, examples |

### Scoring Scale

| Score | Label | Criteria |
|-------|-------|----------|
| 5 | Excellent | Exceeds standards, exemplary |
| 4 | Good | Meets all standards |
| 3 | Acceptable | Meets minimum, room for improvement |
| 2 | Below Standard | Missing key requirements |
| 1 | Poor | Significant issues, needs rework |

## Evaluation Process

### 1. Evidence Collection
For each dimension, gather concrete evidence:

```markdown
#### Correctness Evidence
- Tests: 142 passing, 0 failing
- Edge cases: null handling verified in auth module
- Regression: no known regressions
- Score: 4/5 (missing boundary value tests for pagination)
```

### 2. Scoring
Apply scores with justification:

```markdown
| Dimension | Score | Evidence |
|-----------|-------|----------|
| Correctness | 4/5 | Tests pass, missing pagination edge cases |
| Security | 3/5 | Input validation present, missing rate limiting |
| Performance | 4/5 | Queries optimized, indexes present |
| Maintainability | 5/5 | Clean architecture, clear naming |
| Testing | 3/5 | 72% coverage, below 80% target |
| Documentation | 4/5 | API docs current, missing setup guide update |
```

### 3. Weighted Score Calculation
```
Total = (4×0.30) + (3×0.20) + (4×0.15) + (5×0.15) + (3×0.10) + (4×0.10)
      = 1.20 + 0.60 + 0.60 + 0.75 + 0.30 + 0.40
      = 3.85 / 5.0
```

### 4. Verdict

| Range | Verdict | Action |
|-------|---------|--------|
| 4.0-5.0 | SHIP IT | Ready for production |
| 3.0-3.9 | IMPROVE | Address findings before shipping |
| < 3.0 | REWORK | Significant issues need resolution |

## Custom Rubrics

Define project-specific rubrics:

```yaml
rubric:
  - name: API Design
    weight: 25%
    checks:
      - RESTful conventions followed
      - Consistent error response format
      - Pagination on list endpoints
  - name: Database
    weight: 25%
    checks:
      - Migrations are reversible
      - Indexes cover common queries
      - No N+1 query patterns
```

## Integration

Use with:
- `/eval` command for on-demand evaluation
- `/verify` command as part of pre-PR checks
- CI pipeline as automated quality gate
