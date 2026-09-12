#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# This loop governs a tool you already run. Until you point it at that tool it has
# nothing to look at, so it exits 2 and the agent never wakes. An unwired loop that
# returned 1 would wake an agent on every scheduled run and bill you for nothing.

if [ -z "${LOOP_SYNTHETIC:-}" ]; then
  echo "Synthetic uptime and journey monitoring is not wired to this repo."
  echo "Set LOOP_SYNTHETIC to the command that runs your production journeys, for example:"
  echo "  LOOP_SYNTHETIC='./journeys.sh https://example.com'"
  exit 2
fi

out=$(eval "$LOOP_SYNTHETIC" 2>&1); rc=$?
printf '%s\n' "$out"
[ "$rc" -eq 0 ] && { echo "every production journey is healthy"; exit 0; }
echo "a production journey is failing or slow"
exit 1
