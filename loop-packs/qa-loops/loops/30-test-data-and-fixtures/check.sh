#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# Fixtures drift from the schema silently. This loop needs both: a schema to check
# against, and a validator that runs it. Without them there is nothing to compare,
# so it exits 2 rather than waking an agent to look at a repo it cannot read.

if [ -n "${LOOP_FIXTURES:-}" ]; then
  out=$(eval "$LOOP_FIXTURES" 2>&1); rc=$?
  printf '%s\n' "$out"
  [ "$rc" -eq 0 ] && { echo "fixtures still match the schema"; exit 0; }
  echo "fixtures have drifted from the schema"
  exit 1
fi

# a project can also wire this by convention, with a script npm already knows about
if [ -f package.json ] && node -e 'process.exit(require("./package.json").scripts?.["validate:fixtures"]?0:1)' 2>/dev/null; then
  out=$(npm run --silent validate:fixtures 2>&1); rc=$?
  printf '%s\n' "$out"
  [ "$rc" -eq 0 ] && { echo "fixtures still match the schema"; exit 0; }
  echo "fixtures have drifted from the schema"
  exit 1
fi

schema=""
for f in schema.json fixtures/schema.json test/schema.json tests/schema.json; do
  [ -f "$f" ] && schema="$f" && break
done

if [ -z "$schema" ]; then
  echo "Test data and fixtures is not wired to this repo: no schema found."
  echo "Set LOOP_FIXTURES to the command that validates your fixtures, for example:"
  echo "  LOOP_FIXTURES='npx ajv validate -s schema.json -d \"fixtures/*.json\"'"
  exit 2
fi

echo "found $schema, but no validator to run against it."
echo "Set LOOP_FIXTURES to the command that checks your fixtures against it."
exit 2
