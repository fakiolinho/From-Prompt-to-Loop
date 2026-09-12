*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 35. Synthetic uptime and journey monitoring

**Trigger:** Continuous schedule
**Ships:** Flags, you decide. It triages and reports. A human makes the call before anything is accepted.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/35-synthetic-uptime-and-journey-monitoring/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

## Owns, and never touches
- Owns:  The synthetic checks and their alerts
- Never: Production

## What to do
- Run synthetic journeys against production on a schedule: can a user log in, search, check out.
- Alert on failure or a latency breach, with the failing step and the timing. A human responds.
- Flag loop: it watches the real thing from the outside and raises the alarm, it does not touch prod.

## When to stop and call a human
- A synthetic failure that might be the monitor, not the app. Confirm from a second region before paging, do not cry wolf.
- Anything that would change production. Not this loop's call, raise the alert.

## Wire it to your tool
Start from `journeys.example.json`. A synthetic monitor (Checkly, Pingdom, Datadog) runs the journeys against prod on a schedule; this loop owns the journey definitions and the alert routing, and raises the alarm. It never touches production.

## Memory
- Read `memory/35-synthetic-uptime-and-journey-monitoring.md` at the start. Append one durable lesson at the end.

---

[← All qa and testing loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
