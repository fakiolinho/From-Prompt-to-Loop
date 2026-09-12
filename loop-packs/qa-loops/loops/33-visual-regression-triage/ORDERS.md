*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 33. Visual regression triage

**Trigger:** On pull request
**Ships:** Flags, you decide. It triages and reports. A human makes the call before anything is accepted.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/33-visual-regression-triage/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

## Owns, and never touches
- Owns:  The baseline screenshots and the triage
- Never: The application code

## What to do
- Diff the new screenshots against the baselines. Accept changes that match an intended UI change in the PR.
- Flag the diffs that look like real regressions, with the before and after, for a human to confirm.
- Open a PR on loop/33-visual-regression-triage that updates the baselines you accepted.

## When to stop and call a human
- A diff you cannot confidently call intended or a regression. Flag it for a human, do not auto accept on a guess.
- A sweeping diff across the whole page. Stop, that is usually a layout break, not an intended change.

## Memory
- Read `memory/33-visual-regression-triage.md` at the start. Append one durable lesson at the end.

---

[← All qa and testing loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
