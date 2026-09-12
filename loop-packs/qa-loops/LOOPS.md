*[Contents](../../README.md) · Chapter 4 of 4*

# Chapter 4 · QA and testing

**Loops 27-35.** The chapter's loops, one row each. New to all this? Start at [what a loop is](../../docs/01-what-is-a-loop.md).

Nine loops from the QA and testing chapter of *From Prompt to Loop*. Numbers track the master
catalog in the guide. One shared runner (`.github/workflows/loop.yml`) runs any of them on
**Claude or Codex**. Each loop is a folder of standing orders plus a check that answers one
question: *is there work?* Exit 0 means nothing to do. Non zero wakes the agent.

The law of this chapter: **never delete or weaken a test to go green.** Quarantine and flag
instead. And reproduce before you fix, a bug is not understood until a test fails for it.

| # | Loop | Trigger | Ships | The check looks for | To run it here |
|---|------|---------|-------|---------------------|--------------|
| 27 | [Bug report to failing test](loops/27-bug-report-to-failing-test/ORDERS.md) | bug filed | Ships on green | reports with no reproducing test | set LOOP_BUGS |
| 28 | [Flaky test detection and quarantine](loops/28-flaky-test-detection-and-quarantine/ORDERS.md) | nightly | Ships on green | a flaky or broken test | **worked example inside**, or set LOOP_TEST |
| 29 | [Self healing UI tests](loops/29-self-healing-ui-tests/ORDERS.md) | UI test fails on a locator | Ships on green | selector-only failures | set LOOP_UI_TESTS |
| 30 | [Test data and fixtures](loops/30-test-data-and-fixtures/ORDERS.md) | schema change | Ships on green | fixtures that no longer fit the schema | set LOOP_FIXTURES |
| 31 | [Smoke tests on every deploy](loops/31-smoke-tests-on-every-deploy/ORDERS.md) | on deploy | Ships on green | a failing critical path post deploy | set LOOP_SMOKE |
| 32 | [Cross browser and device matrix](loops/32-cross-browser-and-device-matrix/ORDERS.md) | nightly / release | Ships on green | failures by config | set LOOP_MATRIX |
| 33 | [Visual regression triage](loops/33-visual-regression-triage/ORDERS.md) | on PR | **Flags, you decide** | screenshot diffs | set LOOP_VISUAL |
| 34 | [E2E coverage from real user flows](loops/34-e2e-coverage-from-real-user-flows/ORDERS.md) | weekly | **Flags, you decide** | top journeys with no e2e test | set LOOP_JOURNEYS |
| 35 | [Synthetic uptime and journey monitoring](loops/35-synthetic-uptime-and-journey-monitoring/ORDERS.md) | continuous | **Flags, you decide** | a failing or slow prod journey | set LOOP_SYNTHETIC |

**Ships on green** loops open a PR on `loop/<name>` and merge once the check passes. A bad
one is one click back. **Flags, you decide** loops stop and hand you the call; they never merge.
**★** marks the guide's three easiest first builds. Both kinds are fenced, capped, and stoppable
the same way.

Loop 28 is the worked example: a complete, runnable flaky test detector. It runs each test 20x,
flags the unstable one, and refuses to call the suite green. Run
`bash loops/28-flaky-test-detection-and-quarantine/check.sh` and it works offline today. The
other eight are orders and a check, ready to wire into your test stack.

Anything in the **To run it here** column that names a `LOOP_*` setting goes in your repo's
`loops.env`, which `./install.sh` writes for you. [WIRING.md](../../WIRING.md) is the full
reference. A loop whose setting is missing exits 2 and says what it wanted; it never guesses
and never wakes an agent.

## Where these tags come from

The two tags and the star on this page are the field guide's own, taken from the catalog on pages
22 to 25. They are not our shorthand. If a row here ever disagrees with the guide, the guide wins,
and `ci/test-docs.sh` says so before you find out the hard way.

**★** marks the three easiest first builds. All three sit in chapter 1, so this chapter has none.
Get one of those running first. This chapter is worth adopting once a loop opening PRs on your repo
has stopped feeling like a risk.

**[Read the field guide](../../From-Prompt-to-Loop_The-Warship-CTO.pdf)**, free, in the root of this
repo. Every loop on this page has its reasoning in there: why it is worth building, what it costs,
and when it is not a loop at all.

---

[← Chapter 3: AI and ML engineering](../ai-ml-loops/LOOPS.md) · [Contents](../../README.md)
