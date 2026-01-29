# Common CLAUDE.md Mistakes

Anti-patterns to avoid when writing your CLAUDE.md file.

---

## Mistake #1: Too Long / Too Many Instructions

### Bad Example

```markdown
# My Project

## Code Standards
- Always use meaningful variable names that describe the purpose
- Keep functions small and focused on a single task
- Write comprehensive documentation for all public APIs
- Use proper error handling with try-catch blocks
- Follow the DRY principle - Don't Repeat Yourself
- Use SOLID principles in your design
- Write unit tests for all new functionality
- Keep code coverage above 80%
- Use proper logging for debugging
- Follow security best practices
- Validate all user input
- Use environment variables for configuration
- Keep dependencies up to date
- Write clear commit messages
- Review code before merging
... (continues for 50 more bullets)
```

### Why It's Bad

- **Token waste**: LLMs have ~150-200 reliable instruction capacity
- **Generic advice**: "Use meaningful names" - Claude already knows this
- **Linter territory**: Many rules are better enforced by tooling
- **Diminishing returns**: After ~100 lines, instructions get ignored

### Better Approach

```markdown
## Code Standards

- Error responses must use RFC 7807 Problem Details format
- All database queries go through repository layer
- Feature flags stored in Redis, not config files
```

Only include rules that are **project-specific** and **can't be inferred**.

---

## Mistake #2: Vague Commands

### Bad Example

```markdown
## Commands

- Run the development server
- Execute the test suite
- Build for production
```

### Why It's Bad

- Claude doesn't know the exact command
- Different projects use different tools
- Wastes a turn asking "how do I run tests?"

### Better Approach

```markdown
## Commands

```bash
pnpm dev        # Start dev server (port 3000)
pnpm test       # Run Vitest
pnpm build      # Production build to dist/
```
```

Exact commands with comments explaining what they do.

---

## Mistake #3: Missing Gotchas

### Bad Example

```markdown
# My Project

A React application.

## Stack
- React 18
- TypeScript
- Vite
```

### Why It's Bad

Every project has quirks. Without a Gotchas section:
- Claude will hit the same issues repeatedly
- You'll waste time explaining the same problems
- Non-obvious behaviors cause confusion

### Better Approach

```markdown
## Gotchas

- Hot reload breaks when editing `vite.config.ts` - restart server
- StrictMode renders components twice in dev (intentional)
- Tailwind purge: update `content` array when adding new directories
- Tests fail if Redis isn't running - use `docker compose up -d`
```

---

## Mistake #4: Generic Descriptions

### Bad Example

```markdown
# My Project

This is a web application built with modern technologies.
It provides a great user experience and follows best practices.
The codebase is clean and maintainable.
```

### Why It's Bad

- Zero actionable information
- Marketing speak, not technical context
- Wastes tokens on fluff

### Better Approach

```markdown
# OrderFlow API

REST API for e-commerce order management. Handles order creation,
payment processing via Stripe, and inventory sync with warehouse system.
```

One sentence explaining **what it does** and **key integrations**.

---

## Mistake #5: No Directory Structure

### Bad Example

```markdown
## Code Organization

We follow a modular architecture with separation of concerns.
Components are organized by feature. Services handle business logic.
```

### Why It's Bad

- Claude can't navigate without knowing structure
- Will waste time exploring or asking questions
- Abstract descriptions don't help

### Better Approach

```markdown
## Key Directories

```
src/
├── features/         # Feature modules (user, order, product)
│   └── user/
│       ├── api.ts    # API client
│       ├── hooks.ts  # React hooks
│       └── types.ts  # TypeScript types
├── components/       # Shared UI components
└── lib/              # Utilities, helpers
```
```

Visual tree structure with brief annotations.

---

## Mistake #6: Obvious Rules

### Bad Example

```markdown
## Code Standards

- Write tests for your code
- Use TypeScript
- Handle errors properly
- Don't commit secrets
- Use Git for version control
```

### Why It's Bad

- Claude already knows these things
- Wastes valuable token budget
- No project-specific value

### Better Approach

Only include rules that are:

1. **Project-specific**: "Use Zod for validation, not Yup"
2. **Non-obvious**: "Feature flags in Redis, not env vars"
3. **Unconventional**: "We use barrel files despite bundle size concerns"

---

## Mistake #7: Outdated Information

### Bad Example

```markdown
## Commands

```bash
npm run start    # Actually we switched to pnpm...
yarn test        # This hasn't worked since the Vitest migration
```
```

### Why It's Bad

- Causes confusion and errors
- Breaks Claude's trust in the document
- Leads to wasted debugging time

### Better Approach

Keep CLAUDE.md updated when you:
- Change package managers
- Migrate testing frameworks
- Restructure directories
- Update major dependencies

---

## Mistake #8: Prose Over Structure

### Bad Example

```markdown
## Architecture

Our application follows a layered architecture where the presentation
layer handles user interaction and communicates with the service layer
which contains business logic. The service layer then interacts with
the repository layer for data persistence. We use dependency injection
to maintain loose coupling between layers. The configuration is managed
through environment variables and a central config module...
```

### Why It's Bad

- Hard to scan quickly
- Buries important information
- Takes more tokens than needed

### Better Approach

```markdown
## Architecture

- **Routes** → Services → Repositories (never skip layers)
- Dependency injection via constructor parameters
- Config: env vars → `src/config.ts` → typed settings object
```

Bullet points and visual hierarchy over paragraphs.

---

## Mistake #9: No Token Awareness

### Bad Example

A CLAUDE.md file with 300+ lines and no token count.

### Why It's Bad

- May exceed effective instruction limit
- No way to know if you're in budget
- Harder to maintain over time

### Better Approach

```markdown
<!-- Tokens: ~1,400 (target: 1,500) | Lines: 75 -->
# My Project
...
```

Track tokens using `tiktoken` with `cl100k_base` encoding.

---

## Quick Reference: Do's and Don'ts

| Do | Don't |
|----|-------|
| Specific versions | Vague "latest" |
| Exact commands | "Run the server" |
| 3-5 code standards | 50 generic rules |
| Gotchas section | Assume Claude knows quirks |
| Directory tree | Prose about structure |
| Token count header | Unlimited length |
| @ imports for details | Everything inline |
| Update when code changes | Let it get stale |
