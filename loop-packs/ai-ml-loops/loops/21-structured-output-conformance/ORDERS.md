*[Contents](../../../../README.md) · [Chapter 3: AI and ML engineering](../../LOOPS.md)*

# Loop 21. Structured output conformance

**Trigger:** A prompt or schema change
**Ships:** Ships on green. Opens a PR you can revert in one click. A regression blocks and opens an issue.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/21-structured-output-conformance/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_SCHEMA` (e.g. `npx ajv validate -s schema.json -d `) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/21-structured-output-conformance/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 21

**Yes.** From your project root:

    ./run-loop.sh 21 --check    is there work? Never wakes an agent.
    ./run-loop.sh 21            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  The output schema and the conformance tests
- Never: The prompt being tested

## What to do
- Validate a batch of real model outputs against the JSON schema.
- Block on any violation: a field missing, a wrong type, an unparseable response.
- Open a PR on loop/21-structured-output-conformance only when conformance holds.

## When to stop and call a human
- A schema change that would break downstream consumers. Flag it, do not loosen the schema to pass.
- Outputs that pass the schema but are obviously wrong. Note it, schema conformance is not correctness.

## Memory
- Read `memory/21-structured-output-conformance.md` at the start. Append one durable lesson at the end.

---

[← All ai and ml engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
