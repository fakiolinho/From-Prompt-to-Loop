*[Contents](../../../../README.md) · [Chapter 2: Cloud and platform](../../LOOPS.md)*

# Loop 16. Alert and on call noise tuning

**Trigger:** Weekly
**Ships:** Flags, you decide. It investigates and proposes. Anything irreversible waits for a human.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**AWS agent engine:** DevOps Agent (GA) to correlate alarm noise with real incidents. Plain CLI fallback: alarm-history frequency analysis.
**The check:** `loops/16-alert-and-on-call-noise-tuning/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).

## Owns, and never touches
- Owns:  Alarm tuning recommendations
- Never: Real alarms. Never silence a signal that matters

## What to do
- Pull CloudWatch alarm history (`aws cloudwatch describe-alarm-history`) and find the alarms that flap or fire without anyone acting.
- Use the DevOps Agent to correlate alarms with actual incidents, so you tune noise, not signal.
- Recommend threshold, grouping, and dedup changes. A human approves. Alert fatigue is how the real page gets missed.

## When to stop and call a human
- An alarm that is noisy because the underlying system is genuinely unstable. Flag the system, the alarm is telling the truth.
- Silencing or deleting an alarm directly. Recommend only.

## Memory
- Read `memory/16-alert-and-on-call-noise-tuning.md` at the start. Append one durable lesson at the end.

---

[← All cloud and platform loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
