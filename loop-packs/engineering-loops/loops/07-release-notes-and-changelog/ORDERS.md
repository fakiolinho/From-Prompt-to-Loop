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
- From the git log since the last tag, write human changelog entries grouped by type: features, fixes, breaking.
- Every entry traces to a real commit. Never invent a change that is not in the log.
- Open one PR on branch loop/07-release-notes-and-changelog that updates CHANGELOG.md.

## When to stop and call a human
- Commits too cryptic to summarize honestly. Note them under an 'unreviewed' heading and flag, do not guess intent.
- A breaking change you are unsure about. Flag it for a human to confirm the migration note.

## Memory
- Read `memory/07-release-notes-and-changelog.md` at the start. Append one durable lesson at the end.

---

[← All software engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
