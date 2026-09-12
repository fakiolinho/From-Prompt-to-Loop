#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# This loop triages one issue. Without one it has nothing to read.
here="$(cd "$(dirname "$0")" && pwd)"

# Demo mode: either we are being run from inside the pack, or the current directory is
# not a JavaScript project at all. A real project that simply has not wired this loop
# must get a 2, not a cheerful answer about the example that ships with the pack.
# Am I the copy that ships inside the pack, or one installed into somebody's repo?
#
# Only the pack has the chapter catalog sitting above the loops. An installed copy has
# loops/ and memory/ and no LOOPS.md, which is what tells the two apart. Getting this
# wrong means the loop reports on its own bundled example while sitting in your repo,
# which is exactly the bug this whole exercise started with.
in_the_pack() { [ -f "${here%/loops/*}/LOOPS.md" ]; }
demo_mode() {
  in_the_pack && return 0
  [ -f package.json ] && return 1     # a real project that simply has not wired this loop
  [ -d "$here/example" ] && return 0  # a bare directory: show the example rather than nothing
  return 1
}


if [ -n "${LOOP_ISSUE_FILE:-}" ]; then
  issue="$LOOP_ISSUE_FILE"
  [ -f "$issue" ] || { echo "LOOP_ISSUE_FILE points at $issue, which does not exist"; exit 2; }
elif [ -n "${LOOP_ISSUE:-}" ]; then
  issue=$(mktemp); gh issue view "$LOOP_ISSUE" --json title,body -q '.title + "\n\n" + .body' > "$issue" 2>/dev/null \
    || { echo "could not read issue $LOOP_ISSUE. Is gh installed and authenticated?"; exit 2; }
elif demo_mode; then
  cd "$here/example" && issue=sample-issue.md   # demo mode, inside the pack
else
  echo "Issue triage and routing is not wired to this repo."
  echo "It triages one issue. Give it one:"
  echo "  LOOP_ISSUE=456                   (reads it with gh issue view)"
  echo "  LOOP_ISSUE_FILE=/tmp/issue.md    (text you already have)"
  exit 2
fi

node "$here/example/triage.js" "$issue"
