*[Contents](../../README.md) · Chapter 3 of 4*

# Chapter 3 · AI and ML engineering

**Loops 19-26.** The chapter's loops, one row each. New to all this? Start at [what a loop is](../../docs/01-what-is-a-loop.md).

Eight loops from the AI and ML chapter of *From Prompt to Loop*. Numbers track the master
catalog in the guide. One shared runner (`.github/workflows/loop.yml`) runs any of them on
**Claude or Codex**. Each loop is a folder of standing orders plus a check that answers one
question: *is there work?* Exit 0 means nothing to do. Non zero wakes the agent.

The rule that governs the whole chapter: **a regression never ships.** If quality, accuracy,
or safety drops below the baseline, the loop stops and opens an issue. It never lowers the bar.

| # | Loop | Trigger | Ships | The check looks for | To run it here |
|---|------|---------|-------|---------------------|--------------|
| 19 | [Eval suite on every prompt or model change](loops/19-eval-suite-on-prompt-or-model-change/ORDERS.md) | prompt/model change | Ships on green | an accuracy regression | **worked example inside**, or set LOOP_EVALS |
| 20 | [RAG knowledge base sync](loops/20-rag-knowledge-base-sync/ORDERS.md) | a source changes | Ships on green | a source newer than its index | set LOOP_RAG |
| 21 | [Structured output conformance](loops/21-structured-output-conformance/ORDERS.md) | prompt/schema change | Ships on green | outputs that break the schema | set LOOP_SCHEMA |
| 22 | [Model version upgrade testing](loops/22-model-version-upgrade-testing/ORDERS.md) | new version available | **Flags, you decide** | (you point it at a version) | set LOOP_CANDIDATE |
| 23 | [Golden set growth from production failures](loops/23-golden-set-growth-from-production-failures/ORDERS.md) | new prod failures | **Flags, you decide** | failures not yet in the golden set | set LOOP_FAILURES |
| 24 | [Prompt cost and routing optimisation](loops/24-prompt-cost-and-routing-optimisation/ORDERS.md) | weekly / cost spike | **Flags, you decide** | cost above baseline | set LOOP_COST |
| 25 | [Safety and red team regression](loops/25-safety-and-red-team-regression/ORDERS.md) | prompt/model change | **Flags, you decide** | a red team regression | set LOOP_REDTEAM |
| 26 | [Data quality and drift monitoring](loops/26-data-quality-and-drift-monitoring/ORDERS.md) | scheduled | **Flags, you decide** | drift over threshold | set LOOP_DRIFT |

**Ships on green** loops open a PR on `loop/<name>` and merge once the check passes. A bad
one is one click back. **Flags, you decide** loops stop and hand you the call; they never merge.
**★** marks the guide's three easiest first builds. Both kinds are fenced, capped, and stoppable
the same way.

Loop 19 is the worked example: a complete, runnable eval harness, an intent classifier with a
real eval set and a baseline. Run `bash loops/19-eval-suite-on-prompt-or-model-change/check.sh`
and it works offline today, blocking on any accuracy regression. The other seven are orders and
a check, ready to wire into your stack. Loop 25 is the same harness pointed at adversarial cases.

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

[← Chapter 2: Cloud and platform](../cloud-loops/LOOPS.md) · [Contents](../../README.md) · [Chapter 4: QA and testing →](../qa-loops/LOOPS.md)
