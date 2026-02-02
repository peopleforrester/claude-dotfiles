<!-- Tokens: ~650 (target: 1500) | Lines: 45 | Compatibility: Claude Code 2.1+ -->
# Demo Todo API

A simple REST API demonstrating claude-dotfiles in action.

## Stack

- **Language**: TypeScript 5.3
- **Framework**: Express.js
- **Database**: SQLite (in-memory for demo)
- **Testing**: Vitest
- **Package Manager**: pnpm

## Commands

```bash
pnpm dev          # Start dev server (port 3000)
pnpm test         # Run tests
pnpm test:watch   # Run tests in watch mode
pnpm build        # Compile TypeScript
pnpm lint         # Run ESLint
```

## Key Directories

```
src/
├── routes/       # Express route handlers
├── services/     # Business logic
├── db/           # Database setup and queries
└── types/        # TypeScript type definitions

tests/
└── *.test.ts     # Test files mirror src/ structure
```

## Code Standards

- Use async/await, never raw Promises
- All route handlers return `{ data: T }` or `{ error: string }`
- Database functions live in `src/db/`, not in routes

## Gotchas

- SQLite resets on server restart (intentional for demo)
- Tests run in isolation - each gets fresh database
- `pnpm dev` uses nodemon - saves trigger restart

## API Endpoints

```
GET    /todos      - List all todos
POST   /todos      - Create todo { title: string }
PATCH  /todos/:id  - Update todo { completed?: boolean }
DELETE /todos/:id  - Delete todo
```
