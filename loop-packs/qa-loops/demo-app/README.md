# qa-loops-demo-app

A playground seeded with real work for QA loops 27, 30, 33 and 34. Watch each loop find its problem,
then fix it or hand it to an agent. Zero dependencies, pure Node, runs offline. (Loop 28, flaky
detection, has its own runnable example under `loops/28-.../example`.)

## Run the whole playground

    node loops.js all          # or: npm run check

## What each loop finds

**Loop 27. Bug report to failing test** `npm run loop27`
`bugs/BUG-101.json` reports a real bug in `src/cart.js`: a discount over 100% goes negative. The
check reproduces it live and shows no test guards it. The loop writes the failing test first, then
the fix makes it pass. Reproduce before you fix. Try it: add `tests/BUG-101.test.js`, run it again.

**Loop 30. Test data and fixtures** `npm run loop30`
`fixtures.json` drifted from `schema.json`: one record misses a field, one has the wrong type. The
loop regenerates or repairs fixtures behind a PR. Try it: fix the two records, run it again.

**Loop 33. Visual regression triage** `npm run loop33`
`screenshots/current.txt` differs from `baseline.txt` (a small region changed). The loop triages: a
real change updates the baseline behind a PR, a flake opens a bug, it never blind-accepts. Try it:
make `current.txt` match `baseline.txt`, run it again.

**Loop 34. E2e coverage from real user flows** `npm run loop34`
`flows.json` is your top journeys by traffic; `e2e-manifest.json` shows checkout and profile-edit
untested. The loop drafts an e2e test for the highest-traffic gap first. Try it: add checkout to
covered, run it again.

## Demo checks vs the real loops
Simplified for instant offline intuition. In the pack the same loops run in CI against your real
repo, fixtures, screenshots and analytics, and the agent opens the PR while you review it.

## The integration loops
Four QA loops, 29 self-healing UI, 31 smoke, 32 cross-browser, 35 synthetic uptime, are thin
governance layers over tools you already run (Playwright, BrowserStack, Pingdom and the like). They
are not stubbed here. Each ships a real config example in its folder and ORDERS that keep the loop
owning the trigger, the gate and the audit trail while the tool does the running.

## Then hand it to an agent
Point the real loop at your project from its folder in the pack and follow its ORDERS.md.
