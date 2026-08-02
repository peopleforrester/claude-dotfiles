# Claude Code Gotchas — August 2026

Model IDs and aliases verified live against `platform.claude.com` and
`code.claude.com/docs/en` on 2026-08-02 (CLI v2.1.220). Other behaviors were
verified against `code.claude.com/docs/en` as of 2026-04.
Training-data-era tutorials frequently contradict these.

## Hooks

- **`$CLAUDE_FILE_PATH` is unreliable.** Read the path from stdin JSON via
  `jq -r '.tool_input.file_path'`. The env var only populates for a subset of
  PostToolUse invocations and is empty elsewhere.
- **Config shape is nested.** An event maps to an array of matcher groups, each
  `{ "matcher": "<tool name>", "hooks": [ <handler>, ... ] }`. The `matcher` is a
  tool name (`Bash`), a `|`/`,` list (`Edit|Write`), `*`/`""` for all, or a
  regex; it is NOT an expression. `tool == "Bash" && ...` is treated as a regex
  against the tool name and never matches. Scope on inputs with a handler-level
  `if` instead.
- **Handler types.** A handler's `type` is one of `command`, `http`, `mcp_tool`,
  `prompt`, or `agent`. There is no `message` type. To show text to the user, a
  `command` hook emits `{"systemMessage": "..."}` on exit 0; to block a call it
  exits 2 (stderr is fed back to Claude). `prompt` runs a single-turn model
  decision; `agent` delegates to a subagent (experimental).
- **New events.** `Setup`, `InstructionsLoaded`, `UserPromptSubmit`,
  `UserPromptExpansion`, `PostToolBatch`, `MessageDisplay`, `PermissionRequest`,
  `PermissionDenied`, `PostToolUseFailure`, `PostCompact`, `SubagentStart`,
  `SubagentStop`, `TaskCreated`, `TaskCompleted`, `TeammateIdle`, `ConfigChange`,
  `CwdChanged`, `DirectoryAdded`, `FileChanged`, `WorktreeCreate`,
  `WorktreeRemove`, `StopFailure`, `Elicitation`, `ElicitationResult`. Use
  `UserPromptSubmit` for policy gates that previously lived on `PreToolUse`.
  `DirectoryAdded` (CLI v2.1.219) fires after `/add-dir` or an SDK
  `register_repo_root` call.
- **`once: true`** fires a hook only on the first matching trigger per session
  (honored only in skill/agent frontmatter, ignored in settings files).
- **`if:`** takes permission-rule syntax (e.g. `Bash(git push *)`, `Edit(*.ts)`)
  and gates a handler on tool events without shell logic in the command.
- **Valid command-handler fields:** `command`, `args`, `if`, `timeout` (seconds,
  default 600), `async`, `asyncRewake`, `statusMessage`, `shell`, `once`.

## Skills

- **`name` is the only required frontmatter field.** `description` is
  strongly recommended for auto-invocation but not schema-required.
- **Skills and commands have merged.** Both surface as `/name`. Prefer skills
  for new work; commands are legacy.
- **Optional frontmatter fields:** `when_to_use`, `argument-hint`, `arguments`,
  `effort`, `model`, `allowed-tools`, `disallowed-tools`,
  `disable-model-invocation`, `user-invocable`, `context`, `agent`, `background`,
  `paths`, `shell`, `hooks`.
- **`context: fork`** runs the skill in a subagent, in the background by default
  as of v2.1.214; set `background: false` to wait for its result in the turn.
- **Plugin namespacing.** Skills distributed via plugins are invoked as
  `/plugin-name:skill-name` to avoid collisions.

## Settings & Permissions

- **Permission modes:** config values are `default`, `acceptEdits`, `plan`,
  `auto`, `dontAsk`, `bypassPermissions`. The `default` mode is displayed as
  **Manual** in the CLI, help, and IDE/desktop, and `manual` is accepted as an
  alias for the value (v2.1.200+); the stored config value is still `default`.
  `auto` (classifier-driven) and `dontAsk` are the newer additions.
- **Sandbox primitives.** `sandbox.*` composes with `defaultMode: auto` to
  replace the old conservative/balanced/autonomous profile taxonomy. Real network
  keys are `allowedDomains`, `deniedDomains`, `strictAllowlist` (v2.1.219+, deny
  non-allowlisted hosts without prompting), `httpProxyPort`, `socksProxyPort`;
  filesystem keys are `filesystem.allowWrite/denyWrite/denyRead/allowRead` and
  `filesystem.disabled` (v2.1.216+); plus `excludedCommands`,
  `autoAllowBashIfSandboxed`, `credentials`, and `allowAppleEvents`. There is no
  `network.denyExternal` or `network.allowLocalBinding` key.
- **CLAUDE.md is truncated around 200 lines upstream.** The 60-100 line
  budget in this repo gives headroom below that ceiling.

## Subagents

- **`isolation: worktree`** runs a subagent in a temporary git worktree with
  its own copy of the repo. The worktree is cleaned up automatically if the
  agent makes no changes.
- **Plugin-distributed subagents** cannot declare `hooks`, `mcpServers`, or
  `permissionMode`. Those must come from the host configuration.

## Auto Memory

- Claude Code writes durable memory to
  `~/.claude/projects/<project-slug>/memory/MEMORY.md` automatically.
- This coexists with project-level `PROJECT_STATE.md` — auto memory captures
  cross-session user/feedback/reference facts, while `PROJECT_STATE.md`
  captures in-flight plan state.

## Model IDs

August 2026 GA models (use these in `settings.json` and skill `model:` fields):

| Tier   | Model ID                           | Notes                              |
|--------|------------------------------------|------------------------------------|
| Fable  | `claude-fable-5`                   | Most capable; not the default; `/model fable` |
| Opus   | `claude-opus-5`                    | Recommended for complex agentic coding; default Opus since CLI v2.1.219 |
| Sonnet | `claude-sonnet-5`                  | Claude Code default; intro $2/$10 per MTok through Aug 31, 2026 |
| Haiku  | `claude-haiku-4-5-20251001`        | Fastest; only current model with extended (non-adaptive) thinking |

Opus 4.8, Opus 4.7, Opus 4.6, Sonnet 4.6, and Sonnet 4.5 are now **legacy**
(still callable, migrate off). Single-segment version IDs like `claude-opus-5`
are correct and current; the older `claude-<tier>-4-8` two-segment form is
legacy. Short forms (`opus`, `sonnet`, `haiku`, `fable`) are accepted in agent
frontmatter and resolve to the current model in that tier.

**Alias resolution is provider-specific.** The `opus` / `sonnet` aliases do not
resolve to the same version everywhere:

| Provider                | `opus`   | `sonnet`   |
|-------------------------|----------|------------|
| Anthropic API           | Opus 5   | Sonnet 5   |
| Claude Platform on AWS  | Opus 5   | Sonnet 4.6 |
| Amazon Bedrock, Google Cloud | Opus 5 | Sonnet 4.5 |
| Microsoft Foundry       | Opus 4.6 | Sonnet 4.5 |

Where an alias resolves to an older model, pin the full ID or set
`ANTHROPIC_DEFAULT_OPUS_MODEL` / `ANTHROPIC_DEFAULT_SONNET_MODEL`. Opus 5 via
alias needs Claude Code v2.1.219+; Sonnet 5 needs v2.1.197+.

## Deny List Limits

`permissions.deny` patterns are simple matchers. They block obvious cases
(`rm -rf *`, `sudo *`) but are easily defeated:

- Alternate flag order: `rm -r -f path` vs `rm -rf path`
- Long flags: `rm --recursive --force path`
- Absolute binary paths: `/bin/rm -rf path`
- Different binaries: `find . -delete`

Use deny lists as defense-in-depth. For real isolation, enable the
`sandbox.*` config and the `protect-sensitive-files.py` hook.

## Docs Host

- Canonical docs moved from `docs.anthropic.com/en/docs/claude-code/*` to
  `code.claude.com/docs/en/*`. Old links still redirect but all new
  references in this repo use the new host.
