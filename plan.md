# claude-dotfiles Remediation Plan

**Date:** 2026-04-23
**Context:** Senior review (2026-04-19) surfaced 3 critical, 5 high, 10 medium, 6 low issues. This plan merges those findings with the in-flight April 2026 improvement phases (3, 4, 5 remaining) into one ordered execution blueprint.

## Guiding Constraints

- Branch workflow: commit to `staging`, never direct to `main`.
- Validate after each step (`python3 scripts/validate.py .` + `node tests/run-all.js`).
- One commit per logical chunk — granular for bisect, not per-file churn.
- Preserve existing CI green state; never skip hooks.
- No feature-flag / backward-compat shims for internal config moves.

## Architecture Decisions

- **Source-of-truth for hook event types:** `schemas/hooks.schema.json`. Validators read from it rather than hardcoding subsets.
- **Source-of-truth for hook file-path access:** stdin JSON via `jq -r '.tool_input.file_path'`. `$CLAUDE_FILE_PATH` is deprecated throughout the repo.
- **Canonical model IDs (April 2026):** Opus 4.7 = `claude-opus-4-7`, Sonnet 4.7 = `claude-sonnet-4-7`, Haiku 4.5 = `claude-haiku-4-5-20251001`. Applied consistently across `settings.json`, schema examples, and docs.
- **Permission taxonomy:** replace the three-profile legacy (`conservative` / `balanced` / `autonomous`) with sandbox primitives. `defaultMode: auto` + `sandbox.*` is the new baseline.
- **Skills replace commands:** `commands/` is removed in Phase 5; `plugin.json.components.commands` is removed in the same commit.
- **Validator consolidation:** JS-only (Node is already required for the test runner). `scripts/ci/validate-*.js` uses `ajv` against the JSON Schemas. Python `validate.py` is retained only for markdown-specific rules (or deleted if empty after consolidation).

## Implementation Order

Issues cluster into 8 phases, ordered by leverage and dependency:

| Phase | Scope | Rationale |
|-------|-------|-----------|
| 3 | Finish in-flight examples + hook config CLAUDE_FILE_PATH fixes | Already staged; close before new work |
| A | Critical bug fixes (token-count regex, protect-sensitive-files.py) | Correctness gates; test signal |
| B | Repo-wide `$CLAUDE_FILE_PATH` replacement | Highest-volume doc drift |
| C | Inventory, model IDs, SECURITY.md, deny-list notes | Trust-building fixes |
| 4 | Sandbox primitive pivot | Breaks existing permission profile file paths; coordinate |
| 5 | Commands → skills migration | Largest change; landed last to avoid churn |
| D | Validator consolidation + schema-driven validation | Closes M1/M2/M3/M4 together |
| E | Cleanup (pycache untrack, CHANGELOG, MCP update, emoji policy) | Low risk, batch at end |

---

## Phase 3 — Finish in-flight examples (IN PROGRESS)

Files already staged in `hooks/templates/`, `agents/worktree-isolated-example.md`. Close with:

1. Update `hooks/hooks.json` remaining `$CLAUDE_FILE_PATH` sites to stdin-jq pattern (already partially done — verify).
2. Commit Phase 3 artifacts in one commit titled `Phase 3: new feature examples for isolation, prompt hooks, and new events`.
3. Run tests.

## Phase A — Critical correctness fixes

**A1. `scripts/token-count.py:295`** — regex bug.
- Change regex `r'<!--\s*Tokens:\s*~?(\d+)'` → `r'<!--\s*Tokens:\s*~?([\d,]+)'`.
- Change `int(m.group(1))` → `int(m.group(1).replace(',', ''))`.
- Verify with `./scripts/token-count.py` — expect no false "~1 tokens" warnings.

**A2. `hooks/validators/protect-sensitive-files.py`** — silent bypass.
- Rewrite entry point to read stdin JSON: `data = json.load(sys.stdin); file_path = data.get("tool_input", {}).get("file_path")`.
- Fail closed: if `file_path` is None/empty, exit 1 with an explicit error.
- Remove all fallbacks to `$CLAUDE_FILE_PATH` env var.
- Add a unit test under `tests/` that feeds crafted stdin JSON and asserts behavior for: (a) sensitive file → exit 1; (b) safe file → exit 0; (c) empty path → exit 1.

**A3. `scripts/ci/validate-agents.js:49`** — model enum drift.
- Allow either the short form (`opus|sonnet|haiku`) or any full model ID matching `^claude-(opus|sonnet|haiku)-\d+-\d+(-\d{8})?$`.

Commit as `Fix critical regressions in token-count, protect-sensitive-files, and agent validator`.

## Phase B — Repo-wide `$CLAUDE_FILE_PATH` eradication

Target files (from grep — 24 total):

**Hook configs (code, high-impact):**
- `hooks/formatters/{black,gofmt,prettier,rustfmt}-on-save.json`
- `hooks/validators/type-check-on-save.json`
- `settings/settings.json`
- `settings/settings.local.example.json`
- `templates/power-user/.claude/settings.json`
- `templates/stacks/{nextjs-fullstack,python-fastapi,react-typescript}/.claude/settings.json`
- `examples/demo-project/.claude/settings.json`

For each: replace inline `"$CLAUDE_FILE_PATH"` commands with `"FILE=$(cat | jq -r '.tool_input.file_path') && <cmd> \"$FILE\""`.

**Documentation (teaches the broken pattern):**
- `hooks/README.md` (6 sites)
- `settings/README.md`
- `TROUBLESHOOTING.md`
- `templates/power-user/.claude/hooks/README.md`
- `rules/python/hooks.md`, `rules/typescript/hooks.md`, `rules/golang/hooks.md`
- `skills/optimization/continuous-learning-v2/SKILL.md`

Each doc: replace the broken example and add a one-liner pointing to `GOTCHAS.md`.

**CLAUDE.md / GOTCHAS.md:** already correct — no changes.

Commit as `Replace unreliable $CLAUDE_FILE_PATH with stdin jq pattern across hook configs and docs`.

## Phase C — Trust-building fixes

**C1. Model ID unification.**
- Pick canonical default: `claude-sonnet-4-7` (fast + capable, matches current fleet default).
- Update:
  - `settings/settings.json:5`
  - `schemas/skill.schema.json` description example
  - Any remaining `claude-sonnet-4-5-20250929` references
- Add a short section to `GOTCHAS.md` listing all three current model IDs.

**C2. README inventory fix.**
- Count actual files: `find agents -name '*.md' | wc -l`, etc.
- Update `README.md:108-110` table with true counts (15/31/39 → whatever current).
- Add `make stats` output target that CI can diff against README; defer CI assertion to Phase D.

**C3. SECURITY.md versions.**
- Replace fictional `1.x.x` table with `0.x.x (current) – supported` and a note that 1.0 hasn't shipped yet.

**C4. Deny-list documentation.**
- Add a comment block in `settings/settings.json` and `settings/permissions/*.json` explaining that deny patterns are shallow matchers — easily defeated by alternate flags, path prefixes, or binaries. Document them as defense-in-depth, not sandbox guarantees.

Commit as `Unify model IDs, correct README inventory, fix SECURITY.md versioning, document deny-list limits`.

## Phase 4 — Sandbox primitive pivot (Option B)

**Delete:**
- `settings/permissions/conservative.json`
- `settings/permissions/balanced.json`
- `settings/permissions/autonomous.json`

**Add:**
- `settings/permissions/sandbox-on.json` — `defaultMode: auto`, `sandbox.enabled: true`, conservative network allowlist.
- `settings/permissions/sandbox-off.json` — `defaultMode: acceptEdits`, sandbox disabled, broad permissions.
- `settings/permissions/autoMode-strict.json` — `defaultMode: auto`, classifier tightened for high-risk tools.
- `settings/permissions/autoMode-permissive.json` — `defaultMode: auto`, classifier loosened for trusted work.
- `settings/permissions/README.md` — document the primitive-based model and when to pick each.

**Update in the same commit:**
- `install.sh` — `--profile` arg and interactive prompts.
- `CLAUDE.md:61` — replace three-profile taxonomy line.
- `README.md:207-217` — update the permission-profiles table.
- `tests/run-all.js:42-44` — enumerate `settings/permissions/*.json` dynamically.
- `llms.txt` — update Settings section.
- `rules/state-persistence.md` — note auto-memory coexistence with `PROJECT_STATE.md`.

Commit as `Phase 4: replace profile taxonomy with sandbox primitives and auto-mode classifiers`.

## Phase 5 — Commands → skills migration

**Migration script:** write `scripts/migrate-commands-to-skills.py` that, for each `commands/<category>/<name>.md`:

1. Creates `skills/<category>/<name>/SKILL.md`.
2. Copies the command body.
3. Normalizes frontmatter: ensures `name: <name>`, `user-invocable: true`, preserves `description`, `argument-hint`, `model` if present.
4. Records the move in a manifest for review.

**Execute:**
- Dry-run the script, review manifest.
- Execute for all 31 commands.
- Delete `commands/` directory.
- Remove `components.commands` from `.claude-plugin/plugin.json`.
- Update `tests/run-all.js:71` to drop the `components.commands` assertion.
- Update `README.md`, `CLAUDE.md` key-directories section, `llms.txt` Components section.
- Update `scripts/ci/validate-commands.js` — either repurpose for skills validation or delete.

**Verify:** no file references `commands/` except git history. `grep -rn "commands/" --exclude-dir=.git` comes back empty except legitimate mentions in CHANGELOG or migration notes.

Commit as `Phase 5: migrate all slash commands to skill directories`.

## Phase D — Validator consolidation

**Choice:** JS-only. Add `ajv` as a dev dependency.

**Refactor:**
- Each `scripts/ci/validate-*.js` reads its corresponding schema from `schemas/` and validates content structurally.
- `validate-hooks.js` reads hook event names from `schemas/hooks.schema.json` rather than hardcoding.
- `validate-agents.js` reads allowed model shapes from a shared `schemas/model.schema.json` (new).
- Port inventory-count assertion into CI: `tests/inventory.js` computes actual counts and diffs against README.md numbers; fails if out of sync.
- `scripts/validate.py` — evaluate what it does that JS validators don't. Delete if redundant; keep only markdown-specific rules otherwise.

Commit as `Consolidate validators: single JS pipeline, schema-driven, inventory CI assertion`.

## Phase E — Cleanup & polish

**E1.** `git rm -r --cached scripts/__pycache__ scripts/lib/__pycache__` — already in `.gitignore` but tracked.
**E2.** Populate `CHANGELOG.md` `[Unreleased]` section incrementally with each phase's highlights (do this retroactively after D).
**E3.** `mcp/servers/github.json` — verify current package. If `github/github-mcp-server` (Go-based) is the current recommendation, update config and README.
**E4.** `Makefile` — add `lint-shell: shellcheck install.sh scripts/*.sh` and include in `test`.
**E5.** Emoji policy — audit `install.sh`, `Makefile` output; replace ✓/✗ with `[OK]`/`[FAIL]` where feasible. Document policy in `CLAUDE.md`.

Commit as individual small commits under `Cleanup: ...`.

---

## Testing Strategy

- After each phase: `python3 scripts/validate.py . && node tests/run-all.js` must pass.
- Phase A adds behavior tests for `protect-sensitive-files.py`. Run pytest (add if absent).
- Phase 4 verification: fresh `./install.sh --dry-run --profile sandbox-on` completes without missing-file errors.
- Phase 5 verification: plugin manifest loads cleanly in a fresh Claude Code session (`claude --version && claude plugin list`).
- Phase D: new schema-driven validators must reject crafted bad inputs (negative tests).

## Risk Register

| Risk | Phase | Mitigation |
|------|-------|-----------|
| Phase 5 breaks user muscle memory on command names | 5 | Keep slash-command names identical — users see no change, only the backing file moves. |
| Phase 4 breaks existing user settings | 4 | Add a migration note to CHANGELOG; old profile names surface a helpful error in `install.sh`. |
| Phase B introduces regex escapes mishandled in JSON | B | Run `jq .` on every edited JSON file before commit; validators catch shape errors. |
| Validator rewrite (D) changes error messages | D | Keep exit codes identical to preserve CI behavior. |

## Out of Scope

- Symlink-mode install default (M9) — user preference, not a bug.
- `BUILT_WITH_CLAUDE.md` relocation (L4) — cosmetic.
- `commitlint` runner wiring (L5) — separate decision.

---

## Summary

8 phases, ordered: 3 → A → B → C → 4 → 5 → D → E. Each phase ends with a green test suite and a pushed commit to `staging`. Total estimated commits: ~14.
