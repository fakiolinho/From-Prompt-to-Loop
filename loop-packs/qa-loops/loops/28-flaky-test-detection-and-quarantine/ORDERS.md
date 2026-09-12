*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 28. Flaky test detection and quarantine

**Trigger:** Nightly
**Ships:** Ships on green. Opens a PR you can revert in one click. It quarantines and flags, never deletes a test.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/28-flaky-test-detection-and-quarantine/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_TEST` (e.g. `npm test`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/28-flaky-test-detection-and-quarantine/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 28

**Yes.** From your project root:

    ./run-loop.sh 28 --check    is there work? Never wakes an agent.
    ./run-loop.sh 28            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  Test quarantine and the tracking issues for flaky tests
- Never: The tests' logic and assertions. Never delete a flaky test

## What to do
- Run the suite many times and measure each test's pass rate. A test that sometimes passes and sometimes fails is flaky.
- Quarantine the flaky ones by adding them to quarantine.json with a linked tracking issue; the detector keeps measuring them but they stop blocking the team. Open a PR for review.
- Never delete a flaky test and never paper over it. Quarantine buys time to fix the real cause.
- Open the tracking issue first, then quarantine against it: `npm run quarantine -- <test> <issue-url>`. The script rejects a missing or non-URL issue, so a quarantined test always links to a real issue.
- A fully runnable example lives in ./example. The check runs it.

## When to stop and call a human
- A test that flakes because the code under it is genuinely racy. Flag the code, the test is telling the truth.
- Pressure to just delete the noisy test. No. Quarantine and track it.

## Memory
- Read `memory/28-flaky-test-detection-and-quarantine.md` at the start. Append one durable lesson at the end.

---

[← All qa and testing loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
