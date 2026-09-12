*[Contents](../../../../README.md) · [Chapter 1: General engineering](../../LOOPS.md)*

# Loop 01. Docs and examples sync

**Trigger:** Push to the source the docs describe
**Ships:** Ships on green. Opens a PR you can revert in one click, and merges once the check is green.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/01-docs-and-examples-sync/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

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

[← All general engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
