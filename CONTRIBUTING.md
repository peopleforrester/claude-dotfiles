# Contributing to claude-dotfiles

Thank you for your interest in contributing! This guide will help you get started.

## Types of Contributions

### CLAUDE.md Templates

**Location:** `claude-md/languages/`, `claude-md/frameworks/`, `claude-md/domains/`

Templates should follow these guidelines:

1. **Token budget**: 60-100 lines optimal, never exceed 150
2. **Include header comment** with token count:
   ```markdown
   <!-- Tokens: ~1,450 (target: 1,500) | Lines: 72 -->
   ```
3. **Required sections**: Stack, Commands, Key Directories
4. **Avoid**: Generic advice, rules enforceable by linters, obvious conventions

**Template structure:**
```markdown
<!-- Tokens: ~X (target: Y) | Lines: Z -->
# [Language/Framework] Project

[One-sentence description of typical project using this stack]

## Stack
- **Language**: [e.g., Python 3.12]
- **Framework**: [if applicable]
- **Package Manager**: [e.g., uv, npm, cargo]

## Commands
\`\`\`bash
[package-manager] run dev      # Start development
[package-manager] run test     # Run tests
[package-manager] run lint     # Lint code
[package-manager] run build    # Build for production
\`\`\`

## Key Directories
\`\`\`
src/
├── [dir]/    # [Purpose]
└── [dir]/    # [Purpose]
\`\`\`

## Code Standards
- [2-3 critical conventions only]

## Gotchas
- [Non-obvious behaviors]
- [Common mistakes]
```

### Skills

**Location:** `skills/[category]/[skill-name]/SKILL.md`

Skills must follow the SKILL.md specification:

```yaml
---
name: lowercase-with-hyphens     # Required, max 64 chars
description: |                    # Required, max 1024 chars
  Clear description of when and why to use this skill.
license: MIT                      # Recommended
compatibility: Claude Code 2.1+
metadata:
  author: your-github-username
  version: "1.0.0"
---

# Skill Title

## When to Use
[Specific scenarios and trigger phrases]

## Instructions
[Step-by-step guidance]

## Examples
[Concrete input/output examples]
```

**Categories:**
- `development/` - Coding workflows (TDD, refactoring)
- `documentation/` - Doc generation
- `git/` - Version control helpers
- `quality/` - Security, performance, accessibility
- `debugging/` - Troubleshooting workflows

### Hooks

**Location:** `hooks/[category]/`

Hook configurations should:

1. Be JSON files with clear naming: `[action]-on-[trigger].json`
2. Include comments explaining the hook's purpose
3. Provide platform variants if needed (macOS, Linux, Windows)

**Categories:**
- `formatters/` - Code formatting (prettier, black, rustfmt)
- `validators/` - Pre-commit checks, file protection
- `notifications/` - Desktop notifications
- `integrations/` - Third-party tool integration

### Settings Profiles

**Location:** `settings/permissions/`

New permission profiles should:

1. Include all sections with `"// SECTION":` comments
2. Always include the standard deny list
3. Document the use case in the file header

## Submission Process

### 1. Fork and Clone

```bash
git clone https://github.com/YOUR_USERNAME/claude-dotfiles.git
cd claude-dotfiles
```

### 2. Create a Branch

```bash
git checkout -b add-[type]-[name]
# Examples:
# add-template-django
# add-skill-security-auditor
# add-hook-eslint-formatter
```

### 3. Make Your Changes

Follow the guidelines above for your contribution type.

### 4. Validate

```bash
# Run validation script
./scripts/validate.py

# For CLAUDE.md templates, check token count
./scripts/token-count.py claude-md/frameworks/your-template.md
```

### 5. Test

For templates and skills, test with an actual Claude Code session:

```bash
mkdir /tmp/test-project && cd /tmp/test-project
cp -r path/to/your/template/* .
claude
# Ask Claude to describe the project setup
```

### 6. Submit PR

- Use a clear, descriptive title
- Reference any related issues
- Include test results or screenshots if applicable

## Quality Checklist

Before submitting:

- [ ] All JSON files parse without errors
- [ ] SKILL.md frontmatter is valid YAML
- [ ] Bash scripts pass shellcheck (if applicable)
- [ ] Token counts are documented for CLAUDE.md templates
- [ ] Tested with Claude Code 2.1+
- [ ] Cross-platform compatible (where applicable)

## Code Style

### Markdown
- Use ATX-style headers (`#`)
- One sentence per line in prose (for better diffs)
- Fenced code blocks with language specifier

### JSON
- Use `"// KEY":` pattern for comments
- 2-space indentation
- No trailing commas

### Bash
- POSIX-compliant when possible
- Include shebang: `#!/usr/bin/env bash`
- Quote variables: `"$VAR"` not `$VAR`

### Python
- Python 3.10+
- No external dependencies unless necessary
- Type hints encouraged

## Questions?

- Open an issue for questions or suggestions
- Tag with `question` or `discussion` label

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
