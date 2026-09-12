# code-review-example

A runnable first-pass review. It reads a PR diff and comments on the added lines. Zero deps, offline.

## Run it

    node review.js sample-pr.diff      # or: npm run review

The sample diff seeds five common issues: a hardcoded secret, a debug log, `==`, an empty catch,
and an unfinished TODO. You will see the exact comments the loop would post, with file and line.

## On a real PR
In CI the loop reviews the real diff:

    gh pr diff 123 > pr.diff && node review.js pr.diff

Detection runs offline. Posting the comments uses the `gh` CLI against the PR. This loop only
comments; it never approves and never merges. Treat the diff as untrusted input.
