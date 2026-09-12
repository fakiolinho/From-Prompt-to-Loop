#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# This loop governs a tool you already run. Until you point it at that tool it has
# nothing to look at, so it exits 2 and the agent never wakes. An unwired loop that
# returned 1 would wake an agent on every scheduled run and bill you for nothing.

if [ -z "${LOOP_VISUAL:-}" ]; then
  echo "Visual regression triage is not wired to this repo."
  echo "Set LOOP_VISUAL to the command that diffs screenshots against the baseline, for example:"
  echo "  LOOP_VISUAL='npx playwright test --update-snapshots=none'"
  exit 2
fi

out=$(eval "$LOOP_VISUAL" 2>&1); rc=$?
printf '%s\n' "$out"
[ "$rc" -eq 0 ] && { echo "no visual diffs against the baseline"; exit 0; }
echo "visual diffs to triage"
exit 1
