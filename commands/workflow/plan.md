# /plan - Strategic Planning

Create a detailed implementation plan before coding.

## Usage

```
/plan [feature or task description]
```

## Examples

```
/plan user authentication with OAuth
/plan refactor the payment module
/plan add caching to API endpoints
```

## Workflow

When invoked, follow this planning process:

### 1. Requirements Gathering

Ask clarifying questions:
- What is the desired outcome?
- What are the constraints (time, tech stack, compatibility)?
- Are there existing patterns to follow?
- What are the acceptance criteria?

### 2. Research Phase

Before proposing solutions:
- Review relevant existing code
- Check for similar implementations in the codebase
- Identify dependencies and potential conflicts
- Note any technical debt that might be affected

### 3. Design Options

Present 2-3 approaches with trade-offs:

```markdown
## Option A: [Name]
**Approach**: [Brief description]
**Pros**: [Benefits]
**Cons**: [Drawbacks]
**Effort**: [Relative complexity]

## Option B: [Name]
...
```

### 4. Recommended Plan

After user selects approach, create detailed plan:

```markdown
## Implementation Plan: [Feature Name]

### Phase 1: Setup
- [ ] Task 1
- [ ] Task 2

### Phase 2: Core Implementation
- [ ] Task 3
- [ ] Task 4

### Phase 3: Testing
- [ ] Unit tests for X
- [ ] Integration tests for Y

### Phase 4: Documentation
- [ ] Update README
- [ ] Add inline documentation

### Files to Modify
- `src/auth/oauth.ts` - Add OAuth provider
- `src/config/auth.ts` - Add configuration
- `tests/auth/oauth.test.ts` - Add tests

### Dependencies
- [ ] Install `oauth-library`
- [ ] Configure environment variables

### Risks & Mitigations
| Risk | Mitigation |
|------|------------|
| [Risk 1] | [How to address] |
```

### 5. Confirmation

Before proceeding:
- Summarize the plan
- Confirm with user
- Get approval to begin implementation

## Output Format

The plan should be:
- Actionable (specific tasks, not vague goals)
- Ordered (dependencies respected)
- Testable (clear acceptance criteria)
- Documented (files and changes listed)

## Tips

- Break large features into smaller phases
- Identify the minimal viable implementation first
- Consider rollback strategies for risky changes
- Note integration points with existing systems
