*[Contents](../../../../README.md) · [Chapter 2: Cloud and platform](../../LOOPS.md)*

# Loop 16. Alert and on call noise tuning

**Trigger:** Weekly
**Ships:** Flags, you decide. It investigates and proposes. Anything irreversible waits for a human.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**AWS agent engine:** DevOps Agent (GA) to correlate alarm noise with real incidents. Plain CLI fallback: alarm-history frequency analysis.
**The check:** `loops/16-alert-and-on-call-noise-tuning/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/16-alert-and-on-call-noise-tuning/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 16

**Yes.** From your project root:

    ./run-loop.sh 16 --check    is there work? Never wakes an agent.
    ./run-loop.sh 16            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. This chapter also needs AWS access and a protected environment, set up once in [SETUP.md](../../SETUP.md). For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

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
