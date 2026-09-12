*[Contents](../../../../README.md) · [Chapter 2: Cloud and platform](../../LOOPS.md)*

# Loop 10. Container and base image bumps

**Trigger:** Weekly
**Ships:** Ships on green. Reversible work runs on green. It opens a PR, or alerts you if the drill fails.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/10-container-and-base-image-bumps/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

## Owns, and never touches
- Owns:  Image tags and Dockerfiles in your build pipeline
- Never: Application code

## What to do
- Find images whose base is out of date in ECR, bump the base, rebuild, and run the image's tests.
- `aws ecr describe-repositories` and `aws ecr describe-images` to see what is current.
- Open a PR on loop/10-container-and-base-image-bumps. A patched base is reversible and ships on green.

## When to stop and call a human
- A base bump that breaks the build or a test. Revert that image, flag it.
- A major base OS change. Open an issue, do not auto bump across a major.

## Memory
- Read `memory/10-container-and-base-image-bumps.md` at the start. Append one durable lesson at the end.

---

[← All cloud and platform loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
