*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 31. Smoke tests on every deploy

**Trigger:** On deploy
**Ships:** Ships on green. Opens a PR you can revert in one click. It quarantines and flags, never deletes a test.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/31-smoke-tests-on-every-deploy/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_SMOKE` (e.g. `./smoke.sh https://staging.example.com`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/31-smoke-tests-on-every-deploy/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 31

**Yes.** From your project root:

    ./run-loop.sh 31 --check    is there work? Never wakes an agent.
    ./run-loop.sh 31            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  The smoke suite
- Never: Production data and config

## What to do
- After every deploy, run the critical path smoke tests against the new release.
- On failure, fail the deploy gate: roll back or alert, do not let a broken release sit live.
- Smoke tests are the seatbelt on every deploy. Small, fast, and they run every single time.

## When to stop and call a human
- A smoke failure that might be a flaky environment, not a bad deploy. Retry once, then alert a human, do not auto roll back on noise.
- Anything beyond roll back or alert. Deeper remediation is a human decision.

## Wire it to your tool
Start from `smoke.example.json` and `smoke.example.sh`. The loop runs these against the new release on the post deploy hook; on failure it gates the deploy (roll back or alert), nothing deeper. Replace the base URL and paths with your critical endpoints.

## Memory
- Read `memory/31-smoke-tests-on-every-deploy.md` at the start. Append one durable lesson at the end.

---

[← All qa and testing loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
