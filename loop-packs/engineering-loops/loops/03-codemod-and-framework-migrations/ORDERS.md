*[Contents](../../../../README.md) · [Chapter 1: Software engineering](../../LOOPS.md)*

# Loop 03. Codemod and framework migrations

**Trigger:** Dispatch: you point it at a migration
**Ships:** Ships on green. Opens a PR you can revert in one click, and merges once the check is green.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/03-codemod-and-framework-migrations/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_CODEMOD` (e.g. `npx jscodeshift -t ./codemods/foo.js src/`) or `MIGRATION` (e.g. `react-18-to-19`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Owns, and never touches
- Owns:  The files the named codemod targets
- Never: Anything outside the codemod's scope, unrelated refactors

## What to do
- Apply the named codemod across the repo with a real tool (jscodeshift, ast-grep, the framework's own migrator).
- Run the build and the full test suite. The migration is done only when both are green.
- Open one PR on branch loop/03-codemod-and-framework-migrations.
- Name the codemod or the target version in your dispatch input, or in this file.

## When to stop and call a human
- The codemod cannot be applied cleanly across the repo. Stop, open an issue with the failing files, do not hand hack a partial migration.
- A migration large enough that a human must review the approach first. Open a draft PR and flag it for review, do not auto merge.

## Memory
- Read `memory/03-codemod-and-framework-migrations.md` at the start. Append one durable lesson at the end.

---

[← All software engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
