*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 32. Cross browser and device matrix

**Trigger:** Nightly or on release
**Ships:** Ships on green. Opens a PR you can revert in one click. It quarantines and flags, never deletes a test.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/32-cross-browser-and-device-matrix/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_MATRIX` (e.g. `npx playwright test --project=chromium --project=webkit`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/32-cross-browser-and-device-matrix/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 32

**Yes.** From your project root:

    ./run-loop.sh 32 --check    is there work? Never wakes an agent.
    ./run-loop.sh 32            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

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
