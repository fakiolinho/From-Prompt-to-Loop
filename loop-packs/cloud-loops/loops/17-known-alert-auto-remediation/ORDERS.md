*[Contents](../../../../README.md) · [Chapter 2: Cloud and platform](../../LOOPS.md)*

# Loop 17. Known alert auto remediation

**Trigger:** On a known alarm firing
**Ships:** Flags, you decide. It investigates and proposes. Anything irreversible waits for a human.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**AWS agent engine:** DevOps Agent (GA) for autonomous root cause; the loop gates the remediation. Plain CLI fallback: match the alarm to a runbook by name.
**Gate:** this loop can change infra, data, or access. Run it under the protected `cloud-loops` environment (see SETUP.md). Irreversible steps stop for a human.
**The check:** `loops/17-known-alert-auto-remediation/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).

## Owns, and never touches
- Owns:  Runbook remediation for KNOWN alarms only
- Never: Unknown alarms, and any irreversible action without the gate

## What to do
- When a known alarm fires, let the DevOps Agent investigate root cause across telemetry, code, and deploys.
- Apply the approved runbook for the reversible fixes (restart, scale out, clear a queue). Gate anything irreversible.
- Record the postmortem so the next occurrence is faster. Known problems should not need a human at 3am.

## When to stop and call a human
- An alarm with no approved runbook, or an unfamiliar failure mode. Page a human, do not improvise on production.
- Any irreversible remediation (data change, capacity teardown). Stops for the gate every time.

## Memory
- Read `memory/17-known-alert-auto-remediation.md` at the start. Append one durable lesson at the end.

---

[← All cloud and platform loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
