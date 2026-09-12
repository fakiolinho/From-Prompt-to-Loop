*[Contents](../../../../README.md) · [Chapter 3: AI and ML engineering](../../LOOPS.md)*

# Loop 26. Data quality and drift monitoring

**Trigger:** Scheduled
**Ships:** Flags, you decide. It measures and recommends. It never changes production on its own.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/26-data-quality-and-drift-monitoring/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

## Owns, and never touches
- Owns:  The drift report
- Never: The data and the model

## What to do
- Compute drift metrics on incoming data against the training or reference distribution.
- Flag when a metric crosses its threshold: schema drift, distribution shift, a spike in nulls or outliers.
- Flag loop: it surfaces the drift early, a human decides whether to retrain or investigate.

## When to stop and call a human
- A drift signal you cannot attribute. Report it plainly with the numbers, do not guess a cause.
- Anything that would retrain or change the model. Not this loop's call.

## Memory
- Read `memory/26-data-quality-and-drift-monitoring.md` at the start. Append one durable lesson at the end.

---

[← All ai and ml engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
