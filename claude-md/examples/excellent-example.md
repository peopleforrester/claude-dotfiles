# Excellent CLAUDE.md Example

This is an annotated example of an excellent CLAUDE.md file. Comments explain why each section works well.

---

<!-- ✅ Token count in header - helps track budget -->
<!-- Tokens: ~1,350 (target: 1,500) | Lines: 72 | Compatibility: Claude Code 2.1+ -->

<!-- ✅ Clear project name and one-line description -->
# TaskFlow API

Backend API service for the TaskFlow project management application.

<!-- ✅ Stack section with specific versions - Claude knows exact tools to use -->
## Stack

- **Language**: TypeScript 5.4
- **Runtime**: Node.js 20 LTS
- **Framework**: Fastify 4.x
- **Database**: PostgreSQL 16 with Prisma
- **Cache**: Redis 7
- **Testing**: Vitest
- **Package Manager**: pnpm

<!-- ✅ Exact commands - no guessing needed -->
## Commands

```bash
pnpm dev              # Start with hot reload (port 3000)
pnpm test             # Run tests
pnpm test:watch       # Watch mode
pnpm test:coverage    # Coverage report
pnpm lint             # ESLint
pnpm typecheck        # tsc --noEmit
pnpm build            # Production build
pnpm db:migrate       # Run Prisma migrations
pnpm db:studio        # Open Prisma Studio
```

<!-- ✅ Concise directory overview - spatial orientation -->
## Key Directories

```
src/
├── routes/           # Fastify route handlers
├── services/         # Business logic
├── repositories/     # Database access (Prisma)
├── middleware/       # Auth, logging, errors
├── schemas/          # Zod validation schemas
└── types/            # TypeScript definitions

tests/
├── unit/             # Unit tests
├── integration/      # API tests
└── fixtures/         # Test data
```

<!-- ✅ Only 3 rules - things Claude can't infer from code -->
## Code Standards

- Zod schemas for all request/response validation
- Repository pattern: routes never call Prisma directly
- Error responses use RFC 7807 Problem Details format

<!-- ✅ Non-obvious decisions - explains "why" not "what" -->
## Architecture Decisions

- Fastify over Express for better TypeScript support and performance
- Redis for session storage and rate limiting (not in-memory)
- Soft deletes via `deletedAt` column, not hard deletes

<!-- ✅ Gotchas section - high ROI, prevents repeated mistakes -->
## Gotchas

- Prisma client regenerates on schema change - run `pnpm db:generate`
- Redis connection required even in development - use Docker
- JWT tokens expire in 15 minutes - use refresh token flow
- Rate limiter uses sliding window - 100 requests per minute per IP

<!-- ✅ Essential env vars only - not exhaustive list -->
## Environment Variables

Required (see `.env.example`):

```
DATABASE_URL=postgresql://...
REDIS_URL=redis://localhost:6379
JWT_SECRET=...
```

<!-- ✅ Brief testing strategy - what to test where -->
## Testing

- Unit: Services, utilities (mock repositories)
- Integration: Full request/response cycle
- Fixtures: `tests/fixtures/users.json` for test data

<!-- ✅ @ import for detailed docs - keeps CLAUDE.md lean -->
## References

See @docs/api-spec.md for endpoint documentation.

---

## Why This Example Works

### Token Efficiency (~1,350 tokens)

- **No wasted words**: Every line provides actionable information
- **No generic advice**: Nothing like "write clean code" or "add tests"
- **Specific versions**: "TypeScript 5.4" not just "TypeScript"

### High-Value Sections

| Section | Why It's Valuable |
|---------|-------------------|
| Commands | Most-used info; exact commands with comments |
| Key Directories | Spatial orientation for large codebase |
| Code Standards | Only 3 rules Claude can't infer |
| Gotchas | Prevents repeated mistakes; huge ROI |

### What's NOT Included (Intentionally)

- ❌ "Please write tests" - obvious, wastes tokens
- ❌ "Use meaningful variable names" - linter handles this
- ❌ "Keep functions small" - too generic
- ❌ Long prose paragraphs - hard to scan
- ❌ Complete API documentation - use @ imports instead

### Formatting Best Practices

- Headers create scannable structure
- Code blocks for commands and file paths
- Bullet points (not paragraphs) for lists
- Tables for structured comparisons
