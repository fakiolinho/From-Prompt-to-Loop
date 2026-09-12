*[Contents](../../../../README.md) · [Chapter 4: QA and testing](../../LOOPS.md)*

# Loop 34. E2E coverage from real user flows

**Trigger:** Weekly
**Ships:** Flags, you decide. It triages and reports. A human makes the call before anything is accepted.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/34-e2e-coverage-from-real-user-flows/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_JOURNEYS` (e.g. `node scripts/top-journeys.js`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/34-e2e-coverage-from-real-user-flows/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 34

**Yes.** From your project root:

    ./run-loop.sh 34 --check    is there work? Never wakes an agent.
    ./run-loop.sh 34            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  end to end tests
- Never: Application source

## What to do
- Take the top real user journeys from analytics and write end to end tests for the ones not yet covered.
- Test what users actually do, in priority order, not hypothetical paths. Open a PR on loop/34-e2e-coverage-from-real-user-flows.
- Coverage that follows real usage catches the breaks that actually cost you.

## When to stop and call a human
- A journey that touches money, auth, or data deletion. Write the test read only or against a sandbox, flag for review before it runs live.
- A flow whose correct outcome is ambiguous. Flag it, do not assert a guessed result.

## Memory
- Read `memory/34-e2e-coverage-from-real-user-flows.md` at the start. Append one durable lesson at the end.

---

[← All qa and testing loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
