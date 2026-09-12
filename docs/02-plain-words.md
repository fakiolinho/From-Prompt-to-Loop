# Plain words

Every word this repo uses, explained once. If a page loses you, the reason is almost always on
this list. The field guide has a longer version on page 6.

## The five words that matter most

**Loop.** A small system that finds work, hands it to an agent, checks the result, writes down
what it learned, and exits. You build the loop. The loop runs the agent.

**Check.** The script that answers one question: is there work? [`check.sh`](../loop-packs/engineering-loops/loops/02-dependency-upgrades/check.sh) in every loop folder.
Exit 0 means no, exit 1 means yes. Nothing is spent until it says yes.

**Orders.** [`ORDERS.md`](../loop-packs/engineering-loops/loops/02-dependency-upgrades/ORDERS.md) in every loop folder. What this loop owns, what it must never touch, and
when to stop and ask a person. The agent reads this every run.

**Agent.** A model that does not just answer. It reads your files, runs commands, edits code,
checks its own work, and keeps going until the job is done. Claude Code or Codex, here.

**Gate.** The moment a human is, or is not, required. **Ships on green** means no human. **Flags,
you decide** means a human owns the button.

## The repo's own words

**Chapter.** One of the four folders under `loop-packs/`. Each holds nine or eight loops that
share a runner and a set of rules. The guide calls them chapters; the folders are named after
them.

**Pack.** The same thing as a chapter. The folder names end in `-loops`.

**Standing orders.** [`CLAUDE.md`](../loop-packs/engineering-loops/CLAUDE.md) (or `AGENTS.md` for Codex) at the top of a chapter. The rules
that apply to every loop in it, read on every single run.

**Memory.** [`memory/NN-name.md`](../loop-packs/engineering-loops/memory/02-dependency-upgrades.md). One line per run, written by the agent, kept in git so a wrong
lesson is one revert away.

**Demo app.** `demo-app/` inside a chapter. A small project deliberately seeded with problems, so
you can watch the checks find real work before you point one at your own code.

**Dry run.** `DRY_RUN=1` in front of a cloud check. It runs against canned AWS responses in
`mock/`, so you can try every cloud loop with no AWS account.

## The general words

**Repository (repo).** The folder holding all the files for one project, plus its history.

**Branch.** A private copy of the project where changes can happen without touching the real
thing.

**Pull request (PR).** A proposal: here are my changes, please review and merge them. The thing
you approve.

**CI.** The robot that runs your tests automatically when changes are proposed. GitHub Actions,
here.

**Fence.** The list of tools an agent is allowed to use, passed as `--allowedTools`. The orders
are the soft rule. The fence is the one that is actually enforced.

**Cap.** `--max-turns` and `--max-budget-usd`. The run ends by itself before it can get
expensive.

**Token.** The unit you pay for, roughly a word.

**Context.** What the agent holds in mind during one run. Fill it with junk and the agent gets
slower, pricier, and worse.

---

[← What a loop is](01-what-is-a-loop.md) · [Contents](../README.md) · [Next: Run the demos →](03-run-the-demos.md)

**The 35 loops:** [Ch 1](../loop-packs/engineering-loops/LOOPS.md) · [Ch 2](../loop-packs/cloud-loops/LOOPS.md) · [Ch 3](../loop-packs/ai-ml-loops/LOOPS.md) · [Ch 4](../loop-packs/qa-loops/LOOPS.md)
