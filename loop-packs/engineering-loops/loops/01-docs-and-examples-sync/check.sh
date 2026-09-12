#!/usr/bin/env bash
set -uo pipefail
# Non-zero when docs or examples drift from the code.
# The fully runnable version of this loop lives in ./example (the docs-loop repo).
cd "$(dirname "$0")/example" 2>/dev/null || { echo "example missing"; exit 1; }
if npm run --silent check-docs >/dev/null 2>&1; then echo "docs in sync"; exit 0; else echo "docs drift"; exit 1; fi
