#!/usr/bin/env bash
set -uo pipefail
# Runnable example in ./example. Three states: 0 at baseline, 3 improvement (ratchet), else regression.
cd "$(dirname "$0")/example" 2>/dev/null || { echo "example missing"; exit 1; }
node run-evals.js >/dev/null 2>&1; rc=$?
[ "$rc" -eq 0 ] && { echo "evals at baseline. nothing to do."; exit 0; }
[ "$rc" -eq 3 ] && { echo "accuracy improved. ratchet with: npm run raise-baseline."; exit 1; }
echo "eval regression"; exit 1
