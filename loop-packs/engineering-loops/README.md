*[Contents](../../README.md) · Chapter 1 of 4 · [the loops in this chapter](LOOPS.md)*

# Chapter 1 · General engineering

**Loops 1-9.** How this chapter works: the runner, the rules, the fences.

The nine loops from the engineering chapter, built as one dual agent pack. Drop it next to
a real repo, point the runner at a loop, and run it on **Claude or Codex**.

## A loop is three layers; only one is loop specific
- **The work and the check** live in `loops/<name>/` (the orders and a real `check.sh`).
- **The trigger and the agent** live in one shared workflow, `.github/workflows/loop.yml`.
- **The standing orders** are split: global rules in `CLAUDE.md` / `AGENTS.md`, per loop
  specifics in each `ORDERS.md`.

Swap the agent, keep everything else. Claude reads `CLAUDE.md`; Codex reads `AGENTS.md`.

## Run any loop

From the Actions tab, run **engineering-loop** with two inputs: the `loop` folder and the
`agent` (`claude` or `codex`). The runner checks first; if there is nothing to do it ends
green and spends nothing. If there is work, it wakes the chosen agent, fenced and capped.

Locally, the same shape:

    # is there work?
    bash loops/06-lint-format-and-type-fixes/check.sh

    # if it exits non-zero, hand the loop to an agent
    npx @anthropic-ai/claude-code -p "Read CLAUDE.md and loops/06-lint-format-and-type-fixes/ORDERS.md. Do exactly what the orders say. Run the check until it exits 0. Open a PR on loop/06-lint-format-and-type-fixes." \
      --allowedTools "Read,Edit,Bash(npm:*),Bash(npx:*),Bash(git:*),Bash(gh:*)" --max-turns 30 --max-budget-usd 2

    # or Codex, same orders
    npx @openai/codex exec --sandbox workspace-write "Read AGENTS.md and loops/06-lint-format-and-type-fixes/ORDERS.md ..."

## What keeps every loop safe
- **Gated:** the agent only runs when the check says there is work. Green nights cost nothing.
- **Fenced:** `--allowedTools` for Claude, `--sandbox workspace-write` for Codex. The orders
  are the soft rule; the fence is the enforced one.
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

## The order
See `LOOPS.md`. Number 1, docs and examples sync, ships with a full runnable example inside
its own folder, `loops/01-docs-and-examples-sync/example`. Run its check and it works offline
today. The other eight are orders and a check, ready to wire into your codebase.

## Try the loops on the demo app
New to the pack? Start in `demo-app/`. It is a small project seeded with real work for loops
2, 4, 5, 6, and 7. Run `node loops.js all` (no install needed) and watch each loop find its
problem, then fix it by hand or hand it to an agent. It is the shortest path from reading the
loops to running them.

Loops 8 and 9 also ship runnable examples: a sample PR diff with `review.js`, and a sample issue with `triage.js`. Run them offline to see the review and the triage with no GitHub flow needed.

---

[Contents](../../README.md) · [Chapter 2: Cloud and platform →](../cloud-loops/README.md)
