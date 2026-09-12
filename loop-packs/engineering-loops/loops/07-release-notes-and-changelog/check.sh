#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# This loop fires on a tag. On a repo that has never tagged, "commits since the last
# tag" is every commit ever made, which is not a changelog entry, it is a git log.
git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repo. Run this from your project root"; exit 2; }

last=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -z "$last" ]; then
  echo "Release notes and changelog is not wired: this repo has no tags."
  echo "The loop writes the entries between one release and the next, so tag a release"
  echo "first (git tag v0.1.0), or set BASE_TAG to the commit to measure from."
  [ -n "${BASE_TAG:-}" ] && last="$BASE_TAG" || exit 2
fi

changelog=""
for f in CHANGELOG.md CHANGELOG HISTORY.md docs/CHANGELOG.md; do
  [ -f "$f" ] && changelog="$f" && break
done
[ -n "$changelog" ] || { echo "no changelog file found. Create CHANGELOG.md first"; exit 2; }

count=$(git log --oneline "$last..HEAD" 2>/dev/null | wc -l | tr -d " ")
[ "$count" = "0" ] && { echo "nothing released since $last, changelog is current"; exit 0; }
echo "$count commit(s) since $last are not yet in $changelog"
exit 1
