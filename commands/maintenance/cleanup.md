---
description: Clean up project files, remove cruft, and organize codebase
---

# /cleanup - Project Cleanup

Clean up project files, remove cruft, and organize codebase.

## Usage

```
/cleanup                     # Full cleanup scan
/cleanup --dead-code         # Find unused code
/cleanup --deps              # Find unused dependencies
/cleanup --files             # Find unnecessary files
```

## Cleanup Checklist

### 1. Unused Dependencies

```bash
# Node.js - find unused packages
npx depcheck

# Python - find unused imports
autoflake --check .
# or
ruff check . --select F401

# List explicitly:
npx depcheck --json | jq '.dependencies'
```

**Action**: Remove from package.json/requirements.txt

### 2. Dead Code

```bash
# JavaScript/TypeScript
npx ts-prune          # Find unused exports
npx unimported        # Find unused files

# Python
vulture .             # Find unused code

# General
grep -r "TODO\|FIXME\|HACK" src/
```

**Action**: Remove or document why it's kept

### 3. Temporary/Generated Files

Find and remove:

```markdown
## Files to Clean

### Build Artifacts
- [ ] dist/
- [ ] build/
- [ ] .next/
- [ ] __pycache__/
- [ ] *.pyc

### Logs
- [ ] *.log
- [ ] npm-debug.log
- [ ] yarn-error.log

### Editor/IDE
- [ ] .DS_Store
- [ ] Thumbs.db
- [ ] .idea/ (if not shared)
- [ ] .vscode/ (if not shared)

### Test Artifacts
- [ ] coverage/
- [ ] .nyc_output/
- [ ] .pytest_cache/

### Misc
- [ ] *.bak
- [ ] *.tmp
- [ ] *~
```

### 4. Git Cleanup

```bash
# Remove merged branches
git branch --merged main | grep -v main | xargs git branch -d

# Remove stale remote branches
git remote prune origin

# Find large files in history
git rev-list --objects --all | \
  git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
  awk '/^blob/ {print $3, $4}' | \
  sort -rn | head -20

# Clean up reflog
git reflog expire --expire=now --all
git gc --prune=now
```

### 5. Commented-Out Code

Find and evaluate:

```bash
# Find commented code blocks
grep -rn "// TODO\|# TODO\|/\*\|'''" src/

# Find disabled tests
grep -rn "\.skip\|@pytest.mark.skip\|xfail" tests/
```

**Decision criteria**:
- If needed: move to proper TODO with issue number
- If obsolete: delete completely
- If for reference: add to documentation

### 6. Duplicate Code

```bash
# JavaScript/TypeScript
npx jscpd src/

# Python
pylint --disable=all --enable=duplicate-code src/

# General
# Review similar file names
find . -name "*.ts" | xargs basename -a | sort | uniq -d
```

### 7. Configuration Cleanup

Review and clean:

```markdown
## Config Files to Review

### Package Configs
- [ ] package.json - remove unused scripts
- [ ] tsconfig.json - remove unused options
- [ ] .eslintrc - remove unused rules

### Environment
- [ ] .env.example - keep in sync with actual vars
- [ ] docker-compose.yml - remove unused services

### CI/CD
- [ ] .github/workflows/ - remove unused workflows
- [ ] .gitlab-ci.yml - clean up stages
```

## Cleanup Report Template

```markdown
## Project Cleanup Report

**Date**: [Date]
**Cleaned By**: [Name]

### Summary
| Category | Items Found | Items Removed | Size Freed |
|----------|-------------|---------------|------------|
| Dependencies | 5 | 3 | - |
| Dead code | 12 files | 10 files | 2.3 KB |
| Build artifacts | 1 dir | 1 dir | 45 MB |
| Git branches | 8 | 6 | - |

### Removed Dependencies
- lodash (unused)
- moment (replaced with date-fns)
- left-pad (unused)

### Removed Files
- src/components/OldButton.tsx (replaced by Button.tsx)
- src/utils/deprecated.ts (unused)
- tests/old-tests/ (obsolete tests)

### Kept (With Justification)
- src/legacy/adapter.ts - Still used by integration X

### Recommendations
- [ ] Consider replacing moment.js with lighter alternative
- [ ] Review src/utils for more cleanup opportunities
- [ ] Set up automated dead code detection
```

## Automation

Add to CI:

```yaml
# .github/workflows/cleanup-check.yml
name: Cleanup Check
on: [pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npx depcheck
      - run: npx ts-prune | grep -v "used in module"
```

## Maintenance Schedule

| Task | Frequency | Automated? |
|------|-----------|------------|
| Dependency audit | Weekly | Yes (Dependabot) |
| Dead code scan | Monthly | Partial |
| Branch cleanup | Monthly | Manual |
| Full cleanup | Quarterly | Manual |

## Tips

- Clean up as you go, not in big batches
- Add cleanup checks to CI
- Document why code is kept if it looks unused
- Use .gitignore properly to prevent cruft
- Review before deleting - some "dead" code is intentional
