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
in_pack_or_not_a_project() {
  case "$PWD" in "${here%/loops/*}"*) return 0;; esac
  [ -f package.json ] && return 1
  [ -d "$here/example" ] && return 0
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
if in_pack_or_not_a_project; then
  cd "$here/example" && exec node detect-flaky.js
fi

echo "Flaky test detection is not wired to this repo."
echo "It needs a command it can run repeatedly, and the number of runs to try:"
echo "  LOOP_TEST='npm test' LOOP_RUNS=20"
exit 2
