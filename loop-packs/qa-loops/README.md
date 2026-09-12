*[Contents](../../README.md) · Chapter 4 of 4 · [the loops in this chapter](LOOPS.md)*

# Chapter 4 · QA and testing

**Loops 27-35.** How this chapter works: the runner, the rules, the fences.

The QA and testing chapter, built as one dual agent pack. Drop it next to your test suite,
point the runner at a loop, and run it on **Claude or Codex**.

## The chapter's one law
Never delete or weaken a test to go green. Quarantine flaky tests and flag broken ones; the
truth a failing test tells is the whole value of having it. Reproduce before you fix. The
global rule lives in `CLAUDE.md` / `AGENTS.md`; each loop adds its specifics.

## A loop is three layers; only one is loop specific
- **The work and the check** live in `loops/<name>/` (orders plus a real `check.sh`).
- **The trigger and the agent** live in one shared workflow, `.github/workflows/loop.yml`.
- **The orders** are split: global in `CLAUDE.md` / `AGENTS.md`, per loop in each `ORDERS.md`.

## Run any loop
From the Actions tab, run **qa-loop** with the `loop` folder and the `agent` (`claude` or
`codex`). The runner checks first; nothing to do, it ends green and spends nothing. Work to do,
it wakes the chosen agent, fenced and capped.

## The worked example
Loop 28 ships a full runnable flaky test detector in
`loops/28-flaky-test-detection-and-quarantine/example`.

    cd loops/28-flaky-test-detection-and-quarantine/example
    npm test     # runs each test 20x; flags the flaky one and exits non-zero

It includes one intentionally flaky test next to two healthy ones, so you can watch the
detector catch it. Quarantining a flaky test is the loop's job; deleting it is forbidden.

## What keeps every loop safe
- **Gated:** the agent only runs when the check says there is work.
- **Fenced:** `--allowedTools` for Claude, `--sandbox workspace-write` for Codex.
- **Capped:** for Claude, `--max-turns 30` and `--max-budget-usd 2` end the run before it can
  get expensive. Codex has neither flag (passing `--max-turns` to Codex is an error), so it
  relies on `--sandbox workspace-write` instead. The job's `timeout-minutes` backs up both.
- **One PR:** one fixed branch per loop, never a second PR for the same work.
- **Honest about a broken check:** `check.sh` exits 0 for no work, 1 for work, and 2 when it is
  not wired to this repo yet. Only a 1 wakes the agent. A 2 fails the run, so you never pay
  tokens for a check that was never pointed at anything.

## Ships on green, or flags for you

Every loop is one of two kinds, and `LOOPS.md` says which.

- **Ships on green.** It opens a PR and merges once the check passes. A bad one is one click back.
- **Flags, you decide.** It stops and hands you the call. It never merges on its own.

Nothing irreversible happens without a person. That is what makes a loop safe to walk away from.

See `LOOPS.md` for the order and the runnable status of each.

## Try the loops on the demo app
New to the pack? Start in `demo-app/`. It is seeded with real work for loops 27, 30, 33 and 34.
Run `node loops.js all` (no install) and watch each find its problem. Loop 28 has its own
runnable example. Loops 29, 31, 32 and 35 are integration loops: each ships a config example
and sharpened ORDERS rather than a stub, because they govern a tool you already run.

---

[← Chapter 3: AI and ML engineering](../ai-ml-loops/README.md) · [Contents](../../README.md)
