*[Contents](../../../../README.md) · [Chapter 3: AI and ML engineering](../../LOOPS.md)*

# Loop 25. Safety and red team regression

**Trigger:** A prompt or model change
**Ships:** Flags, you decide. It measures and recommends. It never changes production on its own.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/25-safety-and-red-team-regression/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_REDTEAM` (e.g. `node run-evals.js --set redteam`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/25-safety-and-red-team-regression/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 25

**Yes.** From your project root:

    ./run-loop.sh 25 --check    is there work? Never wakes an agent.
    ./run-loop.sh 25            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  The red team suite and its baseline
- Never: The prompts and models under test

## What to do
- Run the adversarial and jailbreak suite on every prompt or model change.
- Block on any new failure. A safety regression is the one regression that is never acceptable.
- Same harness as loop 19, pointed at adversarial cases. Open a PR only when the suite is clean.

## When to stop and call a human
- A new jailbreak you cannot yet defend. Open an issue, mark it high priority, never weaken the test to pass.
- Any pressure to ship despite a safety regression. The answer is no. Escalate to a human.

## Memory
- Read `memory/25-safety-and-red-team-regression.md` at the start. Append one durable lesson at the end.

---

[← All ai and ml engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
