#!/usr/bin/env bash
# Run the loop demos in one go. No AWS account, no API key. Needs Node 18 or newer and bash.
#
# A demo that finds work exits 1. That is success, not failure, so this script cannot just
# use `set -e`. It checks every exit code against what that demo is supposed to do, and it
# fails loudly on anything else. A demo runner that always exits 0 proves nothing.
set -uo pipefail
cd "$(dirname "$0")"

FAILED=0
hr(){ printf '\n=================  %s  =================\n' "$1"; }

# run "<label>" "<allowed exit codes>" "<text the output must contain>" <command...>
#
# An exit code alone is not proof. A demo that finds work exits 1, and so does a demo that
# crashed on line one. So we check the exit code AND that the demo actually said the thing
# it exists to say. Pass "" to skip the text check.
run() {
  local label="$1" allowed="$2" must="$3"; shift 3
  local out rc
  out=$("$@" 2>&1); rc=$?
  printf '%s\n' "$out"
  case " $allowed " in
    *" $rc "*) ;;
    *) printf '\n!! %s exited %d. Allowed: %s. This demo is broken.\n' "$label" "$rc" "$allowed"
       FAILED=$((FAILED + 1)); return 0 ;;
  esac
  if [ -n "$must" ] && ! printf '%s' "$out" | grep -qF "$must"; then
    printf '\n!! %s exited %d but never printed "%s". It did not do its job.\n' "$label" "$rc" "$must"
    FAILED=$((FAILED + 1))
  fi
  return 0
}

hr "FLAGSHIP RUNNABLE EXAMPLES (loops 1, 19, 28)"
echo "- loop 1 docs sync:"
run "loop 1 check" "0 1" "docs" bash loop-packs/engineering-loops/loops/01-docs-and-examples-sync/check.sh
echo "- loop 19 eval harness:"
run "loop 19 evals" "0 3" "accuracy" bash -c 'cd loop-packs/ai-ml-loops/loops/19-eval-suite-on-prompt-or-model-change/example && node run-evals.js'
echo "- loop 28 flaky detector:"
run "loop 28 detector" "0 1" "ran each test" bash -c 'cd loop-packs/qa-loops/loops/28-flaky-test-detection-and-quarantine/example && node detect-flaky.js'

hr "ENGINEERING (loops 2, 4, 5, 6, 7)"
npm install --prefix loop-packs/engineering-loops/demo-app --silent --no-audit --no-fund >/dev/null 2>&1 \
  || echo "(npm install skipped, loop 2 and 5 may show less)"
run "engineering demo-app" "1" "loop(s) found work" bash -c 'cd loop-packs/engineering-loops/demo-app && node loops.js all'

hr "AI AND ML (loops 20-26)"
run "ai-ml demo-app" "1" "loop(s) found work" bash -c 'cd loop-packs/ai-ml-loops/demo-app && node loops.js all'

hr "QA (loops 27, 30, 33, 34)"
run "qa demo-app" "1" "loop(s) found work" bash -c 'cd loop-packs/qa-loops/demo-app && node loops.js all'

hr "CLOUD (loops 10-18, offline dry run)"
for d in loop-packs/cloud-loops/loops/*/; do
  printf "%-44s " "$(basename "$d")"
  run "cloud $(basename "$d")" "0 1" "" bash -c "cd loop-packs/cloud-loops && DRY_RUN=1 bash 'loops/$(basename "$d")/check.sh'"
done

if [ "$FAILED" -ne 0 ]; then
  hr "BROKEN"
  echo "$FAILED demo(s) did not behave as documented. This is a real failure, not 'found work'."
  exit 1
fi

hr "DONE"
echo "That was all four chapters finding real work in seeded data."
echo
echo "Next:"
echo "  What you just watched   docs/01-what-is-a-loop.md"
echo "  Run one on your repo    docs/04-your-first-loop.md   (10 minutes, a real PR)"
echo "  Browse all 35           README.md"
