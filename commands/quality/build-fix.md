---
description: Diagnose and fix build errors systematically. Invokes the build-resolver agent for type errors, dependency conflicts, and CI failures.
---

# /build-fix - Build Error Resolution

Invoke the **build-resolver** agent to diagnose and fix build failures.

## Usage

```
/build-fix                      # Fix current build errors
/build-fix --ci                 # Diagnose CI pipeline failure
/build-fix --types              # Focus on type errors only
/build-fix --deps               # Focus on dependency issues
```

## Process

1. **Classify** the error (syntax, type, import, dependency, runtime, config)
2. **Diagnose** the root cause (not just symptoms)
3. **Fix** at the source (avoid `@ts-ignore`, `as any`, or workarounds)
4. **Verify** with full build + test cycle
5. **Document** the fix for future reference

## Common Error Categories

| Category | Example | Typical Fix |
|----------|---------|-------------|
| Type error | `Property 'x' does not exist` | Fix type definition or usage |
| Import error | `Cannot find module` | Fix path, check exports |
| Dependency | `ERESOLVE could not resolve` | Update versions, add overrides |
| Config | `Cannot find tsconfig.json` | Fix path, verify config |
| Runtime | `Test timeout exceeded` | Fix async handling, increase timeout |

## Output

```markdown
## Build Fix Report

### Error Summary
[Concise description of the build error]

### Root Cause
[What caused the error and why]

### Fix Applied
[Diff showing the change]

### Verification
- [x] Local build passes
- [x] Tests pass
- [ ] CI pipeline passes
```
