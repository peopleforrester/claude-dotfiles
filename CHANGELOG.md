# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.2] - 2026-08-04

### Fixed
- **README claimed 3 permission profiles; there are 4.** The count went stale
  when the profile taxonomy was replaced in 0.5.0. `tests/test_inventory.js`
  guarded six of the seven inventory rows but not this one, which is why it
  drifted unnoticed. Corrected the number and added the missing assertion, so
  the build now fails if any inventory row drifts from the filesystem.
- **`BUILT_WITH_CLAUDE.md` read as a description of the current repo.** Its
  "single Claude Code session" framing and figures (100+ files, 15,000+ lines,
  14 skills) were accurate for the first release on 2026-01-28 and stale for
  everything after it. Dated the origin story and added a first-session vs today
  column, since the original figures were true at the time and worth keeping.
- Added an H1 to the README. The heading was ASCII art, so the document had no
  real `<h1>` for search results, screen readers, or link previews.

### Added
- `assets/hero.png` — 16:9 hero image on the README.
- Above-the-fold evidence block showing real `npm test` output, replacing setup
  instructions as the first thing a visitor sees.

### Changed
- Sharpened the repo, package, and plugin descriptions from the generic
  "production-ready configurations" to the specific inventory they describe.

## [0.7.1] - 2026-08-04

### Removed
- Dead `commands` installation from both `install.sh` and `install.ps1`. The
  `commands/` directory was migrated to skills in 0.5.0, but both installers
  still carried the install function, the `--commands`/`-Commands` flag, the
  interactive prompt, and the `--all` step for it (a no-op that warned about a
  missing directory). Slash commands now ship as skills and install with them.
- `plan.md` and `todo.md` — internal 0.5.0 planning artifacts that did not
  belong in the public distribution and still referenced superseded model IDs.

### Fixed
- Synced the `install.ps1` version banner (was stuck at `0.1.0`) to the release.

## [0.7.0] - 2026-08-02

Full reconciliation of the hook, sandbox, permission, and skill surfaces against
the live Claude Code docs (CLI v2.1.220), verified against `code.claude.com/docs`
on 2026-08-02. Backed by the research spike
`mrf-knowledge/claude-code/2026-08-02_config-best-practices-august-2026.md`.

### Fixed
- **Hook configs did not work.** Every shipped hook example used an invalid
  matcher (`Write(*.ts)|Edit(*.ts)`, `tool == "Bash" && ...`), which Claude Code
  treats as a regex against the tool name and never matches. Matchers are tool
  names; rewrote all of them to `Bash` / `Edit|Write` and scoped inputs with a
  handler-level `if` or an in-command guard. Affected `hooks/hooks.json`, all
  `hooks/formatters/*`, `hooks/validators/*`, `hooks/integrations/*`,
  `hooks/templates/prompt-handler.json`, `settings/settings.json`, all five
  templates, `settings/settings.local.example.json`, `examples/demo-project`, and
  the hook docs.
- **`message` is not a hook handler type.** Three `hooks/hooks.json` reminders
  used `type: "message"` (and one skill example). Converted to `command` handlers
  that emit `{"systemMessage": ...}` on exit 0 or block with exit 2. Valid types
  are `command`, `http`, `mcp_tool`, `prompt`, `agent`.
- **Fabricated sandbox keys.** `sandbox.network.denyExternal` and
  `sandbox.network.allowLocalBinding` do not exist. Replaced with real keys
  (`allowedDomains`, `strictAllowlist`) across `settings/settings.json`, all
  templates, and the permission profiles/docs.
- **Stale three-profile docs.** `settings/README.md`, `SECURITY.md`,
  `scripts/README.md`, `BUILT_WITH_CLAUDE.md`, and the standard-template comment
  still referenced the Conservative/Balanced/Autonomous profiles removed in
  0.5.0. Updated to the four sandbox/autoMode profiles.
- **Skill schema drift.** `context` was typed as an array of paths but is the
  string `fork`; `effort` was missing `xhigh`/`max`. Corrected both.

### Changed
- Hook schema rewritten to the real nested shape (event → matcher groups →
  `hooks[]` handlers), the correct handler-type enum, all 31 events (added
  `Setup`, `UserPromptExpansion`, `PostToolBatch`, `MessageDisplay`,
  `DirectoryAdded`), and valid handler fields (`if`, `timeout`, `async`,
  `asyncRewake`, `statusMessage`, `shell`, `once`).
- `validate-hooks.js` now validates the nested structure, errors on invalid
  handler types, warns on expression/permission-form matchers, and checks
  top-level event sections (previously only `hooks`-wrapped files).
- `validate-agents.js` warns on agent names containing `:` (reserved for plugin
  namespacing, v2.1.218).
- GOTCHAS documents the nested hook shape, matcher rules, the `Manual` display
  name for `default` mode, real sandbox keys, and `context: fork` background.
- Skill schema gained `when_to_use`, `arguments`, `disallowed-tools`,
  `background`, and `hooks` fields.

### Added
- `test_inventory.js` prunes generated directories (`__pycache__`, etc.) so a
  stray `.pyc` no longer inflates the hook count.

## [0.6.0] - 2026-08-02

Reconciles the repo against the live Claude Code lineup and CLI (v2.1.220),
verified against `platform.claude.com` and `code.claude.com/docs/en` on
2026-08-02. Backed by the research spike
`mrf-knowledge/claude-code/2026-08-02_config-best-practices-august-2026.md`.

### Fixed
- **Agent-model validator rejected current model IDs.** The regex in
  `scripts/ci/validate-agents.js` required two numeric segments
  (`^claude-...-\d+-\d+`), so single-segment IDs like `claude-opus-5`,
  `claude-sonnet-5`, and `claude-fable-5` were flagged "Unknown model".
  Widened the pattern and added the `fable` short form. Covered by new
  fixtures in `tests/test_validate_agents.js`.

### Changed
- **Default model → the `sonnet` alias** in `settings/settings.json`
  (was the now-legacy `claude-sonnet-4-6`). An alias tracks the current
  generation and will not go stale; on the Anthropic API `sonnet` resolves
  to Sonnet 5 and `opus` to Opus 5 as of August 2026.
- Refreshed the `GOTCHAS.md` model table to the August 2026 lineup
  (Fable 5, Opus 5, Sonnet 5, Haiku 4.5), added a provider-specific alias
  resolution table, and marked Opus 4.8/4.7/4.6 and Sonnet 4.6/4.5 legacy.
- Updated `schemas/skill.schema.json` model description to the August lineup
  and clarified that aliases are accepted.

### Added
- `DirectoryAdded` hook event (CLI v2.1.219) to `schemas/hooks.schema.json`
  and the GOTCHAS event list.

### Security
- Resolved 4 newly-disclosed high-severity advisories in the dev-dependency
  chain (`brace-expansion` GHSA-3jxr-9vmj-r5cp / GHSA-mh99-v99m-4gvg,
  `js-yaml` GHSA-52cp-r559-cp3m, `linkify-it` GHSA-v245-v573-v5vm) via
  `npm audit fix` (lockfile-only; no declared-range change). `npm audit`
  now reports 0 vulnerabilities.

## [0.5.2] - 2026-07-12

### Changed
- Re-verified the GA model lineup for July 2026 — unchanged (Opus 4.8,
  Sonnet 4.6, Haiku 4.5). Restamped the "as of" currency markers in
  `GOTCHAS.md`, `settings/settings.json`, and `schemas/skill.schema.json`
  from June to July 2026.
- Bumped `@commitlint/config-conventional` 21.0.2 → 21.2.0.

## [0.5.1] - 2026-06-18

### Fixed
- **Invalid default model ID.** `settings/settings.json` set `claude-sonnet-4-7`,
  which does not exist (the Sonnet line is 4.5 → 4.6) and would 404 at runtime.
  Corrected the default to `claude-sonnet-4-6`.
- Refreshed model IDs to the June 2026 GA lineup (Opus 4.8, Sonnet 4.6, Haiku 4.5)
  in `GOTCHAS.md`, `schemas/skill.schema.json`, the agent-model validator's example
  text, and its test fixtures — removing all references to the nonexistent
  `claude-sonnet-4-7`.

### Changed
- Bumped dev dependencies: `markdownlint-cli` 0.48 → 0.49,
  `@commitlint/config-conventional` 19 → 21.
- Raised the Node engine floor to `>=22.12.0` to match
  `@commitlint/config-conventional` 21's requirement.

## [0.5.0] - 2026-04-26

### Added
- `agents/worktree-isolated-example.md` — demonstrates `isolation: worktree`
- `hooks/templates/{instructions-loaded,user-prompt-submit,prompt-handler}.json`
  — examples of new April 2026 hook events and the `prompt` handler type
- `GOTCHAS.md` — single source of truth for verified April 2026 behaviors
  (hook events, skill frontmatter, sandbox primitives, model IDs, deny limits)
- `settings/permissions/{sandbox-on,sandbox-off,autoMode-strict,autoMode-permissive}.json`
  — composable primitives replacing the legacy three-profile taxonomy
- `settings/permissions/README.md` — composition guide
- `scripts/migrate-commands-to-skills.py` — one-shot migration tool
- Test suite: `tests/test_token_count.py`, `tests/test_protect_sensitive_files.py`,
  `tests/test_validate_agents.js`, `tests/test_inventory.js`

### Changed
- **BREAKING**: `commands/` directory removed — all 31 commands migrated to
  `skills/<category>/<name>/SKILL.md` with `user-invocable: true`. Slash command
  names (`/tdd`, `/verify`, `/orchestrate`, etc.) are unchanged for users.
- **BREAKING**: Permission profiles renamed and re-conceived
  - `conservative` → use `autoMode-strict` or `sandbox-off`
  - `balanced` → use `sandbox-off` (closest match)
  - `autonomous` → use `autoMode-permissive` or `sandbox-on`
  - `install.sh --profile <legacy>` now errors with migration guidance
- `settings.json` model bumped to `claude-sonnet-4-7` (April 2026 GA)
- `schemas/hooks.schema.json` adds 18 April 2026 events plus `http`/`prompt`/
  `agent` handler types and `if`/`once`/`shell`/`statusMessage` fields
- `schemas/skill.schema.json` makes `description` optional (only `name` required)
  and adds 10 new fields: `argument-hint`, `effort`, `model`, `allowed-tools`,
  `disable-model-invocation`, `user-invocable`, `context`, `agent`, `paths`,
  `shell`
- Repo-wide replacement of `$CLAUDE_FILE_PATH` with stdin-jq pattern across
  hook configs, docs, and rules

### Fixed
- `scripts/token-count.py` regex now matches comma-formatted token counts
  (`~1,400` parsed as 1400 instead of silently matching `1`)
- `hooks/validators/protect-sensitive-files.py` reads tool invocation from
  stdin JSON and fails closed on missing/malformed input. Removes the silent
  bypass that triggered when `$CLAUDE_FILE_PATH` was unpopulated.
- `scripts/ci/validate-agents.js` accepts full model IDs in addition to
  short names
- `scripts/ci/validate-hooks.js` reads valid event names from
  `schemas/hooks.schema.json` instead of a hardcoded subset
- Documentation host migrated from `docs.anthropic.com/claude-code` to
  `code.claude.com/docs/en`
- README inventory counts now match filesystem reality (CI-asserted)
- `SECURITY.md` supported-versions table corrected (no fictional 1.x entry)

### Removed
- `commands/` directory (all content migrated to `skills/`)
- `scripts/ci/validate-commands.js` (now covered by `validate-skills.js`)
- `settings/permissions/{conservative,balanced,autonomous}.json`
- `npm run validate:commands` script entry

## [0.4.0] - 2026-02-05

### Added
- **Spec-Driven Development Workflow**: Interview-first specification system (Brain Spec lite)
  - `skills/development/spec-driven-development/` — Core spec workflow patterns and file format
  - `agents/spec-interviewer.md` — Opus agent for 8-category requirement interviews
  - `/spec-new` — Create specs through structured interviews
  - `/spec-status` — View spec progress and next tasks
  - `/spec-task` — Update task status and add implementation notes
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
- README updated with current inventory: 15 agents, 26 commands, 29 skills, 21 rules
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

[Unreleased]: https://github.com/peopleforrester/claude-dotfiles/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/peopleforrester/claude-dotfiles/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/peopleforrester/claude-dotfiles/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/peopleforrester/claude-dotfiles/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/peopleforrester/claude-dotfiles/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/peopleforrester/claude-dotfiles/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/peopleforrester/claude-dotfiles/releases/tag/v0.1.0
