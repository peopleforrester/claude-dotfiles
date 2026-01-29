<div align="center">
  <h1>claude-dotfiles</h1>
  <p><strong>Production-ready configurations for Claude Code</strong></p>

  <p>
    <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-yellow.svg">
    <img alt="Claude Code 2.1+" src="https://img.shields.io/badge/Claude%20Code-2.1%2B-blueviolet">
    <img alt="Platform" src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey">
  </p>

  <p>
    <a href="#-quick-start">Quick Start</a> •
    <a href="#-whats-included">Features</a> •
    <a href="#-choose-your-template">Templates</a> •
    <a href="#-documentation">Documentation</a> •
    <a href="#-contributing">Contributing</a>
  </p>
</div>

---

## Quick Start

**One-command installation:**

```bash
curl -fsSL https://raw.githubusercontent.com/michaelrishiforrester/claude-dotfiles/main/install.sh | bash
```

**Or clone and install manually:**

```bash
git clone https://github.com/michaelrishiforrester/claude-dotfiles.git ~/.claude-dotfiles
cd ~/.claude-dotfiles
./install.sh
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/michaelrishiforrester/claude-dotfiles/main/install.ps1 | iex
```

## What's Included

| Category | Contents | Directory |
|----------|----------|-----------|
| **CLAUDE.md Templates** | Language, framework, and domain-specific templates | [`claude-md/`](./claude-md/) |
| **Skills** | TDD workflow, code review, documentation, git helpers | [`skills/`](./skills/) |
| **Hooks** | Auto-formatters, validators, notifications | [`hooks/`](./hooks/) |
| **Settings** | Permission profiles (conservative → autonomous) | [`settings/`](./settings/) |
| **MCP Configs** | GitHub, Slack, Notion, PostgreSQL bundles | [`mcp/`](./mcp/) |
| **Starter Templates** | Complete project setups ready to copy | [`templates/`](./templates/) |

## Choose Your Template

### By Experience Level

| Template | Lines | Best For |
|----------|-------|----------|
| [`templates/minimal/`](./templates/minimal/) | ~30 | Quick projects, learning Claude Code |
| [`templates/standard/`](./templates/standard/) | ~80 | Most projects (recommended) |
| [`templates/power-user/`](./templates/power-user/) | ~100 | Full automation, advanced workflows |

### By Stack

| If you're building... | Use this template |
|-----------------------|-------------------|
| React/TypeScript app | [`templates/stacks/react-typescript/`](./templates/stacks/react-typescript/) |
| Python FastAPI | [`templates/stacks/python-fastapi/`](./templates/stacks/python-fastapi/) |
| Next.js fullstack | [`templates/stacks/nextjs-fullstack/`](./templates/stacks/nextjs-fullstack/) |
| CLI tool | [`claude-md/domains/cli-tool.md`](./claude-md/domains/cli-tool.md) |
| Library/package | [`claude-md/domains/library.md`](./claude-md/domains/library.md) |
| Monorepo | [`claude-md/domains/monorepo.md`](./claude-md/domains/monorepo.md) |

## Installation Options

```bash
# Interactive mode (default) - choose what to install
./install.sh

# Install everything
./install.sh --all

# Minimal install (CLAUDE.md + settings only)
./install.sh --minimal

# Install specific components
./install.sh --skills          # Skills only
./install.sh --hooks           # Hooks only
./install.sh --mcp             # MCP configs only

# Options
./install.sh --profile balanced   # Permission profile (conservative|balanced|autonomous)
./install.sh --symlink            # Symlink instead of copy
./install.sh --no-backup          # Skip backing up existing configs
```

## Settings Profiles

| Profile | Description | Default Mode | Use Case |
|---------|-------------|--------------|----------|
| **Conservative** | Ask before most actions | `prompt` | Learning, sensitive projects |
| **Balanced** | Auto-accept edits, ask for bash | `acceptEdits` | Daily development |
| **Autonomous** | Minimal interruptions | `acceptEdits` | Trusted automation |

All profiles include security defaults that deny access to `.env`, `~/.ssh/`, `~/.aws/`, and dangerous bash commands.

## Compatibility

| Platform | Version | Status |
|----------|---------|--------|
| Claude Code | 2.1+ | Full support |
| Claude Desktop | Latest | Skills + MCP |
| Cursor | Latest | Skills compatible |
| OpenAI Codex CLI | Latest | Skills compatible |

## Directory Structure After Install

```
~/.claude/
├── settings.json           # Global settings (from chosen profile)
├── settings.local.json     # Your personal overrides (gitignored)
├── skills/                 # Global skills
│   ├── tdd-workflow/
│   ├── code-reviewer/
│   ├── commit-helper/
│   └── ...
└── hooks/                  # Hook scripts
    ├── format-typescript.sh
    ├── format-python.sh
    └── notify-complete.sh
```

## Documentation

- [CLAUDE.md Best Practices](./claude-md/README.md) - Writing effective project memory
- [Skills Guide](./skills/README.md) - Using and creating skills
- [Hooks Cookbook](./hooks/README.md) - Automation recipes
- [Settings Reference](./settings/README.md) - Complete settings.json documentation
- [MCP Setup Guide](./mcp/README.md) - MCP server configuration
- [Troubleshooting](./TROUBLESHOOTING.md) - Common issues and solutions

## Contributing

Contributions welcome! See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

**Most Wanted:**
- Framework templates (Laravel, Django, Go, Rust)
- Industry-specific configs (healthcare, finance, e-commerce)
- MCP server bundles
- Translations

## License

MIT © [Michael Rishi Forrester](https://github.com/michaelrishiforrester)

---

<div align="center">
  <sub>Built for the Claude community</sub>
</div>
