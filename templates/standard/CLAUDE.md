<!-- Tokens: ~1,400 (target: 1,500) | Lines: 78 | Compatibility: Claude Code 2.1+ -->
# Project Name

Brief description of what this project does and its primary purpose.

## Stack

- **Language**: TypeScript 5.x
- **Runtime**: Node.js 20+
- **Framework**: [e.g., Next.js 14, Express, Fastify]
- **Database**: [e.g., PostgreSQL 16, SQLite]
- **Package Manager**: npm

## Commands

```bash
npm run dev        # Start development server
npm run test       # Run test suite
npm run test:watch # Run tests in watch mode
npm run lint       # Lint code
npm run lint:fix   # Lint and auto-fix
npm run build      # Production build
npm run start      # Start production server
```

## Key Directories

```
src/
├── components/    # UI components (if frontend)
├── lib/           # Shared utilities and helpers
├── services/      # Business logic and external integrations
├── api/           # API routes or handlers
├── types/         # TypeScript type definitions
└── config/        # Configuration files

tests/
├── unit/          # Unit tests
├── integration/   # Integration tests
└── fixtures/      # Test data and mocks
```

## Code Standards

- Use TypeScript strict mode; avoid `any` types
- Prefer named exports over default exports
- Error messages should be user-friendly and actionable

## Architecture Decisions

- [Document non-obvious architectural choices]
- [Explain why certain patterns are used]
- [Note any trade-offs made]

## Gotchas

- [Project-specific warnings]
- [Things that break easily]
- [Non-obvious behaviors]
- [Environment-specific quirks]

## Dependencies

Key dependencies to understand:

- **[package-name]**: [Brief explanation of why it's used]
- **[package-name]**: [Brief explanation of why it's used]

## Environment Variables

Required environment variables (see `.env.example`):

- `DATABASE_URL`: Database connection string
- `API_KEY`: External API authentication

## Workflow

1. Create feature branch from `main`
2. Write tests for new functionality
3. Implement the feature
4. Ensure all tests pass
5. Submit PR for review

## Testing Strategy

- Unit tests for pure functions and utilities
- Integration tests for API endpoints
- Test files co-located with source: `*.test.ts`

## Additional Context

For detailed documentation, see:
- Architecture overview: `docs/architecture.md`
- API documentation: `docs/api.md`
- Contributing guide: `CONTRIBUTING.md`
