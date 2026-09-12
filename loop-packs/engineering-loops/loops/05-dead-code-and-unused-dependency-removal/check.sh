#!/usr/bin/env bash
set -uo pipefail
# Non-zero when dead code or unused deps exist (there is work).
# note: knip's static analysis cannot see dynamic/reflective usage. The orders make the
# agent confirm every removal against a green build before it ships.
if npx --yes knip >/dev/null 2>&1; then echo "no dead code or unused deps"; exit 0; else echo "knip found candidates"; exit 1; fi
