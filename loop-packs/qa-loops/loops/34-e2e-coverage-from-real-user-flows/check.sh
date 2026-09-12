#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# This loop governs a tool you already run. Until you point it at that tool it has
# nothing to look at, so it exits 2 and the agent never wakes. An unwired loop that
# returned 1 would wake an agent on every scheduled run and bill you for nothing.

if [ -z "${LOOP_JOURNEYS:-}" ]; then
  echo "E2e coverage from real user flows is not wired to this repo."
  echo "Set LOOP_JOURNEYS to a command that prints your top production journeys, for example:"
  echo "  LOOP_JOURNEYS='node scripts/top-journeys.js'"
  exit 2
fi

out=$(eval "$LOOP_JOURNEYS" 2>&1); rc=$?
printf '%s\n' "$out"
[ "$rc" -eq 0 ] && { echo "the top journeys all have an e2e test"; exit 0; }
echo "top journeys with no e2e test"
exit 1
