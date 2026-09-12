#!/usr/bin/env bash
set -uo pipefail
# Non-zero when fixtures no longer match the schema. note: wire your schema + a validator.
[ -f schema.json ] || { echo "no schema.json; wire your schema and fixtures"; exit 1; }
echo "schema present; wire a validator over your fixtures"; exit 1
