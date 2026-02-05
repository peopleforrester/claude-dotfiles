---
description: Coordinate multi-agent workflow for complex tasks
---

# /orchestrate

Run a coordinated multi-agent workflow for complex tasks that benefit from
specialized perspectives.

## Arguments
- `$ARGUMENTS` — Description of the task to orchestrate

## Workflow

### 1. Planning Phase
Delegate to the **planner** agent:
- Break down the task into discrete, ordered subtasks
- Identify which agent is best suited for each subtask
- Present the plan for user approval

### 2. Execution Phase
For each subtask in order:
1. Delegate to the appropriate agent
2. Collect the agent's output
3. Verify the output meets acceptance criteria
4. If issues found, iterate with the agent or escalate

### 3. Integration Phase
After all subtasks complete:
1. Run the **code-reviewer** agent on all changes
2. Run the **security-reviewer** agent if security-sensitive
3. Consolidate findings and present summary

### 4. Verification Phase
Run the `/verify` command to ensure:
- All tests pass
- No type errors
- No lint violations
- Security checks clean

## Agent Roster

| Agent | Use For |
|-------|---------|
| planner | Breaking down requirements |
| architect | System design decisions |
| tdd-guide | Test-first implementation |
| code-reviewer | Quality review |
| security-reviewer | Security audit |
| database-reviewer | Schema/query review |
| e2e-runner | E2E test creation |
| doc-updater | Documentation sync |

## Output

Present a summary:
- Tasks completed: X/Y
- Agents used: [list]
- Issues found: [count by severity]
- Final verdict: READY / NEEDS WORK
