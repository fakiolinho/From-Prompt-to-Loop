*[Contents](../../../../README.md) · [Chapter 1: Software engineering](../../LOOPS.md)*

# Loop 01. Docs and examples sync

**Trigger:** Push to the source the docs describe
**Ships:** Ships on green. Opens a PR you can revert in one click, and merges once the check is green.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/01-docs-and-examples-sync/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_DOCS` (e.g. `npm run test:examples`) in your `loops.env`, or a `check-docs` or `check:docs` script in package.json, which the check uses when `LOOP_DOCS` is unset. With neither the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/01-docs-and-examples-sync/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 01

**Yes.** From your project root:

    ./run-loop.sh 01 --check    is there work? Never wakes an agent.
    ./run-loop.sh 01            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  /docs and /examples
- Never: Source code and the public API

## What to do
- When the API changes, rewrite the drifted docs and examples to match the code.
- Run every example. It is fixed only when each one runs clean.
- Open or update one PR on branch loop/01-docs-and-examples-sync.
- A fully runnable example of this loop lives in `./example`. The check runs it; copy it next to a real SDK to put the loop to work.

## When to stop and call a human
- The API changed in a way you cannot map to docs without guessing intent. Open an issue and stop.
- An example you cannot make pass. Leave it failing and flag it. Never weaken the check.

## Memory
- Read `memory/01-docs-and-examples-sync.md` at the start. Append one durable lesson at the end.

---

[← All software engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
