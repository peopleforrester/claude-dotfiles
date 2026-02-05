<!-- Tokens: ~550 | Lines: 80 | Compatibility: Claude Code 2.1+ -->
# Agent Delegation Rules

When and how to use Claude Code subagents effectively for complex tasks.

## When to Delegate

### Use Subagents For
- Independent research tasks that don't depend on each other
- Parallel exploration of different parts of a codebase
- Deep analysis requiring separate, focused context
- Background tasks that don't need immediate results
- Tasks requiring a different model (Haiku for speed, Opus for depth)

### Keep in Main Agent
- Sequential tasks where each step depends on the previous
- Tasks requiring the full conversation history
- Quick operations that would complete in under 30 seconds
- Tasks needing user interaction or clarification
- Final decision-making that synthesizes multiple inputs

## Delegation Patterns

### Research Fan-Out
```
Main Agent: "Understand the codebase"
  ├── Subagent A (Haiku): "Map the authentication module"
  ├── Subagent B (Haiku): "Map the database schema"
  └── Subagent C (Haiku): "Map the API routes"
Main Agent: Synthesize findings → proceed with implementation
```

### Specialist Review
```
Main Agent: "Implement and verify feature"
  ├── [Implement feature in main context]
  ├── Subagent (Opus): "Security review of changes"
  └── Subagent (Sonnet): "Code quality review"
Main Agent: Address findings → finalize
```

### Background Processing
```
Main Agent: Working on feature A
  └── Subagent (background, Haiku): "Run full test suite"
Main Agent: Continue working, check results when ready
```

## Subagent Task Specification

### Always Include
```markdown
## Task
[Specific, bounded task description]

## Context
[Relevant background the subagent needs]

## Scope
[What files/directories to focus on]

## Success Criteria
[How to determine if the task is complete]

## Constraints
[What NOT to do, boundaries to respect]
```

### Always
- Give subagents specific, bounded tasks with clear deliverables
- Provide necessary context upfront (don't assume they know the conversation)
- Define explicit success criteria
- Specify which tools the subagent should use
- Aggregate and validate results before proceeding

### Never
- Delegate tasks that require user input or confirmation
- Create circular dependencies between subagents
- Spawn more than 3-5 parallel subagents (diminishing returns)
- Delegate security-sensitive operations without Opus model
- Assume subagent results are correct without verification

## Subagent Communication Format

### Task Assignment (Main → Subagent)
```markdown
## Task: [Clear title]
Analyze the authentication middleware for security vulnerabilities.

## Focus Files
- src/middleware/auth.ts
- src/utils/token.ts

## Deliverable
List of findings with severity, file:line, and remediation.
```

### Result Report (Subagent → Main)
```markdown
## Summary
[1-2 sentence outcome]

## Findings
1. [Finding with location and severity]
2. [Finding with location and severity]

## Recommendations
- [Actionable next step]
```

## Available Agents Reference

| Agent | Best For | Model |
|-------|----------|-------|
| planner | Feature planning, risk assessment | Opus |
| architect | System design, ADRs | Opus |
| code-reviewer | Quality review, style | Sonnet |
| security-reviewer | Vulnerability analysis | Opus |
| tdd-guide | Test-first development | Sonnet |
| build-resolver | Build/CI error fixing | Sonnet |
| doc-updater | Documentation maintenance | Haiku |
| refactor-cleaner | Dead code removal | Sonnet |
