# Project State: claude-dotfiles

Phase: 3.1 Stage
Approved: pending

## Lifecycle

- [x] 1.1 Research
- [x] 1.2 Plan
- [x] 1.3 Approve
- [x] 2.1 Test
- [x] 2.2 Implement
- [x] 2.3 Verify
- [x] 3.1 Stage
- [ ] 3.2 Confirm CI  <- you are here
- [ ] 3.3 Promote

## Contracts

No open contract. Work on this repo is currency maintenance against the
published documentation, not a specified build, so each pass is scoped by what
the sweep finds rather than by an approved plan. A change large enough to need
one gets a PRD and an approval line here first.

## Current Plan

**September 2026 currency pass.** Reconcile the repo against the live
documentation and fix what has drifted since the August pass. Every claim
touched is verified against the published source on the day it is written, and
the verification date goes in the text rather than in a session transcript.

Standing rule for this repo, learned the expensive way: a validator that checks
shape cannot check meaning, and a green local run is not evidence of a correct
artifact. CI on the pushed commit is the gate, not `npm test` on this machine.

## Branch & Tests

- Branch: staging
- Working tree: clean at each commit; explicit paths staged, never `git add -A`
- Last local run: 13 passed, 0 failed
- Last CI: pending on d6bdeb7

## Phase History

- 2026-04-07 1.2 -> 1.3 April 2026 alignment plan approved; shipped in 0.5.0
- 2026-08-09 3.3 Reconciliation to the August lineup promoted to main
- 2026-08-07 3.2 CI red on both branches, unnoticed for 21 days
- 2026-09-17 2.3 Five senior-review findings fixed; CI green for the first
  time since 2026-08-07
- 2026-09-17 2.2 September currency pass: hook events, token estimator,
  model lineup, skill validator schema wiring

## Outbound Requests

Cross-repo asks filed on the repo that has to act on them, per the
cross-repo-communication rule.

| Filed | Repo | Issue | Ask | Status |
|---|---|---|---|---|
| 2026-08-09 | `peopleforrester/mrf-engagement-orchestrator` | [#66](https://github.com/peopleforrester/mrf-engagement-orchestrator/issues/66) | Publish "The hooks were valid JSON. They never fired." Draft, hero, and calendar entry supplied | open |
| 2026-08-07 | `peopleforrester/mrf-engagement-orchestrator` | [#56](https://github.com/peopleforrester/mrf-engagement-orchestrator/issues/56) | Write an article on this repo from source material | closed, superseded by #66 |

## Superseded Plans

The April 2026 initiative that this file used to describe as EXECUTING shipped
in 0.5.0. Its five phases (documentation truth, schema completeness, new
feature examples, the sandbox primitive pivot, and the command-to-skill
migration) are all complete. [CHANGELOG.md](./CHANGELOG.md) is the accurate
release history; the plan text is preserved in git history rather than here.
