*[Contents](../../../../README.md) · [Chapter 2: Cloud and platform](../../LOOPS.md)*

# Loop 18. IAM and permission audit

**Trigger:** Weekly
**Ships:** Flags, you decide. It investigates and proposes. Anything irreversible waits for a human.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**AWS agent engine:** Security Agent / AWS Continuum (GA/preview) for deep permission and exposure analysis. Plain CLI fallback: Access Analyzer + credential report.
**Gate:** this loop can change infra, data, or access. Run it under the protected `cloud-loops` environment (see SETUP.md). Irreversible steps stop for a human.
**The check:** `loops/18-iam-and-permission-audit/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).

## Owns, and never touches
- Owns:  least privilege findings and diffs
- Never: IAM policies. Never change access without approval

## What to do
- Run IAM Access Analyzer (`aws accessanalyzer list-findings`) and pull the credential report (`aws iam get-credential-report`).
- Find over permissioned roles, unused access, stale keys, and public exposure. For deeper analysis, use the Security Agent / AWS Continuum.
- Open findings with a proposed least privilege diff. Any policy change is applied only behind the gate.

## When to stop and call a human
- A permission that looks unused but guards a rare critical path. Flag it, do not strip access on a guess.
- Any IAM change before approval. Access changes are irreversible in their blast radius: gated, always.

## Memory
- Read `memory/18-iam-and-permission-audit.md` at the start. Append one durable lesson at the end.

---

[← All cloud and platform loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
