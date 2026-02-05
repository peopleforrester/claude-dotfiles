---
description: Create a new feature specification through structured interview
---

# /spec-new

Start a structured interview to create a comprehensive specification before
implementation. Uses the `spec-interviewer` agent to gather requirements
across 8 categories.

## Arguments
- `$ARGUMENTS` — Name or brief description of the feature to spec

## Process

### 1. Initialize Spec
Create the spec directory and files:
```
.spec/
└── {slug}.spec.md     # Will be populated by interview
```

Generate slug from the feature name (lowercase, hyphens).

### 2. Context Gathering
Before starting the interview, explore the codebase:
- Detect the tech stack (language, framework, database)
- Find similar existing implementations
- Identify relevant patterns and conventions

### 3. Conduct Interview
Delegate to the **spec-interviewer** agent to ask questions across:

| Category | Focus |
|----------|-------|
| Functional | What it does, who uses it, user flows |
| Technical | Language, framework, existing patterns |
| Data Model | Entities, relationships, storage |
| Edge Cases | Error handling, boundary conditions |
| Security | Auth, validation, secrets, OWASP |
| Testing | Test types, coverage, fixtures |
| Non-Functional | Performance, scale, accessibility |
| Implementation | Task breakdown, dependencies, risks |

### 4. Compile Spec Document
After the interview, compile answers into `.spec/{slug}.spec.md`:

```markdown
# Spec: {Feature Name}

## Status: draft
## Created: {date}
## Updated: {date}

## Overview
{Summary from interview}

## Functional Requirements
{From functional category}

## Technical Constraints
{From technical category}

## Data Model
{From data model category}

## Edge Cases & Error Handling
{From edge cases category}

## Security Considerations
{From security category}

## Testing Strategy
{From testing category}

## Non-Functional Requirements
{From non-functional category}

## Implementation Approach
{From implementation category}

## Acceptance Criteria
- [ ] {Derived criteria}
```

### 5. Generate Task Breakdown
Delegate to the **planner** agent to create `.spec/{slug}.tasks.md`:

```markdown
# Tasks: {Feature Name}

## Progress: 0/N complete (0%)

### Phase 1: Foundation
- [ ] 1.1 Task description
- [ ] 1.2 Task description

### Phase 2: Core Implementation
- [ ] 2.1 Task description
- [ ] 2.2 Task description

### Phase 3: Testing & Hardening
- [ ] 3.1 Task description
- [ ] 3.2 Task description
```

### 6. Create Implementation Log
Initialize `.spec/{slug}.log.md`:

```markdown
# Implementation Log: {Feature Name}

## {date} — Spec created

Spec created via /spec-new interview.
Ready for implementation.
```

## Output

After completion, display:

```markdown
## Spec Created: {Feature Name}

**Files created:**
- `.spec/{slug}.spec.md` — Specification document
- `.spec/{slug}.tasks.md` — Task breakdown (N tasks)
- `.spec/{slug}.log.md` — Implementation log

**Next steps:**
1. Review the spec: `cat .spec/{slug}.spec.md`
2. Check task status: `/spec-status {slug}`
3. Start implementation: `/orchestrate implement {slug}`

**WAITING FOR CONFIRMATION** before starting implementation.
```

## Example

```
User: /spec-new user authentication

Claude: Creating spec for "user-authentication"...

[Interview begins]

Q1: What is the core purpose of this authentication feature?
...

[After interview completes]

## Spec Created: User Authentication

**Files created:**
- `.spec/user-authentication.spec.md` — Specification document
- `.spec/user-authentication.tasks.md` — Task breakdown (12 tasks)
- `.spec/user-authentication.log.md` — Implementation log

**Next steps:**
1. Review the spec: `cat .spec/user-authentication.spec.md`
2. Check task status: `/spec-status user-authentication`
3. Start implementation: `/orchestrate implement user-authentication`

**WAITING FOR CONFIRMATION** before starting implementation.
```
