---
name: verification-loop
description: |
  Pre-PR quality verification workflow. Runs build, type-check, lint, test,
  security scan, and coverage analysis in sequence. Stops on first failure
  and reports actionable fixes. Use before creating pull requests.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - workflow
    - quality
    - verification
---

# Verification Loop

Systematic pre-PR quality gate that catches issues before code review.

## The Loop

Run each step in order. Stop on first failure, fix, then restart from step 1.

```
┌─────────────────────────────────────────┐
│  1. Build        → Compiles cleanly?    │
│  2. Type Check   → Types are sound?     │
│  3. Lint         → Style rules pass?    │
│  4. Unit Tests   → Logic is correct?    │
│  5. Integration  → Systems work together│
│  6. Security     → No vulnerabilities?  │
│  7. Coverage     → Meets thresholds?    │
│  8. Debug Audit  → No leftover debug?   │
└─────────────────────────────────────────┘
         ↑  Fix & restart on failure  ↓
```

## Step Commands by Stack

### JavaScript / TypeScript
```bash
# 1. Build
npm run build        # or: tsc --noEmit

# 2. Type check
npx tsc --noEmit     # TypeScript only

# 3. Lint
npx eslint . --max-warnings 0
npx prettier --check .

# 4. Unit tests
npx vitest run       # or: npx jest

# 5. Integration tests
npx vitest run --config vitest.integration.config.ts

# 6. Security
npm audit --audit-level=high
npx eslint . --rule 'no-eval: error'

# 7. Coverage
npx vitest run --coverage  # Target: 80% lines

# 8. Debug audit
grep -rn "console\.log\|debugger\|TODO.*FIXME" src/ --include="*.ts" --include="*.tsx"
```

### Python
```bash
# 1. Build (syntax check)
python -m py_compile main.py

# 2. Type check
mypy src/ --strict

# 3. Lint
ruff check src/
ruff format --check src/

# 4. Unit tests
pytest tests/unit/ -v

# 5. Integration tests
pytest tests/integration/ -v

# 6. Security
pip-audit
bandit -r src/ -ll

# 7. Coverage
pytest --cov=src --cov-report=term-missing --cov-fail-under=80

# 8. Debug audit
grep -rn "breakpoint()\|pdb\|print(" src/ --include="*.py"
```

### Go
```bash
# 1. Build
go build ./...

# 2. Type check (included in build)
go vet ./...

# 3. Lint
golangci-lint run

# 4. Unit tests
go test ./... -race -count=1

# 5. Integration tests
go test ./... -tags=integration -race

# 6. Security
govulncheck ./...

# 7. Coverage
go test ./... -coverprofile=coverage.out -covermode=atomic
go tool cover -func=coverage.out  # Target: 80%

# 8. Debug audit
grep -rn "fmt\.Print\|log\.Print" . --include="*.go" | grep -v "_test.go"
```

### Rust
```bash
# 1. Build
cargo build

# 2. Type check
cargo check

# 3. Lint
cargo clippy -- -D warnings
cargo fmt -- --check

# 4. Unit tests
cargo test

# 5. Integration tests
cargo test --test '*'

# 6. Security
cargo audit

# 7. Coverage
cargo tarpaulin --out Lcov  # Target: 80%

# 8. Debug audit
grep -rn "dbg!\|println!\|todo!\|unimplemented!" src/ --include="*.rs"
```

## Failure Response Protocol

When a step fails:

1. **Read the error** — full output, not just the first line
2. **Identify root cause** — is it this change or pre-existing?
3. **Fix minimally** — smallest change to resolve the issue
4. **Restart from step 1** — earlier fixes may introduce regressions

## Coverage Thresholds

| Code Category | Minimum |
|---------------|---------|
| Business logic | 80% |
| API handlers | 70% |
| Utility functions | 90% |
| Security-critical | 100% |
| Generated code | Excluded |

## Checklist

- [ ] All 8 steps pass in sequence
- [ ] No skipped steps
- [ ] Coverage meets thresholds
- [ ] No debug/console statements in production code
- [ ] No `TODO` or `FIXME` without linked issue
- [ ] CI pipeline matches local verification
