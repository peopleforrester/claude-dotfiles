---
description: Extract reusable patterns from the current session
---

# /learn

Analyze the current session to extract reusable patterns, conventions, and
lessons learned. Save them for future reference.

## Arguments
- `$ARGUMENTS` — Optional focus area (e.g., "error handling", "testing patterns")

## Process

### 1. Session Analysis
Review the current session for:
- Patterns that were applied repeatedly
- Conventions discovered in the codebase
- Solutions to problems encountered
- Anti-patterns that were corrected
- Architecture decisions made

### 2. Pattern Extraction
For each pattern found, document:

```markdown
### Pattern: [Name]
**Context**: When to apply this pattern
**Solution**: What to do
**Example**: Code or command example
**Source**: Where this was learned (file, session context)
```

### 3. Categorization
Group patterns by type:
- **Code Style**: Naming, formatting, organization
- **Architecture**: Structure, dependencies, boundaries
- **Testing**: Test patterns, fixtures, assertions
- **Error Handling**: Exception patterns, recovery strategies
- **Performance**: Optimization techniques, caching
- **Security**: Validation patterns, auth patterns

### 4. Output
Save extracted patterns to the project's documentation or
suggest additions to CLAUDE.md for the project.

## Integration
Patterns can be promoted to:
- **Rules** (always-follow constraints)
- **Skills** (reusable workflows)
- **CLAUDE.md entries** (project conventions)
