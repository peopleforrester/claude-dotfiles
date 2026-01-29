---
name: changelog-writer
description: |
  Generate and maintain changelogs following Keep a Changelog and Conventional
  Commits standards. Use when releasing versions, documenting changes, or
  updating project history.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: michaelrishiforrester
  version: "1.0.0"
  tags:
    - documentation
    - changelog
    - release
---

# Changelog Writer

Create and maintain changelogs following industry standards.

## When to Use

- Preparing a new release
- Documenting recent changes
- Creating initial changelog
- Migrating to standard format

## Changelog Format

Following [Keep a Changelog](https://keepachangelog.com/):

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New feature description

### Changed
- Modified behavior description

### Deprecated
- Soon-to-be removed feature

### Removed
- Removed feature description

### Fixed
- Bug fix description

### Security
- Security fix description

## [1.0.0] - 2026-01-15

### Added
- Initial release
- Core functionality

[Unreleased]: https://github.com/user/repo/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/user/repo/releases/tag/v1.0.0
```

## Change Categories

| Category | Use For |
|----------|---------|
| **Added** | New features |
| **Changed** | Changes in existing functionality |
| **Deprecated** | Features to be removed in future |
| **Removed** | Features removed in this release |
| **Fixed** | Bug fixes |
| **Security** | Security vulnerability fixes |

## Writing Good Entries

### Do

```markdown
### Added
- Add user authentication with JWT tokens
- Add rate limiting (100 requests/minute per IP)
- Add CSV export for reports

### Fixed
- Fix memory leak when processing large files (#234)
- Fix incorrect timezone handling in date picker
```

### Don't

```markdown
### Added
- Added stuff
- New feature
- Updates

### Fixed
- Fixed bug
- Fix issue
```

## Entry Guidelines

### Be Specific

```markdown
# Bad
- Fixed a bug

# Good
- Fix crash when uploading files larger than 10MB (#156)
```

### Include Context

```markdown
# Bad
- Changed the API

# Good
- Change `/users` endpoint to require authentication (BREAKING)
```

### Reference Issues/PRs

```markdown
- Add dark mode support (#234)
- Fix memory leak in image processor (fixes #189)
```

### Indicate Breaking Changes

```markdown
### Changed
- **BREAKING**: Rename `getUser()` to `fetchUser()` for consistency
- **BREAKING**: Remove deprecated `v1` API endpoints
```

## Conventional Commits to Changelog

Map commit types to changelog categories:

| Commit Type | Changelog Category |
|-------------|-------------------|
| `feat:` | Added |
| `fix:` | Fixed |
| `docs:` | (usually not included) |
| `style:` | (usually not included) |
| `refactor:` | Changed (if user-facing) |
| `perf:` | Changed |
| `test:` | (usually not included) |
| `chore:` | (usually not included) |
| `BREAKING CHANGE:` | Changed/Removed |

### Example Commits to Entries

```
feat: add user profile page
fix: resolve login timeout issue (#123)
feat!: change authentication to OAuth 2.0
```

Becomes:

```markdown
### Added
- Add user profile page

### Changed
- **BREAKING**: Change authentication to OAuth 2.0

### Fixed
- Resolve login timeout issue (#123)
```

## Version Numbering

Following [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH

1.0.0 → 1.0.1  (patch: bug fixes)
1.0.1 → 1.1.0  (minor: new features, backward compatible)
1.1.0 → 2.0.0  (major: breaking changes)
```

### When to Bump

| Change Type | Version Bump |
|-------------|--------------|
| Bug fix (backward compatible) | PATCH |
| New feature (backward compatible) | MINOR |
| Breaking change | MAJOR |
| Security fix | PATCH (or MINOR if new feature) |

## Release Checklist

When preparing a release:

1. [ ] Move items from `[Unreleased]` to new version section
2. [ ] Add release date: `## [1.2.0] - 2026-01-15`
3. [ ] Update comparison links at bottom
4. [ ] Remove empty categories
5. [ ] Review for clarity and completeness
6. [ ] Commit changelog with version bump

## Automation Tools

### Conventional Changelog

```bash
npx conventional-changelog -p angular -i CHANGELOG.md -s
```

### Release Please

```yaml
# .github/workflows/release.yml
- uses: google-github-actions/release-please-action@v4
  with:
    release-type: node
```

### Changesets

```bash
npx changeset        # Create changeset
npx changeset version # Update versions
```

## Template: Initial Changelog

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - YYYY-MM-DD

### Added
- Initial release
- [List initial features]

[Unreleased]: https://github.com/user/repo/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/user/repo/releases/tag/v0.1.0
```
