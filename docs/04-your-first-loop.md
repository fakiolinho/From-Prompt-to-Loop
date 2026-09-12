# Your first loop

From watching demos to a loop running on your own repo and opening a real PR. About ten minutes.

## Which loop, and why that one

**Engineering loop 2, dependency upgrades.** Do not start with all thirty five. Start with the
one that is hardest to get wrong.

- Its check is `npm outdated`, which only reads.
- Its change is a version bump. The maintainer wrote the code and the world reviewed it.
- Its PR is three lines and easy to review.
- If it gets something wrong, you close the PR and nothing happened.

The field guide stars it for exactly that reason. Once you trust the shape, [add the next
one](05-add-the-next.md).

## First, know what proves a change is safe

Before you point any loop at a repo, answer one question: **what command proves this project
still works?** Tests, a build, a smoke script. The loop is worth exactly as much as that command
is, and not a penny more.

Loop 2's check looks for it and tells you what it found:

    6 dependency upgrade(s) available within range. Verify command: npm run build

If it finds nothing it exits 2 and refuses to wake the agent, because an upgrade nobody can
verify is not a loop, it is a gamble on a schedule. Set `LOOP_VERIFY` to name your own command
if the guess is wrong.

Two things that command cannot prove, on any repo:

- **It cannot vouch for what it does not cover.** A config file read by filename, a package
  loaded at runtime, a fixture passed to a script as a path: none of them appear in a build.
- **It cannot verify its own removal.** A suite with fewer tests passes more easily, so no loop
  here is allowed to delete a test.

## What stops it running away

These are in the workflow file, not in a promise.

| Limit | What it does |
|---|---|
| The check runs first | No work means the agent never wakes, so nothing is spent. |
| `--max-budget-usd 2` | The run ends before it can get expensive. |
| `--max-turns 30` | It cannot grind forever. |
| `timeout-minutes: 20` | A stuck run dies on its own. |
| `--allowedTools` | A fixed list of tools. This is enforced, not requested. |
| One branch, one PR | It never opens a second PR for the same work. |
| It never merges | You review and merge. Always. |
| A check that exits 2 | Fails the run. You do not pay tokens for a check that was never wired. |

**Off switch:** cancel the run in the Actions tab, or delete the workflow file. Nothing keeps
running in the background.

## Step 1. Install it

From this repo, pointed at yours:

    ./install.sh ~/code/my-app 02

That copies the loop, the standing orders, the runner and the PR template into the right
places, and writes a `loops.env` listing exactly the settings this loop needs. It never
overwrites anything of yours without asking.

A whole chapter works the same way:

    ./install.sh ~/code/my-app engineering

<details>
<summary>Or copy the five things by hand</summary>

    CLAUDE.md  and  AGENTS.md              the rules the agent reads every run
    .github/workflows/loop.yml             one runner for the whole chapter
    .github/PULL_REQUEST_TEMPLATE.md       what the agent's PR has to tell you
    loops/02-dependency-upgrades/          the loop you are adopting
    memory/02-dependency-upgrades.md       where the loop writes what it learned

Keep the paths. The runner looks for `loops/<name>/check.sh` at your repo root.
</details>

The PR template is the one people skip. It is what turns the agent's pull request into
evidence you can rule on, instead of a diff you have to reverse engineer at the end of a
long day.

## Step 2. Fill in loops.env, and name an owner

Open `loops.env`. Every setting your loops need is there, commented out, with an example:

    # loop 02: dependency-upgrades
    # LOOP_VERIFY=''

Fill in the ones you want. **A setting you leave blank is not a problem**: that loop exits 2,
says what it wanted, and never wakes an agent. You can install everything and wire it up over
weeks. [WIRING.md](../WIRING.md) lists every setting for all thirty five.

Then open `loops/02-dependency-upgrades/ORDERS.md` and replace the `**Owner:**` line with a
real person. Ten seconds, and it decides whether this is a fleet somebody runs or a fleet
nobody maintains. An unowned loop is the one still running badly a year from now, because
nobody ever felt responsible for turning it off.

## Step 3. Add one secret

In your repo: **Settings > Secrets and variables > Actions > New repository secret.**

Name it `ANTHROPIC_API_KEY`, or `OPENAI_API_KEY` if you will run Codex.

`GITHUB_TOKEN` is provided for you. You do not add it.

## Step 4. Let it open PRs

**Settings > Actions > General > Workflow permissions.** Turn on *"Allow GitHub Actions to create
and approve pull requests"*.

Skip this and you get the quietest failure there is: a green run that shipped nothing.

## Step 5. Commit, push, and run it

- Actions tab, pick **engineering-loop**, click **Run workflow**.
- Set `loop` to `02-dependency-upgrades` and `agent` to `claude`.

Two things can happen, and both are correct:

- **Nothing is outdated.** The run ends at the check. No agent, no spend.
- **Something is outdated.** The agent opens a PR on branch `loop/02-dependency-upgrades`.
  Review it and merge.

That is one full loop, end to end, on your code.

## Step 6. Make it run on its own

The runner starts out manual so your first runs are deliberate. When you trust it, add a
schedule to `.github/workflows/loop.yml`:

    on:
      schedule:
        - cron: "0 6 * * 1"      # Mondays 06:00 UTC
      workflow_dispatch:
        inputs:
          loop:  { description: "loop folder", required: true }
          agent: { description: "claude or codex", default: "claude" }

A scheduled run has nobody to type the `loop` input, so it needs the loop name hard coded. Copy
the loop step into a small dedicated workflow per scheduled loop.

## When the first runs go sideways, and they will

| What happened | What it means |
|---|---|
| It opened a PR you disagree with | Do not fix it by hand. Add the missing rule to `CLAUDE.md` and run it again. That is the only way the loop gets better. |
| Two runs, two PRs | The branch rule was ignored, or the concurrency group is missing. One branch per loop. |
| Green, but nothing shipped | Almost always Step 4. Check the PR actually exists before you trust the silence. |
| You do not trust it yet | Correct. Review the first several PRs properly. Take your hands off when it has earned it. |

---

[← Run the demos](03-run-the-demos.md) · [Contents](../README.md) · [Next: Add the next one →](05-add-the-next.md)

**The 35 loops:** [Engineering](../loop-packs/engineering-loops/LOOPS.md) · [Cloud](../loop-packs/cloud-loops/LOOPS.md) · [AI and ML](../loop-packs/ai-ml-loops/LOOPS.md) · [QA](../loop-packs/qa-loops/LOOPS.md)
