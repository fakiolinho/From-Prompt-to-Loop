# eval-loop-example

A runnable eval loop. It keeps a tiny intent classifier at or above a baseline accuracy and acts
on three outcomes: it blocks a regression, ratchets the baseline up on an improvement, and does
nothing when you are exactly at the bar. Zero dependencies, offline. The AI-work unit test.

## Run it, full cycle, locally
The classifier ships above its baseline, so a fresh run shows the improvement path:

    node run-evals.js          # accuracy 1.0 vs baseline 0.9 -> IMPROVEMENT (exit 3)
    npm run raise-baseline     # ratchets baseline.json up to 1.0 (in CI this opens a PR)
    node run-evals.js          # now at baseline -> green (exit 0)

Then see the regression guard:

    # break a rule in src/classify.js, then:
    node run-evals.js          # drops below baseline -> REGRESSION (exit 1), lists the misses

Three exit codes drive the workflow: 0 at baseline, 1 regression, 3 improvement. `npm test` runs the harness; exit 3 is a good outcome (an improvement to ratchet), not a failure. A plain CI that only knows pass/fail will read 3 as non-zero, so drive it via the check, not `npm test`.

## What is in here

    src/classify.js      the system under test (stands in for your prompt or model)
    evals/cases.json     the eval set: utterances and their correct intent
    baseline.json        the bar. Raised only on a real improvement, never lowered to pass
    run-evals.js         the harness: scores accuracy, exits 1 / 0 / 3
    raise-baseline.js    ratchets the baseline up to current accuracy (improvement only)
    CLAUDE.md/AGENTS.md  the standing orders (Claude reads one, Codex the other)

## The loop
On any change to the prompt or model, run the evals. On an improvement the baseline is ratcheted
up and the change ships as a PR you approve, so the bar only rises and smaller regressions get
caught. On a regression the agent opens an issue and stops. Grow the set from real production
failures so the same miss never comes back unseen.

## Prerequisites for the agent and PR steps
Detection and the baseline math run fully offline. The actions, opening the regression issue and
the baseline-raise PR, use the `gh` CLI against a connected GitHub remote. Without `gh`
authenticated and a remote, detection still works; that is simply where the run stops.
