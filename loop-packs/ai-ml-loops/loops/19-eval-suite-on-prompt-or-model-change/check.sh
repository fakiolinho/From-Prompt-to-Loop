#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# The eval harness has three states of its own: at baseline, above it (ratchet the bar),
# or below it (a regression, which never ships).
here="$(cd "$(dirname "$0")" && pwd)"

in_pack_or_not_a_project() {
  case "$PWD" in "${here%/loops/*}"*) return 0;; esac
  [ -f package.json ] && return 1
  [ -d "$here/example" ] && return 0
  return 1
}

if [ -n "${LOOP_EVALS:-}" ]; then
  cmd="$LOOP_EVALS"
elif [ -f package.json ] && node -e 'process.exit((require("./package.json").scripts||{}).evals?0:1)' 2>/dev/null; then
  cmd="npm run --silent evals"
elif in_pack_or_not_a_project; then
  cd "$here/example" || { echo "example missing"; exit 2; }
  cmd="node run-evals.js"
else
  echo "Eval suite is not wired to this repo."
  echo "It needs a command that scores your prompt or model against a fixed set and"
  echo "compares it to a baseline. Add an evals script, or set LOOP_EVALS:"
  echo "  LOOP_EVALS='node run-evals.js'"
  echo "This is the unit test of AI work. Without it nothing else in this chapter means much."
  exit 2
fi

eval "$cmd" >/dev/null 2>&1; rc=$?
[ "$rc" -eq 0 ] && { echo "evals at baseline, nothing to do"; exit 0; }
[ "$rc" -eq 3 ] && { echo "accuracy is above baseline. Ratchet it: npm run raise-baseline"; exit 1; }
echo "eval regression. This never ships; open an issue with the failing cases"
exit 1
