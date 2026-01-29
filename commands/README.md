# Slash Commands Guide

Slash commands are user-invokable workflows that you trigger with `/command` syntax.
They provide structured processes for common development tasks.

## Available Commands

### Workflow (`workflow/`)

| Command | Description |
|---------|-------------|
| [/plan](./workflow/plan.md) | Create implementation plans before coding |
| [/review](./workflow/review.md) | Perform thorough code reviews |
| [/deploy](./workflow/deploy.md) | Guide through deployment process |

### Git (`git/`)

| Command | Description |
|---------|-------------|
| [/pr](./git/pr.md) | Create well-structured pull requests |
| [/changelog](./git/changelog.md) | Generate changelog entries |

### Maintenance (`maintenance/`)

| Command | Description |
|---------|-------------|
| [/lint-fix](./maintenance/lint-fix.md) | Systematically fix linting errors |
| [/update-deps](./maintenance/update-deps.md) | Safely update dependencies |
| [/cleanup](./maintenance/cleanup.md) | Remove dead code and cruft |

## Using Commands

Invoke a command by typing `/` followed by the command name:

```
/plan user authentication with OAuth
/review src/auth/login.ts
/pr
/lint-fix
```

Commands can accept arguments:
- File paths: `/review src/components/Button.tsx`
- Descriptions: `/plan add caching to API`
- Flags: `/update-deps --security`

## Commands vs Skills

| Aspect | Commands | Skills |
|--------|----------|--------|
| Invocation | Explicit `/command` | Automatic based on context |
| Scope | Specific workflow | General capability |
| Structure | Step-by-step process | Guidelines and patterns |
| Output | Structured result | Varies |

### When to Use Commands

- You want a specific, structured workflow
- The task has clear start and end
- You want consistent output format

### When Skills Apply

- Claude detects relevant context automatically
- You mention skill-related keywords
- Task matches skill description

## Command Structure

Each command follows this pattern:

```markdown
# /command-name - Title

Description of what the command does.

## Usage

/command [arguments]

## Process

### Step 1: [Name]
What to do in this step.

### Step 2: [Name]
What to do in this step.

## Output Format

What the command produces.

## Tips

Helpful advice for using the command.
```

## Creating Custom Commands

### 1. Create Command File

```markdown
# /my-command - Description

## Usage
/my-command [args]

## Process
1. First step
2. Second step
3. Third step

## Output
What to produce
```

### 2. Save Location

- Global: `~/.claude/commands/my-command.md`
- Project: `.claude/commands/my-command.md`

### 3. Naming Conventions

- Use lowercase with hyphens
- Be descriptive but concise
- Group related commands in subdirectories

## Command Best Practices

### Do

- Provide clear step-by-step processes
- Include example invocations
- Define expected output format
- Add tips for common scenarios

### Don't

- Make commands too broad
- Duplicate skill functionality
- Skip the verification steps
- Assume context not provided

## Example Workflow

```
User: /plan add user notifications

Claude: [Follows /plan command]

1. Gathers requirements
   - What triggers notifications?
   - What channels? (email, push, in-app)
   - Any user preferences?

2. Reviews existing code
   - Checks for existing notification code
   - Identifies integration points

3. Proposes options
   - Option A: Simple email notifications
   - Option B: Full notification system

4. Creates detailed plan
   [Structured implementation plan]

5. Confirms with user
   Ready to proceed?
```

## Integration with Other Features

Commands can reference:
- **Skills**: Use `/plan` then invoke `tdd-workflow` skill
- **Hooks**: Commands may trigger hooks (e.g., formatting)
- **CLAUDE.md**: Commands respect project configuration

## Tips for Effective Commands

1. **Be specific**: `/review` is better than a general "look at code"
2. **Chain commands**: `/plan` → implement → `/review` → `/pr`
3. **Use with context**: Provide file paths or descriptions
4. **Follow the process**: Commands work best when steps are followed
