# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Framework Skills**: Django security, TDD, verification; Spring Boot patterns, security, TDD
  - `skills/frameworks/django-security/` — OWASP, CSP, CSRF, secrets management
  - `skills/frameworks/django-tdd/` — pytest-django, factory_boy, API testing
  - `skills/frameworks/django-verification/` — Pre-deployment quality gates
  - `skills/frameworks/springboot-patterns/` — Layered architecture, JPA, REST, DTOs
  - `skills/frameworks/springboot-security/` — Spring Security 6.x, JWT, CORS, rate limiting
  - `skills/frameworks/springboot-tdd/` — JUnit 5, MockMvc, Testcontainers, JaCoCo
- **Project Guidelines Example**: `skills/development/project-guidelines-example/` — Reference template for CLAUDE.md
- **Instinct Management Commands**: 4 new commands in `commands/learning/`
  - `/instinct-status` — View learned instincts with confidence bars
  - `/instinct-import` — Import instincts from teammates or community
  - `/instinct-export` — Export instincts with privacy sanitization
  - `/evolve` — Cluster instincts into skills, commands, or agents
- **Language Rule Extensions**: `hooks.md` and `patterns.md` for TypeScript, Python, Go
- **LLM Documentation**: `llms.txt` for LLM-optimized project discovery

### Changed
- README updated with v0.3.0 content: 14 agents, 20 commands, 28 skills, modular rules
- Rules links in README now point to `rules/common/` (from `rules/`)
- Validator now skips fenced code blocks, template files, placeholder links, and GitHub relative links
- Warnings reduced from 51 to 0

## [0.3.0] - 2026-02-05

### Added
- **Plugin Distribution**: `.claude-plugin/` with `plugin.json` and `marketplace.json`
  - Enables single-command installation as Claude Code plugin
  - Self-hosted marketplace configuration for discovery
- **Language-Specific Rules**: Modular rules for TypeScript, Python, Go
  - Each language has `coding-style.md`, `testing.md`, `security.md`, `hooks.md`, `patterns.md`
  - Restructured `rules/` into `common/` base + language-specific directories
- **Contexts System**: Dynamic mode switching in `contexts/`
  - `dev.md` - Active development mode
  - `review.md` - Code review mode (read-only focus)
  - `research.md` - Exploration and investigation mode
- **New Agents**: 5 additional specialized personas
  - `e2e-runner.md` - Playwright E2E testing specialist
  - `database-reviewer.md` - PostgreSQL/Supabase specialist
  - `python-reviewer.md` - Python code review specialist
  - `go-reviewer.md` - Go code review specialist
  - `go-build-resolver.md` - Go build error resolution
- **New Commands**: 9 additional slash commands
  - `/orchestrate` - Multi-agent workflow coordination
  - `/learn` - Extract reusable patterns from sessions
  - `/checkpoint` - Save verification state for resumption
  - `/eval` - Evaluate code against quality criteria
  - `/test-coverage` - Analyze and report test coverage gaps
  - `/e2e` - Generate end-to-end tests with Playwright
  - `/sessions` - Manage session history and state
  - `/multi-plan` - Multi-agent collaborative planning
  - `/multi-execute` - Execute approved multi-agent plans
- **New Skills**: 6 additional workflow definitions
  - `continuous-learning-v2` - Instinct-based learning with confidence scoring
  - `iterative-retrieval` - Progressive context refinement for subagents
  - `eval-harness` - Structured evaluation framework with rubrics
  - `backend-patterns` - API, database, caching, service patterns
  - `python-testing` - pytest patterns, fixtures, parametrize, async
  - `golang-testing` - Table-driven tests, benchmarks, fuzzing, race detection
- **JSON Schemas**: Validation schemas in `schemas/`
  - `hooks.schema.json` - Hook configuration validation
  - `plugin.schema.json` - Plugin manifest validation
  - `skill.schema.json` - Skill frontmatter validation
- **Node.js Validators**: Cross-platform CI scripts in `scripts/ci/`
  - `validate-agents.js`, `validate-commands.js`, `validate-skills.js`
  - `validate-rules.js`, `validate-hooks.js`, `validate-all.js`
- **Test Suite**: `tests/run-all.js` with 8 validation checks
- **Linting Config**: `.markdownlint.json`, `commitlint.config.js`, `package.json`
- **Session Management**: `scripts/session-manager.sh` for state persistence
- **Package Manager Detection**: `scripts/detect-package-manager.sh`
- **Enhanced Examples**: `user-CLAUDE.md`, `statusline.json`, session examples

### Changed
- Agent tool restrictions: reviewers are now read-only (removed Bash from code-reviewer, security-reviewer)
- Added YAML frontmatter to 8 existing commands missing `description` field
- CI workflow now includes multi-OS/multi-Node matrix testing
- `rules/README.md` updated to document modular language structure

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

[Unreleased]: https://github.com/peopleforrester/claude-dotfiles/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/peopleforrester/claude-dotfiles/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/peopleforrester/claude-dotfiles/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/peopleforrester/claude-dotfiles/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/peopleforrester/claude-dotfiles/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/peopleforrester/claude-dotfiles/releases/tag/v0.1.0
