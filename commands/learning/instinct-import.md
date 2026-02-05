---
description: Import instincts from teammates or community collections
---

# /instinct-import

Import instincts from external sources (teammates, community, exported files).

## Arguments
- `$ARGUMENTS` — Path to instinct file, directory, or URL

## Process

### 1. Source Detection
Identify the source format:
- Single `.md` file: Import one instinct
- Directory: Import all instincts from directory
- JSON/YAML file: Import structured instinct collection

### 2. Validation
For each instinct being imported:
- Verify required fields (id, trigger, confidence, domain)
- Check for conflicts with existing instincts (same id or overlapping trigger)
- Validate confidence score is in range [0.1, 0.9]

### 3. Conflict Resolution

```markdown
## Import Conflicts

| Instinct | Existing | Incoming | Resolution |
|----------|----------|----------|------------|
| prefer-const | 0.7 (personal) | 0.5 (imported) | Keep higher (0.7) |
| use-errgroup | — | 0.6 (imported) | Import as new |
| validate-zod | 0.9 (personal) | 0.8 (imported) | Keep existing |
```

**Merge strategies:**
- **Higher confidence wins** (default): Keep whichever has higher confidence
- **Incoming wins**: Override with imported values
- **Flag for review**: Mark conflicts for manual resolution

### 4. Storage
Imported instincts are stored in:
```
~/.claude/instincts/inherited/
  teammate-prefer-const.md
  community-use-errgroup.md
```

Each imported instinct is tagged with:
- `source: imported`
- `imported_from: [filename or teammate]`
- `imported_at: [timestamp]`
- `original_confidence: [score]`

### 5. Report

```markdown
## Import Complete

- Imported: 5 instincts
- Skipped (conflicts): 2
- New domains discovered: 1 (database)
- Run `/instinct-status` to review
```
