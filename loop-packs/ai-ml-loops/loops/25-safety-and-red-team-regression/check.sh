#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# Until this points at something real it cannot tell you anything. Returning 1 here
# would wake an agent on every scheduled run to look at data it does not have.

if [ -z "${LOOP_REDTEAM:-}" ]; then
  echo "Safety and red team regression is not wired to this repo."
  echo "Set LOOP_REDTEAM to the command that runs your adversarial set (the same harness as loop 19), for example:"
  echo "  LOOP_REDTEAM='node run-evals.js --set redteam'"
  exit 2
fi

out=$(eval "$LOOP_REDTEAM" 2>&1); rc=$?
printf '%s\n' "$out"
[ "$rc" -eq 0 ] && { echo "the red team set still holds"; exit 0; }
echo "a red team regression. This blocks the release"
exit 1
