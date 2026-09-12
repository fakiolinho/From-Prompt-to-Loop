#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# Until this points at something real it cannot tell you anything. Returning 1 here
# would wake an agent on every scheduled run to look at data it does not have.

if [ -z "${LOOP_SCHEMA:-}" ]; then
  echo "Structured output conformance is not wired to this repo."
  echo "Set LOOP_SCHEMA to the command that validates sample outputs against your schema, for example:"
  echo "  LOOP_SCHEMA='npx ajv validate -s schema.json -d 'samples/*.json''"
  exit 2
fi

out=$(eval "$LOOP_SCHEMA" 2>&1); rc=$?
printf '%s\n' "$out"
[ "$rc" -eq 0 ] && { echo "every sampled output matches the contract"; exit 0; }
echo "outputs have drifted from the schema"
exit 1
