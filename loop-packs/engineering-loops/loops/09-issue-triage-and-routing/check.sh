#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# This loop triages one issue. Without one it has nothing to read.
here="$(cd "$(dirname "$0")" && pwd)"

# Demo mode: either we are being run from inside the pack, or the current directory is
# not a JavaScript project at all. A real project that simply has not wired this loop
# must get a 2, not a cheerful answer about the example that ships with the pack.
in_pack_or_not_a_project() {
  case "$PWD" in "${here%/loops/*}"*) return 0;; esac
  [ -f package.json ] && return 1
  [ -d "$here/example" ] && return 0
  return 1
}


if [ -n "${LOOP_ISSUE_FILE:-}" ]; then
  issue="$LOOP_ISSUE_FILE"
  [ -f "$issue" ] || { echo "LOOP_ISSUE_FILE points at $issue, which does not exist"; exit 2; }
elif [ -n "${LOOP_ISSUE:-}" ]; then
  issue=$(mktemp); gh issue view "$LOOP_ISSUE" --json title,body -q '.title + "\n\n" + .body' > "$issue" 2>/dev/null \
    || { echo "could not read issue $LOOP_ISSUE. Is gh installed and authenticated?"; exit 2; }
elif in_pack_or_not_a_project; then
  cd "$here/example" && issue=sample-issue.md   # demo mode, inside the pack
else
  echo "Issue triage and routing is not wired to this repo."
  echo "It triages one issue. Give it one:"
  echo "  LOOP_ISSUE=456                   (reads it with gh issue view)"
  echo "  LOOP_ISSUE_FILE=/tmp/issue.md    (text you already have)"
  exit 2
fi

node "$here/example/triage.js" "$issue"
