#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# This loop governs a tool you already run. Until you point it at that tool it has
# nothing to look at, so it exits 2 and the agent never wakes. An unwired loop that
# returned 1 would wake an agent on every scheduled run and bill you for nothing.

if [ -z "${LOOP_UI_TESTS:-}" ]; then
  echo "Self healing ui tests is not wired to this repo."
  echo "Set LOOP_UI_TESTS to the command that runs your UI suite, for example:"
  echo "  LOOP_UI_TESTS='npx playwright test --reporter=json'"
  exit 2
fi

out=$(eval "$LOOP_UI_TESTS" 2>&1); rc=$?
printf '%s\n' "$out"
[ "$rc" -eq 0 ] && { echo "the UI suite is green, no selectors to heal"; exit 0; }
echo "UI test failures to triage; repair selectors, never assertions"
exit 1
