*[Contents](../../README.md) · Chapter 3 of 4 · [the loops in this chapter](LOOPS.md)*

# Chapter 3 · AI and ML engineering

**Loops 19-26.** How this chapter works: the runner, the rules, the fences.

The AI and ML chapter, built as one dual agent pack. Drop it next to your ML repo, point the
runner at a loop, and run it on **Claude or Codex**.

## The chapter's one law
A regression never ships. Evals, conformance, and red team loops block and open an issue when
quality or safety drops. The baseline is raised only on a real, held improvement, never edited
down to pass. The global rule lives in `CLAUDE.md` / `AGENTS.md`; each loop adds its specifics.

## A loop is three layers; only one is loop specific
- **The work and the check** live in `loops/<name>/` (orders plus a real `check.sh`).
- **The trigger and the agent** live in one shared workflow, `.github/workflows/loop.yml`.
- **The orders** are split: global in `CLAUDE.md` / `AGENTS.md`, per loop in each `ORDERS.md`.

## Run any loop

**On your machine first.** From this repo, pointed at yours:

    ./install.sh ~/code/my-app 19      put the loop in your repo
    cd ~/code/my-app
    ./run-loop.sh 19 --check           is there work?
    ./run-loop.sh 19                   hand it to the agent and watch

`run-loop.sh` is the workflow, locally. It loads `loops.env`, runs the check, wakes the agent
only if the answer is 1, and runs the check again afterwards so nothing marks its own work. No
secret, no schedule, nothing committed. If you are signed in to Claude Code, a subscription
included, there is nothing to buy.

**Then on a clock.** From the Actions tab, run **ai-ml-loop** with the `loop` folder and the `agent`
(`claude` or `codex`). The runner checks first; nothing to do, it ends green and spends nothing.
Work to do, it wakes the chosen agent, fenced and capped. A CI runner has no login, so that path
needs `ANTHROPIC_API_KEY` in your repo secrets.

A loop that needs a setting says so and exits 2. Settings live in `loops.env`; the full list is
in [WIRING.md](../../WIRING.md).


## The worked example
Loop 19 ships a full runnable eval harness in `loops/19-eval-suite-on-prompt-or-model-change/example`.

    cd loops/19-eval-suite-on-prompt-or-model-change/example
    npm test     # green. Nothing regressed.
    npm run evals   # the raw harness: 0 at baseline, 3 above it, 1 on a regression

Break a rule in `src/classify.js` and it drops below baseline and refuses to ship, naming the
exact cases that failed. That is the AI-work version of a unit test.

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
New to the pack? Start in `demo-app/`. It is seeded with real work for loops 20 to 26. Run
`node loops.js all` (no install) and watch each loop find its problem, then fix it by hand or
hand it to an agent. The shortest path from reading the loops to running them.

---

[← Chapter 2: Cloud and platform](../cloud-loops/README.md) · [Contents](../../README.md) · [Chapter 4: QA and testing →](../qa-loops/README.md)
