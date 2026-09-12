*[Contents](../../../../README.md) · [Chapter 2: Cloud and platform](../../LOOPS.md)*

# Loop 11. Backup restore drills

**Trigger:** Weekly
**Ships:** Ships on green. Reversible work runs on green. It opens a PR, or alerts you if the drill fails.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**Gate:** this loop can change infra, data, or access. Run it under the protected `cloud-loops` environment (see SETUP.md). Irreversible steps stop for a human.
**The check:** `loops/11-backup-restore-drills/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/11-backup-restore-drills/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 11

**Yes.** From your project root:

    ./run-loop.sh 11 --check    is there work? Never wakes an agent.
    ./run-loop.sh 11            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. This chapter also needs AWS access and a protected environment, set up once in [SETUP.md](../../SETUP.md). For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  Restore-test jobs into an isolated throwaway target
- Never: Production data and the source backups themselves

## What to do
- Pick a recent recovery point, restore it into an isolated test target, verify the data is intact, then tear the target down.
- `aws backup list-recovery-points-by-backup-vault` to choose, `aws backup start-restore-job` into the test target.
- A backup you have never restored is a hope, not a backup. This loop proves it weekly.

## When to stop and call a human
- The restore fails or the data is corrupt. Open a high priority issue immediately, this is the whole point of the drill.
- Restoring anywhere near production. Never. The restore target is isolated and disposable, behind the human gate.

## Memory
- Read `memory/11-backup-restore-drills.md` at the start. Append one durable lesson at the end.

---

[← All cloud and platform loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
