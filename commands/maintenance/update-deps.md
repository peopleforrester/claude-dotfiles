# /update-deps - Dependency Updates

Safely update project dependencies.

## Usage

```
/update-deps                 # Check and update all dependencies
/update-deps --minor         # Only minor/patch updates
/update-deps --security      # Security updates only
```

## Process

### 1. Check Current Status

```bash
# Node.js
npm outdated
# or
pnpm outdated

# Python
pip list --outdated
# or with uv
uv pip list --outdated

# Rust
cargo outdated

# Go
go list -m -u all
```

### 2. Check for Security Issues

```bash
# Node.js
npm audit
pnpm audit

# Python
pip-audit
safety check

# Rust
cargo audit

# Go
govulncheck ./...
```

### 3. Categorize Updates

| Category | Risk Level | Action |
|----------|------------|--------|
| Security patches | Critical | Update immediately |
| Patch versions (x.x.X) | Low | Usually safe |
| Minor versions (x.X.0) | Medium | Review changelog |
| Major versions (X.0.0) | High | Check breaking changes |

### 4. Update Strategy

#### Safe Updates First

```bash
# Node.js - patch updates only
npm update

# Or specific packages
npm update lodash express

# Python
pip install --upgrade package==x.x.x
```

#### Minor Updates

```bash
# Node.js - use npm-check-updates
npx npm-check-updates -u --target minor
npm install

# Python - update to latest minor
pip install 'package>=1.0,<2.0'
```

#### Major Updates (Careful!)

```bash
# Check breaking changes first
npm info package changelog

# Update one at a time
npm install package@latest

# Run tests after each
npm test
```

### 5. Verify Updates

After each update batch:

```bash
# Run tests
npm test

# Run type check
npm run typecheck

# Run build
npm run build

# Quick smoke test
npm run dev
```

## Update Report Template

```markdown
## Dependency Update Report

**Date**: [Date]
**Updated By**: [Name]

### Security Updates (Critical)
| Package | From | To | CVE |
|---------|------|-----|-----|
| lodash | 4.17.19 | 4.17.21 | CVE-2021-23337 |

### Patch Updates (Low Risk)
| Package | From | To |
|---------|------|-----|
| express | 4.18.1 | 4.18.2 |

### Minor Updates (Medium Risk)
| Package | From | To | Notes |
|---------|------|-----|-------|
| react | 18.2.0 | 18.3.0 | New hooks |

### Major Updates (Review Required)
| Package | From | To | Breaking Changes |
|---------|------|-----|------------------|
| typescript | 4.9.5 | 5.3.0 | See migration guide |

### Skipped Updates
| Package | Current | Latest | Reason |
|---------|---------|--------|--------|
| webpack | 4.46.0 | 5.89.0 | Major refactor needed |

### Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Build succeeds
- [ ] Manual smoke test
```

## Handling Breaking Changes

### Before Major Update

1. Read the changelog/migration guide
2. Check if project uses affected features
3. Estimate effort to update
4. Create a separate branch

### Migration Process

```markdown
## Migration: [Package] v[Old] → v[New]

### Breaking Changes That Affect Us
1. [Change 1] - Used in: [files]
2. [Change 2] - Used in: [files]

### Migration Steps
- [ ] Update package
- [ ] Fix [breaking change 1]
- [ ] Fix [breaking change 2]
- [ ] Update tests
- [ ] Update documentation

### Files Modified
- src/utils/helper.ts
- src/components/Button.tsx
```

## Lock File Management

Keep lock files in sync:

```bash
# Node.js - regenerate lock file
rm -rf node_modules package-lock.json
npm install

# Python - regenerate requirements
pip freeze > requirements.txt

# Or with pip-tools
pip-compile requirements.in
```

## Automated Updates

Consider automation tools:

```yaml
# Dependabot (.github/dependabot.yml)
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      development-dependencies:
        dependency-type: "development"
      production-dependencies:
        dependency-type: "production"
```

## Tips

- Update dependencies regularly (weekly/monthly)
- Don't let them get too far behind
- Pin exact versions in production
- Test thoroughly after updates
- Keep a changelog of dependency updates
- Consider using Renovate or Dependabot
