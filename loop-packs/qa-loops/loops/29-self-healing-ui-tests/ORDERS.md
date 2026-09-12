*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 29. Self healing UI tests

**Trigger:** A UI test fails on a selector
**Ships:** Ships on green. Opens a PR you can revert in one click. It quarantines and flags, never deletes a test.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/29-self-healing-ui-tests/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

## Owns, and never touches
- Owns:  Selectors in the UI tests
- Never: Application code and test assertions

## What to do
- When a UI test breaks because an element moved or its selector changed, but the element clearly still exists, update the selector and rerun.
- Heal only the locator. Never touch what the test asserts. Open a PR on loop/29-self-healing-ui-tests.
- A self healed selector keeps green tests green. It must never hide a real break.

## When to stop and call a human
- A test failing because the feature actually changed or disappeared. Do not heal it. Flag it: that is a real signal.
- A selector you can only fix by loosening the assertion. Stop, that is masking a break.

## Wire it to your tool
This loop governs a Playwright/Cypress suite. Start from `selectors.example.json` and `ui-test.example.spec.js`: the loop heals the locator map, never the assertions. Point `check.sh` at your test run; the agent edits selectors and opens a PR.

## Memory
- Read `memory/29-self-healing-ui-tests.md` at the start. Append one durable lesson at the end.

---

[← All qa and testing loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
