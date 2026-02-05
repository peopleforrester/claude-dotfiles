# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-02-05

### Added
- **Rules System**: 7 always-follow constraint files in `rules/`
  - `security.md` - OWASP Top 10, secrets management, input validation
  - `coding-style.md` - Immutability, file organization, naming conventions
  - `testing.md` - TDD workflow, 80% coverage minimum
  - `git-workflow.md` - Conventional commits, PR process
  - `performance.md` - Model selection, context window management
  - `agents.md` - Subagent delegation patterns
- **Agents System**: 9 specialized persona definitions in `agents/`
  - `planner.md` - Implementation planning and risk assessment
  - `architect.md` - System design and ADR generation
  - `code-reviewer.md` - Quality and security code review
  - `security-reviewer.md` - OWASP vulnerability analysis
  - `tdd-guide.md` - Red-green-refactor enforcement
  - `build-resolver.md` - Build/CI error diagnosis
  - `doc-updater.md` - Documentation maintenance
  - `refactor-cleaner.md` - Dead code removal
- **Enhanced Commands**: 7 new slash commands in `commands/`
  - `/tdd` - Start TDD workflow
  - `/verify` - Pre-PR 8-step quality gate
  - `/code-review` - Comprehensive code review
  - `/security-review` - OWASP security audit
  - `/build-fix` - Build error resolution
  - `/refactor-clean` - Dead code removal
  - `/update-docs` - Documentation sync
- **Language Pattern Skills**: 4 new skills in `skills/patterns/`
  - `python-patterns` - Protocols, dataclasses, async, Pydantic
  - `typescript-patterns` - Branded types, discriminated unions, Zod
  - `golang-patterns` - Error wrapping, errgroup, interfaces, generics
  - `rust-patterns` - thiserror, ownership, traits, async Tokio
- **Framework Pattern Skills**: 4 new skills in `skills/frameworks/`
  - `react-patterns` - Hooks, composition, performance, error boundaries
  - `nextjs-patterns` - App Router, server components, caching, middleware
  - `fastapi-patterns` - Dependency injection, Pydantic v2, async, middleware
  - `django-patterns` - ORM optimization, DRF, service layer, middleware
- **Optimization Skills**: 3 new skills
  - `verification-loop` - Pre-PR quality verification workflow
  - `continuous-learning` - Cross-session knowledge building patterns
  - `strategic-compact` - Context window optimization strategies

### Changed
- `install.sh` now supports `--rules`, `--agents`, `--commands` flags
- `install.ps1` now supports `-Rules`, `-Agents`, `-Commands` parameters
- `scripts/validate.py` validates rules, agents, and command files
- README updated with rules, agents, and commands documentation
- `--all` flag now installs rules, agents, and commands in addition to existing components

## [0.1.2] - 2026-02-03

### Added
- CodeRabbit configuration (`.coderabbit.yaml`) for AI-powered code reviews
- Path-specific review instructions for JSON, SKILL.md, CLAUDE.md, and shell scripts
- Auto-review enabled for PRs to main and staging branches

## [0.1.1] - 2026-02-03

### Fixed
- GitHub Actions validation now passes - `token-count.py` uses appropriate limits for different file types
- Consistent GitHub username (`peopleforrester`) across all URLs in CHANGELOG.md and TROUBLESHOOTING.md
- Author field in all 14 skill files updated for consistency

### Changed
- Skills now have 200-350 line limits (detailed reference guides need more space)
- Documentation files now have 150-300 line limits
- Templates retain original strict limits (30-150 lines depending on type)

## [0.1.0] - 2026-01-28

### Added
- Initial repository structure
- MIT License
- README with quick start and documentation
- CONTRIBUTING guidelines
- Install script (bash) with interactive mode
- Install script (PowerShell) for Windows
- Core templates:
  - `templates/minimal/` - Bare essentials (~30 lines)
  - `templates/standard/` - Recommended baseline (~80 lines)
  - `templates/power-user/` - Full featured setup (~100 lines)
- Settings profiles:
  - `settings/permissions/conservative.json`
  - `settings/permissions/balanced.json`
  - `settings/permissions/autonomous.json`
- 14 curated skills for development, documentation, git, and quality
- Hook configurations for formatters, validators, and notifications
- MCP server configurations for GitHub, Slack, Notion, PostgreSQL, and more
- Stack-specific templates for React/TypeScript, Python/FastAPI, Next.js

### Compatibility
- Claude Code 2.1+
- Claude Desktop (skills and MCP)
- Cursor (skills)
- OpenAI Codex CLI (skills)

[Unreleased]: https://github.com/peopleforrester/claude-dotfiles/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/peopleforrester/claude-dotfiles/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/peopleforrester/claude-dotfiles/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/peopleforrester/claude-dotfiles/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/peopleforrester/claude-dotfiles/releases/tag/v0.1.0
