*[Contents](../../../../README.md) · [Chapter 1: Software engineering](../../LOOPS.md)*

# Loop 02. Dependency upgrades

**Trigger:** Weekly schedule
**Ships:** Ships on green. Opens a PR you can revert in one click, and merges once the check is green.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/02-dependency-upgrades/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_VERIFY` in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Owns, and never touches
- Owns:  package.json and the lockfile
- Never: Application source, public APIs, anything generated

## What to do
- Bump to the **Wanted** column of `npm outdated`, never the Latest column.
  Wanted is what the ranges already in package.json allow. Latest is not always newer:
  `@types/node` pins its latest tag to the current Node LTS, so on a repo running a newer
  major, "upgrading to latest" is a downgrade of two majors.
- Never install a version lower than the one already installed, whatever npm calls latest.
- Run the repo's verify command, the one the check named. The bump is done only when it is
  green. If there is no verify command the check exits 2 and you never run at all.
- Open one PR per batch on branch loop/02-dependency-upgrades. Reversible, ships on green.
- The maintainer wrote the code and the world reviewed it. Your risk is integration, and the
  verify command is the only thing that catches it. It is worth exactly as much as that
  command is.

## When to stop and call a human
- A major version bump. Open an issue with the changelog link and stop. Never auto bump a major.
- Tests that will not go green after a bump. Revert that one dep, flag it, keep the rest.

## Memory
- Read `memory/02-dependency-upgrades.md` at the start. Append one durable lesson at the end.

---

[← All software engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
