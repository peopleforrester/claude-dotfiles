<div align="center">

```
     ╭──────────────────────────────────────────╮
     │                                          │
     │          claude-dotfiles                 │
     │                                          │
     │     🧠  Give Claude Code a Memory  🧠    │
     │                                          │
     ╰──────────────────────────────────────────╯
```

**Production-ready configurations for Claude Code**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Claude Code 2.1+](https://img.shields.io/badge/Claude%20Code-2.1%2B-blueviolet)](https://docs.anthropic.com/claude-code)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)](#compatibility)
[![Built with Claude](https://img.shields.io/badge/Built%20with-Claude%20Code-orange)](BUILT_WITH_CLAUDE.md)

[Quick Start](#-quick-start) •
[Why This Exists](#-why-this-exists) •
[What's Included](#-whats-included) •
[Documentation](#-documentation)

</div>

---

## 🤔 Why This Exists

**Without configuration**, Claude Code starts every session with zero context about your project:

```
You: "Run the tests"
Claude: "What test framework do you use? What's the command?"

You: "Use our API client"
Claude: "I don't see an API client. Where is it located?"

You: "Follow our coding standards"
Claude: "What are your coding standards?"
```

**With claude-dotfiles**, Claude remembers everything:

```
You: "Run the tests"
Claude: *runs `pytest -v`*

You: "Use our API client"
Claude: *imports from src/lib/api.ts*

You: "Follow our coding standards"
Claude: *uses your error handling pattern, naming conventions, etc.*
```

**One-time setup. Permanent memory.**

---

## ⚡ Quick Start

**30 seconds to a smarter Claude:**

```bash
# Clone and install
git clone https://github.com/peopleforrester/claude-dotfiles.git ~/.claude-dotfiles
cd ~/.claude-dotfiles
./install.sh

# Copy a template to your project
cp templates/standard/CLAUDE.md ~/your-project/CLAUDE.md

# Edit it for your project
# Then start Claude Code - it now knows your project!
```

<details>
<summary><strong>Other installation methods</strong></summary>

**One-command install (when public):**
```bash
curl -fsSL https://raw.githubusercontent.com/peopleforrester/claude-dotfiles/main/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/peopleforrester/claude-dotfiles/main/install.ps1 | iex
```

**Using Make:**
```bash
make install        # Interactive
make install-all    # Everything
make install-minimal # Just essentials
```

</details>

---

## 📦 What's Included

| You Get | What It Does | Files |
|---------|--------------|-------|
| **[CLAUDE.md Templates](./claude-md/)** | Tell Claude about your project's stack, commands, and conventions | 13 templates |
| **[Rules](./rules/)** | Always-follow constraints (security, style, testing, git) | 7 rules |
| **[Agents](./agents/)** | Specialized personas (planner, architect, reviewer, TDD guide) | 9 agents |
| **[Commands](./commands/)** | Slash commands (/tdd, /verify, /code-review, /security-review) | 7 commands |
| **[Skills](./skills/)** | Pattern libraries (React, Next.js, FastAPI, Django, Rust, Go, TS, Python) | 22 skills |
| **[Hooks](./hooks/)** | Automate actions (format on save, notifications) | 13 hooks |
| **[Settings](./settings/)** | Control what Claude can do automatically | 3 profiles |
| **[MCP Configs](./mcp/)** | Connect Claude to GitHub, databases, Slack | 10 configs |

### Starter Templates

| Template | Best For | Get Started |
|----------|----------|-------------|
| **[Minimal](./templates/minimal/)** | Quick projects, learning | `cp templates/minimal/CLAUDE.md .` |
| **[Standard](./templates/standard/)** | Most projects ⭐ | `cp templates/standard/CLAUDE.md .` |
| **[Power User](./templates/power-user/)** | Full automation | `cp -r templates/power-user/.* .` |

### Stack-Specific Templates

| Stack | Template |
|-------|----------|
| React + TypeScript | [`templates/stacks/react-typescript/`](./templates/stacks/react-typescript/) |
| Python + FastAPI | [`templates/stacks/python-fastapi/`](./templates/stacks/python-fastapi/) |
| Next.js Fullstack | [`templates/stacks/nextjs-fullstack/`](./templates/stacks/nextjs-fullstack/) |

### Language & Framework Templates

Browse [`claude-md/`](./claude-md/) for templates covering:
- **Languages:** Python, TypeScript, Rust, Go
- **Frameworks:** React, Next.js, FastAPI, Rails, Django
- **Domains:** APIs, CLI tools, libraries, monorepos

### Rules System

Rules are always-loaded constraints that Claude follows automatically:

| Rule | What It Enforces |
|------|------------------|
| **[security.md](./rules/security.md)** | OWASP Top 10, secrets management, input validation |
| **[coding-style.md](./rules/coding-style.md)** | Immutability, file organization, naming conventions |
| **[testing.md](./rules/testing.md)** | TDD workflow, 80% coverage minimum |
| **[git-workflow.md](./rules/git-workflow.md)** | Conventional commits, PR process |
| **[performance.md](./rules/performance.md)** | Model selection, context management |
| **[agents.md](./rules/agents.md)** | When to delegate to subagents |

### Agents

Specialized personas you can invoke for focused tasks:

| Agent | Expertise | Command |
|-------|-----------|---------|
| **[planner](./agents/planner.md)** | Implementation planning, risk assessment | `/plan` |
| **[architect](./agents/architect.md)** | System design, ADRs, trade-offs | `/architect` |
| **[code-reviewer](./agents/code-reviewer.md)** | Quality, security, maintainability review | `/code-review` |
| **[security-reviewer](./agents/security-reviewer.md)** | OWASP vulnerability analysis | `/security-review` |
| **[tdd-guide](./agents/tdd-guide.md)** | Red-green-refactor enforcement | `/tdd` |
| **[build-resolver](./agents/build-resolver.md)** | Build/CI error diagnosis | `/build-fix` |
| **[doc-updater](./agents/doc-updater.md)** | Documentation maintenance | `/update-docs` |
| **[refactor-cleaner](./agents/refactor-cleaner.md)** | Dead code removal | `/refactor-clean` |

### Slash Commands

| Command | What It Does |
|---------|--------------|
| `/tdd` | Start TDD workflow (red-green-refactor) |
| `/verify` | Pre-PR quality gate (8-step verification loop) |
| `/code-review` | Comprehensive code review with severity levels |
| `/security-review` | OWASP-based security audit |
| `/build-fix` | Diagnose and fix build errors |
| `/refactor-clean` | Find and remove dead code |
| `/update-docs` | Sync documentation with code changes |

---

## 🛡️ Permission Profiles

Control how much autonomy Claude has:

| Profile | Claude Can... | Best For |
|---------|---------------|----------|
| **Conservative** | Read files, ask before changes | Learning, sensitive projects |
| **Balanced** ⭐ | Edit files, ask before shell commands | Daily development |
| **Autonomous** | Most actions without asking | Trusted automation |

All profiles block access to `.env`, `~/.ssh/`, `~/.aws/`, and dangerous commands.

```bash
./install.sh --profile balanced  # Recommended
```

---

## 📚 Documentation

| Guide | What You'll Learn |
|-------|-------------------|
| [CLAUDE.md Best Practices](./claude-md/README.md) | Write effective project context |
| [Skills Guide](./skills/README.md) | Use and create skills |
| [Hooks Cookbook](./hooks/README.md) | Automate your workflow |
| [Settings Reference](./settings/README.md) | Configure permissions |
| [MCP Setup](./mcp/README.md) | Connect external services |
| [Troubleshooting](./TROUBLESHOOTING.md) | Fix common issues |

---

## 🔧 Development

```bash
make test       # Run all tests
make validate   # Validate configs
make tokens     # Check token counts
make stats      # Show repo statistics
make help       # See all commands
```

---

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](./CONTRIBUTING.md).

**Most Wanted:**
- Templates for Laravel, Vue, Svelte, Go frameworks
- Industry-specific configs
- Translations

---

## 🌟 Built with Claude Code

This entire repository was built in a single Claude Code session.

100+ files, 15,000+ lines, created by Claude to help Claude work better.

**[Read the full story →](./BUILT_WITH_CLAUDE.md)**

---

## 📄 License

MIT © [Michael Rishi Forrester](https://github.com/peopleforrester)

---

<div align="center">

**[⬆ Back to top](#)**

Made with 🧠 by Claude Code

</div>
