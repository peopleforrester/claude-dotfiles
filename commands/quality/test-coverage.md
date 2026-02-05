---
description: Analyze and report test coverage with improvement suggestions
---

# /test-coverage

Analyze test coverage for the project and identify gaps that need tests.

## Arguments
- `$ARGUMENTS` — Optional path to analyze (defaults to entire project)

## Process

### 1. Run Coverage Analysis

**JavaScript/TypeScript:**
```bash
npx vitest run --coverage 2>&1 || npx jest --coverage 2>&1
```

**Python:**
```bash
pytest --cov=src --cov-report=term-missing 2>&1
```

**Go:**
```bash
go test -cover -coverprofile=coverage.out ./... 2>&1
go tool cover -func=coverage.out
```

### 2. Identify Gaps
For each file with coverage below 80%:
- List uncovered lines/branches
- Categorize: business logic, error handling, edge cases, utilities
- Prioritize by risk (business logic > error handling > edge cases)

### 3. Generate Report

```markdown
## Coverage Report

### Summary
| Metric | Value | Target |
|--------|-------|--------|
| Line Coverage | X% | 80% |
| Branch Coverage | X% | 75% |
| Function Coverage | X% | 90% |

### Files Below Target
| File | Coverage | Gap | Priority |
|------|----------|-----|----------|
| src/auth.ts | 45% | 35% | HIGH |
| src/utils.ts | 72% | 8% | MEDIUM |

### Suggested Tests
1. **HIGH** `src/auth.ts` - Missing tests for:
   - Token expiration handling
   - Invalid credential scenarios
   - Rate limiting edge cases

2. **MEDIUM** `src/utils.ts` - Missing tests for:
   - Empty input handling
   - Unicode edge cases
```

### 4. Quick Mode
With `--quick` argument, only show the summary table and files below target.
