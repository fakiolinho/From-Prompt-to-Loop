# docs-loop

A reference loop that keeps an SDK's docs and examples in sync with its code.
Zero dependencies. Runs offline. Works in any CI with no setup.

This is the one fully runnable example from *From Prompt to Loop*. Clone it, break it,
watch it notice, then point the same pattern at your own SDK.

## Why this is a real loop

| Test | This loop |
|------|-----------|
| Recurs and hurts | docs rot on every API change, and docs that lie cost customers |
| Checks its own work | every example is run, not eyeballed (`npm run examples`) |
| Reversible | a bad change is one revert; it ships a PR, never a push to main |
| Not bot-owned | nothing else keeps your examples honest |
| Compounds | the memory file makes every future run smarter |

## What is in here

    src/index.js           a tiny pretend SDK, the source of truth
    docs/api.md            the docs that must match it
    examples/*.js          runnable examples that must match it
    examples/run-all.js    the self-check: runs every example, exits 1 on any failure
    scripts/check-docs.js  the docs-coverage check: every API symbol must be documented
    CLAUDE.md / AGENTS.md  the standing orders (Claude reads one, Codex the other)
    .claude/settings.json  a hook that runs the check after every edit
    .github/workflows/     the trigger that turns it into a loop
    memory/docs-loop.md    git-backed memory, one line per run

## Run the check

    npm test     # runs the examples and the docs-coverage check

Green means docs, examples, and code agree. Try it: rename `key` to `apiKey` in
`src/index.js`, run `npm test`, watch it go red. Fix the docs and examples back, green again.
The docs check covers the full surface, top-level exports and the methods on what they return,
so renaming `send` is caught, not just renaming `createClient`.

## Run the loop for real, on Claude or Codex

The harness above is real and runs offline. The agent that does the rewriting runs on your
infrastructure with your key. The work, the check, and the trigger are the same on either
tool. Only the driver changes: the rules file and the headless command. CLAUDE.md and
AGENTS.md hold the same orders; Claude reads CLAUDE.md, Codex reads AGENTS.md.

**Claude, headless:**

    npx @anthropic-ai/claude-code -p "Read CLAUDE.md and memory/docs-loop.md. \
      Sync /docs and /examples to the API in /src. Run npm run check-docs until green. \
      Open or update the single PR on branch docs-loop/sync, never a second, and \
      append what drifted to memory/docs-loop.md." \
      --allowedTools "Read,Edit,Write,Bash(npm:*),Bash(git:*),Bash(gh:*)" \
      --max-turns 30 --max-budget-usd 2

**Codex, same orders:**

    npx @openai/codex exec --sandbox workspace-write "Read AGENTS.md and memory/docs-loop.md. \
      Sync /docs and /examples to the API in /src. Run npm run check-docs until green. \
      Open or update the single PR on branch docs-loop/sync, never a second."

How it behaves, and why:

- **The check has three answers.** In sync ends the run at the check, no tokens. Drift wakes
  the agent. No `check-docs` script fails the job loudly and never wakes an agent, because there
  is nothing it could prove its work against.
- **One command everywhere.** The hook, the CI gate and the standing orders all run
  `npm run check-docs`. If they checked different things, the loop could ship on a green it
  never earned.
- **The agent is fenced, not just asked.** `--allowedTools` limits Claude to reading, editing,
  writing new files, and the `npm`, `git`, `gh` commands it needs; Codex gets
  `--sandbox workspace-write`.
  CLAUDE.md is the standing order, the fence is what enforces it.
- **The run is capped.** `--max-turns`, `--max-budget-usd`, and the job timeout are the kill switch.
- **It can actually open the PR.** The workflow grants `contents: write` and
  `pull-requests: write` and passes `GH_TOKEN`. To use the default token, enable
  *Settings > Actions > General > "Allow GitHub Actions to create and approve pull requests"*,
  or pass a fine-grained PAT / GitHub App token as `GH_TOKEN`.

Set `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` in repo secrets. Review the first few PRs, then
let it merge itself once it earns the trust.

## What it remembers

`memory/docs-loop.md` is git-backed: every lesson the loop writes is a commit you can read,
review, or revert. A bad lesson is one rollback, and `git blame` tells you which run wrote it.
