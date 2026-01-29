---
name: commit-helper
description: |
  Write clear, conventional commit messages. Use when the user asks to commit
  changes, needs help with commit messages, or when following Conventional
  Commits specification is required.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: michaelrishiforrester
  version: "1.0.0"
  tags:
    - git
    - commits
    - workflow
---

# Commit Helper

Write clear, meaningful commit messages following conventions.

## When to Use

- User asks to commit changes
- Help writing commit messages
- Following Conventional Commits
- Preparing commits for PR

## Conventional Commits Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type (Required)

| Type | Use For |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, whitespace (not CSS) |
| `refactor` | Code change that neither fixes nor adds |
| `perf` | Performance improvement |
| `test` | Adding or fixing tests |
| `build` | Build system or dependencies |
| `ci` | CI configuration |
| `chore` | Maintenance tasks |
| `revert` | Reverting previous commit |

### Scope (Optional)

The area of the codebase:

```
feat(auth): add OAuth login
fix(api): resolve timeout issue
docs(readme): update installation steps
```

### Subject (Required)

- Imperative mood: "add" not "added" or "adds"
- Lowercase first letter
- No period at end
- Max 50 characters

### Body (Optional)

- Explain "what" and "why", not "how"
- Wrap at 72 characters
- Blank line between subject and body

### Footer (Optional)

- Breaking changes: `BREAKING CHANGE: description`
- Issue references: `Fixes #123`, `Closes #456`

## Examples

### Simple Feature

```
feat: add user profile page
```

### Feature with Scope

```
feat(auth): add password reset functionality
```

### Bug Fix with Issue Reference

```
fix(cart): resolve incorrect total calculation

The cart total was not including the shipping cost
when calculating the final amount.

Fixes #234
```

### Breaking Change

```
feat(api)!: change authentication to OAuth 2.0

BREAKING CHANGE: The /auth/login endpoint now requires
OAuth 2.0 credentials instead of username/password.

Migration guide: https://docs.example.com/oauth-migration
```

### Refactoring

```
refactor(utils): extract date formatting to separate module

Moved date formatting functions from utils.ts to
dates.ts for better organization and reusability.
```

### Multiple Changes

If commits have unrelated changes, split them:

```bash
# Bad: one commit with unrelated changes
git commit -m "fix: login bug and add profile page"

# Good: separate commits
git commit -m "fix(auth): resolve login timeout issue"
git commit -m "feat(profile): add user profile page"
```

## Commit Message Process

### 1. Check What Changed

```bash
git status
git diff --staged
```

### 2. Determine the Type

- Added something new? → `feat`
- Fixed a bug? → `fix`
- Only documentation? → `docs`
- Code reorganization? → `refactor`

### 3. Identify the Scope

What area of the code?
- `auth`, `api`, `ui`, `db`, `config`, etc.
- Skip if change is global

### 4. Write the Subject

- Start with verb: add, fix, update, remove, refactor
- Be specific but concise
- Focus on what, not how

### 5. Add Body if Needed

Include body when:
- Change is complex
- Context helps future readers
- Non-obvious decisions were made

## Good vs Bad Examples

### Subject Line

```
# Bad
fix: fixed the bug
feat: new feature added
update: updated some stuff

# Good
fix(cart): resolve race condition in checkout
feat(search): add fuzzy matching support
refactor(api): extract validation to middleware
```

### Body

```
# Bad (how, not why)
Changed the function to use a loop instead of recursion
and added a cache variable.

# Good (why)
The recursive implementation was causing stack overflow
on large datasets. Switched to iterative approach with
memoization to handle inputs up to 100k items.
```

## Commit Workflow

```bash
# Stage specific files
git add src/auth/login.ts src/auth/login.test.ts

# Write commit message
git commit -m "fix(auth): resolve session timeout issue

Sessions were expiring immediately due to incorrect
timestamp comparison. Fixed by using UTC timestamps.

Fixes #189"
```

## Amending Commits

```bash
# Amend last commit message
git commit --amend -m "new message"

# Add forgotten files to last commit
git add forgotten-file.ts
git commit --amend --no-edit
```

**Warning**: Don't amend commits that have been pushed.

## Commit Message Template

Create `.gitmessage` template:

```
# <type>(<scope>): <subject>
#
# <body>
#
# <footer>

# Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore
# Scope: auth, api, ui, db, etc. (optional)
# Subject: imperative, lowercase, no period, max 50 chars
# Body: what and why, wrap at 72 chars
# Footer: BREAKING CHANGE:, Fixes #, Closes #
```

Configure git:

```bash
git config --global commit.template ~/.gitmessage
```

## Quality Checklist

- [ ] Type is appropriate for the change
- [ ] Subject is imperative mood ("add" not "added")
- [ ] Subject is under 50 characters
- [ ] Subject doesn't end with period
- [ ] Body explains why, not how (if included)
- [ ] Breaking changes are marked
- [ ] Related issues are referenced
