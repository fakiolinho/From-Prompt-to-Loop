# flaky-detect-example

A runnable flaky-test detector. It runs every test many times, measures each one's pass rate, and
fails on an unstable test, unless that test is quarantined. Quarantine is how a flaky test stops
blocking the team without being deleted, and how the suite reaches green. Zero deps, offline.

## Run it, full cycle, locally
The example ships with one intentionally flaky test and an empty quarantine, so a fresh run shows
detection:

    node detect-flaky.js               # order-lookup FLAKY -> exit 1 (detection works)
    npm run quarantine -- order-lookup https://github.com/you/repo/issues/1  # needs a real tracking-issue URL
    node detect-flaky.js               # order-lookup now QUARANTINED, suite GREEN (exit 0)

A quarantined test keeps running and being measured, you still see its pass rate, but it no longer
fails the build, and it stays clearly distinct from a healthy test.

## What is in here

    tests/*.test.js      two healthy tests and one intentionally flaky one
    detect-flaky.js      the detector: runs each test 20x, classifies, respects quarantine.json
    quarantine.json      the quarantine list the detector reads (ships empty)
    quarantine.js        adds a test to quarantine with a tracking-issue placeholder
    CLAUDE.md/AGENTS.md  the standing orders (Claude reads one, Codex the other)

## The loop
Nightly, run the detector. For each FLAKY test, the agent opens a tracking issue, adds the test to
quarantine.json with that issue, and opens a PR you approve. The test keeps running so the flake is
still measured, but it stops blocking the team. Never delete a flaky test and never weaken it: a
flaky test is a real signal that something underneath is racy or slow.

## Prerequisites for the agent and PR steps
Detection runs fully offline. The actions, opening the tracking issue and the quarantine PR, use
the `gh` CLI against a connected GitHub remote. Without `gh` authenticated and a remote, detection
still works; that is simply where the run stops.
