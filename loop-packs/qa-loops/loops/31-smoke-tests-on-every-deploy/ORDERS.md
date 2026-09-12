*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 31. Smoke tests on every deploy

**Trigger:** On deploy
**Ships:** Ships on green. Opens a PR you can revert in one click. It quarantines and flags, never deletes a test.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/31-smoke-tests-on-every-deploy/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

## Owns, and never touches
- Owns:  The smoke suite
- Never: Production data and config

## What to do
- After every deploy, run the critical path smoke tests against the new release.
- On failure, fail the deploy gate: roll back or alert, do not let a broken release sit live.
- Smoke tests are the seatbelt on every deploy. Small, fast, and they run every single time.

## When to stop and call a human
- A smoke failure that might be a flaky environment, not a bad deploy. Retry once, then alert a human, do not auto roll back on noise.
- Anything beyond roll back or alert. Deeper remediation is a human decision.

## Wire it to your tool
Start from `smoke.example.json` and `smoke.example.sh`. The loop runs these against the new release on the post deploy hook; on failure it gates the deploy (roll back or alert), nothing deeper. Replace the base URL and paths with your critical endpoints.

## Memory
- Read `memory/31-smoke-tests-on-every-deploy.md` at the start. Append one durable lesson at the end.

---

[← All qa and testing loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
