#!/usr/bin/env bash
set -uo pipefail
# Non-zero when the suite contains a flaky (or broken) test. Runnable example in ./example.
cd "$(dirname "$0")/example" 2>/dev/null || { echo "example missing"; exit 1; }
if npm test >/dev/null 2>&1; then echo "all tests stable"; exit 0; else echo "flaky or broken test found"; exit 1; fi
