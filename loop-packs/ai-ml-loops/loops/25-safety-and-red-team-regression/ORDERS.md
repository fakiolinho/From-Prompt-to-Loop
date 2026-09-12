*[Contents](../../../../README.md) · [Chapter 3: AI and ML engineering](../../LOOPS.md)*

# Loop 25. Safety and red team regression

**Trigger:** A prompt or model change
**Ships:** Flags, you decide. It measures and recommends. It never changes production on its own.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/25-safety-and-red-team-regression/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

## Owns, and never touches
- Owns:  The red team suite and its baseline
- Never: The prompts and models under test

## What to do
- Run the adversarial and jailbreak suite on every prompt or model change.
- Block on any new failure. A safety regression is the one regression that is never acceptable.
- Same harness as loop 19, pointed at adversarial cases. Open a PR only when the suite is clean.

## When to stop and call a human
- A new jailbreak you cannot yet defend. Open an issue, mark it high priority, never weaken the test to pass.
- Any pressure to ship despite a safety regression. The answer is no. Escalate to a human.

## Memory
- Read `memory/25-safety-and-red-team-regression.md` at the start. Append one durable lesson at the end.

---

[← All ai and ml engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
