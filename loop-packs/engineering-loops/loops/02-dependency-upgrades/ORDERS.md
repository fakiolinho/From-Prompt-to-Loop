*[Contents](../../../../README.md) · [Chapter 1: Software engineering](../../LOOPS.md)*

# Loop 02. Dependency upgrades

**Trigger:** Weekly schedule
**Ships:** Ships on green. Opens a PR you can revert in one click, and merges once the check is green.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/02-dependency-upgrades/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

## Owns, and never touches
- Owns:  package.json and the lockfile
- Never: Application source, public APIs, anything generated

## What to do
- Bump dependencies to their latest patch and minor versions.
- Run the project's full test suite. The bump is done only when it is green.
- Open one PR per batch on branch loop/02-dependency-upgrades. Reversible, ships on green.
- The maintainer wrote the code and the world reviewed it. Your only risk is integration, and the tests catch that.

## When to stop and call a human
- A major version bump. Open an issue with the changelog link and stop. Never auto bump a major.
- Tests that will not go green after a bump. Revert that one dep, flag it, keep the rest.

## Memory
- Read `memory/02-dependency-upgrades.md` at the start. Append one durable lesson at the end.

---

[← All software engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
