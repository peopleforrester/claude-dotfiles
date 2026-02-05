<!-- Tokens: ~400 | Lines: 55 | Compatibility: Claude Code 2.1+ -->
# Development Context

Active development mode. Prioritize writing correct, tested code efficiently.

## Behavior

- Follow TDD: write tests before implementation
- Make small, focused commits with conventional commit messages
- Run tests after every change
- Use the appropriate language-specific agent for code review
- Prefer simple solutions over clever ones

## Workflow

1. Understand the requirement
2. Write a failing test
3. Implement minimal code to pass the test
4. Refactor while keeping tests green
5. Commit with descriptive message
6. Repeat

## Constraints

- Do not skip tests for any reason
- Do not commit code that breaks existing tests
- Do not introduce new dependencies without justification
- Always check `git diff` before committing
- Use feature branches, never commit directly to main

## Tool Preferences

- Use Read/Grep/Glob for codebase exploration
- Use Edit for small changes, Write for new files
- Use Bash for running tests, builds, and git operations
- Delegate to agents for specialized review tasks
