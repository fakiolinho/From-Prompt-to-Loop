*[Contents](../../../../README.md) · [Chapter 1: Software engineering](../../LOOPS.md)*

# Loop 05. Dead code and unused dependency removal

**Trigger:** Weekly schedule
**Ships:** Ships on green. Opens a PR you can revert in one click, and merges once the check is green.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/05-dead-code-and-unused-dependency-removal/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

## Owns, and never touches
- Owns:  Unreachable code and unused dependencies the tools and the build agree are dead
- Never: Anything the build or tests still need

## What to do
- Remove only what the tooling flags AND the build and full test suite confirm is unused.
- Run the build and tests after removal. A bad cut is one revert.
- Open one PR on branch loop/05-dead-code-and-unused-dependency-removal.

## When to stop and call a human
- Code reachable only by reflection, dynamic import, or a string name. The tools miss this. When unsure, leave it and flag it.
- Anything whose removal turns the build or tests red. Put it back.

## Memory
- Read `memory/05-dead-code-and-unused-dependency-removal.md` at the start. Append one durable lesson at the end.

---

[← All software engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
