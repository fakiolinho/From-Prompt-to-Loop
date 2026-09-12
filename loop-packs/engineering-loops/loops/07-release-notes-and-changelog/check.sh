#!/usr/bin/env bash
set -uo pipefail
git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repo — run from your project root"; exit 2; }
# Non-zero when there are commits since the last tag not yet in the changelog. exit 2 = not wired.
last=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
range=${last:+$last..HEAD}
count=$(git log --oneline ${range:-HEAD} 2>/dev/null | wc -l | tr -d " ")
[ "$count" = "0" ] && { echo "nothing new to log"; exit 0; } || { echo "$count commits to add to the changelog"; exit 1; }
