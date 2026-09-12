*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 27. Bug report to failing test

**Trigger:** A bug report is filed or labelled
**Ships:** Ships on green. Opens a PR you can revert in one click. It quarantines and flags, never deletes a test.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/27-bug-report-to-failing-test/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_BUGS` (e.g. `gh issue list --label bug --json number,title`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/27-bug-report-to-failing-test/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 27

**Yes.** From your project root:

    ./run-loop.sh 27 --check    is there work? Never wakes an agent.
    ./run-loop.sh 27            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  Tests
- Never: Application source. This loop reproduces, it does not fix

## What to do
- Turn the bug report into the smallest test that reproduces it, and watch it fail for the right reason.
- Commit the failing test on loop/27-bug-report-to-failing-test and hand it to whoever fixes the code.
- A bug is not understood until a test fails for it. This loop makes that test exist.

## When to stop and call a human
- A report too vague to reproduce. Comment asking for exact steps, do not invent a scenario.
- A 'bug' that is actually intended behavior. Flag it for a human, do not write a test that locks in a wrong expectation.

## Memory
- Read `memory/27-bug-report-to-failing-test.md` at the start. Append one durable lesson at the end.

---

[← All qa and testing loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
