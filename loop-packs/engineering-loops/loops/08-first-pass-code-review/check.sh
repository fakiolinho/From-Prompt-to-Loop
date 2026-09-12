#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# This loop reviews a diff. Without one it has nothing to read, so it exits 2 rather
# than waking an agent to review a sample that ships with the pack.
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


if [ -n "${LOOP_PR_DIFF:-}" ]; then
  diff_file="$LOOP_PR_DIFF"
  [ -f "$diff_file" ] || { echo "LOOP_PR_DIFF points at $diff_file, which does not exist"; exit 2; }
elif [ -n "${LOOP_PR:-}" ]; then
  diff_file=$(mktemp); gh pr diff "$LOOP_PR" > "$diff_file" 2>/dev/null \
    || { echo "could not read PR $LOOP_PR. Is gh installed and authenticated?"; exit 2; }
elif in_pack_or_not_a_project; then
  cd "$here/example" && diff_file=sample-pr.diff   # demo mode, inside the pack
else
  echo "First pass code review is not wired to this repo."
  echo "It reviews one diff. Give it one:"
  echo "  LOOP_PR=123                 (reads it with gh pr diff)"
  echo "  LOOP_PR_DIFF=/tmp/pr.diff   (a diff you already have)"
  exit 2
fi

node "$here/example/review.js" "$diff_file"
