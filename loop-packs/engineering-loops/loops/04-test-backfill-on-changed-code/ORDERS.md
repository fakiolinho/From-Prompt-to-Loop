*[Contents](../../../../README.md) · [Chapter 1: Software engineering](../../LOOPS.md)*

# Loop 04. Test backfill on changed code

**Trigger:** On pull request or push
**Ships:** Ships on green. Opens a PR you can revert in one click, and merges once the check is green.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/04-test-backfill-on-changed-code/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `BASE_REF` in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/04-test-backfill-on-changed-code/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 04

**Yes.** From your project root:

    ./run-loop.sh 04 --check    is there work? Never wakes an agent.
    ./run-loop.sh 04            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  Test files only
- Never: Application source. Never change src to make a test pass

## What to do
- For code changed without matching tests, write focused tests that pass against the current behavior.
- Tests assert what the code does today, not what you wish it did.
- Open one PR on branch loop/04-test-backfill-on-changed-code that adds the tests.

## When to stop and call a human
- The intended behavior is ambiguous and a test would only guess it. Flag the file, do not invent an assertion.
- A change to src would be needed to make code testable. That is a human decision. Flag it.

## Memory
- Read `memory/04-test-backfill-on-changed-code.md` at the start. Append one durable lesson at the end.

---

[← All software engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
