*[Contents](../../../../README.md) · [Chapter 2: Cloud and platform](../../LOOPS.md)*

# Loop 14. Infrastructure drift reconciliation

**Trigger:** Daily
**Ships:** Flags, you decide. It investigates and proposes. Anything irreversible waits for a human.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/14-infrastructure-drift-reconciliation/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).

## Owns, and never touches
- Owns:  Infrastructure-as code reconciliation PRs
- Never: Live infrastructure. Never apply directly to prod

## What to do
- Detect drift between your IaC and what is actually deployed (`aws cloudformation detect-stack-drift`, or AWS Config rules).
- Open a PR that brings the IaC back in line with reality, or flags reality that should be reverted. A human applies it.
- Drift is how a 3am hotfix becomes next quarter's mystery outage. This loop surfaces it daily.

## When to stop and call a human
- Drift you cannot tell is an intended hotfix or an accident. Flag it for a human, do not auto reconcile a guess.
- Applying any change to live infrastructure. This loop proposes; humans apply.

## Memory
- Read `memory/14-infrastructure-drift-reconciliation.md` at the start. Append one durable lesson at the end.

---

[← All cloud and platform loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
