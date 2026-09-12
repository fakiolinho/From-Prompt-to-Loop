#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# Flakiness is only visible across repeated runs, so this loop needs a command it can
# run many times. Without one it has nothing to observe.
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


if [ -n "${LOOP_TEST:-}" ]; then
  runs="${LOOP_RUNS:-10}"
  pass=0; fail=0
  for i in $(seq 1 "$runs"); do
    if eval "$LOOP_TEST" >/dev/null 2>&1; then pass=$((pass+1)); else fail=$((fail+1)); fi
  done
  echo "ran the suite ${runs}x: $pass passed, $fail failed"
  [ "$fail" -eq 0 ] && { echo "stable across $runs runs"; exit 0; }
  [ "$pass" -eq 0 ] && { echo "failing every run. That is broken, not flaky. Fix it, do not quarantine it"; exit 1; }
  echo "flaky: the same code passed $pass and failed $fail times"
  exit 1
fi

# demo mode, inside the pack: the worked example plants one flaky test
if demo_mode; then
  cd "$here/example" && exec node detect-flaky.js
fi

echo "Flaky test detection is not wired to this repo."
echo "It needs a command it can run repeatedly, and the number of runs to try:"
echo "  LOOP_TEST='npm test' LOOP_RUNS=20"
exit 2
