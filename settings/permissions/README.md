# Permission Profiles (April 2026)

These four profiles compose two orthogonal Claude Code primitives:

- **`sandbox.*`** — container-style isolation for bash and (optionally) network
- **`defaultMode: auto`** — classifier-driven decisions about whether to ask
  the user, accept the edit, or block

The legacy `conservative` / `balanced` / `autonomous` profiles have been
removed. They conflated these primitives into preset bundles, which made
real customization awkward.

## Choosing a Profile

| Profile | Sandbox | Default Mode | Escalation Surface |
|---------|---------|--------------|--------------------|
| **sandbox-on** | yes | `auto` | Anything outside the sandbox |
| **sandbox-off** | no | `acceptEdits` | Bash always asks, edits go through |
| **autoMode-strict** | yes | `auto` | All writes, edits, bash, network |
| **autoMode-permissive** | yes | `auto` | Destructive bash, external network |

### When to pick which

- **sandbox-on** — Long-running automation in CI or batch jobs. You want
  bash isolated and the model to handle yes/no decisions.
- **sandbox-off** — Daily local development on machines you fully trust.
  Familiar `acceptEdits` flow, prompts only on bash.
- **autoMode-strict** — First time on auto mode. Anything that mutates state
  or reaches the network escalates to you. Useful while you build trust.
- **autoMode-permissive** — Trusted automation. Routine edits, reads, and
  dev bash flow through; destructive bash and external fetches escalate.

## Composition Rules

- `permissions.deny` is checked first and is non-negotiable in every profile.
- `auto.allowOn` and `auto.escalateOn` are matchers identical to the
  `allow` / `ask` lists; the classifier consults them when `defaultMode`
  is `auto`.
- `sandbox.enabled: true` does not override `permissions.deny` — denied
  paths stay denied even inside the sandbox.

## Customizing

Treat these as starting points. Common edits:

```bash
# Tighten auto-mode escalation
jq '.auto.escalateOn += ["Bash(npm publish *)"]' \
  settings/permissions/autoMode-permissive.json

# Loosen sandbox network policy
jq '.sandbox.network.denyExternal = false' \
  settings/permissions/sandbox-on.json
```

Always re-validate after edits: `python3 scripts/validate.py .`.

## See also

- [`settings/settings.json`](../settings.json) — full reference config
- [`GOTCHAS.md`](../../GOTCHAS.md) — permission-mode and sandbox notes
- [`SECURITY.md`](../../SECURITY.md) — deny-list defense-in-depth caveats
