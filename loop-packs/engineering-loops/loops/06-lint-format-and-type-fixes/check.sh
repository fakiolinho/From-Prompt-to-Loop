#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# Two rules, both learned the hard way on real repositories:
#
#   1. Only run a tool this project actually uses. `prettier --check .` on a repo that
#      never adopted prettier flags every file it owns. That is not a lint fix, it is a
#      364 file diff nobody asked for.
#   2. Use the project's own version. `npx --yes eslint` fetches the newest major, so a
#      repo pinned to eslint 9 gets linted by eslint 10 and simply crashes.
[ -f package.json ] || { echo "no package.json here. Run this from your project root"; exit 2; }

# Prefer the locally installed binary. Fall back to npx only for a tool that is a
# declared dependency, so the version still comes from this project's lockfile.
missing=""
run() {
  tool="$1"; shift
  if [ -x "node_modules/.bin/$tool" ]; then "node_modules/.bin/$tool" "$@"; return $?; fi
  if npx --no-install "$tool" --version >/dev/null 2>&1; then
    npx --no-install "$tool" "$@" 2>/dev/null; return $?
  fi
  missing="$missing $tool"   # configured but not installed: that is not "dirty"
  return 0
}
declared() { node -e "const p=require('./package.json');const d={...p.dependencies,...p.devDependencies};process.exit(d['$1']?0:1)" 2>/dev/null; }

configured=""
dirty=0

if ls eslint.config.js eslint.config.mjs eslint.config.cjs eslint.config.ts .eslintrc .eslintrc.js .eslintrc.json .eslintrc.yml >/dev/null 2>&1 || declared eslint; then
  configured="$configured eslint"
  run eslint . >/dev/null 2>&1 || dirty=1
fi

if ls .prettierrc .prettierrc.json .prettierrc.js .prettierrc.yml prettier.config.js prettier.config.mjs >/dev/null 2>&1 || declared prettier; then
  configured="$configured prettier"
  run prettier --check . >/dev/null 2>&1 || dirty=1
fi

if [ -f tsconfig.json ]; then
  configured="$configured tsc"
  run tsc --noEmit >/dev/null 2>&1 || dirty=1
fi

if [ -z "$configured" ]; then
  echo "Lint, format and type fixes is not wired to this repo: it uses none of"
  echo "eslint, prettier or TypeScript. This loop fixes what those tools decide;"
  echo "with none configured there is nothing for it to be right about."
  exit 2
fi

if [ -n "$missing" ]; then
  echo "these tools are configured here but not installed:$missing"
  echo "Run npm ci first, so the loop uses this project's pinned versions."
  exit 2
fi

[ "$dirty" -eq 0 ] && { echo "clean:$configured"; exit 0; }
echo "issues found by:$configured"
exit 1
