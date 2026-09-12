*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 27. Bug report to failing test

**Trigger:** A bug report is filed or labelled
**Ships:** Ships on green. Opens a PR you can revert in one click. It quarantines and flags, never deletes a test.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/27-bug-report-to-failing-test/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

## Owns, and never touches
- Owns:  Tests
- Never: Application source. This loop reproduces, it does not fix

## What to do
- Turn the bug report into the smallest test that reproduces it, and watch it fail for the right reason.
- Commit the failing test on loop/27-bug-report-to-failing-test and hand it to whoever fixes the code.
- A bug is not understood until a test fails for it. This loop makes that test exist.

## When to stop and call a human
- A report too vague to reproduce. Comment asking for exact steps, do not invent a scenario.
- A 'bug' that is actually intended behavior. Flag it for a human, do not write a test that locks in a wrong expectation.

## Memory
- Read `memory/27-bug-report-to-failing-test.md` at the start. Append one durable lesson at the end.

---

[← All qa and testing loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
