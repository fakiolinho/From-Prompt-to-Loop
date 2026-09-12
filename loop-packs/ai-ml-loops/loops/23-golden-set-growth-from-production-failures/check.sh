#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# Until this points at something real it cannot tell you anything. Returning 1 here
# would wake an agent on every scheduled run to look at data it does not have.

if [ -z "${LOOP_FAILURES:-}" ]; then
  echo "Golden set growth from production failures is not wired to this repo."
  echo "Set LOOP_FAILURES to the command that lists production misses not yet in your eval set, for example:"
  echo "  LOOP_FAILURES='node scripts/recent-misses.js'"
  exit 2
fi

out=$(eval "$LOOP_FAILURES" 2>&1); rc=$?
printf '%s\n' "$out"
[ "$rc" -eq 0 ] && { echo "the golden set already covers every known miss"; exit 0; }
echo "production failures not yet in the golden set"
exit 1
