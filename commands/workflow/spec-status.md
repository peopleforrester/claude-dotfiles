---
description: Show specification progress and next tasks
---

# /spec-status

Display the current status of one or all specifications, including task
progress, completion percentage, and recommended next actions.

## Arguments
- `$ARGUMENTS` — Optional: spec slug to show details for a specific spec

## Process

### Without Arguments — List All Specs

Read all `.spec/*.spec.md` files and display summary:

```markdown
## Active Specifications

| Spec | Status | Progress | Next Task |
|------|--------|----------|-----------|
| user-auth | active | 5/12 (42%) | 2.3 Implement logout |
| api-rate-limit | draft | 0/8 (0%) | Review spec |
| payment-integration | completed | 15/15 (100%) | — |

**Total:** 3 specs, 20/35 tasks complete (57%)
```

### With Spec Slug — Show Details

Read `.spec/{slug}.spec.md` and `.spec/{slug}.tasks.md`:

```markdown
## Spec: User Authentication

**Status:** active
**Created:** 2026-02-05
**Updated:** 2026-02-05
**Progress:** 5/12 tasks (42%)

### Task Status

#### Phase 1: Foundation ✓ Complete
- [x] 1.1 Create database migration for users table
- [x] 1.2 Create database migration for sessions table
- [x] 1.3 Create User model with repository pattern

#### Phase 2: Core Implementation (In Progress)
- [x] 2.1 Implement AuthService.register()
- [x] 2.2 Implement AuthService.login()
- [ ] 2.3 Implement AuthService.logout() ← **NEXT**
- [ ] 2.4 Create auth middleware

#### Phase 3: Hardening
- [ ] 3.1 Add rate limiting
- [ ] 3.2 Add input validation
- [ ] 3.3 Add comprehensive tests

### Progress Bar
[████████░░░░░░░░░░░░] 42%

### Recent Activity
- 2026-02-05: Completed task 2.2 (login implementation)
- 2026-02-05: Completed task 2.1 (register implementation)

### Recommended Actions
1. Continue with task 2.3: Implement AuthService.logout()
2. Run `/spec-task user-auth 2.3 start` to begin
3. After completing Phase 2, run `/verify` before Phase 3
```

## Status Values

| Status | Meaning |
|--------|---------|
| `draft` | Spec created but not yet approved for implementation |
| `active` | Implementation in progress |
| `completed` | All tasks done and verified |
| `archived` | Spec retained for reference but no longer active |

## Progress Calculation

Progress is calculated from the tasks file:
- Count `[x]` (completed) vs `[ ]` (pending) checkboxes
- Percentage = completed / total * 100
- Round to nearest integer

## Output Formats

### Summary View (no args)
Compact table of all specs with key metrics.

### Detail View (with slug)
Full task breakdown with progress bars and recommendations.

### JSON Output (for scripting)
If the user requests JSON format:

```json
{
  "spec": "user-auth",
  "status": "active",
  "created": "2026-02-05",
  "updated": "2026-02-05",
  "progress": {
    "completed": 5,
    "total": 12,
    "percentage": 42
  },
  "nextTask": {
    "id": "2.3",
    "title": "Implement AuthService.logout()"
  }
}
```

## Error Handling

| Condition | Response |
|-----------|----------|
| No `.spec/` directory | "No specs found. Create one with `/spec-new`" |
| Spec slug not found | "Spec '{slug}' not found. Available: [list]" |
| Tasks file missing | "Tasks file missing for '{slug}'. Regenerate with planner agent." |
