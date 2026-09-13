# Changelog

Two things ship from this repo: the code, and the field guide PDF beside it. They change for
different reasons and at different speeds, so each keeps its own history below, newest first.

When real use proves the guide wrong, the repo changes first, and the correction waits in
[BOOK-CHANGES.md](BOOK-CHANGES.md) until a revision of the PDF applies it.

---

## The field guide

`From-Prompt-to-Loop_The-Warship-CTO.pdf`, 39 pages.

### Second revision, September 2026

Applies entries 1 to 7 of [BOOK-CHANGES.md](BOOK-CHANGES.md). The printed catalog now agrees
with the repo on all 35 loops.

- **Page 9, the anatomy.** The check has three answers, not two. A new branch, **Not wired**,
  fails loudly and never wakes an agent on a repo the check cannot read (entry 3). The agent box
  now says it runs the commands the project already defines, never ones it invents (entry 5).
- **Page 22, the catalog heading.** Chapter 1 is Software engineering, not General engineering
  (entry 1).
- **Page 22, loop 2.** The tests are worth exactly as much as they cover, and a repo with no
  tests gets no safety, which is why the check refuses to run without one (entry 4).
- **Page 22, loop 5.** Flags, you decide, not Ships on green. It opens an issue with the
  candidates and the evidence instead of deleting them, because a green build cannot prove a cut
  was safe, and deleting a test only makes the suite easier to pass (entry 2).
- **Page 22, loop 6.** Runs the lint, format and type commands the project already defines, not
  commands the loop invents (entries 4 and 5).
- **Page 22, loop 7.** Measures from the last release, so it needs a version shaped tag. The
  nearest tag is not always a release (entry 6).
- **Page 35, what it costs.** Now gives the half that gets somebody started: a run on your own
  machine uses the login your agent already has, so there is nothing to buy to try this. The key
  is for unattended runs in CI, and that is the usage metered per token (entry 7).
- **Page 3.** Carries the revision line.

**Still open:** pages 19 and 20, question 2 of the five question test, still describe the check
as pass or fail (entry 3). Checking this revision page by page against the repo turned up eight
more, entries 8 to 15, for the next revision.

### First edition, September 2026

Published with the repo on 2026-09-12. Thirty five loops in four chapters, the anatomy of a
loop, the five question test, the cost of running a fleet, and the starter pack.

---

## The repo

### 1.0.0, September 2026

The first release, alongside the first edition of the guide, built and hardened on real
repositories between 12 and 13 September.

**Added**

- The 35 loops in four chapters. Each has orders, a check and a memory file, and each chapter
  has one GitHub Actions runner with a separate job that verifies the agent's work.
- `install.sh`, `loops.env` and `WIRING.md`, so a loop can reach your repo.
- `run-loop.sh`. Run one loop on your own machine: the check first, the agent only if there is
  work, then the check again with no agent in the room. It uses the Claude Code or Codex you
  already have installed, and its login.
- Every loop's `ORDERS.md` opens with **Run this loop**. It asks whether you have already run
  `install.sh`, and gives the exact commands for either answer, with `WIRING.md` for more.
- `LOOP_HOLD` for loop 2. Park an upgrade that cannot land, so the loop stops waking an agent
  every run to fail at the same thing.
- A root `package.json`: `npm test`, `npm run demos` and `npm run build`, with a Node 18 floor
  that CI runs on, so the claim is proved rather than asserted.
- `SECURITY.md` and `CONTRIBUTING.md`. The front door now says what this costs, and that a
  local run needs no API key.
- The eight guide pages, published on GitHub Pages and rebuilt on every push, in the Night
  bridge theme, with both diagrams drawn to match.
- CI: one job per chapter, and the docs tested against the guide's catalog.

**Fixed**

- `install.sh` no longer replaces your `CLAUDE.md` or `AGENTS.md`. The standing orders go in as a
  marked section at the end, and a rerun refreshes only that section.
- `install.sh` seeds a loop's memory once and never offers to overwrite it.
- `install.sh .` installs into the folder you ran it from, not into this repo, and installing
  into this repo is refused.
- A second run of `install.sh` no longer fails on `cmp` against a folder, or copies a loop inside
  itself.
- Loops 1, 2 and 19 said their setting was required, when each check falls back to a
  package.json script first. Loop 2's orders asked for an issue per major version, which its
  check never counts.
- Loop 1's check could report "in sync" about its own bundled example when run from inside
  another project.
- Loop 1's example, the guide's starter pack, gave its check two answers and would wake the
  agent on a repo with no `check-docs` script. Its check now has three, its agent may `Write` as
  well as `Edit`, and the gate, the hook and the standing orders all run `npm run check-docs`.

**Fixed, and sent back to the guide**

- A check has three answers. Thirty three of the 35 loops said "there is work" on repos they
  were not wired to, the cloud chapter worst of all (BOOK-CHANGES.md entry 3).
- Loop 5 flags and never deletes, and loop 2 bumps to Wanted, not Latest (entry 2).
- Loop 6 runs the project's own commands, and loop 7 needs a real release tag (entries 5 and 6).
- Chapter 1 is Software engineering (entry 1).
