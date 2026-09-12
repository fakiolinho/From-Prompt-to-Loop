#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# Unconfigured, knip does not know your entry points, and everything they reach looks
# dead. On a real app that turned 8 findings into 34, including the test suite. So this
# loop refuses to run until somebody has told the tool what the entry points are.
#
# This loop only ever reports. It never deletes. See ORDERS.md for why.

[ -f package.json ] || { echo "no package.json here. Run this from your project root"; exit 2; }

configured=0
for f in knip.json knip.jsonc knip.ts knip.js knip.config.ts knip.config.js .kniprc .kniprc.json; do
  [ -e "$f" ] && configured=1 && break
done
# a "knip" key in package.json counts too
[ "$configured" -eq 0 ] && node -e 'process.exit(require("./package.json").knip?0:1)' 2>/dev/null && configured=1

if [ "$configured" -eq 0 ]; then
  echo "no knip config here. Without one, knip cannot see entry points it was not told about"
  echo "(tests run from a glob, workers named in a deploy config, fixtures passed as paths),"
  echo "and it will report most of your project as dead. Add a knip config first."
  exit 2
fi

if npx --yes knip >/dev/null 2>&1; then
  echo "no dead code or unused dependencies"
  exit 0
fi
echo "knip found candidates. This loop reports them for a human; it never deletes."
exit 1
