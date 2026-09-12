*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 29. Self healing UI tests

**Trigger:** A UI test fails on a selector
**Ships:** Ships on green. Opens a PR you can revert in one click. It quarantines and flags, never deletes a test.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/29-self-healing-ui-tests/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_UI_TESTS` (e.g. `npx playwright test --reporter=json`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/29-self-healing-ui-tests/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 29

**Yes.** From your project root:

    ./run-loop.sh 29 --check    is there work? Never wakes an agent.
    ./run-loop.sh 29            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

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
