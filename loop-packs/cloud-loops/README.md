*[Contents](../../README.md) · Chapter 2 of 4 · [the loops in this chapter](LOOPS.md)*

# Chapter 2 · Cloud and platform

**Loops 10-18.** How this chapter works: the runner, the rules, the fences.

The cloud and platform chapter, built as one dual agent pack on **real AWS CLI**, with the new
AWS frontier agents wired in as optional engines. Drop it next to your infra, run **SETUP.md**
once, then run any loop on **Claude or Codex**.

**Try it before touching AWS:** every loop runs offline with `DRY_RUN=1` against canned outputs (see SETUP.md, "Try it locally first"). Drop `DRY_RUN` to run the identical checks against your real account.

## The principle: AWS agents are ships, the loop is the dock
AWS now ships three autonomous agents: **Security**, **DevOps**, and **FinOps**. They are
powerful, and they run for hours on their own in your account. This pack does not reimplement
them and does not blindly trust them. Where an agent does the analysis better (cost root cause,
incident root cause, penetration testing), the loop **calls it** and **governs the result**: the
trigger, the least privilege fence, the human gate on anything irreversible, the cost cap, and
the audit trail. We own the dock. The agent is optional, every loop has a plain-CLI path.

## Set up once
See **SETUP.md**: install AWS CLI v2, create the OIDC role (no long lived keys), enable the
services each loop reads, optionally turn on the agents, and create the protected `cloud-loops`
environment so irreversible loops pause for human approval.

## Run any loop
From the Actions tab, run **cloud-loop** with the `loop` folder and the `agent`. The runner
assumes the scoped role, runs the AWS CLI check, and only wakes the agent if there is work.

## What keeps every loop safe
- **No keys:** the runner signs in with short lived OIDC credentials, scoped to this repo.
- **Least privilege:** the loop's role starts read only. You add scoped write per loop, never admin.
- **Gated:** loops that can delete, change IAM, rotate a production secret, or touch capacity run
  under a protected environment with required reviewers. Irreversible never ships on green.
- **Fenced and capped:** `--allowedTools "...Bash(aws:*)..."`, `--max-turns 30`,
  `--max-budget-usd 2`, and a job timeout. That is the kill switch.
- **Honest about a broken check:** `check.sh` exits 0 for no work, 1 for work, and 2 when it is
  not wired to your account yet. Only a 1 wakes the agent. A 2 fails the run, so you never pay
  tokens for a check that was never pointed at anything.

## Ships on green, or flags for you

Every loop is one of two kinds, and `LOOPS.md` says which.

- **Ships on green.** Reversible work runs on green and opens a PR you can revert in one click.
- **Flags, you decide.** It investigates and proposes. Anything irreversible waits for a person.

In this chapter most loops are the second kind, because most cloud actions cannot be taken back.

## The honest line on proof
Every check is real AWS CLI and syntax verified. It cannot be run against a live account from a
build sandbox, so the live proof is you: run SETUP.md, point a loop at your account, watch the
check report real findings. See `LOOPS.md` for the order, the engine, and the check per loop.

---

[← Chapter 1: General engineering](../engineering-loops/README.md) · [Contents](../../README.md) · [Chapter 3: AI and ML engineering →](../ai-ml-loops/README.md)
