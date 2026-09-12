#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# note: heuristic. Looks for a sibling test or spec file next to each changed source file.
git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repo. Run this from your project root"; exit 2; }

base="${BASE_REF:-origin/main}"
git rev-parse --verify --quiet "$base" >/dev/null || {
  echo "cannot compare against '$base'. Set BASE_REF to the branch this work forks from,"
  echo "for example BASE_REF=origin/develop"
  exit 2
}

changed=$(git diff --name-only "$base"...HEAD 2>/dev/null | grep -E '\.(js|ts|jsx|tsx)$' | grep -vE '(test|spec)\.' || true)

if [ -z "$changed" ]; then
  # Saying "covered" here would be a lie: nothing was examined.
  echo "no source changes against $base, so there is nothing to backfill"
  exit 0
fi

work=0
for f in $changed; do
  d=$(dirname "$f"); n=$(basename "$f"); n="${n%.*}"
  ls "$d"/*"$n"*test* "$d"/*"$n"*spec* >/dev/null 2>&1 || { echo "no test for $f"; work=1; }
done
[ "$work" -eq 0 ] && { echo "every changed file has a sibling test"; exit 0; }
exit 1
