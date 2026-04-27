# claude-dotfiles Remediation TODO

State tracker for the plan in `plan.md`. Update after each commit.

## Phase 3 — Finish in-flight examples (IN PROGRESS)
- [x] Add `agents/worktree-isolated-example.md`
- [x] Add `hooks/templates/instructions-loaded.json`
- [x] Add `hooks/templates/user-prompt-submit.json`
- [x] Add `hooks/templates/prompt-handler.json`
- [x] Fix `hooks/hooks.json` `$CLAUDE_FILE_PATH` sites
- [ ] Commit Phase 3 artifacts + tests

## Phase A — Critical correctness fixes
- [ ] Fix `scripts/token-count.py:295` regex to accept comma-formatted numbers
- [ ] Rewrite `hooks/validators/protect-sensitive-files.py` to read stdin JSON + fail-closed
- [ ] Add unit tests for `protect-sensitive-files.py`
- [ ] Fix `scripts/ci/validate-agents.js:49` model enum to accept full model IDs
- [ ] Commit A1–A3

## Phase B — `$CLAUDE_FILE_PATH` eradication
Hook configs:
- [ ] `hooks/formatters/black-on-save.json`
- [ ] `hooks/formatters/gofmt-on-save.json`
- [ ] `hooks/formatters/prettier-on-save.json`
- [ ] `hooks/formatters/rustfmt-on-save.json`
- [ ] `hooks/validators/type-check-on-save.json`
- [ ] `settings/settings.json`
- [ ] `settings/settings.local.example.json`
- [ ] `templates/power-user/.claude/settings.json`
- [ ] `templates/stacks/nextjs-fullstack/.claude/settings.json`
- [ ] `templates/stacks/python-fastapi/.claude/settings.json`
- [ ] `templates/stacks/react-typescript/.claude/settings.json`
- [ ] `examples/demo-project/.claude/settings.json`

Docs:
- [ ] `hooks/README.md` (6 sites)
- [ ] `settings/README.md`
- [ ] `TROUBLESHOOTING.md`
- [ ] `templates/power-user/.claude/hooks/README.md`
- [ ] `rules/python/hooks.md`
- [ ] `rules/typescript/hooks.md`
- [ ] `rules/golang/hooks.md`
- [ ] `skills/optimization/continuous-learning-v2/SKILL.md`
- [ ] Commit Phase B

## Phase C — Trust-building fixes
- [ ] Pick canonical model ID; update `settings/settings.json`
- [ ] Update `schemas/skill.schema.json` description example
- [ ] Add model ID reference to `GOTCHAS.md`
- [ ] Recount and update `README.md:108-110` inventory
- [ ] Add `make stats` target output reference
- [ ] Rewrite `SECURITY.md:62-63` supported-versions table
- [ ] Add deny-list shallow-matcher notes to `settings/settings.json` + profile files
- [ ] Commit Phase C

## Phase 4 — Sandbox primitive pivot (Option B)
- [ ] Delete `settings/permissions/{conservative,balanced,autonomous}.json`
- [ ] Add `settings/permissions/sandbox-on.json`
- [ ] Add `settings/permissions/sandbox-off.json`
- [ ] Add `settings/permissions/autoMode-strict.json`
- [ ] Add `settings/permissions/autoMode-permissive.json`
- [ ] Add `settings/permissions/README.md`
- [ ] Update `install.sh` `--profile` handling
- [ ] Update `CLAUDE.md:61` taxonomy line
- [ ] Update `README.md:207-217` permission table
- [ ] Update `tests/run-all.js:42-44` (dynamic enumeration)
- [ ] Update `llms.txt` Settings section
- [ ] Update `rules/state-persistence.md` auto-memory note
- [ ] Commit Phase 4

## Phase 5 — Commands → skills migration
- [ ] Write `scripts/migrate-commands-to-skills.py`
- [ ] Dry-run, review manifest
- [ ] Execute migration for all 31 commands
- [ ] Delete `commands/` directory
- [ ] Remove `components.commands` from `.claude-plugin/plugin.json`
- [ ] Update `tests/run-all.js:71` to drop the assertion
- [ ] Update `README.md` Components section
- [ ] Update `CLAUDE.md` Key Directories section
- [ ] Update `llms.txt` Components section
- [ ] Repurpose or delete `scripts/ci/validate-commands.js`
- [ ] Verify no dangling `commands/` references
- [ ] Commit Phase 5

## Phase D — Validator consolidation
- [ ] Add `ajv` to package.json devDependencies
- [ ] Refactor `scripts/ci/validate-hooks.js` to read events from schema
- [ ] Refactor `scripts/ci/validate-skills.js` to validate via ajv
- [ ] Refactor `scripts/ci/validate-agents.js` to use shared model schema
- [ ] Add `schemas/model.schema.json`
- [ ] Add `tests/inventory.js` CI count assertion
- [ ] Evaluate + remove/prune `scripts/validate.py`
- [ ] Commit Phase D

## Phase E — Cleanup & polish
- [ ] `git rm -r --cached scripts/__pycache__ scripts/lib/__pycache__`
- [ ] Populate `CHANGELOG.md [Unreleased]` from phases 3/A/B/C/4/5/D
- [ ] Verify + update `mcp/servers/github.json` if deprecated
- [ ] Add `lint-shell` Makefile target + include in `make test`
- [ ] Emoji audit: `install.sh`, `Makefile` output
- [ ] Document emoji policy in `CLAUDE.md`

## Gate

Before declaring 0.5.0 ready:
- [ ] All phases above complete
- [ ] `git status` clean on staging
- [ ] `python3 scripts/validate.py . && node tests/run-all.js` green
- [ ] `./scripts/token-count.py` produces no false warnings
- [ ] Fresh install on a clean dir succeeds in each profile
- [ ] `CHANGELOG.md [0.5.0]` section written and dated
