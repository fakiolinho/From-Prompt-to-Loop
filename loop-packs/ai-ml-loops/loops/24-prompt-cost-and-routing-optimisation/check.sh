#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# Until this points at something real it cannot tell you anything. Returning 1 here
# would wake an agent on every scheduled run to look at data it does not have.

if [ -z "${LOOP_COST:-}" ]; then
  echo "Prompt cost and routing optimisation is not wired to this repo."
  echo "Set LOOP_COST to the command that reports spend per prompt or route, for example:"
  echo "  LOOP_COST='node scripts/cost-report.js'"
  exit 2
fi

out=$(eval "$LOOP_COST" 2>&1); rc=$?
printf '%s\n' "$out"
[ "$rc" -eq 0 ] && { echo "spend is within budget on every route"; exit 0; }
echo "prompts or routes are over budget"
exit 1
