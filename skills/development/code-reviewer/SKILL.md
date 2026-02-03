---
name: code-reviewer
description: |
  Systematic code review for pull requests and code changes. Use when the user
  asks for a code review, PR review, or wants feedback on code quality. Provides
  structured feedback on correctness, security, performance, and maintainability.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - development
    - review
    - quality
---

# Code Review Assistant

Systematic approach to reviewing code changes for quality and correctness.

## When to Use

- User asks for a code review or PR review
- Reviewing changes before merging
- User asks "is this code okay?" or "any issues with this?"
- Before deploying to production

## Review Process

### 1. Understand Context

Before reviewing code:

- What is the purpose of this change?
- What problem does it solve?
- Are there related issues or documentation?

### 2. Review in Layers

Review code systematically in this order:

```
Layer 1: Correctness     - Does it work as intended?
Layer 2: Security        - Are there vulnerabilities?
Layer 3: Performance     - Are there bottlenecks?
Layer 4: Maintainability - Is it readable and extensible?
Layer 5: Style           - Does it follow conventions?
```

## Review Checklist

### Correctness

- [ ] Logic handles all expected cases
- [ ] Edge cases considered (empty, null, boundaries)
- [ ] Error handling is appropriate
- [ ] No obvious bugs or typos
- [ ] Tests cover the changes

### Security

- [ ] No hardcoded secrets or credentials
- [ ] User input is validated and sanitized
- [ ] SQL queries use parameterized statements
- [ ] No XSS vulnerabilities (user data escaped)
- [ ] Authentication/authorization checked
- [ ] Sensitive data not logged

### Performance

- [ ] No N+1 query problems
- [ ] Large datasets paginated
- [ ] Expensive operations cached if appropriate
- [ ] No unnecessary re-renders (React)
- [ ] Async operations where beneficial

### Maintainability

- [ ] Code is readable without extensive comments
- [ ] Functions are focused and reasonably sized
- [ ] No code duplication (DRY)
- [ ] Clear naming for variables and functions
- [ ] Appropriate abstraction level

### Style

- [ ] Follows project conventions
- [ ] Consistent formatting
- [ ] No commented-out code
- [ ] Imports organized

## Feedback Format

Structure feedback as:

```markdown
## Summary

Brief overview of the change and overall assessment.

## Must Fix (Blocking)

Issues that must be addressed before merge.

### Issue 1: [Title]
**Location**: `file.ts:42`
**Problem**: Description of the issue
**Suggestion**: How to fix it

## Should Fix (Non-blocking)

Improvements that should be made but don't block merge.

## Consider (Optional)

Suggestions for future improvement.

## Positive Feedback

What was done well.
```

## Examples

### Security Issue

```markdown
### Issue: SQL Injection Vulnerability
**Location**: `users.ts:28`
**Problem**: User input directly concatenated into SQL query
**Suggestion**: Use parameterized query:
\`\`\`typescript
// Before
const query = `SELECT * FROM users WHERE id = ${userId}`;

// After
const query = 'SELECT * FROM users WHERE id = $1';
const result = await db.query(query, [userId]);
\`\`\`
```

### Performance Issue

```markdown
### Issue: N+1 Query in Loop
**Location**: `orders.ts:15-20`
**Problem**: Database query inside loop causes N+1 queries
**Suggestion**: Fetch all related data in single query:
\`\`\`typescript
// Before: N+1 queries
for (const order of orders) {
  order.items = await db.getItems(order.id);
}

// After: 2 queries
const orderIds = orders.map(o => o.id);
const allItems = await db.getItemsByOrderIds(orderIds);
\`\`\`
```

### Positive Feedback

```markdown
## Positive Feedback

- Good separation of concerns between service and repository layers
- Comprehensive error handling with specific error types
- Well-structured tests covering edge cases
```

## Review Tone

- Be constructive, not critical
- Explain the "why" behind suggestions
- Acknowledge good work
- Use "we" and "let's" not "you should"
- Ask questions when intent is unclear
- Distinguish between must-fix and nice-to-have

## Questions to Ask

If something is unclear:

- "What's the expected behavior when X happens?"
- "Is there a reason this approach was chosen over Y?"
- "Could you help me understand this section?"
