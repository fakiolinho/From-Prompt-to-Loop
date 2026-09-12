*[Contents](../../../../README.md) · [Chapter 2: Cloud and platform](../../LOOPS.md)*

# Loop 11. Backup restore drills

**Trigger:** Weekly
**Ships:** Ships on green. Reversible work runs on green. It opens a PR, or alerts you if the drill fails.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**Gate:** this loop can change infra, data, or access. Run it under the protected `cloud-loops` environment (see SETUP.md). Irreversible steps stop for a human.
**The check:** `loops/11-backup-restore-drills/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

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
