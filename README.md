# From Prompt to Loop, the loops

**Thirty five loops that keep a product alive after it ships.** Ready to run, on Claude Code or
Codex. The companion code to the free field guide,
**[From Prompt to Loop](From-Prompt-to-Loop_The-Warship-CTO.pdf)**, which sits in this folder.

A loop is a small system that finds work, hands it to an agent, checks the result, and writes
down what it learned. You build it once. It runs without you after that.

MIT licensed. Take it, use it, build on it.

---

## Three doors

| | | |
|---|---|---|
| **See it work** | `./run-all-demos.sh` | 1 minute, no setup |
| **Understand it** | [What a loop is](docs/01-what-is-a-loop.md) | 5 minutes |
| **Run one for real** | [Your first loop](docs/04-your-first-loop.md) | 10 minutes, a real PR |

New here? **[Start with page 0](docs/00-start-here.md).** It is one screen and it points you at
the right door.

---

## Contents

### The guide

| | Page | What it covers |
|---|---|---|
| 0 | [Read this first](docs/00-start-here.md) | pick your door, what you need |
| 1 | [What a loop is](docs/01-what-is-a-loop.md) | the five parts, the exit codes, the two kinds |
| 2 | [Plain words](docs/02-plain-words.md) | every term, explained once |
| 3 | [Run the demos](docs/03-run-the-demos.md) | see all four chapters find real work |
| 4 | [Your first loop](docs/04-your-first-loop.md) | loop 2 on your own repo, step by step |
| 5 | [Add the next one](docs/05-add-the-next.md) | the order to grow in, without drowning |
| 6 | [Operating a fleet](docs/06-operating.md) | cost, brakes, security, memory |
| 7 | [Where these fit](docs/07-where-these-fit.md) | vs. the build loops everyone cites |

### The four chapters

The guide numbers the loops 1 to 35 straight through. The chapters just split the range.

| | Chapter | Loops | What is in it |
|---|---|---|---|
| 1 | [Software engineering](loop-packs/engineering-loops/LOOPS.md) | 1-9 | docs and examples sync, dependency upgrades, codemods, test backfill, dead code, lint and types, release notes, code review, issue triage |
| 2 | [Cloud and platform](loop-packs/cloud-loops/LOOPS.md) | 10-18 | base image bumps, backup restore drills, orphaned resources, cert rotation, infra drift, cost anomalies, alert noise, auto remediation, IAM audit |
| 3 | [AI and ML engineering](loop-packs/ai-ml-loops/LOOPS.md) | 19-26 | eval suite on every change, RAG sync, structured output, model upgrades, golden set growth, prompt cost, red team, data drift |
| 4 | [QA and testing](loop-packs/qa-loops/LOOPS.md) | 27-35 | bug to failing test, flaky tests, self healing UI tests, fixtures, smoke tests, browser matrix, visual diffs, e2e coverage, synthetic monitoring |

**Three loops ship working code you can run right now:** loop 1 (docs sync), loop 19 (eval
harness), and loop 28 (flaky test detector). Every cloud loop runs offline with `DRY_RUN=1`.

---

## Two kinds of loop, and only two

Every loop is one or the other. Its `ORDERS.md` says which.

- **Ships on green.** It opens a PR and merges once the check passes. A bad one is one click back.
- **Flags, you decide.** It stops and hands you the call. It never merges on its own.

Nothing irreversible happens without a person. That is the whole reason you can walk away.

---

## How this is laid out

    From-Prompt-to-Loop_The-Warship-CTO.pdf   the field guide, free

    docs/                 the guide above, pages 0 to 7
    loop-packs/           the four chapters
      <chapter>/
        LOOPS.md            one row per loop, and which ship working code
        README.md           how this chapter works
        CLAUDE.md           rules the agent reads every run (AGENTS.md for Codex)
        loops/NN-name/      ORDERS.md (what it may do) + check.sh (is there work?)
                            example/ where a loop ships working code
        memory/NN-name.md   what the loop learned, one line per run
        .github/workflows/loop.yml   one runner for the whole chapter
    ci/                   this repo's own tests, one per chapter

`cloud-loops` also has a `SETUP.md`, because it runs against AWS rather than a repo.

---

## Is it still working?

    ./ci/test-pack.sh engineering-loops    # one chapter
    ./ci/test-docs.sh                      # the docs against the field guide

CI runs both on every push, one job per chapter, so a red square tells you which chapter broke.
See [`ci/README.md`](ci/README.md).

---

## Who made this

Marios Fakiolas writes The Warship CTO. Crews, not committees. Loops, not turns.
[mariosfakiolas.com](https://mariosfakiolas.com)
