<!-- Tokens: ~650 | Lines: 85 | Compatibility: Claude Code 2.1+ -->
# Git Workflow Rules

Constraints for consistent version control practices across all projects.

## Conventional Commits

### Format
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types
| Type | When to Use | Example |
|------|-------------|---------|
| `feat` | New feature for users | `feat(auth): add OAuth2 login` |
| `fix` | Bug fix for users | `fix(cart): prevent negative quantities` |
| `docs` | Documentation only | `docs(readme): add setup instructions` |
| `style` | Formatting, no logic change | `style(api): fix indentation` |
| `refactor` | Code change, no behavior change | `refactor(db): extract query builder` |
| `test` | Adding or fixing tests | `test(auth): add login edge cases` |
| `chore` | Build, deps, CI, tooling | `chore(deps): update vitest to 2.x` |
| `perf` | Performance improvement | `perf(search): add index on user_id` |
| `ci` | CI configuration changes | `ci: add type-check to pipeline` |

### Rules
- Description is imperative, present tense ("add" not "added")
- Description does not end with a period
- First line under 72 characters
- Body wraps at 72 characters
- Breaking changes noted with `BREAKING CHANGE:` footer

## Branch Workflow

### Always
- Branch from `main` (or `develop` if project uses gitflow)
- Use descriptive branch names: `feat/user-auth`, `fix/cart-total`, `docs/api-reference`
- Keep branches short-lived (merge within days, not weeks)
- Rebase on target branch before opening PR to avoid merge conflicts
- Delete branches after merge

### Never
- Commit directly to `main` or `staging` without a PR (except hotfixes with approval)
- Force push to shared branches (`main`, `staging`, `develop`)
- Merge without passing CI checks
- Leave stale branches for more than 2 weeks

## Pull Request Requirements

### Before Opening a PR
- [ ] All tests pass locally (`npm test`, `pytest`, `go test`)
- [ ] Lint passes with no errors
- [ ] Type checking passes (if applicable)
- [ ] Commit messages follow conventional format
- [ ] Branch is rebased on target (no unnecessary merge commits)
- [ ] Self-review completed (read your own diff)

### PR Description
```markdown
## Summary
[1-3 sentences describing what and why]

## Changes
- Specific change 1
- Specific change 2

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots (if UI changes)
[Before/after if applicable]
```

### PR Size Guidelines
| Size | Lines Changed | Review Approach |
|------|--------------|-----------------|
| Small | < 100 | Quick review |
| Medium | 100-400 | Standard review |
| Large | 400-800 | Break into smaller PRs if possible |
| Too Large | > 800 | Must be split |

## Merge Strategy

- **Squash merge** for feature branches (clean history)
- **Merge commit** for release branches (preserve history)
- **Rebase** for small fixes (linear history)

## Hotfix Protocol

For production-critical fixes:
1. Branch from `main`: `hotfix/description`
2. Fix and test
3. Open PR with `[HOTFIX]` prefix
4. Get expedited review
5. Merge to `main` and backport to `staging`/`develop`
