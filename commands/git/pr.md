# /pr - Create Pull Request

Generate a well-structured pull request.

## Usage

```
/pr                    # Create PR for current branch
/pr [base-branch]      # Create PR targeting specific base
/pr main               # Create PR to main
```

## Process

### 1. Gather Information

Before creating the PR:

```bash
# Check current branch and status
git branch --show-current
git status

# Review commits to include
git log main..HEAD --oneline

# Review all changes
git diff main..HEAD
```

### 2. Analyze Changes

Examine the changes to understand:
- What features/fixes are included
- What files were modified
- Any breaking changes
- Dependencies added/removed

### 3. Generate PR

Create PR using GitHub CLI:

```bash
gh pr create \
  --title "feat: Add user authentication" \
  --body "$(cat <<'EOF'
## Summary

Brief description of what this PR does and why.

## Changes

- Added OAuth integration with Google
- Created user session management
- Added login/logout endpoints

## Testing

- [ ] Unit tests added for auth service
- [ ] Integration tests for OAuth flow
- [ ] Manual testing completed

## Screenshots

[If applicable]

## Checklist

- [ ] Tests pass
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] Reviewed my own code

## Related Issues

Closes #123
EOF
)"
```

## PR Title Format

Follow conventional commit format:

```
<type>: <description>

Types:
- feat:     New feature
- fix:      Bug fix
- docs:     Documentation only
- style:    Formatting, no code change
- refactor: Code change, no feature/fix
- perf:     Performance improvement
- test:     Adding tests
- chore:    Maintenance tasks
```

Examples:
```
feat: Add user authentication with OAuth
fix: Resolve cart calculation rounding error
docs: Update API documentation for v2
refactor: Extract payment processing to service
```

## PR Body Template

```markdown
## Summary

[1-2 sentences describing what this PR does]

## Motivation

[Why is this change needed? Link to issue/discussion]

## Changes

- [Change 1]
- [Change 2]
- [Change 3]

## Testing

Describe testing performed:
- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing

### Test Instructions

1. [Step 1]
2. [Step 2]
3. [Expected result]

## Screenshots

[If UI changes, include before/after screenshots]

| Before | After |
|--------|-------|
| [img]  | [img] |

## Breaking Changes

[List any breaking changes and migration steps]

## Checklist

- [ ] Tests pass locally
- [ ] Code follows project style
- [ ] Self-reviewed
- [ ] Documentation updated
- [ ] No sensitive data exposed

## Related

- Closes #[issue]
- Related to #[issue]
- Depends on #[PR]
```

## Size Guidelines

| Size | Lines Changed | Review Time |
|------|---------------|-------------|
| XS | < 50 | Minutes |
| S | 50-200 | < 1 hour |
| M | 200-500 | 1-2 hours |
| L | 500-1000 | Half day |
| XL | > 1000 | Consider splitting |

Prefer smaller PRs for faster reviews and easier rollbacks.

## Draft PRs

For work in progress:

```bash
gh pr create --draft \
  --title "WIP: Feature X" \
  --body "Work in progress - not ready for review"
```

Convert to ready when complete:
```bash
gh pr ready
```

## Tips

- Link to related issues with "Closes #123"
- Request specific reviewers if needed
- Add labels for categorization
- Use PR templates if project has them
- Keep PRs focused on single concern
