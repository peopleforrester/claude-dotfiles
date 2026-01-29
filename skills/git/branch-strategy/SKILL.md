---
name: branch-strategy
description: |
  Git branching strategies and workflows. Use when setting up a project's
  branching model, discussing Git workflow, or deciding between trunk-based
  and Git Flow approaches.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: michaelrishiforrester
  version: "1.0.0"
  tags:
    - git
    - workflow
    - branching
---

# Branch Strategy Guide

Choose and implement the right Git branching strategy.

## When to Use

- Setting up a new project's Git workflow
- Discussing branching strategies
- Deciding between trunk-based and feature branches
- Establishing team conventions

## Strategy Comparison

| Strategy | Best For | Team Size | Release Frequency |
|----------|----------|-----------|-------------------|
| Trunk-Based | Continuous deployment | Any | Daily/Hourly |
| GitHub Flow | Web apps, SaaS | Small-Medium | Daily/Weekly |
| Git Flow | Versioned releases | Medium-Large | Scheduled |

## Trunk-Based Development

### Overview

```
main ─────●─────●─────●─────●─────●─────●───→
          │     │     │           │     │
          └─●───┘     └─────●─────┘     └─●
          (short-lived feature branches)
```

### Characteristics

- Single main branch (`main` or `trunk`)
- Short-lived feature branches (< 1 day)
- Merge to main frequently
- Feature flags for incomplete work
- Continuous integration required

### Workflow

```bash
# Start feature
git checkout main
git pull
git checkout -b feat/add-login

# Work in small increments
git commit -m "feat: add login form"
git push -u origin feat/add-login

# Create PR same day
gh pr create --title "feat: add login form"

# Merge quickly (after review)
gh pr merge --squash
```

### When to Use

- Experienced team with good CI/CD
- Continuous deployment
- Feature flags available
- High test coverage

## GitHub Flow

### Overview

```
main ─────●─────────────●─────────────●───→
          │             │             │
          └──●──●──●────┘             │
          feature/login               │
                        └──●──●──●────┘
                        feature/dashboard
```

### Characteristics

- `main` is always deployable
- Feature branches for all changes
- PRs required for merging
- Deploy from `main` after merge

### Workflow

```bash
# Start feature
git checkout main
git pull
git checkout -b feature/user-dashboard

# Develop with multiple commits
git commit -m "feat: add dashboard layout"
git commit -m "feat: add metrics widgets"
git commit -m "test: add dashboard tests"
git push -u origin feature/user-dashboard

# Create PR
gh pr create --title "feat: add user dashboard"

# After review, merge
gh pr merge --squash

# Deploy main
```

### Branch Naming

```
feature/description    # New features
fix/description        # Bug fixes
docs/description       # Documentation
refactor/description   # Refactoring
test/description       # Test additions
```

### When to Use

- Web applications
- Continuous deployment
- Small to medium teams
- Simple release process

## Git Flow

### Overview

```
main     ─────●───────────────────●───────→
              │                   │
develop ──●───●───●───●───●───●───●───●───→
          │       │   │       │
          └─●─●───┘   │       │
          feature/a   │       │
                      └─●─●───┘
                      release/1.0
```

### Branches

| Branch | Purpose | Lifetime |
|--------|---------|----------|
| `main` | Production code | Permanent |
| `develop` | Integration branch | Permanent |
| `feature/*` | New features | Temporary |
| `release/*` | Release preparation | Temporary |
| `hotfix/*` | Production fixes | Temporary |

### Workflow

```bash
# Start feature
git checkout develop
git checkout -b feature/payment-system

# Develop
git commit -m "feat: add payment form"
git push -u origin feature/payment-system

# Merge to develop (via PR)
gh pr create --base develop

# Start release
git checkout develop
git checkout -b release/1.0.0

# Finalize release
git checkout main
git merge release/1.0.0
git tag v1.0.0
git checkout develop
git merge release/1.0.0

# Hotfix
git checkout main
git checkout -b hotfix/security-patch
# ... fix ...
git checkout main
git merge hotfix/security-patch
git tag v1.0.1
git checkout develop
git merge hotfix/security-patch
```

### When to Use

- Scheduled release cycles
- Multiple versions in production
- Larger teams
- QA/staging environments

## Branch Naming Conventions

### Format

```
<type>/<ticket>-<description>
```

### Examples

```
feature/AUTH-123-oauth-login
fix/BUG-456-cart-calculation
hotfix/SEC-789-xss-vulnerability
release/1.2.0
docs/update-api-reference
```

### Guidelines

- Use lowercase
- Use hyphens (not underscores)
- Include ticket number if applicable
- Keep description short but clear

## Environment Branches

### Setup

```
main      → Production
staging   → Staging environment
develop   → Development environment
```

### Promotion Flow

```
feature/* → develop → staging → main
                ↓         ↓       ↓
              Dev      Stage    Prod
```

### Automation

```yaml
# Deploy on merge to specific branches
on:
  push:
    branches:
      - main      # Deploy to production
      - staging   # Deploy to staging
      - develop   # Deploy to development
```

## Merge Strategies

### Squash Merge

```bash
gh pr merge --squash
```

- Combines all commits into one
- Clean history
- Best for feature branches

### Merge Commit

```bash
gh pr merge --merge
```

- Preserves all commits
- Creates merge commit
- Best for release branches

### Rebase

```bash
gh pr merge --rebase
```

- Linear history
- Rewrites commits
- Best for small changes

## Protected Branches

### Recommended Settings

```yaml
# main branch
- Require PR reviews: 1-2 reviewers
- Require status checks: CI must pass
- Require up-to-date branch
- No force pushes
- No deletions

# develop branch
- Require PR reviews: 1 reviewer
- Require status checks: CI must pass
```

## Migration Guide

### From Git Flow to Trunk-Based

1. Implement feature flags
2. Increase CI/CD coverage
3. Shorten branch lifetimes gradually
4. Remove `develop` branch
5. Merge directly to `main`

### From No Strategy to GitHub Flow

1. Protect `main` branch
2. Require PRs for all changes
3. Set up CI checks
4. Train team on workflow
5. Establish naming conventions

## Decision Checklist

Choose **Trunk-Based** if:
- [ ] Deploy multiple times per day
- [ ] Have strong CI/CD
- [ ] Can use feature flags
- [ ] Team is experienced

Choose **GitHub Flow** if:
- [ ] Deploy daily to weekly
- [ ] Want simple workflow
- [ ] Don't need versioned releases
- [ ] Small to medium team

Choose **Git Flow** if:
- [ ] Have scheduled releases
- [ ] Need multiple versions
- [ ] Have QA process
- [ ] Larger team with roles
