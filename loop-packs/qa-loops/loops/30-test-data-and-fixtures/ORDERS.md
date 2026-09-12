*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 30. Test data and fixtures

**Trigger:** A schema or model change
**Ships:** Ships on green. Opens a PR you can revert in one click. It quarantines and flags, never deletes a test.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/30-test-data-and-fixtures/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_FIXTURES` (e.g. `npx ajv validate -s schema.json -d \"fixtures/*.json\"`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

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
