*[Contents](../../../../README.md) · [Chapter 3: AI and ML engineering](../../LOOPS.md)*

# Loop 19. Eval suite on every prompt or model change

**Trigger:** Any change to a prompt, model, or chain
**Ships:** Ships on green. Opens a PR you can revert in one click. A regression blocks and opens an issue.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/19-eval-suite-on-prompt-or-model-change/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_EVALS` (e.g. `node run-evals.js`) in your `loops.env`, or an `evals` script in package.json, which the check uses when `LOOP_EVALS` is unset. With neither the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/19-eval-suite-on-prompt-or-model-change/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 19

**Yes.** From your project root:

    ./run-loop.sh 19 --check    is there work? Never wakes an agent.
    ./run-loop.sh 19            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  The eval set and the baseline score
- Never: The prompts and models under test

## What to do
- Run the full eval set against the changed prompt or model and score it.
- If the score improves, ratchet the baseline (`npm run raise-baseline` in the example) and open a PR on loop/19-eval-suite-on-prompt-or-model-change for review. If it is exactly at baseline, do nothing.
- If the score regresses, open an issue with the failing cases and stop. Never ship a regression.
- A fully runnable example lives in ./example. The check runs it. This is the unit test of AI work.

## When to stop and call a human
- A score drop you cannot explain. Open an issue, do not raise or lower the baseline to hide it.
- An eval case that has gone ambiguous. Flag it for a human, do not delete it to go green.

## Memory
- Read `memory/19-eval-suite-on-prompt-or-model-change.md` at the start. Append one durable lesson at the end.

---

[← All ai and ml engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
