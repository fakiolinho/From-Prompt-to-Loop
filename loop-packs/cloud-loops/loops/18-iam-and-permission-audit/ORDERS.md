*[Contents](../../../../README.md) · [Chapter 2: Cloud and platform](../../LOOPS.md)*

# Loop 18. IAM and permission audit

**Trigger:** Weekly
**Ships:** Flags, you decide. It investigates and proposes. Anything irreversible waits for a human.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**AWS agent engine:** Security Agent / AWS Continuum (GA/preview) for deep permission and exposure analysis. Plain CLI fallback: Access Analyzer + credential report.
**Gate:** this loop can change infra, data, or access. Run it under the protected `cloud-loops` environment (see SETUP.md). Irreversible steps stop for a human.
**The check:** `loops/18-iam-and-permission-audit/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/18-iam-and-permission-audit/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 18

**Yes.** From your project root:

    ./run-loop.sh 18 --check    is there work? Never wakes an agent.
    ./run-loop.sh 18            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. This chapter also needs AWS access and a protected environment, set up once in [SETUP.md](../../SETUP.md). For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

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
