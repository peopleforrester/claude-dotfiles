---
description: Run comprehensive pre-PR verification loop. Checks build, types, lint, tests, security, and coverage.
---

# /verify - Pre-PR Verification Loop

Run a comprehensive quality check before creating a pull request.

## Usage

```
/verify                    # Full verification (all checks)
/verify quick              # Skip E2E and security scan
/verify fix                # Auto-fix lint and formatting issues
/verify pre-commit         # Checks relevant for commits only
```

## Verification Steps

Execute in this exact order. Stop on critical failures.

### 1. Build Check
```bash
npm run build || cargo build || go build ./... || python -m py_compile src/**/*.py
```

### 2. Type Check
```bash
npx tsc --noEmit || mypy src/ || cargo check
```

### 3. Lint Check
```bash
npm run lint || ruff check . || golangci-lint run || cargo clippy -- -D warnings
```

### 4. Unit Tests
```bash
npm test || pytest || go test ./... || cargo test
```

### 5. Integration Tests (skip with `quick`)
```bash
npm run test:integration
```

### 6. Security Scan (skip with `quick`)
```bash
npm audit --audit-level=high || pip-audit || cargo audit
```

### 7. Coverage Check
```bash
npm run test:coverage  # Target: 80%+
```

### 8. Console/Debug Audit
```bash
# Find leftover debug statements
grep -rn "console.log\|debugger\|print(" --include="*.ts" --include="*.py" src/
```

## Output Format

```
VERIFICATION REPORT
===================

Build:     [PASS/FAIL]
Types:     [PASS/FAIL] (X errors)
Lint:      [PASS/FAIL] (X warnings)
Tests:     [PASS/FAIL] (X/Y passed, Z% coverage)
Security:  [PASS/FAIL] (X vulnerabilities)
Debug:     [PASS/FAIL] (X statements found)

Ready for PR: [YES/NO]

Issues to Fix:
1. ...
```

## Fix Mode

With `/verify fix`, auto-fix where possible:
- `npm run lint:fix` or `ruff check --fix .`
- `npx prettier --write .` or `black .`
- `npm audit fix` (non-breaking only)
