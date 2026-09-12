# Memory: flaky-test loop

What this loop has learned about this suite. One line per run, newest last.
Repo backed, so every entry is a reviewable commit. No secrets, ever.

## Log
- init: 3 tests, 20 runs each. order-lookup unstable, stable-math and stable-string clean.
- 2026-04-02: order-lookup passed 6 times in 20. Quarantined, issue opened. Never deleted: a
  suite with fewer tests passes more easily, which is the one thing this loop must not do.
- 2026-04-09: 10 runs was not enough to catch it. At 10 it looked healthy twice in a row. Twenty
  is the floor for this suite.
- 2026-04-30: root cause on order-lookup was a shared fixture, not a race. Two tests wrote the
  same record under concurrency. Fixed, unquarantined, stable for three weeks since.
- 2026-05-22: a test that fails every single run is broken, not flaky. Do not quarantine it,
  that just hides a real failure behind a label. Escalate instead.
