*[Contents](../../../../README.md) · [Chapter 1: Software engineering](../../LOOPS.md)*

# Loop 07. Release notes and changelog

**Trigger:** On tag or release
**Ships:** Ships on green. Opens a PR you can revert in one click, and merges once the check is green.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/07-release-notes-and-changelog/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `BASE_TAG` in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/07-release-notes-and-changelog/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 07

**Yes.** From your project root:

    ./run-loop.sh 07 --check    is there work? Never wakes an agent.
    ./run-loop.sh 07            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  CHANGELOG.md and the release notes
- Never: Source, version numbers, anything but the notes

## What to do
- From the git log since the last **release** tag, write human changelog entries grouped by
  type: features, fixes, breaking.
- Every entry traces to a real commit. Never invent a change that is not in the log.
- Open one PR on branch loop/07-release-notes-and-changelog that updates the changelog.

## When to stop and call a human
- A range that covers hundreds of commits. That is not a release, it is a wrong baseline.
  The check refuses it; do not work around the refusal.
- A tag that is not a release. The nearest tag is not always a release: one real repo's only
  tag was called `patch`, and measuring from it meant 710 commits of "release notes".
- A breaking change you cannot describe from the log alone. Flag it rather than guessing.

## Memory
- Read `memory/07-release-notes-and-changelog.md` at the start. Append one durable lesson at the end.

---

[← All software engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
