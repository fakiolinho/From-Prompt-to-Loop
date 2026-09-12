#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# Two things have to be true before this wakes an agent:
#   1. something is actually upgradable inside the ranges you already allow
#   2. this repo can prove a bump is safe
# Miss the second and you have an agent shipping unverified upgrades. No honest
# check, no autonomy.

[ -f package.json ] || { echo "no package.json here. Run this from your project root"; exit 2; }

# What proves a bump is safe here? Name your own with LOOP_VERIFY, else we look.
# e.g. LOOP_VERIFY='npm test && npm run build'
if [ -n "${LOOP_VERIFY:-}" ]; then
  verify="$LOOP_VERIFY"
elif node -e 'process.exit(require("./package.json").scripts?.test?0:1)' 2>/dev/null; then
  verify="npm test"
elif node -e 'process.exit(require("./package.json").scripts?.build?0:1)' 2>/dev/null; then
  verify="npm run build"
else
  echo "no way to prove an upgrade is safe here: this project has no test and no build script."
  echo "Add one, or set LOOP_VERIFY to the command that proves your app still works."
  exit 2
fi

# Only count what can move inside the ranges already in package.json. A package
# whose Latest is a major is not this loop's job, and npm's Latest can even be
# OLDER than what you have installed (@types/node tracks the Node LTS, not the
# newest release). Wanted is the honest column.
# npm outdated exits non-zero when it finds anything, so swallow that here: a
# non-zero exit from it is data, not an error.
# An upgrade that cannot land (a peer pin, a build it breaks) would keep this check at
# 1 forever, waking an agent every run to fail at the same thing. A person parks it by
# name in LOOP_HOLD, space or comma separated, and it stops counting until they lift it.
# Read with printenv: it is not wiring, so it has no place in the list of settings.
outdated=$( { npm outdated --json 2>/dev/null || true; } )
result=$(printf '%s' "$outdated" | HOLD="$(printenv LOOP_HOLD || true)" node -e '
let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{
  let d={};try{d=JSON.parse(s||"{}")}catch(e){}
  const hold=(process.env.HOLD||"").split(/[\s,]+/).filter(Boolean);
  const up=Object.entries(d).filter(([,p])=>p.current&&p.wanted&&p.current!==p.wanted).map(([n])=>n);
  const held=up.filter(n=>hold.includes(n));
  console.log((up.length-held.length)+" "+held.join(","));
})' 2>/dev/null)
set -- $result
count=${1:-0}; held=${2:-}

if [ "$count" -eq 0 ]; then
  echo "dependencies are current within their ranges. Verify command: $verify"
  [ -n "$held" ] && echo "held back by LOOP_HOLD: $held"
  exit 0
fi
echo "$count dependency upgrade(s) available within range. Verify command: $verify"
[ -n "$held" ] && echo "held back by LOOP_HOLD: $held"
exit 1
