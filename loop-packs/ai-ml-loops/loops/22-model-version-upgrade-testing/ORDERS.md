*[Contents](../../../../README.md) · [Chapter 3: AI and ML engineering](../../LOOPS.md)*

# Loop 22. Model version upgrade testing

**Trigger:** A new model version becomes available
**Ships:** Flags, you decide. It measures and recommends. It never changes production on its own.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/22-model-version-upgrade-testing/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_CANDIDATE` (e.g. `claude-opus-5`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Owns, and never touches
- Owns:  The comparison report
- Never: The production model pin. Never auto switch

## What to do
- Run the full eval set against the new model version and diff the results against the current one.
- Post a report: what improved, what regressed, cost and latency delta. A human decides the switch.
- This is a flag loop. It measures and recommends, it never flips the production model itself.

## When to stop and call a human
- A new version that regresses anything safety related. Lead the report with it, do not bury it.
- Anything that would change the live model. Not this loop's call.

## Memory
- Read `memory/22-model-version-upgrade-testing.md` at the start. Append one durable lesson at the end.

---

[← All ai and ml engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
