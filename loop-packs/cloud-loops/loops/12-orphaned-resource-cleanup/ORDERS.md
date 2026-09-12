*[Contents](../../../../README.md) · [Chapter 2: Cloud and platform](../../LOOPS.md)*

# Loop 12. Orphaned resource cleanup

**Trigger:** Weekly
**Ships:** Flags, you decide. It investigates and proposes. Anything irreversible waits for a human.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**Gate:** this loop can change infra, data, or access. Run it under the protected `cloud-loops` environment (see SETUP.md). Irreversible steps stop for a human.
**The check:** `loops/12-orphaned-resource-cleanup/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/12-orphaned-resource-cleanup/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 12

**Yes.** From your project root:

    ./run-loop.sh 12 --check    is there work? Never wakes an agent.
    ./run-loop.sh 12            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. This chapter also needs AWS access and a protected environment, set up once in [SETUP.md](../../SETUP.md). For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

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
