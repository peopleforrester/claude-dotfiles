---
name: update-docs
description: Update documentation to match current code. Detects drift between docs and implementation. Invokes the doc-updater agent.
user-invocable: true
---
# /update-docs - Documentation Update

Invoke the **doc-updater** agent to sync documentation with code changes.

## Usage

```
/update-docs                    # Full documentation audit
/update-docs README.md          # Update specific file
/update-docs --api              # Focus on API documentation
/update-docs --changelog        # Update CHANGELOG only
```

## What Gets Checked

1. **README.md** - Installation steps, usage examples, env vars
2. **API Documentation** - Endpoints, parameters, responses
3. **Inline Docs** - JSDoc, docstrings, rustdoc accuracy
4. **CHANGELOG** - New entries for recent changes
5. **Architecture Docs** - Diagrams and decisions match reality

## Documentation Drift Detection

The agent compares:
- Recently changed source files vs documentation
- Public API signatures vs documented signatures
- Environment variables in code vs documented variables
- Dependencies in package.json vs documented requirements

## Output

```markdown
## Documentation Update Report

### Changes Made
| File | Section | Change |
|------|---------|--------|
| README.md | Setup | Updated Node version |
| docs/api.md | /users | Added new parameter |

### Drift Detected
- [File]: [What needs updating]

### Suggestions
- [Documentation improvement idea]
```

## When to Use

- After completing a feature
- Before creating a release
- When documentation feels outdated
- After refactoring that changes APIs
