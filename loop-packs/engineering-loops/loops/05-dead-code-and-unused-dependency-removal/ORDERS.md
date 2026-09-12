*[Contents](../../../../README.md) · [Chapter 1: Software engineering](../../LOOPS.md)*

# Loop 05. Dead code and unused dependency removal

**Trigger:** Weekly schedule
**Ships:** Flags, you decide. It reports candidates and opens an issue. A human presses delete.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/05-dead-code-and-unused-dependency-removal/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/05-dead-code-and-unused-dependency-removal/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 05

**Yes.** From your project root:

    ./run-loop.sh 05 --check    is there work? Never wakes an agent.
    ./run-loop.sh 05            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

## Owns, and never touches
- Owns:  Unreachable code and unused dependencies the tools and the build agree are dead
- Never: Anything the build or tests still need

## What to do
- Run the tooling and collect the candidates. Do not remove anything.
- For each candidate, gather the evidence a human needs: where it is referenced, or the fact
  that nothing references it, and which of the traps below might apply.
- Open one issue listing the candidates, grouped by confidence. Never open a deletion PR.

## The traps that make this a flag loop, not a ships loop
Static analysis sees imports. It does not see these, and each one has bitten this loop on a
real repository:
- **Config loaded by convention.** `next.config.*`, `open-next.config.*`, `wrangler.*`,
  `drizzle.*`. Nothing imports them. A build tool reads them by name.
- **Runtime packages.** `sharp` and friends are never imported by your source. Removing them
  leaves the build green and breaks production later.
- **Paths passed as strings.** Fixtures and sample directories handed to a script as an
  argument look unreachable.
- **Entry points the tool was not told about.** Test files matched by a glob inside an npm
  script, or a worker entry named in a deploy config. Miss one and everything it reaches
  looks dead too, which is how eight findings become thirty four.

## When to stop and call a human
- Always, before anything is deleted. That is the whole point of this loop.
- Never propose removing a test. A suite with fewer tests passes more easily, so running the
  tests cannot prove that cut was safe.

## Memory
- Read `memory/05-dead-code-and-unused-dependency-removal.md` at the start. Append one durable lesson at the end.

---

[← All software engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
