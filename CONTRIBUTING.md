# Contributing to claude-dotfiles

Thank you for your interest in contributing! This project aims to be the definitive
resource for Claude Code configurations, and community contributions are essential.

## Quick Links

- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Security Policy](SECURITY.md)
- [Issue Templates](.github/ISSUE_TEMPLATE/)

## Ways to Contribute

### 1. Add a New Template

We're always looking for CLAUDE.md templates for:

- **Languages**: Elixir, Scala, Kotlin, Swift, etc.
- **Frameworks**: Laravel, Svelte, Vue, Spring Boot, etc.
- **Domains**: Mobile apps, game dev, embedded systems, etc.

### 2. Add a New Skill

Skills that would be valuable:

- Testing strategies (E2E, integration, mocking)
- DevOps workflows (CI/CD, Docker, Kubernetes)
- Language-specific patterns

### 3. Add Hooks

Platform-specific hooks, formatters for other languages, or creative integrations.

### 4. Improve Documentation

- Fix typos or unclear explanations
- Add examples
- Translate to other languages

### 5. Report Issues

Found a bug? Have a suggestion? [Open an issue](../../issues/new/choose).

---

## Development Setup

```bash
# Clone the repository
git clone https://github.com/peopleforrester/claude-dotfiles.git
cd claude-dotfiles

# Set up development environment
make dev-setup

# Run tests
make test

# See all available commands
make help
```

## Contribution Guidelines

### For CLAUDE.md Templates

#### Token Budget

| Type | Target | Maximum |
|------|--------|---------|
| Minimal | 500 | 1,000 |
| Standard | 1,500 | 2,500 |
| Framework-specific | 1,800 | 3,000 |

Check your token count:
```bash
python scripts/token-count.py your-template.md
```

#### Required Sections

Every CLAUDE.md must include:

```markdown
<!-- Tokens: ~X (target: Y) | Lines: Z | Compatibility: Claude Code 2.1+ -->
# Project Name

One-sentence description.

## Stack
## Commands
## Key Directories
```

#### Recommended Sections

```markdown
## Code Standards    # 2-3 project-specific rules only
## Gotchas           # Non-obvious behaviors, things that break
## Architecture      # If non-trivial
```

#### What NOT to Include

- Generic advice ("write clean code")
- Linter-enforceable rules
- More than 100 lines
- Long prose paragraphs

### For Skills (SKILL.md)

#### Required Frontmatter

```yaml
---
name: skill-name          # lowercase, hyphens, ≤64 chars
description: |            # ≤1024 chars
  Clear description of when Claude should use this skill.
---
```

#### Required Sections

```markdown
# Skill Title

## When to Use
[Specific triggers and scenarios]

## Instructions
[Step-by-step guidance]

## Examples
[Concrete code examples]
```

#### Style Guide

- Use numbered lists for sequential steps
- Use bullet points for options
- Include real, runnable code examples
- Add a checklist at the end if applicable

### For Hooks

#### JSON Format

```json
{
  "// ABOUT": "Brief description",
  "// USAGE": "How to use this hook",
  "// REQUIRES": "Any dependencies",

  "PostToolUse": [...]
}
```

#### Best Practices

- End commands with `|| true` to prevent blocking
- Use `2>/dev/null` to suppress errors
- Test on target platform(s)
- Include platform variants if applicable

### For Settings/MCP

- Use `"// KEY":` comment pattern
- Never include real credentials
- Include setup instructions in comments
- Document all required environment variables

---

## Pull Request Process

### 1. Fork & Branch

```bash
# Fork on GitHub, then:
git clone https://github.com/YOUR-USERNAME/claude-dotfiles.git
git checkout -b feature/your-feature-name
```

### 2. Make Changes

- Follow the guidelines above
- Run `make test` before committing
- Write clear commit messages

### 3. Test

```bash
# Validate all configs
make validate

# Check token counts
make tokens

# Run full test suite
make test
```

### 4. Submit PR

- Fill out the PR template completely
- Link related issues
- Be responsive to feedback

---

## Style Guide

### File Naming

| Type | Convention | Example |
|------|------------|---------|
| Templates | lowercase with hyphens | `react-typescript.md` |
| Skills | lowercase with hyphens | `tdd-workflow/SKILL.md` |
| Hooks | descriptive with suffix | `prettier-on-save.json` |

### Markdown

- Use ATX headers (`#`, `##`, `###`)
- Use fenced code blocks with language identifiers
- Use tables for structured data
- Keep lines under 100 characters

### Code Examples

- Use realistic, runnable examples
- Include both the code and expected output
- Add comments explaining non-obvious parts

---

## Recognition

Contributors are recognized in:

- The README contributors section
- Release notes when their contribution ships
- The GitHub contributors graph

---

## Questions?

- Open a [discussion](../../discussions) for questions
- Check existing [issues](../../issues) for known problems
- Review the [README](README.md) for documentation

Thank you for contributing! 🙏
