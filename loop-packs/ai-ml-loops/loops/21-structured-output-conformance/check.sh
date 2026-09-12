#!/usr/bin/env bash
set -uo pipefail
# Non-zero when outputs do not conform. note: wire ajv or zod over your sample outputs.
[ -f schema.json ] || { echo "no schema.json; wire your output schema and a validator"; exit 1; }
echo "schema present; wire a validator (ajv/zod) over your sample outputs"; exit 1
