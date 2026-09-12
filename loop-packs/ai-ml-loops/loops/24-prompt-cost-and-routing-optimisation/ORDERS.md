*[Contents](../../../../README.md) · [Chapter 3: AI and ML engineering](../../LOOPS.md)*

# Loop 24. Prompt cost and routing optimisation

**Trigger:** Weekly, or cost above baseline
**Ships:** Flags, you decide. It measures and recommends. It never changes production on its own.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/24-prompt-cost-and-routing-optimisation/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

## Owns, and never touches
- Owns:  A routing recommendation report
- Never: The live routing config. Never flip routing silently

## What to do
- Find prompts where a cheaper or smaller model holds quality on the eval set.
- Recommend the routing change with the measured quality and cost delta behind it.
- Flag loop: it recommends, a human approves. Saving tokens is the goal, spending them right is the point.

## When to stop and call a human
- A cheaper model that holds average quality but fails an edge case. Say so, do not recommend on the average alone.
- Anything that changes live routing. Not this loop's call.

## Memory
- Read `memory/24-prompt-cost-and-routing-optimisation.md` at the start. Append one durable lesson at the end.

---

[← All ai and ml engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
