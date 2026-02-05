---
description: Cluster related instincts into skills, commands, or agents
---

# /evolve

Analyze learned instincts and cluster related ones into higher-level
constructs: skills, commands, or agents.

## Arguments
- `$ARGUMENTS` — Optional: domain to evolve, or "analyze" for dry-run

## Process

### 1. Cluster Analysis
Group instincts by domain and identify clusters:

```markdown
## Cluster Analysis

### Cluster: TypeScript Code Style (5 instincts, avg confidence: 0.7)
- prefer-const-assertions (0.8)
- use-discriminated-unions (0.7)
- branded-types-for-ids (0.6)
- no-enum-use-const (0.7)
- type-imports-separate (0.7)

→ Candidate for: **Skill** (coding reference)

### Cluster: Input Validation (3 instincts, avg confidence: 0.8)
- validate-inputs-with-zod (0.9)
- check-auth-on-endpoints (0.8)
- sanitize-html-output (0.7)

→ Candidate for: **Rule** (always-enforce constraint)

### Cluster: Database Review (4 instincts, avg confidence: 0.6)
- check-n-plus-one (0.7)
- use-indexes-for-where (0.6)
- paginate-list-endpoints (0.5)
- use-transactions (0.6)

→ Candidate for: **Agent prompt enhancement** (add to database-reviewer)
```

### 2. Evolution Thresholds

| Target | Min Instincts | Min Avg Confidence | Criteria |
|--------|--------------|-------------------|----------|
| Skill | 3+ | 0.5 | Related workflow patterns |
| Rule | 3+ | 0.7 | Hard constraints (always/never) |
| Command | 3+ | 0.5 | User-invoked workflow |
| Agent enhancement | 4+ | 0.5 | Domain-specific expertise |

### 3. Generation
For approved clusters, generate the appropriate construct:

**Skill generation:**
```markdown
---
name: typescript-style-evolved
description: |
  Evolved from 5 learned instincts about TypeScript coding style.
  Covers const assertions, discriminated unions, branded types.
---
# TypeScript Style Patterns (Learned)
[Content synthesized from instinct evidence]
```

### 4. Output Location
Generated constructs are saved to:
```
~/.claude/evolved/
  skills/typescript-style-evolved/SKILL.md
  rules/input-validation-evolved.md
```

### 5. Report

```markdown
## Evolution Report

| Cluster | Size | Confidence | Evolved To | Status |
|---------|------|-----------|-----------|--------|
| TS Code Style | 5 | 0.7 | Skill | Created |
| Input Validation | 3 | 0.8 | Rule | Created |
| Database Review | 4 | 0.6 | Agent enhancement | Suggested |

### Next Steps
- Review generated files in `~/.claude/evolved/`
- Copy approved files to appropriate directories
- Run `/instinct-status` to see remaining unclustered instincts
```

## Dry Run
Use `/evolve analyze` to see cluster analysis without generating files.
