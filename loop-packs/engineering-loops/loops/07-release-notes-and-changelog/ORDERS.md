*[Contents](../../../../README.md) · [Chapter 1: Software engineering](../../LOOPS.md)*

# Loop 07. Release notes and changelog

**Trigger:** On tag or release
**Ships:** Ships on green. Opens a PR you can revert in one click, and merges once the check is green.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/07-release-notes-and-changelog/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

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
