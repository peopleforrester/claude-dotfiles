---
description: Plan a complex task using multiple specialized agents
---

# /multi-plan

Create a comprehensive implementation plan by coordinating the planner
and architect agents for complex, multi-component tasks.

## Arguments
- `$ARGUMENTS` — Description of the feature or system to plan

## Process

### 1. Requirements Decomposition
Use the **planner** agent to:
- Break down requirements into components
- Identify dependencies between components
- Estimate effort for each component

### 2. Architecture Design
Use the **architect** agent to:
- Evaluate architectural approaches
- Define component boundaries and interfaces
- Create ADRs for significant decisions
- Produce system diagram

### 3. Integration Plan
Combine outputs into a unified plan:
- Ordered task list with dependencies
- Architecture decisions documented
- Risk assessment with mitigations
- Testing strategy per component

### 4. Output

```markdown
## Multi-Agent Plan: [Feature]

### Architecture
[ASCII diagram from architect]

### ADRs
[Key decisions from architect]

### Implementation Phases
[Ordered tasks from planner]

### Risk Matrix
[Combined risk assessment]

### Agent Assignments
| Phase | Primary Agent | Review Agent |
|-------|--------------|--------------|
| Phase 1 | tdd-guide | code-reviewer |
| Phase 2 | tdd-guide | security-reviewer |
```

**WAITING FOR CONFIRMATION** before proceeding to implementation.
