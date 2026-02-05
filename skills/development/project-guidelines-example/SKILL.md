---
name: project-guidelines-example
description: |
  Reference template for creating project-specific CLAUDE.md files. Shows
  how to structure project guidelines with stack info, commands, directory
  structure, code standards, and gotchas sections for optimal Claude usage.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - guidelines
    - template
    - project-setup
    - documentation
---

# Project Guidelines Example

A reference for crafting effective project-level CLAUDE.md files.

## Template Structure

Every CLAUDE.md should contain these sections in order:

```markdown
<!-- Tokens: ~X | Lines: Y | Compatibility: Claude Code 2.1+ -->
# Project Name

Brief one-line description of what this project does.

## Stack
## Commands
## Key Directories
## Code Standards
## Gotchas
```

## Section: Stack

Define the technology choices upfront so Claude knows the ecosystem.

```markdown
## Stack

- **Language**: TypeScript 5.x (strict mode)
- **Runtime**: Node.js 20 LTS
- **Framework**: Next.js 14 (App Router)
- **Database**: PostgreSQL 16 via Prisma ORM
- **Testing**: Vitest + Testing Library + Playwright
- **Package Manager**: pnpm
- **Deployment**: Vercel (production), Railway (staging)
```

Keep it concise. List only primary technologies, not every dependency.

## Section: Commands

List the commands Claude will need most often.

```markdown
## Commands

| Command | Purpose |
|---------|---------|
| `pnpm dev` | Start development server |
| `pnpm test` | Run unit tests |
| `pnpm test:e2e` | Run Playwright E2E tests |
| `pnpm lint` | Lint with ESLint + Prettier |
| `pnpm typecheck` | TypeScript type checking |
| `pnpm db:migrate` | Run Prisma migrations |
| `pnpm db:seed` | Seed development database |
```

Include database, deployment, and CI commands if relevant.

## Section: Key Directories

Help Claude navigate the codebase.

```markdown
## Key Directories

| Path | Purpose |
|------|---------|
| `src/app/` | Next.js App Router pages and layouts |
| `src/components/` | Shared React components |
| `src/lib/` | Utility functions and shared logic |
| `src/server/` | Server-side code (API routes, services) |
| `src/server/db/` | Prisma schema and migrations |
| `tests/` | Test files mirroring src/ structure |
| `e2e/` | Playwright E2E test specs |
```

## Section: Code Standards

Define patterns Claude should follow.

```markdown
## Code Standards

- All files start with a 2-line `// ABOUTME:` comment
- Use `const` by default, `let` only when reassignment is needed
- Prefer named exports over default exports
- Error handling: explicit try/catch, no silent swallowing
- Database queries go in `src/server/services/`, never in components
- API responses use `{ data, error, meta }` envelope pattern
- Tests follow Arrange-Act-Assert pattern with descriptive names
```

Include only project-specific rules. Generic best practices are handled by rules.

## Section: Gotchas

Document non-obvious behaviors and common pitfalls.

```markdown
## Gotchas

- `pnpm test` requires PostgreSQL running locally (`docker compose up db`)
- The `NEXT_PUBLIC_` prefix is required for client-side env vars
- Prisma Client must be regenerated after schema changes (`pnpm db:generate`)
- E2E tests require `pnpm build` first (tests against production build)
- The `/api/webhooks/` routes bypass auth middleware intentionally
- File uploads go to S3, not local filesystem (even in development)
```

## Anti-Patterns to Avoid

### Too verbose (wastes tokens)
```markdown
## Stack
We use TypeScript because it provides type safety which helps catch bugs
at compile time. Our team decided on Next.js 14 after evaluating several
frameworks including Remix and SvelteKit...
```

### Too vague (not actionable)
```markdown
## Commands
Use the standard commands for development.
```

### Duplicating language rules
```markdown
## Code Standards
- Use camelCase for variables (already in rules/typescript/coding-style.md)
- Write tests for all code (already in rules/common/testing.md)
```

## Token Budget Guidelines

| Project Size | Target Lines | Target Tokens |
|-------------|-------------|---------------|
| Small (1-5 files) | 30-50 | ~500 |
| Medium (5-50 files) | 60-100 | ~1,000 |
| Large (50+ files) | 80-150 | ~1,500 |

Claude reads CLAUDE.md on every message. Keep it under 150 lines.

## Combining with Rules

Project CLAUDE.md should complement, not duplicate, rules:

```
~/.claude/rules/         <- Global coding standards (shared across projects)
.claude/rules/           <- Project-specific rules (e.g., this API always returns JSON)
CLAUDE.md                <- Project context (stack, commands, structure, gotchas)
```

## Checklist

- [ ] Token count documented in header comment
- [ ] Stack section lists primary technologies only
- [ ] Commands section includes all common development tasks
- [ ] Key Directories maps the most-used paths
- [ ] Code Standards covers project-specific patterns only
- [ ] Gotchas documents non-obvious behaviors
- [ ] Total file under 150 lines
- [ ] No duplication with global rules
