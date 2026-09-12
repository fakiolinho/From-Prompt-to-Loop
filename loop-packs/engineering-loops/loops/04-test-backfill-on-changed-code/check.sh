#!/usr/bin/env bash
set -uo pipefail
git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repo — run from your project root"; exit 2; }
# Non-zero when changed code has no matching test (there is work). exit 2 = not wired.
# note: heuristic — looks for a sibling test/spec file next to each changed source file.
base="${BASE_REF:-origin/main}"
changed=$(git diff --name-only "$base"...HEAD 2>/dev/null | grep -E '\.(js|ts|jsx|tsx)$' | grep -vE '(test|spec)\.' || true)
work=0
for f in $changed; do
  d=$(dirname "$f"); n=$(basename "$f"); n="${n%.*}"
  ls "$d"/*"$n"*test* "$d"/*"$n"*spec* >/dev/null 2>&1 || { echo "no test for $f"; work=1; }
done
[ "$work" -eq 0 ] && { echo "changed code is covered"; exit 0; } || exit 1
