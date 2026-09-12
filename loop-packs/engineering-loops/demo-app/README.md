# loops-demo-app

A deliberately messy little cart project. It exists so you can watch the engineering loops find
real work, then fix it yourself or hand it to Claude or Codex. Zero dev dependencies, the checks
are pure Node, so you can run everything immediately.

## Run the whole playground

    node loops.js all          # or: npm run check

Five loops each find the problem seeded for them. Fix one, run again, watch it clear.

## What each loop finds, and what to do

**Loop 2. Dependency upgrades**

    npm install && npm run loop2     # real `npm outdated`

`ms` and `is-odd` are pinned old. The loop bumps patch/minor, runs the tests, opens a PR.
Try it: change `"ms": "2.0.0"` to `"2.1.3"` and run it again.

**Loop 4. Test backfill**

    npm run loop4

`src/discount.js` is live code (index.js uses it) with no test. The loop writes one that passes
against current behaviour. Try it: add `src/discount.test.js` and run it again.

**Loop 5. Dead code and unused dependencies**

    npm run loop5

`src/unused.js` is never imported, and `is-odd` sits in package.json unused. The loop removes both,
then proves the build and tests still pass. Try it: delete `src/unused.js` and the `is-odd` dep.

**Loop 6. Lint, format, and type fixes**

    npm run loop6

`src/messy.js` uses `==`, `var`, and an unused variable. The loop auto-fixes the mechanical ones.
Try it: switch to `===`, `const`, drop the unused var, and run it again.

**Loop 7. Release notes and changelog**

    npm run loop7

`package.json` is 1.1.0 but `CHANGELOG.md` stops at 1.0.0. The loop writes the missing entry from
the commit log. Try it: add a `## 1.1.0` section and run it again.

## Demo checks vs the real loops
These built-in checks are simplified so the whole thing runs offline with no setup, the fastest way
to build intuition. The pack's real checks use standard tools: `npm outdated` (2), git diff (4),
`knip` (5), eslint + prettier + tsc (6), git log since the last tag (7). Loops 2, 5, and 6 will run
those real tools against this project after `npm install`; 4 and 7 use git in the pack, which this
demo stands in for so you can see them with no git setup.

## Then hand it to an agent
Once you have watched a loop find work, point the real loop at this project: from the loop's folder
in the pack, follow its `ORDERS.md` with Claude or Codex. The agent opens the PR; you review it.
That is the jump from "I ran the examples" to "I am running the pack."
