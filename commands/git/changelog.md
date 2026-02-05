---
description: Generate changelog entries following Keep a Changelog format
---

# /changelog - Generate Changelog Entry

Create changelog entries following Keep a Changelog format.

## Usage

```
/changelog                    # Generate entry for recent changes
/changelog v1.2.0             # Generate entry for specific version
/changelog --unreleased       # Add to Unreleased section
```

## Process

### 1. Analyze Changes

Review commits since last release:

```bash
# Find last release tag
git describe --tags --abbrev=0

# List commits since last tag
git log v1.1.0..HEAD --oneline

# Or list commits since date
git log --since="2024-01-01" --oneline
```

### 2. Categorize Changes

Group changes into categories:

| Category | Description |
|----------|-------------|
| **Added** | New features |
| **Changed** | Changes in existing functionality |
| **Deprecated** | Soon-to-be removed features |
| **Removed** | Removed features |
| **Fixed** | Bug fixes |
| **Security** | Security vulnerability fixes |

### 3. Generate Entry

Format following [Keep a Changelog](https://keepachangelog.com/):

```markdown
## [1.2.0] - 2026-01-28

### Added
- User authentication with OAuth support (#123)
- Dark mode theme option (#145)
- Export data to CSV functionality

### Changed
- Improved dashboard loading performance by 40%
- Updated dependencies to latest versions

### Fixed
- Cart total calculation rounding error (#156)
- Mobile navigation menu not closing (#162)

### Security
- Patched XSS vulnerability in comment field

[1.2.0]: https://github.com/user/repo/compare/v1.1.0...v1.2.0
```

## Changelog File Structure

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- [New feature in development]

## [1.2.0] - 2026-01-28

### Added
- Feature X

### Fixed
- Bug Y

## [1.1.0] - 2026-01-15

### Added
- Feature Z

[Unreleased]: https://github.com/user/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/user/repo/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/user/repo/compare/v1.0.0...v1.1.0
```

## Writing Good Entries

### Do

- Write for users, not developers
- Be specific about what changed
- Include issue/PR numbers for reference
- Group related changes together
- Highlight breaking changes prominently

### Don't

- Include internal refactoring details
- List every commit
- Use technical jargon without explanation
- Forget to update version links

## Examples

### Good Entries

```markdown
### Added
- Email notifications for order status changes (#234)
- Support for multiple payment methods including Apple Pay

### Changed
- Dashboard now loads 3x faster due to lazy loading
- Minimum password length increased to 12 characters

### Fixed
- Users no longer logged out after password reset (#267)
- PDF export now includes all table columns (#271)

### Security
- Fixed SQL injection vulnerability in search (CVE-2026-1234)
```

### Bad Entries

```markdown
### Changed
- Updated code
- Fixed stuff
- Refactored components
- Merged PR #123
```

## Automation

### From Git Commits

If using conventional commits:

```bash
# Generate from conventional commits
git log v1.1.0..HEAD --pretty=format:"%s" | \
  grep -E "^(feat|fix|docs|style|refactor|perf|test|chore):" | \
  sort
```

### With Release Tools

```bash
# Using standard-version
npx standard-version

# Using release-please
# Configured via GitHub Actions
```

## Semantic Versioning Reference

When to bump versions:

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Breaking changes | Major (X.0.0) | 1.0.0 → 2.0.0 |
| New features | Minor (0.X.0) | 1.0.0 → 1.1.0 |
| Bug fixes | Patch (0.0.X) | 1.0.0 → 1.0.1 |

## Tips

- Update changelog with every PR (in Unreleased)
- Convert Unreleased to version on release
- Keep entries user-focused
- Link to full diff at bottom of file
- Consider audience: users vs developers
