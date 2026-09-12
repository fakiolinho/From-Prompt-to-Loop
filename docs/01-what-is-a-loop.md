# What a loop is

Five parts. Every loop in this repo is this shape, whatever the job. Change the trigger and the
check; the rest stays the same.

    1. TRIGGER    something wakes it up
                  a push, a merge, 2am, an alert, a new issue
                       |
                       v
    2. CHECK      is there work?            <-- the part everyone skips
                  one honest pass or fail the agent can run on itself
                       |
           +-----------+-----------+
           |                       |
      nothing to do            there is work
      exit. costs nothing.     wake the agent
                                   |
                                   v
    3. AGENT      it does the job, fenced
                  reads the orders, works, checks itself, retries within a ceiling
                       |
                       v
    4. GATE       ships on green, or flags and waits
                  reversible: open a PR. irreversible: a human owns the button
                       |
                       v
    5. MEMORY     it writes down what it learned
                  the runner is destroyed. the lesson survives, in the repo.

> Miss the check and you have an expensive cron job. Miss the gate and you have a liability.

## Where each part lives in this repo

Open any loop folder, say `loop-packs/engineering-loops/loops/02-dependency-upgrades/`, and you
will find the same two files every time.

| Part | The file | What it is |
|---|---|---|
| Trigger | `.github/workflows/loop.yml` | one runner for the whole chapter |
| Check | `loops/NN-name/check.sh` | is there work? |
| Agent | your API key, plus the orders below | Claude Code or Codex |
| Orders | `loops/NN-name/ORDERS.md` | what this loop owns, and must never touch |
| Rules | `CLAUDE.md` / `AGENTS.md` | the rules for the whole chapter, read every run |
| Gate | `ORDERS.md` says which kind | see below |
| Memory | `memory/NN-name.md` | one line per run |

## The check is the whole trick

`check.sh` answers one question and says so with its exit code:

| Exit | Means | What happens |
|---|---|---|
| **0** | no work | The run ends. The agent never wakes. You spend nothing. |
| **1** | there is work | The agent wakes, under the orders. |
| **2** | not wired here | The run fails loudly. The agent still never wakes. |

That is why a quiet night is free, and why a check pointed at the wrong folder costs you nothing
instead of costing you tokens.

Try one:

    cd loop-packs/engineering-loops/demo-app
    bash ../loops/05-dead-code-and-unused-dependency-removal/check.sh
    echo "exit code: $?"

## Two kinds of loop, and only two

Every loop in the catalog is one or the other. Its `ORDERS.md` says which on line three.

**Ships on green.** It opens a PR and merges once the check passes. A bad one is one click back.
Docs sync, dependency upgrades, lint fixes.

**Flags, you decide.** It stops and hands you the call, because it cannot fully certify its own
work or because the action cannot be taken back. Code review, IAM audit, visual regression.

Nothing irreversible happens without a person. That is the whole reason you can walk away.

## Is your idea actually a loop?

Before you build one of your own, the guide has a five question test (page 19). The short form:
does it recur and hurt, can it check its own work honestly, can you undo a miss, and is a boring
tool already doing it? Four yeses buy you the right to walk away.

---

[← Read this first](00-start-here.md) · [Contents](../README.md) · [Next: Plain words →](02-plain-words.md)
