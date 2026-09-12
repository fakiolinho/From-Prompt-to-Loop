# Run the demos

No AWS account. No API key. Node 18 or newer and bash, nothing else.

## Step 1. Run everything

From the root of this repo:

    ./run-all-demos.sh

One command. Every chapter finds real work in seeded data, and the cloud chapter runs offline
against canned AWS responses. Takes about a minute.

> **A demo that prints findings and exits non zero has not failed.** That is the check saying
> "there is work here." non zero is the whole point. See
> [what a loop is](01-what-is-a-loop.md#the-check-is-the-whole-trick).

## Step 2. Read one piece of output

Look for this block in what scrolled past:

    Loop 5. Dead code and unused dependencies   (pack check: `knip`)
      DEAD FILE   src/unused.js  (exported but nothing imports it)
      UNUSED DEP  is-odd  (in package.json, never imported)
      The loop would remove these, then prove the build and tests still pass.

That is a real check, on a real project, finding real problems. The loop's job is the last line.

## Step 3. Run one chapter on its own

Each chapter has a playground you can run by itself:

    cd loop-packs/engineering-loops/demo-app && node loops.js all
    cd loop-packs/ai-ml-loops/demo-app       && node loops.js all
    cd loop-packs/qa-loops/demo-app          && node loops.js all

Cloud has no demo app, because it runs against AWS. Use the dry run instead:

    cd loop-packs/cloud-loops
    DRY_RUN=1 bash loops/15-cost-and-spend-anomaly-watch/check.sh

## Step 4. Run a single check

This is the smallest unit in the whole repo. One loop, one question.

    cd loop-packs/engineering-loops/demo-app
    bash ../loops/02-dependency-upgrades/check.sh
    echo "exit code: $?"

Exit 1 means it found work. That is the moment a real run would wake an agent.

## Three loops ship working code

Most loops are orders plus a check, ready to point at your stack. Three are built in full and
run right now:

| Loop | What it does | Run it |
|---|---|---|
| **1** docs and examples sync | rewrites drifted docs, runs every example to prove it works | `bash loop-packs/engineering-loops/loops/01-docs-and-examples-sync/check.sh` |
| **19** eval suite | scores a classifier against an eval set, blocks on a regression | `cd loop-packs/ai-ml-loops/loops/19-*/example && node run-evals.js` |
| **28** flaky test detector | runs each test 20 times, catches the unstable one | `cd loop-packs/qa-loops/loops/28-*/example && node detect-flaky.js` |

## If it will not run

| What you see | What to do |
|---|---|
| `permission denied` | `chmod +x run-all-demos.sh`, or the check you ran |
| `node: command not found` | install Node 18 or newer, then open a new terminal |
| `gh: command not found` | that is only the agent step. Every check still runs. |
| a check exits **2** | it is not wired to this folder. Run it from your project root. |
| findings printed, non zero exit | correct. That means "found work." |

---

[← Plain words](02-plain-words.md) · [Contents](../README.md) · [Next: Your first loop →](04-your-first-loop.md)
