*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 30. Test data and fixtures

**Trigger:** A schema or model change
**Ships:** Ships on green. Opens a PR you can revert in one click. It quarantines and flags, never deletes a test.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/30-test-data-and-fixtures/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_FIXTURES` (e.g. `npx ajv validate -s schema.json -d \"fixtures/*.json\"`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/30-test-data-and-fixtures/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 30

**Yes.** From your project root:

    ./run-loop.sh 30 --check    is there work? Never wakes an agent.
    ./run-loop.sh 30            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  Fixtures and factories
- Never: The tests' assertions and application code

## What to do
- When the schema changes, regenerate the fixtures and factories to match it: minimal, valid, and realistic.
- Run the suite to confirm the new fixtures still drive every test. Open a PR on loop/30-test-data-and-fixtures.
- Stale fixtures fail tests for the wrong reason. Keep them honest to the current schema.

## When to stop and call a human
- A fixture change that would alter what a test proves. Flag it, do not quietly change the meaning of a test.
- A schema change you cannot map to valid data without guessing. Open an issue and stop.

## Memory
- Read `memory/30-test-data-and-fixtures.md` at the start. Append one durable lesson at the end.

---

[← All qa and testing loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
