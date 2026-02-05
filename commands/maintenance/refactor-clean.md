---
description: Remove dead code, unused dependencies, and reduce complexity. Invokes the refactor-cleaner agent.
---

# /refactor-clean - Dead Code Removal

Invoke the **refactor-cleaner** agent to clean up the codebase.

## Usage

```
/refactor-clean                 # Full codebase scan
/refactor-clean src/            # Scan specific directory
/refactor-clean --deps          # Focus on unused dependencies
/refactor-clean --imports       # Focus on unused imports only
```

## What Gets Cleaned

1. **Dead Code** - Unused functions, variables, and exports
2. **Unused Dependencies** - Packages in package.json not imported anywhere
3. **Unused Imports** - Import statements with no references
4. **TODO/FIXME Audit** - Stale comments that should be resolved or tracked
5. **Complexity Hotspots** - Functions over 50 lines, files over 500 lines

## Safety Guarantees

- Tests must pass before any refactoring begins
- One change at a time with test verification
- Code is removed completely (never commented out)
- All callers are verified before removing functions
- Refactoring commits are kept separate from feature commits

## Output

```markdown
## Refactoring Report

### Dead Code Found
| Type | Location | Action |
|------|----------|--------|
| Unused function | file:line | Removed |
| Unused import | file:line | Removed |

### Metrics
- Dead code removed: X lines
- Dependencies cleaned: Y packages
- Complexity reduced: Z functions simplified
```

## When to Use

- After completing a feature (cleanup pass)
- Before major releases
- When onboarding new team members (reduce confusion)
- Periodically (monthly codebase hygiene)
