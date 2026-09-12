#!/usr/bin/env bash
# Test one loop pack. Usage: ci/test-pack.sh engineering-loops
#
# What it proves:
#   1. every check.sh is valid bash and honours the exit contract (0 no work, 1 work, 2 not wired)
#   2. every check.sh says something — a silent check is a check nobody can read
#   3. every loop has its orders and its memory file
#   4. the pack's demo-app finds the work it was seeded with
#   5. every runnable example still passes its own tests
set -uo pipefail
cd "$(dirname "$0")/.."
. ci/lib.sh

PACK="${1:?usage: ci/test-pack.sh <pack>}"
[ -d "loop-packs/$PACK" ] || { echo "no such pack: $PACK"; exit 1; }
echo "Testing $PACK"

head2 "checks are valid bash"
for f in loop-packs/"$PACK"/loops/*/check.sh; do
  if bash -n "$f" 2>/dev/null; then ok "$(basename "$(dirname "$f")")"; else bad "$(basename "$(dirname "$f")") does not parse"; fi
done

head2 "checks honour the exit contract and report what they found"
# A check runs from a project root, the way a user runs it. Each pack's demo-app is that
# root here; cloud has no demo-app, so its checks run from the pack with DRY_RUN=1 mocks.
ROOT="loop-packs/$PACK"
REL="loops"
if [ -d "loop-packs/$PACK/demo-app" ]; then ROOT="loop-packs/$PACK/demo-app"; REL="../loops"; fi
for d in loop-packs/"$PACK"/loops/*/; do
  n=$(basename "$d")
  out=$( cd "$ROOT" && DRY_RUN=1 bash "$REL/$n/check.sh" 2>&1 ); rc=$?
  case "$rc" in
    0|1) [ -n "$out" ] && ok "$n (exit $rc)" || bad "$n exited $rc but printed nothing" ;;
    2)   bad "$n exited 2 (not wired) from a real project root — it would wake the agent for nothing" ;;
    *)   bad "$n exited $rc — outside the 0 / 1 / 2 contract" ;;
  esac
done

head2 "every loop has orders and a memory file"
for d in loop-packs/"$PACK"/loops/*/; do
  n=$(basename "$d")
  [ -f "$d/ORDERS.md" ] && ok "$n ORDERS.md" || bad "$n has no ORDERS.md"
  [ -f "loop-packs/$PACK/memory/$n.md" ] && ok "$n memory" || bad "$n has no memory/$n.md"
done

head2 "the demo-app finds its seeded work"
if [ -f "loop-packs/$PACK/demo-app/loops.js" ]; then
  ( cd "loop-packs/$PACK/demo-app" && node loops.js all >/dev/null 2>&1 )
  rc=$?
  # 1 = found work, which is the whole point of the seeded demo
  [ "$rc" -eq 1 ] && ok "demo-app found work (exit 1)" || bad "demo-app exited $rc, expected 1"
else
  ok "no demo-app in this pack (cloud runs on DRY_RUN mocks)"
fi

head2 "runnable examples still pass their own tests"
found=0
for e in loop-packs/"$PACK"/loops/*/example/; do
  [ -f "$e/package.json" ] || continue
  grep -q '"test"' "$e/package.json" || continue
  found=1
  n=$(basename "$(dirname "$e")")
  ( cd "$e" && npm test >/dev/null 2>&1 ); rc=$?
  # loop 28's detector is *supposed* to exit non-zero: it found the planted flaky test
  case "$n" in
    # the flaky detector is *supposed* to go red: it found the planted flaky test
    28-*) [ "$rc" -ne 0 ] && ok "$n caught the planted flaky test" || bad "$n went green — it missed the flaky test" ;;
    *)    [ "$rc" -eq 0 ] && ok "$n npm test" || bad "$n npm test exited $rc" ;;
  esac
done
[ "$found" -eq 1 ] || ok "no runnable examples in this pack"

summary "$PACK"
