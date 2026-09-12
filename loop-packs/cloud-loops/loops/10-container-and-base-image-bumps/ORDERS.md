*[Contents](../../../../README.md) · [Chapter 2: Cloud and platform](../../LOOPS.md)*

# Loop 10. Container and base image bumps

**Trigger:** Weekly
**Ships:** Ships on green. Reversible work runs on green. It opens a PR, or alerts you if the drill fails.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/10-container-and-base-image-bumps/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/10-container-and-base-image-bumps/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 10

**Yes.** From your project root:

    ./run-loop.sh 10 --check    is there work? Never wakes an agent.
    ./run-loop.sh 10            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. This chapter also needs AWS access and a protected environment, set up once in [SETUP.md](../../SETUP.md). For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

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
