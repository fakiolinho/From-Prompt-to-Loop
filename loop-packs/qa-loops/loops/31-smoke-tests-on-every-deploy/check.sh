#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# This loop governs a tool you already run. Until you point it at that tool it has
# nothing to look at, so it exits 2 and the agent never wakes. An unwired loop that
# returned 1 would wake an agent on every scheduled run and bill you for nothing.

if [ -z "${LOOP_SMOKE:-}" ]; then
  echo "Smoke tests on every deploy is not wired to this repo."
  echo "Set LOOP_SMOKE to the command that smoke tests a release, for example:"
  echo "  LOOP_SMOKE='./smoke.sh https://staging.example.com'"
  exit 2
fi

out=$(eval "$LOOP_SMOKE" 2>&1); rc=$?
printf '%s\n' "$out"
[ "$rc" -eq 0 ] && { echo "smoke tests passed against the release"; exit 0; }
echo "a critical path failed after deploy"
exit 1
