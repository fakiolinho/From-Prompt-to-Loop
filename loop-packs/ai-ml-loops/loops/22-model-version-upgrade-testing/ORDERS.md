*[Contents](../../../../README.md) · [Chapter 3: AI and ML engineering](../../LOOPS.md)*

# Loop 22. Model version upgrade testing

**Trigger:** A new model version becomes available
**Ships:** Flags, you decide. It measures and recommends. It never changes production on its own.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/22-model-version-upgrade-testing/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_CANDIDATE` (e.g. `claude-opus-5`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/22-model-version-upgrade-testing/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 22

**Yes.** From your project root:

    ./run-loop.sh 22 --check    is there work? Never wakes an agent.
    ./run-loop.sh 22            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  The comparison report
- Never: The production model pin. Never auto switch

## What to do
- Run the full eval set against the new model version and diff the results against the current one.
- Post a report: what improved, what regressed, cost and latency delta. A human decides the switch.
- This is a flag loop. It measures and recommends, it never flips the production model itself.

## When to stop and call a human
- A new version that regresses anything safety related. Lead the report with it, do not bury it.
- Anything that would change the live model. Not this loop's call.

## Memory
- Read `memory/22-model-version-upgrade-testing.md` at the start. Append one durable lesson at the end.

---

[← All ai and ml engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
