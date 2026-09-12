*[Contents](../../../../README.md) · [Chapter 2: Cloud and platform](../../LOOPS.md)*

# Loop 15. Cost and spend anomaly watch

**Trigger:** Daily
**Ships:** Flags, you decide. It investigates and proposes. Anything irreversible waits for a human.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**AWS agent engine:** FinOps Agent (preview, us-east-1) for cost root cause investigation. Plain CLI fallback: `aws ce get-anomalies` plus CloudTrail lookup.
**The check:** `loops/15-cost-and-spend-anomaly-watch/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/15-cost-and-spend-anomaly-watch/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 15

**Yes.** From your project root:

    ./run-loop.sh 15 --check    is there work? Never wakes an agent.
    ./run-loop.sh 15            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. This chapter also needs AWS access and a protected environment, set up once in [SETUP.md](../../SETUP.md). For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  Anomaly investigation reports and tracked tickets
- Never: Resources. Never cut spend by changing infra without approval

## What to do
- Check Cost Anomaly Detection for open anomalies (`aws ce get-anomalies`).
- For each, hand the investigation to the FinOps Agent: it correlates the CloudTrail event, the service, and the IAM principal that caused the spike.
- Post the finding, open a tracked ticket with the recommendation. Recommend the fix; a human approves any change.

## When to stop and call a human
- An anomaly that is expected (a planned launch, a one off batch). Note it and close, do not raise a false alarm.
- Any change to resources to cut cost. Not this loop's call, it recommends.

## Memory
- Read `memory/15-cost-and-spend-anomaly-watch.md` at the start. Append one durable lesson at the end.

---

[← All cloud and platform loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
