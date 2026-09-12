*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 32. Cross browser and device matrix

**Trigger:** Nightly or on release
**Ships:** Ships on green. Opens a PR you can revert in one click. It quarantines and flags, never deletes a test.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/32-cross-browser-and-device-matrix/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

## Owns, and never touches
- Owns:  The compatibility report
- Never: The application and the tests

## What to do
- Run the suite across the browser and device matrix and collect failures by configuration.
- Post a report: which flows break on which browser or device. A human decides what to fix.
- Flag loop: it surfaces compatibility gaps, it does not change the app.

## When to stop and call a human
- A failure that only reproduces on one rare config. Report it with the exact config, do not drop it as noise.
- Anything that would change the app to pass. Not this loop's call.

## Wire it to your tool
Start from `matrix.example.json`. A device farm (BrowserStack, Sauce, Playwright) runs the suite across the matrix; this loop owns the matrix list and posts the gap report. It changes neither the app nor the tests.

## Memory
- Read `memory/32-cross-browser-and-device-matrix.md` at the start. Append one durable lesson at the end.

---

[← All qa and testing loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
