# PROJECT_STATE

## Current Initiative: Anthropic-Aligned April 2026 Improvements

**Status:** EXECUTING — plan approved by Michael 2026-04-07

## Approved Plan

### Decisions made
- MIGRATE all 31 commands to skills (Michael: repo is a distribution model
  of best practices, stragglers undermine the point)
- Keep full model IDs (reproducibility)
- Keep schema strictness
- Keep 60-100 line CLAUDE.md budget
- Phase 4 Option B: full sandbox taxonomy pivot

### Phase 1 — Documentation truth
- Bulk replace docs.anthropic.com/en/docs/claude-code/* -> code.claude.com/docs/en/*
- Fix $CLAUDE_FILE_PATH gotcha in CLAUDE.md (replace with jq stdin pattern)
- Fix SKILL.md frontmatter requirements wording in CLAUDE.md
- Add upstream 200-line note to CLAUDE.md token budget
- Migrate model_recommendation references in rules/model-selection.md to model

### Phase 2 — Schema completeness
- hooks.schema.json: add 15+ new events (InstructionsLoaded, UserPromptSubmit,
  PermissionRequest, PermissionDenied, PostToolUseFailure, SubagentStart,
  TaskCreated, TaskCompleted, StopFailure, TeammateIdle, ConfigChange,
  CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PostCompact,
  Elicitation, ElicitationResult)
- hooks.schema.json: add handler types command|http|prompt|agent
  (was command|message) plus fields if/async/statusMessage/once/shell
- skill.schema.json: add optional fields argument-hint, effort, model,
  allowed-tools, disable-model-invocation, user-invocable, context, agent,
  paths, shell. Keep name required (per Michael).
- Add docs/gotchas-claude-code-april-2026.md capturing research findings

### Phase 3 — New feature examples
- agents/worktree-isolated-example.md with isolation: worktree
- .lsp.json plugin example
- Hook templates for InstructionsLoaded and UserPromptSubmit
- Hook handler example using prompt type
- Document plugin namespacing (/plugin-name:skill-name)
- Document plugin subagent restrictions (no hooks/mcpServers/permissionMode)
- Document auto and dontAsk permission modes in settings docs

### Phase 4 — Sandbox primitive pivot (Option B, full)
- DELETE settings/permissions/{conservative,balanced,autonomous}.json
- ADD settings/permissions/{sandbox-on,sandbox-off,autoMode-strict,
  autoMode-permissive}.json with sandbox.* + defaultMode auto primitives
- ADD settings/permissions/README.md explaining the primitives and composition
- UPDATE state-persistence.md rule for auto memory (~/.claude/projects/<p>/
  memory/MEMORY.md) coexistence with PROJECT_STATE.md
- Consider version bump 0.4.0 -> 0.5.0 (user-facing taxonomy change)

### Phase 5 — Command to skill migration
- Convert all 31 commands/*.md -> skills/*/SKILL.md as directories
- Update plugin.json components (drop commands/, already has skills/)
- Delete commands/ directory
- Update validators/tests that reference commands
- Update tests/run-all.js to drop command validation
- Update README, CLAUDE.md, and any docs referencing commands/

## Branch Workflow
- Work on staging
- Commit + run tests after each phase
- Push staging, then merge to main, then push main (per CLAUDE.md rules)
- Do NOT skip tests between phases

## Previous Completed Work
- Commit 23898ed: Fix senior review findings
- Commit 3800aff: Harden CI workflows to April 2026
- Commit 486c3e0: Runtime version floor consistency (Node >=22, Python >=3.12)

## Branch State
- staging: 486c3e0 synced
- main: 526087e synced
