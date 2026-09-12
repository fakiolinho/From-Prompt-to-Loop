#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# This loop governs a tool you already run. Until you point it at that tool it has
# nothing to look at, so it exits 2 and the agent never wakes. An unwired loop that
# returned 1 would wake an agent on every scheduled run and bill you for nothing.

if [ -z "${LOOP_MATRIX:-}" ]; then
  echo "Cross browser and device matrix is not wired to this repo."
  echo "Set LOOP_MATRIX to the command that runs your suite across the grid, for example:"
  echo "  LOOP_MATRIX='npx playwright test --project=chromium --project=webkit'"
  exit 2
fi

out=$(eval "$LOOP_MATRIX" 2>&1); rc=$?
printf '%s\n' "$out"
[ "$rc" -eq 0 ] && { echo "every browser and device in the matrix passed"; exit 0; }
echo "failures in one or more matrix configurations"
exit 1
