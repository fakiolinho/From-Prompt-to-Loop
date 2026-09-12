#!/usr/bin/env bash
set -uo pipefail
# Non-zero when a PR has review-worthy findings. Runs the example review over the sample diff so it
# is demonstrable offline. In CI, point it at the real diff: gh pr diff <n> > pr.diff
cd "$(dirname "$0")/example" 2>/dev/null || { echo "example missing"; exit 1; }
node review.js sample-pr.diff
