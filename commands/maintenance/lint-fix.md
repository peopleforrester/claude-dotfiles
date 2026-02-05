---
description: Fix linting errors systematically across the codebase
---

# /lint-fix - Iterative Lint Fixing

Fix linting errors systematically across the codebase.

## Usage

```
/lint-fix                    # Fix all linting errors
/lint-fix src/               # Fix errors in specific directory
/lint-fix --check            # Check without fixing (dry run)
```

## Process

### 1. Run Initial Lint Check

Get overview of all issues:

```bash
# JavaScript/TypeScript
npm run lint
# or
npx eslint . --format=compact

# Python
ruff check .
# or
flake8 .

# Rust
cargo clippy

# Go
golangci-lint run
```

### 2. Categorize Issues

Group errors by type:

| Category | Priority | Auto-fixable |
|----------|----------|--------------|
| Syntax errors | Critical | No |
| Type errors | High | No |
| Formatting | Low | Yes |
| Best practices | Medium | Sometimes |
| Code style | Low | Yes |

### 3. Auto-Fix What's Possible

Run auto-fix commands:

```bash
# ESLint
npx eslint . --fix

# Prettier
npx prettier --write .

# Python (ruff)
ruff check . --fix
ruff format .

# Python (black)
black .

# Rust
cargo fmt
cargo clippy --fix

# Go
gofmt -w .
golangci-lint run --fix
```

### 4. Handle Remaining Errors

For errors that can't be auto-fixed:

```markdown
## Manual Fixes Required

### Error 1: [Rule name]
**File**: src/components/Button.tsx:15
**Issue**: [Description]
**Fix**:
```typescript
// Before
const Button = (props) => ...

// After
const Button: React.FC<ButtonProps> = (props) => ...
```

### Error 2: [Rule name]
...
```

### 5. Verify Fixes

After all fixes:

```bash
# Run lint again - should be clean
npm run lint

# Run tests to ensure fixes didn't break anything
npm test

# Run type check
npm run typecheck
```

## Common Lint Rules & Fixes

### ESLint

| Rule | Issue | Fix |
|------|-------|-----|
| `no-unused-vars` | Unused variable | Remove or use it |
| `prefer-const` | `let` for never-reassigned | Change to `const` |
| `no-console` | Console statement | Remove or disable rule |
| `@typescript-eslint/no-explicit-any` | Using `any` | Add proper types |

### Ruff / Flake8

| Rule | Issue | Fix |
|------|-------|-----|
| E501 | Line too long | Break line or disable |
| F401 | Unused import | Remove import |
| F841 | Unused variable | Remove or prefix with `_` |
| E302 | Missing blank lines | Add blank lines |

### Clippy

| Rule | Issue | Fix |
|------|-------|-----|
| `needless_return` | Explicit return | Remove `return` keyword |
| `clone_on_copy` | Cloning Copy type | Remove `.clone()` |
| `redundant_closure` | Unnecessary closure | Use function directly |

## Batch Processing Strategy

For large codebases:

```markdown
## Lint Fix Plan

### Phase 1: Auto-fixable (Low risk)
- [ ] Run prettier/formatter
- [ ] Run eslint --fix
- [ ] Commit: "style: auto-fix formatting"

### Phase 2: Safe manual fixes
- [ ] Fix unused imports
- [ ] Fix unused variables
- [ ] Commit: "refactor: remove unused code"

### Phase 3: Type improvements
- [ ] Replace `any` with proper types
- [ ] Add missing type annotations
- [ ] Commit: "types: improve type safety"

### Phase 4: Logic fixes
- [ ] Fix potential bugs (eslint warnings)
- [ ] Address security concerns
- [ ] Commit: "fix: address lint warnings"
```

## Suppressing Warnings

When a rule shouldn't apply:

```typescript
// Single line
// eslint-disable-next-line no-console
console.log('debug');

// Block
/* eslint-disable no-console */
console.log('start');
console.log('end');
/* eslint-enable no-console */

// File level (at top)
/* eslint-disable no-console */
```

```python
# Ruff / Flake8
x = 1  # noqa: F841
```

## Tips

- Fix one category at a time
- Commit after each category
- Run tests frequently
- Don't suppress warnings without good reason
- Update lint config if rules don't fit project
