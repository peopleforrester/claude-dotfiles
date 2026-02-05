---
name: iterative-retrieval
description: |
  Progressive context refinement pattern for subagents. Solves the problem
  of agents not knowing what context they need until they start working.
  Uses a 4-phase loop: DISPATCH, EVALUATE, REFINE, LOOP.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags: [context, subagents, retrieval, optimization]
---

# Iterative Retrieval Pattern

Solve the subagent context problem: agents don't know what they need
until they start looking.

## The Problem

When delegating to subagents, you face a dilemma:
- **Send everything**: Context overflow, wasted tokens, confused agent
- **Send nothing**: Agent lacks context, produces poor results
- **Guess what's needed**: Often wrong, misses critical files

## The Solution: 4-Phase Iterative Loop

### Phase 1: DISPATCH
Send a broad initial query to gather candidate context:

```markdown
Search for files related to: [topic]
Keywords: [initial keywords]
File patterns: [likely patterns]
Return: File paths with relevance scores
```

### Phase 2: EVALUATE
Score each result for relevance (0.0 to 1.0):

```markdown
| File | Relevance | Reason |
|------|-----------|--------|
| src/auth/login.ts | 0.9 | Core auth logic |
| src/utils/hash.ts | 0.7 | Used by auth |
| src/config.ts | 0.3 | Has auth config section |
| src/routes.ts | 0.2 | Only references auth path |
```

Identify gaps:
- What terminology does this codebase use? (update search terms)
- What patterns are referenced but not found?
- What dependencies need exploration?

### Phase 3: REFINE
Update search criteria based on evaluation:

```markdown
Updated keywords: [refined keywords from codebase terminology]
New file patterns: [patterns discovered during evaluation]
Specific files to read: [high-relevance files]
Gaps to fill: [what's still missing]
```

### Phase 4: LOOP
Repeat phases 1-3 with refined criteria.

**Stopping Criteria:**
- 3+ files with relevance >= 0.7
- No critical gaps identified
- OR max 3 iterations reached (proceed with best available)

## Example: Finding Auth Implementation

**Iteration 1:**
- DISPATCH: Search for "auth", "login", "session"
- EVALUATE: Found middleware but not the auth service
- REFINE: Codebase uses "identity" not "auth"

**Iteration 2:**
- DISPATCH: Search for "identity", "credential", "token"
- EVALUATE: Found IdentityService, TokenManager, SessionStore
- Result: 5 files with relevance >= 0.8 — stop and proceed

## Implementation Pattern

```typescript
async function iterativeRetrieve(topic: string, maxIterations = 3) {
  let keywords = extractKeywords(topic);
  let context: FileContext[] = [];

  for (let i = 0; i < maxIterations; i++) {
    // DISPATCH
    const candidates = await searchCodebase(keywords);

    // EVALUATE
    const scored = await scoreRelevance(candidates, topic);
    context = mergeContext(context, scored.filter(s => s.relevance >= 0.5));

    // Check stopping criteria
    const highRelevance = context.filter(c => c.relevance >= 0.7);
    if (highRelevance.length >= 3) break;

    // REFINE
    keywords = refineKeywords(keywords, scored);
  }

  return context;
}
```

## When to Use

- Delegating research to a subagent
- Exploring unfamiliar codebases
- Gathering context for code review
- Building context for architectural analysis

## When NOT to Use

- You already know exactly what files are needed
- The task is in a single file
- The codebase is small enough to read entirely
