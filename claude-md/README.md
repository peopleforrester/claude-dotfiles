# CLAUDE.md Best Practices Guide

This directory contains CLAUDE.md templates organized by language, framework, and domain.
Use these as starting points and customize for your specific project.

## What is CLAUDE.md?

CLAUDE.md is a markdown file in your project root that provides context to Claude Code.
It's like a `.editorconfig` for AI assistance—project-specific instructions that help
Claude understand your codebase and work more effectively.

## Quick Start

1. Choose a template from this directory
2. Copy it to your project root as `CLAUDE.md`
3. Customize with your specific commands, directories, and gotchas
4. Keep it updated as your project evolves

## Template Categories

### By Language (`languages/`)

| Template | Best For |
|----------|----------|
| [python.md](./languages/python.md) | Python 3.10+ with uv, pytest, ruff |
| [typescript.md](./languages/typescript.md) | TypeScript 5.x with Node.js |
| [rust.md](./languages/rust.md) | Rust with Cargo |
| [go.md](./languages/go.md) | Go 1.21+ with modules |

### By Framework (`frameworks/`)

| Template | Best For |
|----------|----------|
| [react.md](./frameworks/react.md) | React 18+ with Vite |
| [nextjs.md](./frameworks/nextjs.md) | Next.js 14+ App Router |
| [fastapi.md](./frameworks/fastapi.md) | FastAPI with SQLAlchemy |
| [rails.md](./frameworks/rails.md) | Rails 7+ with Hotwire |
| [django.md](./frameworks/django.md) | Django 5+ with DRF |

### By Domain (`domains/`)

| Template | Best For |
|----------|----------|
| [api-backend.md](./domains/api-backend.md) | REST/GraphQL API services |
| [cli-tool.md](./domains/cli-tool.md) | Command-line applications |
| [library.md](./domains/library.md) | Published packages/libraries |
| [monorepo.md](./domains/monorepo.md) | Multi-package repositories |

### Examples (`examples/`)

| File | Purpose |
|------|---------|
| [excellent-example.md](./examples/excellent-example.md) | Annotated best-in-class example |
| [common-mistakes.md](./examples/common-mistakes.md) | Anti-patterns to avoid |

---

## Writing Effective CLAUDE.md

### Token Budget

| Template Type | Target Lines | Target Tokens | Max Tokens |
|---------------|--------------|---------------|------------|
| Minimal | 25-35 | 500 | 1,000 |
| Standard | 60-80 | 1,500 | 2,500 |
| Power User | 80-100 | 2,000 | 3,500 |

**Why it matters**: Claude's system prompt uses ~50 instructions. LLMs reliably follow
~150-200 total instructions. Stay well under this budget.

### Required Sections

Every CLAUDE.md should include:

```markdown
# Project Name

One-sentence description.

## Stack
[Language, framework, versions]

## Commands
[Exact commands with comments]

## Key Directories
[Project structure overview]
```

### Recommended Sections

```markdown
## Code Standards
[2-3 project-specific rules only]

## Architecture Decisions
[Non-obvious design choices]

## Gotchas
[Things that break, quirks, warnings]

## Environment Variables
[Required env vars]
```

### Section Guidelines

#### Commands

Be exact. Include the comment explaining what it does.

```markdown
## Commands

```bash
pnpm dev        # Start dev server (port 3000)
pnpm test       # Run Vitest
pnpm db:migrate # Apply Prisma migrations
```
```

#### Key Directories

Use a tree structure with brief annotations.

```markdown
## Key Directories

```
src/
├── routes/       # API route handlers
├── services/     # Business logic
├── repositories/ # Database access
└── types/        # TypeScript definitions
```
```

#### Code Standards

Only include rules that are:
- Project-specific (not generic best practices)
- Not enforceable by linters
- Things Claude can't infer from the code

```markdown
## Code Standards

- Error responses use RFC 7807 Problem Details format
- All database queries go through repository layer
- Feature flags stored in Redis, not config files
```

#### Gotchas

This section has the highest ROI. Include things that:
- Break silently
- Require server restarts
- Have non-obvious configuration
- Caused confusion before

```markdown
## Gotchas

- Prisma client regenerates on schema change - run `pnpm db:generate`
- Redis required even in dev - use Docker Compose
- JWT tokens expire in 15 minutes - use refresh token flow
```

---

## What NOT to Include

### Generic Advice (Wastes Tokens)

```markdown
❌ - Use meaningful variable names
❌ - Write comprehensive tests
❌ - Follow SOLID principles
❌ - Handle errors properly
```

### Linter Territory

```markdown
❌ - Use const instead of let when possible
❌ - Add semicolons at end of statements
❌ - Use single quotes for strings
```

### Obvious Rules

```markdown
❌ - Don't commit secrets to Git
❌ - Use TypeScript for type safety
❌ - Keep functions small
```

### Long Prose Paragraphs

```markdown
❌ Our application follows a layered architecture where the
   presentation layer handles user interaction and communicates
   with the service layer which contains business logic...
```

Use bullet points and visual structure instead.

---

## Advanced Features

### @ Imports

Reference other files without bloating CLAUDE.md:

```markdown
## References

See @docs/architecture.md for system design.
See @docs/api.md for endpoint documentation.
```

### Token Counting

Add a header comment with token count:

```markdown
<!-- Tokens: ~1,450 (target: 1,500) | Lines: 72 -->
# My Project
```

Use `tiktoken` with `cl100k_base` encoding to count.

### CLAUDE.md Inheritance

Claude Code reads CLAUDE.md from:
1. Current directory
2. Parent directories (up to git root)
3. Home directory (`~/.claude/CLAUDE.md`)

More specific files override general ones.

---

## Maintenance

### When to Update CLAUDE.md

- Changed package manager (npm → pnpm)
- Migrated testing framework (Jest → Vitest)
- Restructured directories
- Added new major dependency
- Discovered new gotchas

### Versioning

Consider including compatibility info:

```markdown
<!-- Compatibility: Claude Code 2.1+ -->
```

---

## Quick Checklist

Before committing your CLAUDE.md:

- [ ] Under 100 lines (80 ideal)
- [ ] Token count in header
- [ ] Exact commands (not vague descriptions)
- [ ] Directory structure included
- [ ] Gotchas section populated
- [ ] No generic advice
- [ ] No linter-enforceable rules
- [ ] Tested with Claude Code session
