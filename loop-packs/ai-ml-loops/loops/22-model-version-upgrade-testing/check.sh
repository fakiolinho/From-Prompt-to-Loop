#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# Until this points at something real it cannot tell you anything. Returning 1 here
# would wake an agent on every scheduled run to look at data it does not have.

if [ -z "${LOOP_CANDIDATE:-}" ]; then
  echo "Model version upgrade testing is not wired to this repo."
  echo "Set LOOP_CANDIDATE to the model version to evaluate against the incumbent, for example:"
  echo "  LOOP_CANDIDATE='claude-opus-5'"
  exit 2
fi

out=$(eval "$LOOP_CANDIDATE" 2>&1); rc=$?
printf '%s\n' "$out"
[ "$rc" -eq 0 ] && { echo "no new version to evaluate"; exit 0; }
echo "a candidate version is waiting on an evaluation"
exit 1
