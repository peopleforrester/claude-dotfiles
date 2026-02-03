---
name: pr-creator
description: |
  Create well-structured pull request descriptions. Use when the user wants to
  create a PR, needs help with PR descriptions, or is preparing changes for
  review. Generates clear titles and comprehensive descriptions.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - git
    - pull-request
    - workflow
---

# Pull Request Creator

Create clear, comprehensive pull request descriptions.

## When to Use

- User wants to create a PR
- Preparing changes for review
- Needs help with PR description
- Following team PR conventions

## PR Structure

```markdown
## Summary

Brief description of what this PR does (1-3 sentences).

## Changes

- Bullet point of change 1
- Bullet point of change 2
- Bullet point of change 3

## Testing

How these changes were tested.

## Screenshots (if applicable)

Visual changes before/after.

## Checklist

- [ ] Tests pass
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
```

## PR Template

```markdown
## Summary

<!-- What does this PR do? Why is it needed? -->

## Changes

<!-- List the specific changes made -->

-
-
-

## Type of Change

<!-- Check the relevant option -->

- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to change)
- [ ] Documentation update
- [ ] Refactoring (no functional changes)

## Testing

<!-- How did you test these changes? -->

- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed

### Test Instructions

<!-- Steps for reviewers to test -->

1.
2.
3.

## Screenshots

<!-- If applicable, add screenshots -->

| Before | After |
|--------|-------|
| image  | image |

## Related Issues

<!-- Link related issues -->

Fixes #
Relates to #

## Checklist

- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review
- [ ] I have added tests that prove my fix/feature works
- [ ] New and existing tests pass locally
- [ ] I have updated documentation as needed
- [ ] My changes generate no new warnings

## Additional Notes

<!-- Any additional context for reviewers -->
```

## Writing Good PR Titles

### Format

```
[type]: short description
```

### Examples

```
# Good
feat: add user authentication with OAuth
fix: resolve memory leak in image processing
docs: update API reference for v2 endpoints
refactor: extract payment logic to separate service

# Bad
Update code
Fixed stuff
WIP
asdf
```

### Guidelines

- Under 50 characters if possible
- Imperative mood ("add" not "added")
- No period at end
- Include type prefix

## Writing the Summary

Good summaries answer:
1. What does this change?
2. Why is it needed?
3. How does it work (briefly)?

### Example

```markdown
## Summary

Adds OAuth 2.0 authentication support to replace the legacy username/password
system. This enables SSO integration and improves security by eliminating
password storage.

The implementation uses Auth0 as the identity provider and includes automatic
token refresh handling.
```

## Listing Changes

Be specific and organized:

```markdown
## Changes

### API
- Add `POST /auth/oauth/callback` endpoint for OAuth flow
- Add `GET /auth/oauth/logout` endpoint
- Deprecate `POST /auth/login` (to be removed in v3)

### Frontend
- Add OAuth login button to login page
- Update auth context to handle OAuth tokens
- Add token refresh interceptor

### Configuration
- Add OAuth environment variables to `.env.example`
- Update deployment docs with new env requirements
```

## Testing Section

Explain how changes were verified:

```markdown
## Testing

### Automated Tests
- Added unit tests for OAuth token validation
- Added integration tests for OAuth callback flow
- All existing auth tests updated and passing

### Manual Testing
1. Tested OAuth flow with Google and GitHub providers
2. Verified token refresh works after expiration
3. Confirmed logout properly clears session
4. Tested error handling for invalid tokens

### Test Coverage
- Auth module: 94% → 96%
```

## Screenshots

For UI changes, show before/after:

```markdown
## Screenshots

### Login Page

| Before | After |
|--------|-------|
| ![old login](url) | ![new login](url) |

### Mobile View

![mobile screenshot](url)
```

## Handling Breaking Changes

Document clearly:

```markdown
## Breaking Changes

This PR includes breaking changes to the authentication API.

### What Changed
- `POST /auth/login` now returns OAuth tokens instead of session cookies
- The `user.sessionId` field has been removed

### Migration Guide
1. Update client to store tokens in localStorage
2. Include `Authorization: Bearer <token>` header on requests
3. Use `/auth/refresh` to renew expired tokens

### Timeline
- v2.5: Deprecation warning added
- v3.0: Legacy auth will be removed
```

## PR Size Guidelines

| Size | Lines Changed | Review Time |
|------|---------------|-------------|
| XS | < 50 | 5-10 min |
| S | 50-200 | 15-30 min |
| M | 200-500 | 30-60 min |
| L | 500-1000 | 1-2 hours |
| XL | > 1000 | Consider splitting |

**Tip**: Smaller PRs get reviewed faster and more thoroughly.

## Splitting Large PRs

If PR is too large, split by:

1. **Refactoring first**: Separate refactoring from feature
2. **Backend/Frontend**: Split by layer
3. **Feature flags**: Merge incomplete features behind flag
4. **Stacked PRs**: Chain dependent PRs

## Draft PRs

Use draft PRs for:
- Work in progress
- Early feedback requests
- CI validation before review

```bash
gh pr create --draft --title "WIP: Add OAuth support"
```

## Quality Checklist

Before requesting review:

- [ ] Title is clear and follows conventions
- [ ] Summary explains what and why
- [ ] All changes are listed
- [ ] Testing approach documented
- [ ] Screenshots for UI changes
- [ ] Breaking changes documented
- [ ] Related issues linked
- [ ] Self-review completed
- [ ] Tests pass
- [ ] No merge conflicts
