---
description: Save current verification state for resumption
---

# /checkpoint

Save a snapshot of the current work state so it can be resumed later.
Captures verification status, pending tasks, and context.

## Arguments
- `$ARGUMENTS` — Optional label for this checkpoint

## Process

### 1. Capture State
Record:
- Current branch and commit hash
- Uncommitted changes (`git diff --stat`)
- Pending tasks from the task list
- Test results (last run status)
- Build status

### 2. Generate Checkpoint

```markdown
## Checkpoint: [Label or timestamp]

### Branch
`[branch]` at `[commit hash]`

### Status
- Tests: PASS/FAIL (X passing, Y failing)
- Build: PASS/FAIL
- Lint: PASS/FAIL
- Uncommitted files: [count]

### In Progress
- [Current task description]
- [What was being worked on]

### Next Steps
1. [What should be done next]
2. [Follow-up items]

### Context
[Important context that would be lost on session end]
```

### 3. Save
Write the checkpoint to a predictable location that can be
found by `/continue` or session resumption.

## Usage
- Before ending a long session
- Before switching to a different task
- After completing a significant milestone
- Before risky operations (to mark a known-good state)
