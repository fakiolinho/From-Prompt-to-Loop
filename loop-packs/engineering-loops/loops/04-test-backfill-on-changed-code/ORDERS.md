*[Contents](../../../../README.md) · [Chapter 1: Software engineering](../../LOOPS.md)*

# Loop 04. Test backfill on changed code

**Trigger:** On pull request or push
**Ships:** Ships on green. Opens a PR you can revert in one click, and merges once the check is green.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/04-test-backfill-on-changed-code/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `BASE_REF` in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

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
