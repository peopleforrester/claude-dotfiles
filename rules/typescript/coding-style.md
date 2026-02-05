<!-- Tokens: ~600 | Lines: 80 | Compatibility: Claude Code 2.1+ -->
# TypeScript Coding Style Rules

Extends `common/coding-style.md` with TypeScript-specific constraints.

## Always

### Type Safety
- Enable `strict: true` in tsconfig.json (all strict checks)
- Use explicit return types on exported functions
- Prefer `unknown` over `any` — narrow with type guards
- Use branded types for domain identifiers (`type UserId = string & { __brand: 'UserId' }`)
- Use discriminated unions for state variants

### Patterns
```typescript
// PREFER: Discriminated unions over boolean flags
type Result<T> =
  | { success: true; data: T }
  | { success: false; error: Error };

// PREFER: const assertions for literal types
const ROLES = ['admin', 'user', 'guest'] as const;
type Role = typeof ROLES[number];

// PREFER: Zod for runtime validation
const UserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
});
type User = z.infer<typeof UserSchema>;
```

### Imports
- Use `type` imports for type-only imports (`import type { User } from './types'`)
- Group: Node built-ins, external packages, internal modules, relative imports
- Use path aliases (`@/`) over deep relative paths (`../../../`)

### File Organization
- One component/class/module per file (200-400 lines target)
- Co-locate tests with source (`Component.tsx` / `Component.test.tsx`)
- Export types from a central `types.ts` or barrel `index.ts`

## Never

- Use `any` without a `// eslint-disable` comment explaining why
- Use `as` type assertions when a type guard is possible
- Use `enum` — prefer `as const` objects or union types
- Disable TypeScript checks with `@ts-ignore` (use `@ts-expect-error` with reason)
- Use `Function` type — use specific function signatures
- Mix CommonJS (`require`) and ESM (`import`) in the same project
