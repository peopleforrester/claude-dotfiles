---
name: spec-task
description: Update task status and add implementation notes
user-invocable: true
---
# /spec-task

Update task status, mark tasks complete, and add implementation notes
to the spec's log file.

## Arguments
- `$ARGUMENTS` — `{spec-slug} {task-id} {action} [notes]`

## Actions

| Action | Description |
|--------|-------------|
| `start` | Mark task as in-progress, log start time |
| `done` | Mark task complete, prompt for notes |
| `skip` | Mark task as skipped with reason |
| `note` | Add a note without changing status |
| `block` | Mark task as blocked with reason |

## Process

### 1. Parse Arguments

```
/spec-task user-auth 2.3 done "Implemented logout with session cleanup"
          └─ slug   └─ id └─ action └─ optional notes
```

### 2. Update Tasks File

Modify `.spec/{slug}.tasks.md`:

**For `done`:**
```diff
- - [ ] 2.3 Implement AuthService.logout()
+ - [x] 2.3 Implement AuthService.logout()
```

**For `skip`:**
```diff
- - [ ] 2.3 Implement AuthService.logout()
+ - [~] 2.3 ~~Implement AuthService.logout()~~ (skipped: {reason})
```

**For `block`:**
```diff
- - [ ] 2.3 Implement AuthService.logout()
+ - [!] 2.3 Implement AuthService.logout() ⚠️ BLOCKED: {reason}
```

### 3. Update Log File

Append to `.spec/{slug}.log.md`:

```markdown
## {date} — Task {task-id}: {action}

### {Task Title}
{User's notes if provided}

**Files changed:** {list if detectable}
**Lines:** +{added} / -{removed} {if detectable}
```

### 4. Update Spec Status

If all tasks are complete:
- Change spec status from `active` to `completed`
- Prompt to run `/verify` for final quality gate

### 5. Display Confirmation

```markdown
## Task Updated

**Spec:** {slug}
**Task:** {task-id} — {task title}
**Action:** {action}
**Notes:** {notes or "—"}

### Updated Progress
[████████████░░░░░░░░] 50% (6/12 tasks)

### Next Task
{Next pending task or "All tasks complete!"}
```

## Examples

### Mark task done
```
User: /spec-task user-auth 2.3 done "Implemented with Redis session store"

Claude:
## Task Updated

**Spec:** user-auth
**Task:** 2.3 — Implement AuthService.logout()
**Action:** done
**Notes:** Implemented with Redis session store

### Updated Progress
[██████████░░░░░░░░░░] 50% (6/12 tasks)

### Next Task
2.4 Create auth middleware
```

### Mark task blocked
```
User: /spec-task user-auth 3.1 block "Waiting for rate limit library decision"

Claude:
## Task Updated

**Spec:** user-auth
**Task:** 3.1 — Add rate limiting
**Action:** blocked
**Reason:** Waiting for rate limit library decision

⚠️ This task is now blocked. Continue with other unblocked tasks.

### Available Tasks
- 3.2 Add input validation
- 3.3 Add comprehensive tests
```

### Add implementation note
```
User: /spec-task user-auth 2.2 note "Decided to use bcrypt cost factor 12"

Claude:
## Note Added

**Spec:** user-auth
**Task:** 2.2 — Implement AuthService.login()
**Note:** Decided to use bcrypt cost factor 12

Note appended to .spec/user-auth.log.md
```

## Batch Operations

Multiple tasks can be updated in one command:

```
/spec-task user-auth done 1.1 1.2 1.3 "Foundation phase complete"
```

This marks tasks 1.1, 1.2, and 1.3 as done with a shared note.

## Integration

After marking tasks complete, consider:
- `/verify` — Run quality checks after completing a phase
- `/spec-status {slug}` — Review updated progress
- `/orchestrate` — Continue with multi-agent implementation

## Error Handling

| Condition | Response |
|-----------|----------|
| Spec not found | "Spec '{slug}' not found. Run `/spec-status` to list specs." |
| Task not found | "Task {id} not found in {slug}. Available: [list]" |
| Already done | "Task {id} is already complete. Use `note` to add comments." |
| Invalid action | "Unknown action '{action}'. Valid: start, done, skip, note, block" |
