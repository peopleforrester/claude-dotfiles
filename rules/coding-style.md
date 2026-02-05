<!-- Tokens: ~700 | Lines: 95 | Compatibility: Claude Code 2.1+ -->
# Coding Style Rules

Constraints for writing maintainable, readable, and consistent code.

## Immutability

### Always
- Prefer `const` over `let`; never use `var` in JavaScript/TypeScript
- Return new objects/arrays rather than mutating existing ones
- Use spread operators (`...`) for shallow copies and updates
- Treat function parameters as read-only

### Pattern
```typescript
// Correct: Create new object
const updated = { ...user, name: newName };

// Incorrect: Mutate in place
user.name = newName;
```

## File Organization

### Always
- One concept per file (single responsibility principle)
- Maximum 300 lines per file; split if larger
- Co-locate tests with source files (`feature.ts` + `feature.test.ts`)
- Group related files in feature directories

### Directory Pattern
```
feature/
├── feature.ts           # Core logic
├── feature.test.ts      # Tests
├── feature.types.ts     # Type definitions
└── index.ts             # Public exports
```

### Size Limits
| Unit | Target | Maximum |
|------|--------|---------|
| Function | < 30 lines | 50 lines |
| File | < 300 lines | 500 lines |
| Module | < 10 files | 20 files |
| Nesting depth | < 3 levels | 4 levels |

## Error Handling

### Always
- Use typed errors with error codes for programmatic handling
- Include context (correlation ID, operation name) in error logs
- Return errors for expected failures; throw for unexpected/unrecoverable
- Handle all promise rejections and async errors

### Pattern
```typescript
type Result<T, E = AppError> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function divide(a: number, b: number): Result<number> {
  if (b === 0) return { ok: false, error: { code: 'DIVISION_BY_ZERO', message: 'Cannot divide by zero' } };
  return { ok: true, value: a / b };
}
```

## Naming Conventions

### Always
- Functions: verb + noun (`calculateTotal`, `fetchUser`, `validateInput`)
- Booleans: `is`/`has`/`can`/`should` prefix (`isValid`, `hasPermission`)
- Constants: SCREAMING_SNAKE_CASE (`MAX_RETRIES`, `DEFAULT_TIMEOUT`)
- Types/Classes: PascalCase (`UserAccount`, `OrderService`)
- Files: kebab-case (`user-account.ts`, `order-service.py`)

### Never
- Single-letter variable names except loop indices (`i`, `j`, `k`)
- Abbreviations unless universally understood (`cfg` -> `configuration`)
- Hungarian notation (`strName`, `nCount`, `bIsValid`)
- Generic names without context (`data`, `info`, `temp`, `result`)

## Code Quality Checklist

Before marking any work complete:
- [ ] Functions are small, focused, and well-named
- [ ] No code duplication (DRY, but avoid premature abstraction)
- [ ] Proper error handling at every level
- [ ] No debug statements left in code (`console.log`, `print`, `debugger`)
- [ ] No hardcoded magic numbers or strings (use named constants)
- [ ] No deeply nested conditionals (use early returns or guard clauses)
- [ ] Public APIs have type annotations or documentation
- [ ] Edge cases are handled (null, empty, boundary values)
