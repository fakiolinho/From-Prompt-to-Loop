# Memory: Infrastructure drift reconciliation

What this loop has learned about **this** repo. One line per run, newest last.

It lives in git on purpose. Every write is a reviewable diff, `git blame` says which run wrote
it, and a wrong lesson is one revert away. A loop with no memory repeats yesterday. A loop with
unread memory repeats yesterday's mistake.

**A good line is specific, and changes what the next run does:**

    2026-03-04: @types/node publishes an older version on its latest tag than the one
    installed here. Take the Wanted column, never Latest.

**A useless line just says the loop ran:**

    2026-03-04: ran the loop, bumped some dependencies.

Never put a secret here.

## Log
