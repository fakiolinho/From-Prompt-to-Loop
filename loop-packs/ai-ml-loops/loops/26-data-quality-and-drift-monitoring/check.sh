#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# Until this points at something real it cannot tell you anything. Returning 1 here
# would wake an agent on every scheduled run to look at data it does not have.

if [ -z "${LOOP_DRIFT:-}" ]; then
  echo "Data quality and drift monitoring is not wired to this repo."
  echo "Set LOOP_DRIFT to the command that compares incoming data to your baseline, for example:"
  echo "  LOOP_DRIFT='node scripts/drift-check.js'"
  exit 2
fi

out=$(eval "$LOOP_DRIFT" 2>&1); rc=$?
printf '%s\n' "$out"
[ "$rc" -eq 0 ] && { echo "data is within tolerance of the baseline"; exit 0; }
echo "drift, nulls or a schema break in incoming data"
exit 1
