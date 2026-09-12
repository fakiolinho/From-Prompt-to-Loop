#!/usr/bin/env bash
set -uo pipefail
# Non-zero when lint, format, or types are not clean (there is work).
ok=0
npx --yes eslint . >/dev/null 2>&1 || ok=1
npx --yes prettier --check . >/dev/null 2>&1 || ok=1
npx --yes tsc --noEmit >/dev/null 2>&1 || ok=1
[ "$ok" -eq 0 ] && { echo "lint, format, and types clean"; exit 0; } || { echo "lint/format/type issues found"; exit 1; }
