## Description

Brief description of what this PR does.

## Type of Change

- [ ] New template (CLAUDE.md)
- [ ] New skill
- [ ] New hook
- [ ] New MCP configuration
- [ ] Bug fix
- [ ] Documentation update
- [ ] Other (describe below)

## Checklist

### For All PRs

- [ ] I've read [CONTRIBUTING.md](../CONTRIBUTING.md)
- [ ] My changes follow the existing code style
- [ ] I've tested my changes locally

### For Templates (CLAUDE.md)

- [ ] Token count is within budget (use `python scripts/token-count.py`)
- [ ] Includes required sections: Stack, Commands, Key Directories
- [ ] Has Gotchas section with real gotchas
- [ ] Header comment includes token count

### For Skills (SKILL.md)

- [ ] Valid YAML frontmatter with `name` and `description`
- [ ] `name` is lowercase with hyphens, ≤64 chars
- [ ] `description` is ≤1024 chars
- [ ] Includes "When to Use" section
- [ ] Has concrete examples

### For Hooks

- [ ] JSON is valid (run `python scripts/validate.py`)
- [ ] Includes usage comments
- [ ] Tested on target platform(s)
- [ ] Handles errors gracefully (`|| true` pattern)

### For Settings/MCP

- [ ] JSON is valid
- [ ] Sensitive values use placeholders
- [ ] Includes setup instructions in comments

## Testing

How did you test this?

## Screenshots (if applicable)

Before/after or demonstration of the feature.

## Related Issues

Closes #(issue number)
