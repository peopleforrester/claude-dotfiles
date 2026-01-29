# Skills System Guide

Skills are reusable instructions that help Claude perform specific tasks effectively.
This directory contains curated, production-ready skills organized by category.

## What Are Skills?

Skills are markdown files with YAML frontmatter that provide:

- **Context**: When to use the skill
- **Instructions**: How to perform the task
- **Examples**: Concrete patterns and templates
- **Checklists**: Quality assurance items

## Available Skills

### Development (`development/`)

| Skill | Description |
|-------|-------------|
| [tdd-workflow](./development/tdd-workflow/SKILL.md) | Test-driven development workflow |
| [code-reviewer](./development/code-reviewer/SKILL.md) | Systematic code review process |
| [api-designer](./development/api-designer/SKILL.md) | REST/GraphQL API design patterns |
| [refactoring-guide](./development/refactoring-guide/SKILL.md) | Safe refactoring techniques |
| [debugging-assistant](./development/debugging-assistant/SKILL.md) | Systematic debugging approach |

### Documentation (`documentation/`)

| Skill | Description |
|-------|-------------|
| [readme-generator](./documentation/readme-generator/SKILL.md) | Create comprehensive READMEs |
| [changelog-writer](./documentation/changelog-writer/SKILL.md) | Conventional changelog format |
| [api-docs](./documentation/api-docs/SKILL.md) | API documentation generation |

### Git (`git/`)

| Skill | Description |
|-------|-------------|
| [commit-helper](./git/commit-helper/SKILL.md) | Conventional commit messages |
| [pr-creator](./git/pr-creator/SKILL.md) | Pull request descriptions |
| [branch-strategy](./git/branch-strategy/SKILL.md) | Git branching workflows |

### Quality (`quality/`)

| Skill | Description |
|-------|-------------|
| [security-auditor](./quality/security-auditor/SKILL.md) | Security vulnerability review |
| [performance-reviewer](./quality/performance-reviewer/SKILL.md) | Performance optimization |
| [accessibility-checker](./quality/accessibility-checker/SKILL.md) | WCAG accessibility audit |

## Using Skills

### In Claude Code

Skills in `~/.claude/skills/` are automatically available. Claude will use them
based on context clues in your requests:

```
You: "Let's use TDD to build this feature"
Claude: [Uses tdd-workflow skill]

You: "Review this code for security issues"
Claude: [Uses security-auditor skill]
```

### Manual Invocation

You can explicitly request a skill:

```
You: "Use the code-reviewer skill to review this PR"
```

### Project-Specific Skills

Place skills in `.claude/skills/` for project-specific skills that override
or supplement global skills.

## Installing Skills

### Via Install Script

```bash
./install.sh --skills
```

### Manual Installation

```bash
# Global skills
cp -r skills/* ~/.claude/skills/

# Project skills
cp -r skills/development/tdd-workflow .claude/skills/
```

## Creating Custom Skills

### Directory Structure

```
skill-name/
├── SKILL.md           # Required: Main skill definition
├── REFERENCE.md       # Optional: Extended documentation
├── templates/         # Optional: Template files
│   └── example.md
└── scripts/           # Optional: Helper scripts
    └── helper.py
```

### SKILL.md Format

```yaml
---
name: skill-name                    # Required: lowercase, hyphens, max 64 chars
description: |                      # Required: max 1024 chars
  Clear description of when and why to use this skill.
  Include trigger phrases and keywords.
license: MIT                        # Optional: SPDX identifier
compatibility: Claude Code 2.1+     # Optional: Version requirement
metadata:                           # Optional
  author: your-username
  version: "1.0.0"
  tags:
    - category
    - topic
---

# Skill Title

Brief introduction to what this skill does.

## When to Use

Describe scenarios that should trigger this skill:
- User asks for X
- When doing Y
- Before Z

## Instructions

Step-by-step guidance for Claude:

1. First, do this
2. Then, do that
3. Finally, verify

## Examples

Concrete examples with code:

\`\`\`typescript
// Example code here
\`\`\`

## Checklist

Quality assurance items:

- [ ] Item 1
- [ ] Item 2
```

### Best Practices

1. **Clear trigger phrases**: Include keywords that should activate the skill
2. **Actionable instructions**: Step-by-step guidance, not vague advice
3. **Concrete examples**: Real code, not pseudocode
4. **Checklists**: Quality gates for completion
5. **Appropriate scope**: One skill = one task type

### Skill Categories

| Category | Scope | Examples |
|----------|-------|----------|
| Development | Coding workflows | TDD, refactoring, debugging |
| Documentation | Writing docs | READMEs, changelogs, API docs |
| Git | Version control | Commits, PRs, branching |
| Quality | Code quality | Security, performance, a11y |
| Testing | Test strategies | Unit, integration, E2E |
| Deployment | Release process | CI/CD, migrations |

## Skill Locations

| Location | Scope | Priority |
|----------|-------|----------|
| `.claude/skills/` | Project | Highest |
| `~/.claude/skills/` | Global | Lower |

Project skills override global skills with the same name.

## Validation

Before using a skill, verify:

```bash
# Check YAML frontmatter is valid
./scripts/validate.py skills/development/tdd-workflow/SKILL.md
```

### Required Fields

- `name`: Lowercase with hyphens, max 64 characters
- `description`: Clear explanation, max 1024 characters

### Optional Fields

- `license`: SPDX identifier (MIT, Apache-2.0, etc.)
- `compatibility`: Minimum Claude Code version
- `metadata`: Author, version, tags

## Contributing Skills

1. Create skill following the format above
2. Test with Claude Code locally
3. Submit PR with:
   - SKILL.md with valid frontmatter
   - Examples that are tested and working
   - Clear description of when to use

See [CONTRIBUTING.md](../CONTRIBUTING.md) for detailed guidelines.

## Skill vs CLAUDE.md

| CLAUDE.md | Skills |
|-----------|--------|
| Project context | Task-specific instructions |
| Always loaded | Loaded when relevant |
| Commands, directories | Workflows, patterns |
| Project-specific | Reusable across projects |

Use CLAUDE.md for project info, skills for workflows.

## Troubleshooting

### Skill Not Loading

1. Check file location: `~/.claude/skills/` or `.claude/skills/`
2. Verify YAML frontmatter is valid
3. Check `name` field matches directory name

### Skill Not Triggering

- Include more trigger phrases in description
- Use explicit invocation: "Use the X skill"

### Conflicts Between Skills

Project skills (`.claude/skills/`) override global skills.
Rename one skill if they have different purposes.
