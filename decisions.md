# Decisions

Append-only. Each entry records what was decided and why, so a later session
does not re-litigate a settled question or re-propose a dead end. Never edit a
prior entry; correct it with a new one.

## 2026-09-17T00:00:00Z · 2.3 · Rejected approaches

### REJECTED: Relax the CI shellcheck severity to `--severity=warning`

**Why:** A senior review recommended it on the premise that `make test` was
green while CI was red, implying a severity mismatch. Measured instead of
assumed: `make lint-shell` was also failing, exit 2, because two of the five
findings are warnings rather than errors. Aligning CI down would have fixed
nothing and would have hidden the two warnings permanently.
**Status:** Permanent. Both gates run at the stricter default and all five
findings are fixed.
**Do not suggest:** a per-file `shellcheck disable` sweep, or splitting the
lint job into a blocking errors job and an advisory warnings job. Both restate
the same trade and the findings were cheap to fix.

### REJECTED: Treat a green `npm test` as evidence the repo is healthy

**Why:** A status report claimed green across the board from a local run while
CI had been red on both branches for 21 days. The inventory test measured the
working tree rather than the repo, so the local pass and the CI failure were
both correct about different things.
**Status:** Permanent.
**Do not suggest:** reporting repo health from any local command. Gate on CI
for the pushed commit, per [[lifecycle-phases]] 3.2.

## 2026-09-17T00:00:00Z · 2.2 · September currency pass

Reconciled the repo against the live documentation, six weeks after the August
pass. Four changes, each verified against the published source on the day:

1. `schemas/hooks.schema.json` was missing `PreModelSwitch` and
   `PostModelSwitch`. Because `validate-hooks.js` derives its event list from
   that schema, it reported both as "Unknown hook type" for configurations the
   harness accepts. Also added the handler fields the reference documents for
   http, mcp_tool, and prompt or agent handlers.
2. `scripts/token-count.py` estimated with constants from a superseded
   tokenizer and under-reported by about a third. Recalibrated to the published
   figures for the tokenizer introduced with Opus 4.7.
3. The model notes named Fable 5 as the most capable model. Fable 5.1
   superseded it and Fable 5 is now legacy. The same pass corrected a false
   claim that `sandbox.network.allowLocalBinding` does not exist; it does, and
   it is macOS-only.
4. `validate-skills.js` never opened the skill schema shipped beside it, so the
   README's "schema-checked" claim was only true of hooks. The validator now
   reads the schema, and the README says precisely which files are
   schema-driven.

**Alternative considered and not taken:** adding `ajv` to validate every config
against its schema properly. It is the right shape, but it means a runtime
dependency and rewriting three validators, which is a change to ask for rather
than to make inside a currency pass.

## 2026-09-17T00:00:00Z · 3.x · PROJECT_STATE.md migrated to the lifecycle schema

The file described an April 2026 initiative as EXECUTING five months after it
shipped in 0.5.0, and carried a note at the bottom admitting the top was stale.
Rewritten to the schema in [[state-persistence]]. The superseded plan text is
in git history rather than duplicated here.

## 2026-10-17T00:00:00Z · E2E command for the heavy gate

`make e2e` (`tests/e2e/test_install_e2e.py`) runs `install.sh` into a scratch
`HOME` for every profile, symlink mode, backup, dry run and each template, then
runs `claude plugin validate --strict` from the published Claude Code CLI on the
installed `~/.claude`. The light gate only ever ran `install.sh --help`, so no
test exercised what a user actually gets.

**Dependency:** `@anthropic-ai/claude-code@2.1.302`, the npm `latest` on
2026-10-17, fetched with `npx` at test time rather than added to
`devDependencies`, so `npm ci` in CI does not pull the CLI and its native
binary. Pinned so the gate changes only when the pin does. The validator is
the harness's own judgement of skills and agents, which the repo's Node
validators only approximate. Bump the pin on a currency pass.

**What it found on the first run:** `install_rules` copied `rules/*.md`, which
since the move to `rules/common/` and `rules/<language>/` matches only
`rules/README.md`. `--all` installed no rules at all. Both installers now copy
`rules/common/*.md`; language rules have no path scoping and stay opt-in, as
`rules/README.md` and `plugin.json`'s `install.rules: ["common"]` already said.

**Not yet in the gate:** the same CLI rejects `.claude-plugin/plugin.json`
(`author` must be an object) and `.claude-plugin/marketplace.json` (no `name`
or `owner`, an invalid `source`, and the plugin name `claude-dotfiles` is
reserved because it starts with `claude-`). Renaming the plugin is Michael's
call, so the manifests go into the gate once that is settled. Filed as a
follow-up from issue #13.
