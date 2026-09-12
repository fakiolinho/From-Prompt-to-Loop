*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 33. Visual regression triage

**Trigger:** On pull request
**Ships:** Flags, you decide. It triages and reports. A human makes the call before anything is accepted.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/33-visual-regression-triage/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_VISUAL` (e.g. `npx playwright test --update-snapshots=none`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/33-visual-regression-triage/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 33

**Yes.** From your project root:

    ./run-loop.sh 33 --check    is there work? Never wakes an agent.
    ./run-loop.sh 33            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  The baseline screenshots and the triage
- Never: The application code

## What to do
- Diff the new screenshots against the baselines. Accept changes that match an intended UI change in the PR.
- Flag the diffs that look like real regressions, with the before and after, for a human to confirm.
- Open a PR on loop/33-visual-regression-triage that updates the baselines you accepted.

## When to stop and call a human
- A diff you cannot confidently call intended or a regression. Flag it for a human, do not auto accept on a guess.
- A sweeping diff across the whole page. Stop, that is usually a layout break, not an intended change.

## Memory
- Read `memory/33-visual-regression-triage.md` at the start. Append one durable lesson at the end.

---

[← All qa and testing loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
