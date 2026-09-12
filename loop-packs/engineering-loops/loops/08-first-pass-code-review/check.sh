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
# Am I the copy that ships inside the pack, or one installed into somebody's repo?
#
# Only the pack has the chapter catalog sitting above the loops. An installed copy has
# loops/ and memory/ and no LOOPS.md, which is what tells the two apart. Getting this
# wrong means the loop reports on its own bundled example while sitting in your repo,
# which is exactly the bug this whole exercise started with.
# Demo mode means two things at once, and it needs both.
#
#   1. I am the copy that ships inside the pack, not one installed into a repo.
#      Only the pack has the chapter catalog sitting above the loops.
#   2. You are standing inside this project, not in a repo of your own.
#
# Miss the second and the pack's own check, run from your repo, reports on the pack's
# bundled example and calls it your result. That is the defect this whole project
# started with, and it came back once already by keying only on the script path.
in_the_pack()     { [ -f "${here%/loops/*}/LOOPS.md" ]; }
cwd_in_project()  {
  d=$PWD
  while [ "$d" != "/" ] && [ -n "$d" ]; do
    [ -d "$d/loop-packs" ] && return 0
    d=$(dirname "$d")
  done
  return 1
}
demo_mode() {
  in_the_pack && cwd_in_project && return 0
  [ -f package.json ] && return 1     # a real project that simply has not wired this loop
  [ -d "$here/example" ] && return 0  # a bare directory: show the example rather than nothing
  return 1
}


if [ -n "${LOOP_PR_DIFF:-}" ]; then
  diff_file="$LOOP_PR_DIFF"
  [ -f "$diff_file" ] || { echo "LOOP_PR_DIFF points at $diff_file, which does not exist"; exit 2; }
elif [ -n "${LOOP_PR:-}" ]; then
  diff_file=$(mktemp); gh pr diff "$LOOP_PR" > "$diff_file" 2>/dev/null \
    || { echo "could not read PR $LOOP_PR. Is gh installed and authenticated?"; exit 2; }
elif demo_mode; then
  cd "$here/example" && diff_file=sample-pr.diff   # demo mode, inside the pack
else
  echo "First pass code review is not wired to this repo."
  echo "It reviews one diff. Give it one:"
  echo "  LOOP_PR=123                 (reads it with gh pr diff)"
  echo "  LOOP_PR_DIFF=/tmp/pr.diff   (a diff you already have)"
  exit 2
fi

node "$here/example/review.js" "$diff_file"
