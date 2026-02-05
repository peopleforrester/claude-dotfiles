---
name: spec-driven-development
description: |
  Interview-first specification workflow for feature development. Guides
  through 8 question categories to build comprehensive specs before coding.
  Use when starting new features, planning complex changes, or establishing
  clear requirements before implementation.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - workflow
    - planning
    - specification
    - interview
---

# Spec-Driven Development

Build comprehensive specifications through structured interviews before writing
any code. Captures requirements, constraints, edge cases, and acceptance
criteria upfront.

## When to Use

- Starting a new feature with unclear requirements
- Planning complex changes that span multiple components
- Onboarding to an unfamiliar codebase
- Creating documentation for future reference
- Establishing clear acceptance criteria before implementation

## Core Concepts

### Spec File Structure

Specs are stored in `.spec/` at the project root:

```
.spec/
├── user-auth.spec.md       # The specification document
├── user-auth.tasks.md      # Task breakdown with checkboxes
└── user-auth.log.md        # Implementation notes and decisions
```

### Spec Document Format

```markdown
# Spec: User Authentication

## Status: draft | active | completed | archived
## Created: 2026-02-05
## Updated: 2026-02-05

## Overview
One-paragraph summary of what this feature does and why.

## Functional Requirements
- User can register with email and password
- User can log in and receive a session token
- User can log out and invalidate their session

## Technical Constraints
- Language: TypeScript
- Framework: Express.js
- Database: PostgreSQL
- Must integrate with existing user model

## Data Model
- User: id, email, password_hash, created_at, updated_at
- Session: id, user_id, token, expires_at

## Edge Cases & Error Handling
- Invalid email format → 400 with validation message
- Duplicate email → 409 Conflict
- Wrong password → 401 with generic message (no info leak)
- Expired session → 401 with refresh guidance

## Security Considerations
- Passwords hashed with bcrypt (cost factor 12)
- Session tokens are UUIDs, not JWTs (revocable)
- Rate limiting on login endpoint (5 attempts/minute)
- No password in logs or error messages

## Testing Strategy
- Unit tests: validation logic, password hashing
- Integration tests: full auth flow with test database
- E2E tests: login/logout via API
- Coverage target: 80%

## Non-Functional Requirements
- Login response time < 500ms
- Support 1000 concurrent sessions
- Session cleanup job runs daily

## Implementation Approach
1. Database schema and migrations
2. User model and repository
3. Auth service (register, login, logout)
4. Auth middleware for protected routes
5. Rate limiting middleware
6. Tests for each layer

## Acceptance Criteria
- [ ] User can register with valid email/password
- [ ] User can log in and receive session token
- [ ] Protected routes reject unauthenticated requests
- [ ] Rate limiting prevents brute force attacks
- [ ] All tests pass with 80% coverage
```

## Interview Process

### The 8 Categories

The interview covers 8 categories to build a complete spec:

| # | Category | Key Questions |
|---|----------|---------------|
| 1 | **Functional** | What does it do? Who uses it? What are the inputs/outputs? |
| 2 | **Technical** | What language/framework? What existing patterns to follow? |
| 3 | **Data Model** | What entities? Relationships? Storage mechanism? |
| 4 | **Edge Cases** | What can go wrong? How should errors be handled? |
| 5 | **Security** | Auth requirements? Input validation? Secrets handling? |
| 6 | **Testing** | What needs tests? Unit vs integration vs E2E? Coverage? |
| 7 | **Non-Functional** | Performance targets? Scalability? Accessibility? |
| 8 | **Implementation** | Suggested approach? Task breakdown? Dependencies? |

### Interview Flow

1. **Start with functional requirements** — understand the "what"
2. **Move to technical constraints** — understand the "how"
3. **Define the data model** — understand the "with what"
4. **Explore edge cases** — understand the "what if"
5. **Address security** — understand the "how safe"
6. **Plan testing** — understand the "how verified"
7. **Non-functional requirements** — understand the "how well"
8. **Implementation approach** — understand the "in what order"

### Adaptive Questioning

Not all categories need equal depth. Adapt based on the feature:

| Feature Type | Focus Categories |
|--------------|------------------|
| UI component | Functional, Edge Cases, Testing |
| API endpoint | Functional, Data Model, Security, Edge Cases |
| Background job | Technical, Edge Cases, Non-Functional |
| Data migration | Data Model, Edge Cases, Testing |
| Security feature | Security, Testing, Edge Cases |

## Integration with Other Tools

### During Planning

| Tool | When to Use |
|------|-------------|
| `planner` agent | Generate detailed task breakdown from spec |
| `architect` agent | Create ADRs for significant decisions |
| `/multi-plan` command | Complex specs needing both agents |

### During Implementation

| Tool | When to Use |
|------|-------------|
| `/tdd` command | Implement with test-driven development |
| `/orchestrate` command | Multi-agent execution of spec tasks |
| `/verify` command | Quality gate before marking complete |

### Task Tracking

Tasks are tracked in `{slug}.tasks.md`:

```markdown
# Tasks: User Authentication

## Progress: 3/8 complete (37%)

### Phase 1: Foundation
- [x] 1.1 Create database migration for users table
- [x] 1.2 Create database migration for sessions table
- [ ] 1.3 Create User model with repository pattern

### Phase 2: Core Implementation
- [x] 2.1 Implement AuthService.register()
- [ ] 2.2 Implement AuthService.login()
- [ ] 2.3 Implement AuthService.logout()
- [ ] 2.4 Create auth middleware

### Phase 3: Hardening
- [ ] 3.1 Add rate limiting
- [ ] 3.2 Add input validation
- [ ] 3.3 Add comprehensive tests
```

### Implementation Log

Track decisions and notes in `{slug}.log.md`:

```markdown
# Implementation Log: User Authentication

## 2026-02-05 — Started implementation

### Task 1.1: User table migration
- Created migration with bcrypt for password hashing
- Decided on UUID primary keys for security
- Added unique constraint on email

### Task 2.1: AuthService.register()
- Used repository pattern from existing UserRepository
- Added email validation with Zod
- Password validation: min 12 chars, requires number and special char
```

## Commands

| Command | Purpose |
|---------|---------|
| `/spec-new` | Start interview to create a new spec |
| `/spec-status` | Show spec progress and next tasks |
| `/spec-task` | Update task status and add notes |

## Best Practices

1. **Interview before coding** — resist the urge to jump into implementation
2. **Keep specs updated** — update when requirements change
3. **Link specs to PRs** — reference spec slug in PR descriptions
4. **Review completed specs** — retrospective for process improvement
5. **Share with team** — specs are documentation for future maintainers

## Checklist

- [ ] All 8 categories addressed (or explicitly N/A)
- [ ] Acceptance criteria are testable
- [ ] Edge cases include error responses
- [ ] Security considerations documented
- [ ] Testing strategy matches feature complexity
- [ ] Task breakdown is ordered by dependencies
