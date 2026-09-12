*[Contents](../../../../README.md) · [Chapter 2: Cloud and platform](../../LOOPS.md)*

# Loop 12. Orphaned resource cleanup

**Trigger:** Weekly
**Ships:** Flags, you decide. It investigates and proposes. Anything irreversible waits for a human.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**Gate:** this loop can change infra, data, or access. Run it under the protected `cloud-loops` environment (see SETUP.md). Irreversible steps stop for a human.
**The check:** `loops/12-orphaned-resource-cleanup/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).

## Owns, and never touches
- Owns:  Deletion of confirmed orphaned resources, behind the gate
- Never: Anything attached, mounted, or in use

## What to do
- Find unattached EBS volumes, unassociated Elastic IPs, and stale snapshots.
- `aws ec2 describe-volumes --filters Name=status,Values=available`, `aws ec2 describe-addresses`.
- List the candidates in an issue with their age and cost. Delete only after a human approves the list.

## When to stop and call a human
- A resource that looks orphaned but is referenced elsewhere. When unsure, leave it and flag it.
- Any deletion before human approval. Deletion is irreversible: it always waits for the gate.

## Memory
- Read `memory/12-orphaned-resource-cleanup.md` at the start. Append one durable lesson at the end.

---

[← All cloud and platform loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
