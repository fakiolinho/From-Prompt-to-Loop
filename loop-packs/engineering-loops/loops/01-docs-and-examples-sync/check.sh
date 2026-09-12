#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# The gate has to RUN the examples, not just look for symbol names. A doc that lies
# still mentions every function it lies about. See the field guide, "one verification
# command is the whole trick".
here="$(cd "$(dirname "$0")" && pwd)"

# Demo mode: either we are being run from inside the pack, or the current directory is
# not a JavaScript project at all. A real project that simply has not wired this loop
# must get a 2, not a cheerful answer about the example that ships with the pack.
in_pack_or_not_a_project() {
  case "$PWD" in "${here%/loops/*}"*) return 0;; esac
  [ -f package.json ] && return 1
  [ -d "$here/example" ] && return 0
  return 1
}


# 1. your repo's own docs check, by convention or by name
if [ -n "${LOOP_DOCS:-}" ]; then
  cmd="$LOOP_DOCS"
elif [ -f package.json ] && node -e 'const s=require("./package.json").scripts||{};process.exit(s["check-docs"]||s["check:docs"]?0:1)' 2>/dev/null; then
  cmd=$(node -e 'const s=require("./package.json").scripts||{};console.log(s["check-docs"]?"npm run --silent check-docs":"npm run --silent check:docs")')
# 2. running inside the pack itself: use the worked example, which is a real repo
elif [ "$PWD" = "$here" ] || in_pack_or_not_a_project; then
  cd "$here/example" || { echo "example missing"; exit 2; }
  cmd="npm run --silent check-docs"
else
  echo "Docs and examples sync is not wired to this repo."
  echo "It needs one command that runs your examples against the current API, not just"
  echo "a search for names. Add a check-docs script, or set LOOP_DOCS, for example:"
  echo "  LOOP_DOCS='npm run test:examples'"
  exit 2
fi

if eval "$cmd" >/dev/null 2>&1; then echo "docs and examples are in sync ($cmd)"; exit 0; fi
echo "docs or examples drifted from the code ($cmd)"
exit 1
