*[Contents](../../../../README.md) · [Chapter 1: Software engineering](../../LOOPS.md)*

# Loop 06. Lint, format, and type fixes

**Trigger:** On push
**Ships:** Ships on green. Opens a PR you can revert in one click, and merges once the check is green.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/06-lint-format-and-type-fixes/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/06-lint-format-and-type-fixes/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 06

**Yes.** From your project root:

    ./run-loop.sh 06 --check    is there work? Never wakes an agent.
    ./run-loop.sh 06            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  Formatting, lint, and mechanically safe type fixes across the repo
- Never: Application logic. A fix that changes behavior is not a lint fix

## What to do
- Run the commands this project already defines: its lint, format and typecheck scripts.
  The check names the ones it found. Never invent a command of your own.
- Apply the mechanical fixes those commands ask for, using the project's own write variants
  (`format:fix`, `prettify:write`) where they exist.
- The loop is done when those same commands exit clean. Not a command you substituted.
- Open one PR on branch loop/06-lint-format-and-type-fixes.

## When to stop and call a human
- A type error with no safe mechanical fix. Flag it; never silence it with `any` or a
  suppression comment.
- Any file outside the scope the project's own commands cover. If a command is scoped to
  `resources/**`, that scope is the team's decision, not an oversight to correct.
- A project with no lint, format or typecheck script. The check exits 2 there. Do not offer
  to pick a style for them; a formatter nobody adopted rewrites every file it can see.

## Memory
- Read `memory/06-lint-format-and-type-fixes.md` at the start. Append one durable lesson at the end.

---

[← All software engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
