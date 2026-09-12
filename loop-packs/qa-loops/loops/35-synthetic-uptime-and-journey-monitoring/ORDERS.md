*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 35. Synthetic uptime and journey monitoring

**Trigger:** Continuous schedule
**Ships:** Flags, you decide. It triages and reports. A human makes the call before anything is accepted.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/35-synthetic-uptime-and-journey-monitoring/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_SYNTHETIC` (e.g. `./journeys.sh https://example.com`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/35-synthetic-uptime-and-journey-monitoring/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 35

**Yes.** From your project root:

    ./run-loop.sh 35 --check    is there work? Never wakes an agent.
    ./run-loop.sh 35            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

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
