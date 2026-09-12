# Standing orders for the docs loop

## How to verify a change
- Run examples: `npm run examples`
- Check docs:   `npm run check:docs`
- Full check:   `npm test`
- A change is done only when `npm test` is green. Green, or it did not happen.

## What this loop owns, and what it must never touch
- Owns:  /docs and /examples
- Never: /src, the public API, /scripts, anything generated
- If a doc or example no longer matches the API in /src, fix the doc or example
  to match the code. Never change /src to match a stale doc. The code is the truth.

## Conventions this team cares about
- Every example runs exactly as written, offline, no real network. No pseudo code.
- One concept per example file. Short. Copy-paste ready.
- Examples are numbered. Match the style of the ones already there.
- Keep docs/api.md ordered the same as the exports in src/index.js.

## When to stop and call a human
- The API in /src changed in a way you cannot map to docs without guessing intent.
  Open an issue, stop, do not invent a new contract.
- An example cannot be made to pass against the current API. Leave it failing, flag it.
- Never delete an example or weaken a check just to go green.

## Opening the PR
- Always work on one fixed branch: `docs-loop/sync`. Never a new branch per run.
- Before opening a PR, check for an open one:
  `gh pr list --head docs-loop/sync --state open`.
  If a PR is already open, push the fix to that same branch and stop. Never open a second.
- One open PR at a time. Re-runs update it, they do not stack.

## Memory
- Read /memory/docs-loop.md at the start of a run. Append durable lessons there.
- Never write secrets, keys, or tokens into memory or anywhere in the repo.
