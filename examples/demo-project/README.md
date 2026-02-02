# Demo Project

This is a minimal example showing claude-dotfiles in action.

## What This Demonstrates

1. **CLAUDE.md** - The configuration file that tells Claude about this project
2. **Project-specific settings** - `.claude/settings.json` with project overrides
3. **Real-world usage** - A simple Todo API that Claude can immediately work with

## Try It

```bash
# From this directory, start Claude Code
claude

# Ask Claude to:
# - "Explain this project structure"
# - "Add a new endpoint to mark all todos complete"
# - "Write a test for the delete endpoint"
# - "What are the gotchas I should know about?"
```

## What Claude Now Knows

Because of the CLAUDE.md file, Claude immediately understands:

- ✅ This is a TypeScript Express API
- ✅ Use `pnpm` for package management
- ✅ Tests are in `tests/` using Vitest
- ✅ Database functions go in `src/db/`
- ✅ Response format is `{ data }` or `{ error }`
- ✅ SQLite resets on restart (it's a demo)

## Compare: Without vs With CLAUDE.md

### Without CLAUDE.md

```
You: "Add a new endpoint"
Claude: "What framework are you using? Where should I put the route?
         What's your response format? Should I add tests?"
```

### With CLAUDE.md

```
You: "Add a new endpoint to get a single todo by ID"
Claude: *creates src/routes/todos.ts with GET /todos/:id*
        *returns { data: todo } format*
        *adds test in tests/todos.test.ts*
```

## Files

```
demo-project/
├── CLAUDE.md              # Project context for Claude
├── README.md              # This file
└── .claude/
    └── settings.json      # Project-specific permissions
```

This is a documentation-only example. For a full working project,
you would add the actual source code, package.json, etc.
