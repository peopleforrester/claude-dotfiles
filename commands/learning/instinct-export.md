---
description: Export instincts for sharing with teammates or backup
---

# /instinct-export

Export learned instincts for sharing with teammates or transferring to another machine.

## Arguments
- `$ARGUMENTS` — Optional: domain filter, output format, or output path

## Process

### 1. Select Instincts
By default, export all instincts with confidence >= 0.5.

Filters:
- `/instinct-export code-style` — Export only code-style domain
- `/instinct-export >0.7` — Export only strong instincts
- `/instinct-export all` — Export everything including tentative

### 2. Privacy Sanitization
Before export, strip sensitive information:
- Remove session IDs
- Remove absolute file paths (convert to relative patterns)
- Remove timestamps older than the instinct creation date
- Remove user-specific context

### 3. Output Formats

**Markdown (default):**
```markdown
---
id: prefer-const-assertions
trigger: "when defining constant arrays or objects in TypeScript"
confidence: 0.7
domain: code-style
---
# Use `as const` for constant definitions
TypeScript `as const` assertions provide literal types and readonly guarantees.
```

**JSON:**
```json
{
  "instincts": [
    {
      "id": "prefer-const-assertions",
      "trigger": "when defining constant arrays or objects in TypeScript",
      "confidence": 0.7,
      "domain": "code-style",
      "action": "Use `as const` for constant definitions"
    }
  ],
  "exported_at": "2026-02-05",
  "count": 1
}
```

### 4. Output Location
Default: `./instincts-export/` in the current directory.
With path argument: `/instinct-export ~/shared/my-instincts/`

### 5. Report

```markdown
## Export Complete

- Exported: 12 instincts across 4 domains
- Format: Markdown
- Location: ./instincts-export/
- Share with: `cp -r ./instincts-export/ ~/shared/team-instincts/`
- Import on other machine: `/instinct-import ./instincts-export/`
```
