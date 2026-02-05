<!-- Tokens: ~400 | Lines: 60 | Compatibility: Claude Code 2.1+ -->
# Example: User-Level CLAUDE.md

Place this at `~/.claude/CLAUDE.md` to set defaults for all your projects.

## My Preferences

- Address me as [Your Name]
- Prefer simple, clean code over clever solutions
- Always ask before reimplementing features from scratch
- Use TDD for all new code

## Default Stack

- Primary languages: Python, TypeScript
- Package management: uv (Python), npm (TypeScript)
- Testing: pytest (Python), Vitest (TypeScript)
- Formatting: ruff (Python), prettier (TypeScript)

## Git Workflow

- Always work on feature branches, never commit to main directly
- Use conventional commit messages (feat:, fix:, refactor:, etc.)
- Run tests before every push
- Create PRs with descriptive summaries

## Coding Standards

- All code files start with a brief 2-line ABOUTME comment
- Type annotations required on all public functions
- Minimum 80% test coverage
- No mock modes — use real data and APIs only

## Communication Style

- Be concise and direct
- Use markdown formatting for structured output
- Include file:line references when discussing code
- Ask for clarification rather than assuming
