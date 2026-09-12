*[Contents](../../../../README.md) · [Chapter 1: General engineering](../../LOOPS.md)*

# Loop 06. Lint, format, and type fixes

**Trigger:** On push
**Ships:** Ships on green. Opens a PR you can revert in one click, and merges once the check is green.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/06-lint-format-and-type-fixes/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

## Owns, and never touches
- Owns:  Formatting, lint, and mechanically safe type fixes across the repo
- Never: Application logic. A fix that changes behavior is not a lint fix

## What to do
- Auto-fix the lint, format, and type errors that have a safe mechanical fix.
- The check passes only when eslint, prettier, and tsc all exit clean.
- Open one PR on branch loop/06-lint-format-and-type-fixes.

## When to stop and call a human
- A type error you can only silence with a disable comment or an any. Never suppress to go green. Flag it.
- A fix that would change runtime behavior. That is not formatting. Flag it.

## Memory
- Read `memory/06-lint-format-and-type-fixes.md` at the start. Append one durable lesson at the end.

---

[← All general engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
