#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# This loop writes the entries between one release and the next, so it needs a real
# release to measure from. Two traps, both found on real repositories:
#   - a repo with no tags: "commits since the last tag" is every commit ever made
#   - a repo whose only tag is called "patch": git describe happily returns it, and the
#     loop asks an agent to write changelog entries for 710 commits against a baseline
#     that was never a release
git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repo. Run this from your project root"; exit 2; }

# Only version shaped tags count as a release: v1.2.3, 1.2, 2024.01.
version_tag() { printf '%s' "$1" | grep -qE '^v?[0-9]+(\.[0-9]+)+'; }

last="${BASE_TAG:-}"
if [ -z "$last" ]; then
  last=$(git tag --sort=-creatordate | while read -r t; do
           if printf '%s' "$t" | grep -qE '^v?[0-9]+(\.[0-9]+)+'; then echo "$t"; break; fi
         done)
fi

if [ -z "$last" ]; then
  stray=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
  echo "Release notes and changelog is not wired: this repo has no release tag."
  if [ -n "$stray" ]; then
    echo "The nearest tag is '$stray', which is not version shaped, so it is not a release"
    echo "baseline. Measuring from it would ask for entries covering every commit since."
  fi
  echo "Tag a release (git tag v0.1.0), or set BASE_TAG to measure from a known point."
  exit 2
fi

changelog=""
for f in CHANGELOG.md CHANGELOG HISTORY.md docs/CHANGELOG.md; do
  [ -f "$f" ] && changelog="$f" && break
done
[ -n "$changelog" ] || { echo "no changelog file found. Create CHANGELOG.md first"; exit 2; }

count=$(git log --oneline "$last..HEAD" 2>/dev/null | wc -l | tr -d " ")
[ "$count" = "0" ] && { echo "nothing released since $last, $changelog is current"; exit 0; }

# A release note covering hundreds of commits is not a release note. It means the
# baseline is wrong, and no agent should be asked to write it.
limit="${LOOP_MAX_COMMITS:-200}"
if [ "$count" -gt "$limit" ]; then
  echo "$count commits since $last. That is too many to be one release."
  echo "The baseline is probably wrong. Tag your actual last release, or raise the"
  echo "ceiling deliberately with LOOP_MAX_COMMITS=$count."
  exit 2
fi

echo "$count commit(s) since $last are not yet in $changelog"
exit 1
