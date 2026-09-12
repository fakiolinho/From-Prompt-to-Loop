*[Contents](../../../../README.md) · [Chapter 2: Cloud and platform](../../LOOPS.md)*

# Loop 13. Certificate and secret rotation

**Trigger:** Daily
**Ships:** Flags, you decide. It investigates and proposes. Anything irreversible waits for a human.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**Gate:** this loop can change infra, data, or access. Run it under the protected `cloud-loops` environment (see SETUP.md). Irreversible steps stop for a human.
**The check:** `loops/13-certificate-and-secret-rotation/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/13-certificate-and-secret-rotation/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 13

**Yes.** From your project root:

    ./run-loop.sh 13 --check    is there work? Never wakes an agent.
    ./run-loop.sh 13            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. This chapter also needs AWS access and a protected environment, set up once in [SETUP.md](../../SETUP.md). For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  Rotation triggers for certs and secrets
- Never: Production rotation without approval

## What to do
- Find certificates expiring within 30 days (`aws acm list-certificates`) and secrets past their rotation window (`aws secretsmanager list-secrets`).
- Rotate non production automatically. For production, open a change request and rotate only behind the gate.
- An expired cert is an outage. This loop catches it weeks early.

## When to stop and call a human
- A rotation that would break a live consumer of the secret. Stop, flag the dependency, do not rotate blind.
- Any production rotation before approval. Gated, always.

## Memory
- Read `memory/13-certificate-and-secret-rotation.md` at the start. Append one durable lesson at the end.

---

[← All cloud and platform loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
