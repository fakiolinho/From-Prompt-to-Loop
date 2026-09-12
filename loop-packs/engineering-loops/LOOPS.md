*[Contents](../../README.md) · Chapter 1 of 4*

# Chapter 1 · Software engineering

**Loops 1-9.** The chapter's loops, one row each. New to all this? Start at [what a loop is](../../docs/01-what-is-a-loop.md).

Nine loops from the engineering chapter of *From Prompt to Loop*. One shared runner
(`.github/workflows/loop.yml`) runs any of them on **Claude or Codex**. Each loop is a
folder of standing orders plus a check that answers one question: *is there work?*
Exit 0 means nothing to do and no agent runs. Non zero wakes the agent.

| # | Loop | Trigger | Ships | The check looks for | Runnable now |
|---|------|---------|-------|---------------------|--------------|
| 1 | [Docs and examples sync](loops/01-docs-and-examples-sync/ORDERS.md) | push to src | Ships on green | docs drift | **yes, full runnable example in `loops/01-docs-and-examples-sync/example`** |
| 2 | **★** [Dependency upgrades](loops/02-dependency-upgrades/ORDERS.md) | weekly | Ships on green | outdated deps (`npm outdated`) | yes |
| 3 | [Codemod and framework migrations](loops/03-codemod-and-framework-migrations/ORDERS.md) | dispatch | Ships on green | (you point it at a migration) | wire the codemod |
| 4 | [Test backfill on changed code](loops/04-test-backfill-on-changed-code/ORDERS.md) | on PR | Ships on green | changed code with no test | yes (heuristic) |
| 5 | [Dead code and unused dependency removal](loops/05-dead-code-and-unused-dependency-removal/ORDERS.md) | weekly | **Flags, you decide** | dead code (`knip`), once knip is configured | reports only |
| 6 | **★** [Lint, format, and type fixes](loops/06-lint-format-and-type-fixes/ORDERS.md) | on push | Ships on green | the project's own lint, format and typecheck scripts | yes |
| 7 | **★** [Release notes and changelog](loops/07-release-notes-and-changelog/ORDERS.md) | on tag | Ships on green | commits since the last release tag | yes |
| 8 | [First pass code review](loops/08-first-pass-code-review/ORDERS.md) | PR opened | **Flags, you decide** | a PR to review | runnable example (review.js) |
| 9 | [Issue triage and routing](loops/09-issue-triage-and-routing/ORDERS.md) | issue opened | **Flags, you decide** | an issue to triage | runnable example (triage.js) |

**Ships on green** loops open a PR on `loop/<name>` and merge once the check passes. A bad
one is one click back. **Flags, you decide** loops stop and hand you the call; they never merge.
**★** marks the guide's three easiest first builds. Both kinds are fenced, capped, and stoppable
the same way.

Loop 1 is the worked example: its `example/` folder is a complete, runnable docs-sync loop
(its own source, check, memory, and standalone workflow). Run `bash loops/01-docs-and-examples-sync/check.sh`
and it works offline today. The other eight are orders and a check, ready to wire into your repo.

## Where these tags come from

The two tags and the star on this page are the field guide's own, taken from the catalog on pages
22 to 25. They are not our shorthand. If a row here ever disagrees with the guide, the guide wins,
and `ci/test-docs.sh` says so before you find out the hard way.

**★** marks the three easiest first builds, and all three are in this chapter: loops 2, 6 and 7.
Mechanical, fully checkable, trivially reversible. Start with one of those and you learn the shape
of a loop without betting anything on it.

**[Read the field guide](../../From-Prompt-to-Loop_The-Warship-CTO.pdf)**, free, in the root of this
repo. Every loop on this page has its reasoning in there: why it is worth building, what it costs,
and when it is not a loop at all.

---

[Contents](../../README.md) · [Chapter 2: Cloud and platform →](../cloud-loops/LOOPS.md)
