#!/usr/bin/env bash
set -uo pipefail
# Non-zero when there is an issue awaiting triage. Runs the example triage over the sample issue so
# it is demonstrable offline. In CI, feed the real issue: gh issue view <n> --json title,body
cd "$(dirname "$0")/example" 2>/dev/null || { echo "example missing"; exit 1; }
node triage.js sample-issue.md
