*[Contents](../../../../README.md) · [Chapter 2: Cloud and platform](../../LOOPS.md)*

# Loop 15. Cost and spend anomaly watch

**Trigger:** Daily
**Ships:** Flags, you decide. It investigates and proposes. Anything irreversible waits for a human.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**AWS agent engine:** FinOps Agent (preview, us-east-1) for cost root cause investigation. Plain CLI fallback: `aws ce get-anomalies` plus CloudTrail lookup.
**The check:** `loops/15-cost-and-spend-anomaly-watch/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

## Owns, and never touches
- Owns:  Anomaly investigation reports and tracked tickets
- Never: Resources. Never cut spend by changing infra without approval

## What to do
- Check Cost Anomaly Detection for open anomalies (`aws ce get-anomalies`).
- For each, hand the investigation to the FinOps Agent: it correlates the CloudTrail event, the service, and the IAM principal that caused the spike.
- Post the finding, open a tracked ticket with the recommendation. Recommend the fix; a human approves any change.

## When to stop and call a human
- An anomaly that is expected (a planned launch, a one off batch). Note it and close, do not raise a false alarm.
- Any change to resources to cut cost. Not this loop's call, it recommends.

## Memory
- Read `memory/15-cost-and-spend-anomaly-watch.md` at the start. Append one durable lesson at the end.

---

[← All cloud and platform loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
