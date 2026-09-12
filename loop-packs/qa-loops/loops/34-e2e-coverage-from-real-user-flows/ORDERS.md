*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 34. E2E coverage from real user flows

**Trigger:** Weekly
**Ships:** Flags, you decide. It triages and reports. A human makes the call before anything is accepted.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/34-e2e-coverage-from-real-user-flows/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_JOURNEYS` (e.g. `node scripts/top-journeys.js`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Owns, and never touches
- Owns:  end to end tests
- Never: Application source

## What to do
- Take the top real user journeys from analytics and write end to end tests for the ones not yet covered.
- Test what users actually do, in priority order, not hypothetical paths. Open a PR on loop/34-e2e-coverage-from-real-user-flows.
- Coverage that follows real usage catches the breaks that actually cost you.

## When to stop and call a human
- A journey that touches money, auth, or data deletion. Write the test read only or against a sandbox, flag for review before it runs live.
- A flow whose correct outcome is ambiguous. Flag it, do not assert a guessed result.

## Memory
- Read `memory/34-e2e-coverage-from-real-user-flows.md` at the start. Append one durable lesson at the end.

---

[← All qa and testing loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
