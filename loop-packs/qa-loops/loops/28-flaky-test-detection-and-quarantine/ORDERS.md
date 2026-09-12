*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 28. Flaky test detection and quarantine

**Trigger:** Nightly
**Ships:** Ships on green. Opens a PR you can revert in one click. It quarantines and flags, never deletes a test.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/28-flaky-test-detection-and-quarantine/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_TEST` (e.g. `npm test`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

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
