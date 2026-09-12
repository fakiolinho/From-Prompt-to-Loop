# Add the next one

You have one loop running. This is the order to add the rest, so you never face thirty five at
once.

> **Launch one, prove it, add a second, then fan out.** Five engineers each quietly building
> their own docs loop is five bills and five sets of rules drifting apart.

## The next two, same chapter, same runner

Both are starred in the field guide for the same reason loop 2 is: mechanical, fully checkable,
trivially reversible.

| Next | Loop | Why it is safe |
|---|---|---|
| 2nd | **6** lint, format, and type fixes | Pure busywork. The tools decide what is right, not the agent. |
| 3rd | **7** release notes and changelog | It writes prose from your commit log. Nothing executable changes. |

One command each, and the runner and the secret are already there:

    ./install.sh ~/code/my-app 06
    ./install.sh ~/code/my-app 07

Then `./run-loop.sh 06 --check` in your repo. Run it again with more loop numbers whenever you
want another; it never overwrites your work without asking, and it adds only the settings the
new loops need to your existing `loops.env`.

## Then adopt a whole chapter

Once three loops feel boring, take a chapter. Pick the one that matches the pain you actually
have.

| Chapter | Loops | Adopt it when | Start here |
|---|---|---|---|
| **1 · Software engineering** | 1-9 | your maintenance backlog never shrinks | [chapter](../loop-packs/engineering-loops/LOOPS.md) |
| **2 · Cloud and platform** | 10-18 | your cloud bill or your on call is the problem | [SETUP.md first](../loop-packs/cloud-loops/SETUP.md) |
| **3 · AI and ML engineering** | 19-26 | you ship prompts or models and have no evals | [chapter](../loop-packs/ai-ml-loops/LOOPS.md) |
| **4 · QA and testing** | 27-35 | your CI signal is not trusted any more | [chapter](../loop-packs/qa-loops/LOOPS.md) |

Each chapter has its own `README.md` (how the pack works) and `LOOPS.md` (one row per loop, with
which ones ship working code today).

## Cloud is the one that is different

Cloud loops act on your AWS account, not a git repo. They sign in with a scoped OIDC role rather
than an API key in a secret, and most of them are **Flags, you decide**, because most cloud
actions cannot be taken back.

Do `loop-packs/cloud-loops/SETUP.md` first, and try everything with `DRY_RUN=1` before you point
anything at a live account.

## Before you build one of your own

The catalog is thirty five loops, not a limit. When you want to add your own, run it through the
guide's five question test (page 19) first:

1. Does it recur, and does it actually hurt?
2. Can it check its own work, cheaply and honestly?
3. Can you undo a miss?
4. Is a boring deterministic tool already doing it?
5. Bonus: does the output compound?

One "no" on the first four and it is not a loop. It is a chore in a loop costume, and building it
burns money you will not get back.

Then do the napkin: cost is tokens per run times runs per month. Payoff is the hours removed plus
the failures prevented. If the payoff does not clear the cost by a wide margin, do not build it.
More on that in [operating a fleet](06-operating.md).

---

[← Your first loop](04-your-first-loop.md) · [Contents](../README.md) · [Next: Operating a fleet →](06-operating.md)

**The 35 loops:** [Engineering](../loop-packs/engineering-loops/LOOPS.md) · [Cloud](../loop-packs/cloud-loops/LOOPS.md) · [AI and ML](../loop-packs/ai-ml-loops/LOOPS.md) · [QA](../loop-packs/qa-loops/LOOPS.md)
