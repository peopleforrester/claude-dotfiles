---
name: typescript-patterns
description: |
  TypeScript 5.x best practices, patterns, and idioms. Covers strict mode,
  branded types, discriminated unions, utility types, and Zod validation.
  Use when writing TypeScript or reviewing TS patterns.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - patterns
    - typescript
    - language
---

# TypeScript Patterns

Modern TypeScript 5.x patterns and best practices.

## Strict Configuration

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true
  }
}
```

## Type Safety Patterns

### Discriminated Unions
```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function divide(a: number, b: number): Result<number> {
  if (b === 0) return { ok: false, error: new Error('Division by zero') };
  return { ok: true, value: a / b };
}

const result = divide(10, 2);
if (result.ok) {
  console.log(result.value); // TypeScript narrows to number
}
```

### Branded Types (Prevent ID Mixing)
```typescript
type UserId = string & { readonly __brand: 'UserId' };
type OrderId = string & { readonly __brand: 'OrderId' };

const userId = 'u123' as UserId;
const orderId = 'o456' as OrderId;

function getUser(id: UserId) { /* ... */ }
getUser(userId);   // OK
getUser(orderId);  // Type error - can't mix IDs
```

### Exhaustive Matching
```typescript
type Shape = { kind: 'circle'; radius: number }
            | { kind: 'square'; side: number }
            | { kind: 'triangle'; base: number; height: number };

function area(shape: Shape): number {
  switch (shape.kind) {
    case 'circle': return Math.PI * shape.radius ** 2;
    case 'square': return shape.side ** 2;
    case 'triangle': return (shape.base * shape.height) / 2;
    default: {
      const _exhaustive: never = shape;
      throw new Error(`Unhandled shape: ${_exhaustive}`);
    }
  }
}
```

### Const Assertions
```typescript
const ROUTES = {
  home: '/',
  users: '/users',
  settings: '/settings',
} as const;

type Route = typeof ROUTES[keyof typeof ROUTES];
// Type: "/" | "/users" | "/settings"
```

## Utility Type Patterns

### Safe Partial Updates
```typescript
function updateUser(id: string, updates: Partial<Omit<User, 'id' | 'createdAt'>>) {
  // Can only update mutable fields
}
```

### Builder Pattern with Types
```typescript
type Builder<T, Built = {}> = {
  set<K extends keyof T>(key: K, value: T[K]): Builder<Omit<T, K>, Built & Pick<T, K>>;
  build(): Built extends T ? T : never;
};
```

## Runtime Validation (Zod)

```typescript
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1).max(100),
  email: z.string().email(),
  role: z.enum(['admin', 'user', 'viewer']),
});

type User = z.infer<typeof UserSchema>;

// Validate at runtime boundaries
function createUser(input: unknown): User {
  return UserSchema.parse(input);
}
```

## Async Patterns

### Type-Safe Fetch
```typescript
async function fetchJson<T>(url: string, schema: z.ZodSchema<T>): Promise<Result<T>> {
  try {
    const response = await fetch(url);
    if (!response.ok) {
      return { ok: false, error: new Error(`HTTP ${response.status}`) };
    }
    const data = await response.json();
    return { ok: true, value: schema.parse(data) };
  } catch (error) {
    return { ok: false, error: error instanceof Error ? error : new Error(String(error)) };
  }
}
```

## Checklist

- [ ] `strict: true` in tsconfig.json
- [ ] No `any` types (use `unknown` for untyped data)
- [ ] Discriminated unions for variant types
- [ ] Branded types for domain IDs
- [ ] Zod schemas at system boundaries
- [ ] `as const` for literal constants
- [ ] Exhaustive switch statements with `never` check
- [ ] Utility types (`Partial`, `Pick`, `Omit`) for derived types
