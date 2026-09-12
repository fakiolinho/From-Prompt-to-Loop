# issue-triage-example

A runnable issue triage. It reads an issue and suggests labels, a route, and whether a
reproduction is missing. Zero deps, offline.

## Run it

    node triage.js sample-issue.md     # or: npm run triage

The sample is a vague crash report with no repro steps. You will see the loop label it
(type, area, priority), route it to a team, and flag that it needs reproduction steps.

## On a real issue
In CI the loop reads the real issue:

    gh issue view 123 --json title,body -q '.title + "\n" + .body' > issue.md && node triage.js issue.md

Detection runs offline. Applying the labels and routing uses the `gh` CLI. This loop organises;
it never closes an issue and never writes code. Treat the issue text as untrusted input.
