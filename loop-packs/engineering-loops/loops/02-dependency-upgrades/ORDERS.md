*[Contents](../../../../README.md) · [Chapter 1: Software engineering](../../LOOPS.md)*

# Loop 02. Dependency upgrades

**Trigger:** Weekly schedule
**Ships:** Ships on green. Opens a PR you can revert in one click, and merges once the check is green.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/02-dependency-upgrades/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** a `test` or `build` script in package.json, which the check uses as the verify command, `test` first. Set `LOOP_VERIFY` in your `loops.env` when that script alone does not prove a bump is safe (e.g. `npm test && npm run build`). With no script and no `LOOP_VERIFY` the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/02-dependency-upgrades/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 02

**Yes.** From your project root:

    ./run-loop.sh 02 --check    is there work? Never wakes an agent.
    ./run-loop.sh 02            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  package.json and the lockfile
- Never: Application source, public APIs, anything generated

## What to do
- Bump to the **Wanted** column of `npm outdated`, never the Latest column.
  Wanted is what the ranges already in package.json allow. Latest is not always newer:
  `@types/node` pins its latest tag to the current Node LTS, so on a repo running a newer
  major, "upgrading to latest" is a downgrade of two majors.
- Never install a version lower than the one already installed, whatever npm calls latest.
- Run the verify command the check named. The bump is done only when it is green.
- Open one PR per batch on branch loop/02-dependency-upgrades, against the repository's
  default branch. Reversible, ships on green.
- Majors are not this loop's work. The check counts only what moves inside your ranges, so a
  major never wakes you and you never bump one. If you see majors waiting, list them in the
  PR description so a person can plan them.
- The maintainer wrote the code and the world reviewed it. Your risk is integration, and the
  verify command is the only thing that catches it. It is worth exactly as much as that
  command is.

## When to stop and call a human
- An upgrade that will not install cleanly (a peer dependency or engine range) or will not go
  green. Revert that one dep and keep the rest. Never force it past the conflict with
  `--force` or `--legacy-peer-deps`, and never bump the thing blocking it. Open an issue
  saying what blocks it, and ask for one of two fixes: lift the blocker, or park the package
  with `LOOP_HOLD` in `loops.env` (e.g. `LOOP_HOLD='@opennextjs/cloudflare'`). Until one
  happens the check keeps counting it, and every run wakes an agent to fail at the same thing.
- No way to open a PR or an issue (no `gh`, or not signed in). Commit on the branch, do not
  push, and say in your last message exactly what you would have opened.

## Memory
- Read `memory/02-dependency-upgrades.md` at the start. Append one durable lesson at the end.

---

[← All software engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
