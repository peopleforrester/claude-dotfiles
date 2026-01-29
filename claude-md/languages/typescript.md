<!-- Tokens: ~1,400 (target: 1,500) | Lines: 78 | Compatibility: Claude Code 2.1+ -->
# TypeScript Project

A TypeScript application with modern tooling and strict type safety.

## Stack

- **Language**: TypeScript 5.x (strict mode)
- **Runtime**: Node.js 20+ LTS
- **Package Manager**: pnpm (preferred) or npm
- **Testing**: Vitest
- **Linting**: ESLint with @typescript-eslint
- **Formatting**: Prettier

## Commands

```bash
pnpm dev              # Start development (watch mode)
pnpm build            # Compile TypeScript to JavaScript
pnpm start            # Run compiled output
pnpm test             # Run tests
pnpm test:watch       # Run tests in watch mode
pnpm test:coverage    # Run with coverage report
pnpm lint             # ESLint check
pnpm lint:fix         # ESLint auto-fix
pnpm format           # Prettier format
pnpm typecheck        # tsc --noEmit
```

## Key Directories

```
src/
├── index.ts          # Application entry point
├── config/           # Configuration and environment
├── types/            # TypeScript type definitions
├── lib/              # Core utilities and helpers
├── services/         # Business logic layer
└── utils/            # General utilities

tests/
├── setup.ts          # Test configuration
├── unit/             # Unit tests (*.test.ts)
└── integration/      # Integration tests
```

## Code Standards

- Strict TypeScript: no `any`, no implicit any
- Prefer `interface` for object shapes, `type` for unions/aliases
- Named exports over default exports
- Async/await over raw promises

## Architecture Decisions

- Zod for runtime validation matching TypeScript types
- Dependency injection via factory functions
- Error handling with custom error classes extending Error

## Gotchas

- `tsconfig.json` paths require corresponding entries in bundler config
- ESM modules: use `.js` extension in imports even for `.ts` files
- Vitest needs `globals: true` in config for Jest-like syntax
- `pnpm` hoists differently - check `node_modules/.pnpm`

## Dependencies

Key packages in `package.json`:

- **zod**: Runtime type validation
- **tsx**: TypeScript execution without compilation
- **tsup**: Fast TypeScript bundler

## Environment Variables

Required (see `.env.example`):

```
NODE_ENV=development
LOG_LEVEL=debug
API_URL=http://localhost:3000
```

## Testing Strategy

- Unit tests: Pure functions, utilities, type guards
- Integration tests: API calls, database operations
- Test files co-located: `foo.ts` → `foo.test.ts`
- Use `vi.mock()` for module mocking

## TypeScript Configuration

Key `tsconfig.json` settings:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  }
}
```
