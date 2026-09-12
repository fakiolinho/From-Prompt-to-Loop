#!/usr/bin/env bash
set -uo pipefail
[ -f package.json ] || { echo "no package.json here — run from your project root"; exit 2; }
# Non-zero when dependencies are out of date (there is work). exit 2 = not wired.
if npm outdated >/dev/null 2>&1; then echo "all dependencies current"; exit 0; else echo "outdated dependencies found"; exit 1; fi
