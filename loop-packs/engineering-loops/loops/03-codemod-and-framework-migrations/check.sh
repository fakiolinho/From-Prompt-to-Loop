#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# You point this loop at one migration. With nothing pointed at, there is no work,
# and a check that always said "yes" would wake an agent on every scheduled run.
if [ -z "${MIGRATION:-}${LOOP_CODEMOD:-}" ]; then
  echo "Codemod and framework migrations is not wired: no migration named."
  echo "This loop runs on dispatch, not on a schedule. Name the target, for example:"
  echo "  MIGRATION='react-18-to-19'"
  echo "  LOOP_CODEMOD='npx jscodeshift -t ./codemods/foo.js src/'"
  exit 2
fi
echo "migration requested: ${MIGRATION:-$LOOP_CODEMOD}"
exit 1
