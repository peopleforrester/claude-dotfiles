---
description: Execute an approved multi-agent plan
---

# /multi-execute

Execute a previously approved plan using coordinated agents.
Requires an approved plan from `/multi-plan` or `/orchestrate`.

## Arguments
- `$ARGUMENTS` — Phase to execute (e.g., "phase 1") or "all" for sequential execution

## Process

### 1. Load Plan
Read the approved plan and identify:
- Current phase to execute
- Agent assignments
- Acceptance criteria
- Dependencies

### 2. Execute Phase
For the specified phase:
1. Delegate implementation to the **tdd-guide** agent
2. Follow TDD workflow (test first, then implement)
3. Run all tests to verify
4. Delegate review to the assigned review agent

### 3. Gate Check
Between phases, verify:
- [ ] All tests pass
- [ ] No type errors
- [ ] No lint violations
- [ ] Code review approved
- [ ] Security review passed (if applicable)

### 4. Progress Report

```markdown
## Execution Progress

### Phase [N]: [Name]
- Status: COMPLETE / IN PROGRESS / BLOCKED
- Tests: X passing, Y failing
- Review: APPROVED / PENDING / CHANGES REQUESTED

### Overall Progress
[====>                    ] 2/5 phases complete

### Next Phase
[Description of what's next]
```

If any gate check fails, stop and report the issue rather than
proceeding to the next phase.
