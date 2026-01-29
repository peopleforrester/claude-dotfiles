<!-- Tokens: ~1,900 (target: 2,000) | Lines: 98 | Compatibility: Claude Code 2.1+ -->
# Project Name

Comprehensive description of what this project does, its primary purpose,
and the problem it solves.

## Stack

- **Language**: TypeScript 5.x (strict mode)
- **Runtime**: Node.js 20+ LTS
- **Framework**: Next.js 14 (App Router)
- **Database**: PostgreSQL 16 with Prisma ORM
- **Cache**: Redis 7+
- **Package Manager**: pnpm
- **Testing**: Vitest + Playwright

## Commands

```bash
pnpm dev           # Start development server (port 3000)
pnpm test          # Run unit tests
pnpm test:watch    # Run tests in watch mode
pnpm test:e2e      # Run Playwright e2e tests
pnpm lint          # ESLint + Prettier check
pnpm lint:fix      # Auto-fix linting issues
pnpm typecheck     # TypeScript type checking
pnpm build         # Production build
pnpm start         # Start production server
pnpm db:migrate    # Run database migrations
pnpm db:seed       # Seed database with test data
pnpm db:studio     # Open Prisma Studio
```

## Key Directories

```
src/
├── app/              # Next.js App Router pages and layouts
├── components/
│   ├── ui/           # Reusable UI primitives
│   └── features/     # Feature-specific components
├── lib/
│   ├── db/           # Database client and utilities
│   ├── api/          # API client and fetchers
│   └── utils/        # General utilities
├── services/         # Business logic layer
├── hooks/            # Custom React hooks
├── types/            # TypeScript type definitions
└── config/           # Runtime configuration

tests/
├── unit/             # Unit tests (*.test.ts)
├── integration/      # API integration tests
└── e2e/              # Playwright end-to-end tests

prisma/
├── schema.prisma     # Database schema
└── migrations/       # Migration history
```

## Code Standards

- TypeScript strict mode required; never use `any`
- Prefer named exports; default exports only for pages
- All async functions must have error handling
- Components use composition over inheritance

## Architecture Decisions

- Server Components by default; Client Components only when needed
- API routes use tRPC for type-safe client-server communication
- Database queries go through service layer, never directly in components
- Feature flags managed via environment variables

## Gotchas

- Hot reload breaks if you modify `middleware.ts` - restart dev server
- Prisma client regenerates on schema change - run `pnpm db:generate`
- Redis connection pooling: max 10 connections in development
- E2E tests require `pnpm db:seed` to run first

## Environment Variables

Required (see `.env.example`):

```
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
NEXTAUTH_SECRET=...
NEXTAUTH_URL=http://localhost:3000
```

## Workflow

1. Create feature branch: `git checkout -b feat/description`
2. Write failing tests first (TDD)
3. Implement minimal code to pass tests
4. Refactor while keeping tests green
5. Run full test suite: `pnpm test && pnpm test:e2e`
6. Submit PR with description of changes

## Testing Strategy

- Unit: Pure functions, utilities, hooks
- Integration: API routes, database operations
- E2E: Critical user journeys only
- Coverage target: 80% for business logic

## Performance Budgets

- First Contentful Paint: < 1.5s
- Largest Contentful Paint: < 2.5s
- Bundle size (JS): < 200KB gzipped

## Additional Context

- Architecture: `@docs/architecture.md`
- API Reference: `@docs/api.md`
- Database Schema: `@docs/database.md`
