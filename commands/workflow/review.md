# /review - Code Review

Perform a thorough code review of changes.

## Usage

```
/review [file, PR, or commit]
/review                      # Review staged changes
/review src/auth/login.ts    # Review specific file
/review #123                  # Review PR #123
```

## Review Process

### 1. Understand Context

Before reviewing:
- What problem does this code solve?
- What was the previous implementation?
- Are there related changes elsewhere?

### 2. Review Checklist

#### Correctness
- [ ] Does the code do what it's supposed to do?
- [ ] Are edge cases handled?
- [ ] Is error handling appropriate?
- [ ] Are there any logic errors?

#### Security
- [ ] No hardcoded secrets or credentials
- [ ] Input validation present
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] Authentication/authorization correct

#### Performance
- [ ] No N+1 query problems
- [ ] No unnecessary loops or iterations
- [ ] Appropriate data structures used
- [ ] No memory leaks

#### Maintainability
- [ ] Code is readable and clear
- [ ] Functions are focused and small
- [ ] Naming is descriptive
- [ ] No code duplication
- [ ] Comments explain "why", not "what"

#### Testing
- [ ] Tests cover the changes
- [ ] Tests are meaningful (not just for coverage)
- [ ] Edge cases tested
- [ ] Tests are maintainable

#### Style
- [ ] Follows project conventions
- [ ] Consistent formatting
- [ ] No leftover debug code
- [ ] No commented-out code

### 3. Provide Feedback

Format feedback clearly:

```markdown
## Summary
[Overall assessment: approve, request changes, or discuss]

## Highlights
- [What's done well]

## Required Changes
1. **[File:Line]** - [Issue description]
   ```suggestion
   // Suggested fix
   ```

## Suggestions (Optional)
- [Nice-to-have improvements]

## Questions
- [Clarifications needed]
```

### 4. Severity Levels

Use consistent severity markers:

| Level | Meaning | Action |
|-------|---------|--------|
| 🔴 **Blocker** | Must fix before merge | Required change |
| 🟡 **Warning** | Should fix, potential issue | Strongly suggested |
| 🔵 **Suggestion** | Could improve code | Optional |
| 💬 **Question** | Need clarification | Discussion |
| 👍 **Praise** | Well done | Positive feedback |

## Example Output

```markdown
## Code Review: Add OAuth Login

### Summary
Overall good implementation. A few security concerns need addressing
before merge.

### Highlights
- Clean separation of OAuth providers
- Good error messages for users
- Comprehensive token validation

### Required Changes

1. 🔴 **src/auth/oauth.ts:45** - Token stored in localStorage
   Tokens should be in httpOnly cookies to prevent XSS.
   ```typescript
   // Instead of localStorage, use secure cookie
   res.cookie('token', token, { httpOnly: true, secure: true });
   ```

2. 🔴 **src/auth/oauth.ts:78** - Missing CSRF protection
   Add state parameter to OAuth flow.

### Suggestions

1. 🔵 **src/auth/oauth.ts:23** - Consider extracting provider config
   This would make adding new providers easier.

### Questions

1. 💬 **src/auth/types.ts:12** - Why is `expiresAt` optional?
   Should tokens always have expiration?

---
**Verdict**: Request changes (2 security issues)
```

## Tips

- Be constructive, not critical
- Explain the "why" behind suggestions
- Acknowledge good work
- Offer alternatives, not just criticism
- Consider the author's experience level
