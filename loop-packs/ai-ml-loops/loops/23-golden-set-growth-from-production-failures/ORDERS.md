*[Contents](../../../../README.md) · [Chapter 3: AI and ML engineering](../../LOOPS.md)*

# Loop 23. Golden set growth from production failures

**Trigger:** New production failures captured
**Ships:** Flags, you decide. It measures and recommends. It never changes production on its own.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/23-golden-set-growth-from-production-failures/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_FAILURES` (e.g. `node scripts/recent-misses.js`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Owns, and never touches
- Owns:  The golden and eval sets
- Never: Production, and the live prompts

## What to do
- Turn confirmed production failures into new eval cases with the correct expected output.
- Add them to the golden set so the same failure can never regress unnoticed again.
- Open a PR on loop/23-golden-set-growth-from-production-failures. This is how the eval suite compounds.

## When to stop and call a human
- A failure whose correct answer is genuinely unclear. Flag it for a human to label, do not guess the expected output.
- Anything that needs a prompt or model change. That is a separate loop. This one only grows the set.

## Memory
- Read `memory/23-golden-set-growth-from-production-failures.md` at the start. Append one durable lesson at the end.

---

[← All ai and ml engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
