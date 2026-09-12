*[Contents](../../../../README.md) · [Chapter 2: Cloud and platform](../../LOOPS.md)*

# Loop 14. Infrastructure drift reconciliation

**Trigger:** Daily
**Ships:** Flags, you decide. It investigates and proposes. Anything irreversible waits for a human.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/14-infrastructure-drift-reconciliation/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/14-infrastructure-drift-reconciliation/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 14

**Yes.** From your project root:

    ./run-loop.sh 14 --check    is there work? Never wakes an agent.
    ./run-loop.sh 14            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. This chapter also needs AWS access and a protected environment, set up once in [SETUP.md](../../SETUP.md). For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

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
