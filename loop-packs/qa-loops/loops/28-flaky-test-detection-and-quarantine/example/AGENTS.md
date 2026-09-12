# Standing orders for the flaky-test loop

_Codex reads this file. Claude reads CLAUDE.md. Identical, keep in sync._

## How to verify
- Run the detector: `npm test`
- It exits non-zero when any test is flaky or broken. Quarantine them, then it goes green.

## What this loop owns, and what it must never touch
- Owns:  quarantine.json (the quarantine list the detector reads) and the tracking issues
- Never: the tests' logic or assertions. Never delete a flaky test.

## What to do on a run
- Run the detector. For each FLAKY test, open a tracking issue and quarantine it by adding it to
  quarantine.json with that issue (`npm run quarantine -- <name>`). The detector keeps running
  it but it no longer blocks the build. Open a PR for review.
- For a broken test (never passes), open an issue and flag it. Do not delete it.

## When to stop and call a human
- A test that flakes because the code under it is genuinely racy. Flag the code, not the test.
- Any pressure to just delete the noisy test. No. Quarantine and track it.

## Memory
- Read memory/flaky.md at the start. Append one line per run.
