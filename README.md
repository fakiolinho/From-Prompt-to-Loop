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
| **Run one for real** | `./install.sh ~/code/my-app 02` | 10 minutes, a real PR |

New here? **[Start with page 0](docs/00-start-here.md).** It is one screen and it points you at
the right door.

### Putting a loop in your own repo

    ./install.sh ~/code/my-app 02            put one loop in your repo
    cd ~/code/my-app && ./run-loop.sh 02     run it there, right now

The first copies the loop, the standing orders, the runner and the PR template into place, and
writes a `loops.env` with the settings that loop needs. The second runs it: check, then the
agent if there is work, then the check again so nothing marks its own homework. No secret, no
schedule, nothing committed.

[WIRING.md](WIRING.md) lists every setting for all thirty five loops. Anything you leave unset
is fine: that loop exits 2, says what it wanted, and never wakes an agent. Walk through it all
in [Your first loop](docs/04-your-first-loop.md).

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

## What it costs, and what it needs

Most of this repo costs nothing and needs nothing. The part that spends money is one step, and
it is fenced.

| | Needs | Costs |
|---|---|---|
| `./run-all-demos.sh` and every `check.sh` | Node 18 and bash | nothing, ever |
| `./run-loop.sh 02` on your machine | your existing Claude Code or Codex login | whatever that agent run costs you |
| The GitHub Actions runner | `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` as a repo secret | per token, metered |

**Locally you do not need an API key.** If you are already signed in to Claude Code, a
subscription included, `run-loop.sh` uses that. Nothing to buy to try this.

**In CI you do.** A GitHub runner has no login, so the workflow needs a key in
`Settings > Secrets and variables > Actions`. That is programmatic usage and it is metered per
token, whatever your interactive plan says. The field guide is blunt about this: do not assume
your subscription covers a fleet, and check your plan's current terms before you build one.

**Every agent run is capped** at `--max-budget-usd 2` and `--max-turns 30`, with a 20 minute
job timeout. And the check runs first, so a loop with nothing to do never wakes an agent at
all. A quiet night costs nothing. That is the whole point of the shape.

## Three answers, not two

Every `check.sh` answers one question, and it has three ways to answer it.

| Exit | Means | What happens |
|---|---|---|
| **0** | no work | The run ends. You spend nothing. |
| **1** | there is work | The agent wakes, fenced and capped. |
| **2** | not wired here | The run fails loudly and says what to wire. The agent never wakes. |

The third one is the one most people leave out, and it is the expensive one. A check with only
two answers says "there is work" when it means "I cannot tell". Point a few dozen of those at a
repo they were never wired to and you get a schedule full of agent runs that can only fail.

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
    package.json          npm test, npm run demos, npm run build
    install.sh            put loops into your own repo
    run-loop.sh           run one there, without GitHub Actions
    WIRING.md             every setting every loop reads
    SECURITY.md           the threat model, honestly
    CONTRIBUTING.md       how to change a loop, and what to test it against
    CHANGELOG.md          what changed, in the repo and in each revision of the guide

`cloud-loops` also has a `SETUP.md`, because it runs against AWS rather than a repo.

[`CHANGELOG.md`](CHANGELOG.md) says what changed, in the repo and in each revision of the field
guide. [`BOOK-CHANGES.md`](BOOK-CHANGES.md) tracks where the repo has learned something the
printed guide does not know yet, with the evidence, so the next revision can catch up.

[`CONTRIBUTING.md`](CONTRIBUTING.md) if you want to change something.
[`SECURITY.md`](SECURITY.md) before you point a loop at anything you care about: what the fences
actually are, and what they do not cover.

---

## Is it still working?

    npm test                               # everything
    ./ci/test-pack.sh engineering-loops    # just one chapter
    ./ci/test-docs.sh                      # just the docs against the field guide

CI runs both on every push, one job per chapter, so a red square tells you which chapter broke.
See [`ci/README.md`](ci/README.md).

---

## Who made this

Marios Fakiolas writes The Warship CTO. Crews, not committees. Loops, not turns.
[mariosfakiolas.com](https://mariosfakiolas.com)
