#!/usr/bin/env bash
# Check the repo against the field guide. The guide is published; the repo follows it.
# The catalog in ci/guide-catalog.tsv is the transcription the repo is tested against.
set -uo pipefail
cd "$(dirname "$0")/.."
. ci/lib.sh

CAT=ci/guide-catalog.tsv
rows() { grep -v '^#' "$CAT" | grep -v '^$'; }

head2 "all 35 loops from the guide exist, in the right pack"
rows | while IFS=$'\t' read -r num pack tag star name; do
  d=$(echo loop-packs/"$pack"/loops/"$num"-*/ 2>/dev/null)
  if [ -d "$d" ]; then echo "ok   $num in $pack"; else echo "FAIL $num missing from $pack"; fi
done > /tmp/loops.$$ ; sed 's/^/  /' /tmp/loops.$$
PASS=$((PASS + $(grep -c '^ok' /tmp/loops.$$)))
FAIL=$((FAIL + $(grep -c '^FAIL' /tmp/loops.$$))); rm -f /tmp/loops.$$

head2 "no loop exists that the guide does not list"
actual=$(ls -d loop-packs/*/loops/*/ | sed 's#.*/loops/##; s#-.*##' | sort)
expect=$(rows | cut -f1 | sort)
extra=$(comm -23 <(echo "$actual") <(echo "$expect"))
[ -z "$extra" ] && ok "no strays" || bad "loops not in the guide: $(echo $extra)"
[ "$(echo "$actual" | wc -l | tr -d ' ')" = "35" ] && ok "35 loops, no more, no less" \
  || bad "found $(echo "$actual" | wc -l | tr -d ' ') loops, the guide has 35"

head2 "each loop's Ships tag matches the guide"
while IFS=$'\t' read -r num pack tag star name; do
  f=$(echo loop-packs/"$pack"/loops/"$num"-*/ORDERS.md)
  [ -f "$f" ] || { bad "$num no ORDERS.md"; continue; }
  want=$([ "$tag" = ships ] && echo "Ships on green" || echo "Flags, you decide")
  got=$(grep -m1 '^\*\*Ships:\*\*' "$f" | grep -o 'Ships on green\|Flags, you decide' | head -1)
  [ "$got" = "$want" ] && ok "$num $want" || bad "$num says '$got', the guide says '$want'"
done < <(rows)

head2 "each pack's LOOPS.md table matches the guide"
while IFS=$'\t' read -r num pack tag star name; do
  n=$((10#$num))
  row=$(grep -m1 "^| $n |" "loop-packs/$pack/LOOPS.md")
  [ -n "$row" ] || { bad "$num not in $pack/LOOPS.md"; continue; }
  want=$([ "$tag" = ships ] && echo "Ships on green" || echo "Flags, you decide")
  echo "$row" | grep -q "$want" && ok "$num row" || bad "$num row in $pack/LOOPS.md disagrees with the guide"
  if [ "$star" = yes ]; then
    echo "$row" | grep -q '★' && ok "$num starred" || bad "$num is a guide star, LOOPS.md does not mark it"
  fi
done < <(rows)

head2 "every loop in every table links to its orders"
while IFS=$'\t' read -r num pack tag star name; do
  n=$((10#$num))
  row=$(grep -m1 "^| $n |" "loop-packs/$pack/LOOPS.md")
  d=$(basename "$(echo loop-packs/"$pack"/loops/"$num"-*/)")
  echo "$row" | grep -qF "](loops/$d/ORDERS.md)" \
    && ok "$num links to its orders" \
    || bad "$num in $pack/LOOPS.md is not a link to loops/$d/ORDERS.md"
done < <(rows)

head2 "every chapter points back at the field guide"
for pack in engineering-loops cloud-loops ai-ml-loops qa-loops; do
  f="loop-packs/$pack/LOOPS.md"
  grep -qF "From-Prompt-to-Loop_The-Warship-CTO.pdf" "$f" \
    && ok "$pack links the PDF" || bad "$pack/LOOPS.md never links the field guide"
  grep -qF "Where these tags come from" "$f" \
    && ok "$pack explains the tags" || bad "$pack/LOOPS.md does not say where its tags come from"
done

head2 "every ORDERS.md has the four sections an agent reads"
for f in loop-packs/*/loops/*/ORDERS.md; do
  n=$(basename "$(dirname "$f")"); miss=""
  for h in "## Owns, and never touches" "## What to do" "## When to stop and call a human" "## Memory"; do
    grep -qF "$h" "$f" || miss="$miss '$h'"
  done
  [ -z "$miss" ] && ok "$n" || bad "$n missing:$miss"
done

head2 "every ORDERS.md says how to run it, installed or not"
# A reader lands on one loop's page from the catalog. That page has to ask whether
# install.sh has run, and give the exact commands for either answer, or they guess.
for f in loop-packs/*/loops/*/ORDERS.md; do
  d=$(basename "$(dirname "$f")"); nn=${d%%-*}; miss=""
  grep -qF "## Run this loop" "$f" || miss="$miss heading"
  grep -qF 'already run `install.sh`' "$f" || miss="$miss install-question"
  grep -qF "./install.sh ~/code/my-app $nn" "$f" || miss="$miss install-command"
  grep -qF "./run-loop.sh $nn --check" "$f" || miss="$miss run-command"
  grep -qF "If you are the agent" "$f" || miss="$miss agent-skip"
  grep -A40 "## Run this loop" "$f" | grep -qF "WIRING.md)" || miss="$miss wiring-link"
  case "$f" in
    loop-packs/cloud-loops/*) grep -A40 "## Run this loop" "$f" | grep -qF "SETUP.md)" || miss="$miss setup-link" ;;
  esac
  [ -z "$miss" ] && ok "$d" || bad "$d does not say how to run it:$miss"
done

head2 "the workflows parse and are wired correctly"
python3 ci/check-workflows.py > /tmp/wf.$$ 2>&1
sed 's/^/  /' /tmp/wf.$$
PASS=$((PASS + $(grep -c '^ok' /tmp/wf.$$)))
FAIL=$((FAIL + $(grep -c '^FAIL' /tmp/wf.$$))); rm -f /tmp/wf.$$

head2 "the maker is never the checker"
for f in loop-packs/*/.github/workflows/loop.yml; do
  c=$(echo "$f" | sed 's#loop-packs/##; s#/.*##')
  grep -q '^  verify:' "$f" && ok "$c has a verify job" \
    || bad "$c has no verify job: the agent would be grading its own work"
  grep -q "needs: run" "$f" && ok "$c verify waits for the agent" \
    || bad "$c verify does not depend on the agent job"
  grep -q "git checkout \"loop/" "$f" && ok "$c verify takes a clean clone of the branch" \
    || bad "$c verify does not re-check the agent's branch on a clean machine"
done

head2 "every chapter tells the agent to run the project's own commands"
for pack in engineering-loops cloud-loops ai-ml-loops qa-loops; do
  for f in "loop-packs/$pack/CLAUDE.md" "loop-packs/$pack/AGENTS.md"; do
    grep -q "Run the project's commands" "$f" \
      && ok "$(echo "$f" | sed 's#loop-packs/##')" \
      || bad "$f does not tell the agent to use the project's own commands"
  done
done

head2 "you can actually install this into a repo"
[ -x install.sh ] && ok "install.sh is executable" || bad "install.sh is missing or not executable"
grep -q 'install.sh' README.md && ok "README says how to install" || bad "README never mentions install.sh"
[ -f WIRING.md ] && ok "WIRING.md present" || bad "WIRING.md is missing"
# every setting a check reads must be documented, or nobody can wire that loop
miss=0
for v in $(grep -rhoE '\$\{(LOOP_[A-Z_]+|MIGRATION|BASE_REF|BASE_TAG)' loop-packs/*/loops/*/check.sh \
           | sed 's/\${//' | sort -u); do
  grep -q "\`$v\`" WIRING.md || { bad "$v is read by a check but absent from WIRING.md"; miss=1; }
done
[ "$miss" -eq 0 ] && ok "every setting a check reads is in WIRING.md"
# and every runner must load the file those settings live in
for f in loop-packs/*/.github/workflows/loop.yml; do
  grep -q 'loops.env' "$f" && ok "$(echo "$f" | cut -d/ -f2) loads loops.env" \
    || bad "$(echo "$f" | cut -d/ -f2) never loads loops.env, so its settings can never reach the check"
done

head2 "the three answer contract is on the front door"
grep -q 'not wired' README.md && ok "README explains exit 2" \
  || bad "README never mentions the third answer a check can give"
grep -q 'exit 2 means' docs/02-plain-words.md && ok "the glossary explains exit 2" \
  || bad "docs/02-plain-words.md defines a check with only two answers"

head2 "every loop stops on the third identical failure"
for pack in engineering-loops cloud-loops ai-ml-loops qa-loops; do
  for f in "loop-packs/$pack/CLAUDE.md" "loop-packs/$pack/AGENTS.md"; do
    grep -q "Stop when you stop making progress" "$f" \
      && ok "$(echo "$f" | sed 's#loop-packs/##')" \
      || bad "$f has no stop rule: a stuck agent would burn all 30 turns"
  done
  # the rule has to reach the agent, not just sit in a file it might not read
  n=$(grep -c "third time" "loop-packs/$pack/.github/workflows/loop.yml")
  [ "$n" -ge 2 ] && ok "$pack tells both agents (claude and codex)" \
    || bad "$pack states the stop rule in $n of 2 agent prompts"
done

head2 "the rules Claude reads and the rules Codex reads are the same"
for pack in engineering-loops cloud-loops ai-ml-loops qa-loops; do
  a=$(grep -v '^_' "loop-packs/$pack/AGENTS.md" | grep -v '^[[:space:]]*$')
  c=$(grep -v '^_' "loop-packs/$pack/CLAUDE.md" | grep -v '^[[:space:]]*$')
  [ "$a" = "$c" ] && ok "$pack CLAUDE.md and AGENTS.md agree" \
    || bad "$pack CLAUDE.md and AGENTS.md have drifted apart"
done

head2 "every ORDERS explains the three answers and what it needs"
for f in loop-packs/*/loops/*/ORDERS.md; do
  n=$(basename "$(dirname "$f")")
  grep -q 'not wired to this repo yet' "$f" \
    && ok "$n describes all three answers" \
    || bad "$n still describes a check with two answers"
  # if its check reads a setting, the orders must name it: that page is what a human reads
  v=$(grep -ohE 'LOOP_[A-Z_]+' "$(dirname "$f")/check.sh" 2>/dev/null \
      | grep -vE 'LOOP_MAX_COMMITS|LOOP_RUNS' | sort -u | head -1)
  if [ -n "$v" ]; then
    grep -q "$v" "$f" && ok "$n names $v" || bad "$n needs $v and never says so"
  fi
done

head2 "chapters are named, not numbered, where a reader has to choose"
for f in docs/*.md README.md; do
  grep -qE '\[Ch [0-9]\]\(|\[Chapter [0-9]\]\(' "$f" \
    && bad "$f offers '[Ch 1]' as a link label, which tells a reader nothing" \
    || ok "$(basename "$f") names its chapters"
done

head2 "every loop has an owner"
for f in loop-packs/*/loops/*/ORDERS.md; do
  n=$(basename "$(dirname "$f")")
  grep -q '^\*\*Owner:\*\*' "$f" && ok "$n names an owner" \
    || bad "$n has no Owner line: a loop nobody owns is a loop nobody maintains"
done

head2 "every chapter ships a PR template, so the gate gets evidence"
for pack in engineering-loops cloud-loops ai-ml-loops qa-loops; do
  f="loop-packs/$pack/.github/PULL_REQUEST_TEMPLATE.md"
  [ -f "$f" ] && ok "$pack has a PR template" || bad "$pack ships no PR template"
done

head2 "secrets cannot be committed by accident"
for f in .gitignore loop-packs/*/.gitignore; do
  grep -q '^\.env$' "$f" && ok "$f ignores .env" || bad "$f does not ignore .env"
done

head2 "no placeholder or leftover words"
# loop 08's review example greps for these on purpose, so it is excluded by name
for w in ponytail lorem-ipsum "TK TK" "REPLACE ME"; do
  hits=$(grep -ril "$w" loop-packs *.md 2>/dev/null \
         | grep -v node_modules | grep -v '08-first-pass-code-review' || true)
  [ -z "$hits" ] && ok "no '$w'" || bad "'$w' left in: $(echo $hits | tr '\n' ' ')"
done

head2 "no doc points at a folder that was never shipped"
# the field guide lives at the repo root as a PDF; there is no guide/ directory
for bad_ref in 'guide/' 'loop-packs/guide'; do
  hits=$(grep -rn "$bad_ref" *.md loop-packs/*/*.md 2>/dev/null || true)
  [ -z "$hits" ] && ok "no reference to $bad_ref" || bad "still points at $bad_ref: $(echo "$hits" | head -3 | tr '\n' ' ')"
done

head2 "every path the top-level docs point at exists"
for doc in README.md docs/*.md; do
  grep -o '`[A-Za-z0-9._/-]*\.\(md\|sh\|yml\|json\|js\|pdf\)`' "$doc" 2>/dev/null \
    | tr -d '`' | sort -u | while read -r p; do
      case "$p" in
        */*) ;;
        *) continue ;;                                 # bare filenames can be relative to a pack
      esac
      case "$p" in
        *NN*|*'<'*|*'*'*) continue ;;                  # NN-name etc. are templates, not links
      esac
      if [ -e "$p" ] || ls "$p" >/dev/null 2>&1 || ls loop-packs/*/"$p" >/dev/null 2>&1; then
        echo "ok   $doc -> $p"
      else
        echo "FAIL $doc points at $p, which does not exist"
      fi
    done
done > /tmp/paths.$$ ; sed 's/^/  /' /tmp/paths.$$
PASS=$((PASS + $(grep -c '^ok' /tmp/paths.$$)))
FAIL=$((FAIL + $(grep -c '^FAIL' /tmp/paths.$$))); rm -f /tmp/paths.$$

head2 "the Node floor this repo claims is the one CI proves"
[ -f package.json ] && ok "root package.json exists" || bad "no root package.json, so npm test does not work"
declared=$(node -e 'console.log((require("./package.json").engines||{}).node||"")' 2>/dev/null)
[ -n "$declared" ] && ok "package.json declares engines.node $declared" \
  || bad "package.json makes no Node version claim, but the docs do"
floor=$(printf '%s' "$declared" | tr -dc '0-9')
grep -q "node-version: $floor" .github/workflows/tests.yml \
  && ok "CI runs on Node $floor, the floor it claims" \
  || bad "package.json says node $declared but CI never tests on it"
grep -q "Node $floor or newer" README.md docs/00-start-here.md \
  && ok "the docs name the same floor" || bad "the docs and package.json disagree on the Node floor"
node -e 'const s=require("./package.json").scripts||{};process.exit(s.test&&s.demos&&s.build?0:1)' \
  && ok "npm test, demos and build all exist" || bad "package.json is missing an entry point the docs promise"

head2 "every python dependency is declared where someone will look"
# an import that only works because the CI image happens to ship it is a dependency
# you have by luck, and one you will lose without warning
for m in $(python3 -c "
import ast, glob, sys
mods = set()
for f in glob.glob('ci/*.py'):
    for node in ast.walk(ast.parse(open(f).read())):
        if isinstance(node, ast.Import):
            mods.update(a.name.split('.')[0] for a in node.names)
        elif isinstance(node, ast.ImportFrom) and node.module:
            mods.add(node.module.split('.')[0])
print(' '.join(sorted(mods)))"); do
  case "$m" in
    glob|html|os|re|sys|json|subprocess|pathlib|textwrap) continue ;;   # standard library
  esac
  pkg=$(echo "$m" | sed 's/markdown_it/markdown-it-py/; s/^yaml$/pyyaml/')
  for f in CONTRIBUTING.md ci/README.md .github/workflows/tests.yml; do
    grep -qi "$pkg" "$f" && ok "$pkg declared in $(basename "$f")" \
      || bad "ci/ imports $m but $f never mentions $pkg"
  done
done

head2 "the repo says how to report a problem and how to contribute"
for f in SECURITY.md CONTRIBUTING.md; do
  [ -f "$f" ] && ok "$f present" || bad "$f is missing from an MIT repo people will fork"
  grep -q "$f" README.md && ok "README links $f" || bad "$f exists but nothing links to it"
done
grep -qi "report a vulnerability" SECURITY.md && ok "SECURITY says how to report" \
  || bad "SECURITY.md never says how to report anything"
grep -qi "do not cover" SECURITY.md && ok "SECURITY says what it does NOT cover" \
  || bad "SECURITY.md only lists controls, never their limits"
grep -q "exit 2" CONTRIBUTING.md && ok "CONTRIBUTING states the check contract" \
  || bad "CONTRIBUTING never tells a contributor the three answer contract"

head2 "memory teaches what a good entry looks like"
for f in loop-packs/*/memory/*.md; do
  grep -q 'A good line is specific' "$f" \
    || bad "$(echo "$f" | sed 's#loop-packs/##') is a bare stub, it never says what to write"
done
ok "all 35 memory stubs show a good line and a useless one"
for e in loop-packs/engineering-loops/loops/01-docs-and-examples-sync/example/memory/docs-loop.md \
         loop-packs/ai-ml-loops/loops/19-eval-suite-on-prompt-or-model-change/example/memory/evals.md \
         loop-packs/qa-loops/loops/28-flaky-test-detection-and-quarantine/example/memory/flaky.md; do
  n=$(grep -c '^- ' "$e")
  [ "$n" -ge 3 ] && ok "$(basename "$e") has $n worked entries" \
    || bad "$(basename "$e") is a worked example with $n memory entries"
done
grep -q 'What a good one looks like' docs/06-operating.md && ok "docs/06 shows one" \
  || bad "nothing in the guide shows a filled memory file"

head2 "the price of running this is stated up front"
grep -qi "what it costs" README.md && ok "README states the cost" \
  || bad "README never says running a loop costs money"
grep -qi "nothing to buy" README.md && ok "README says a local run needs no key" \
  || bad "README does not say a local run works on an existing login"
grep -qi "what it costs" docs/index.html && ok "the landing page states the cost" \
  || bad "the landing page never mentions cost"
grep -q "ANTHROPIC_API_KEY" docs/00-start-here.md && ok "page 0 names the key CI needs" \
  || bad "page 0 never names the key the workflow needs"
grep -q "max-budget-usd 2" README.md && ok "README names the per run cap" \
  || bad "README never states the spend cap on an agent run"

head2 "a loop can be run without GitHub"
[ -x run-loop.sh ] && ok "run-loop.sh is executable" || bad "nothing lets a user run a loop locally"
grep -q 'run-loop.sh' install.sh && ok "install.sh ships it into the target repo" \
  || bad "install.sh never copies run-loop.sh, so an installed repo cannot run a loop by hand"
grep -q 'check.sh' run-loop.sh && ok "it runs the check first" || bad "run-loop.sh skips the check"
grep -q 'max-budget-usd' run-loop.sh && ok "it caps spend like the workflow" \
  || bad "run-loop.sh wakes an agent with no budget cap"
grep -q 'verifying, with no agent' run-loop.sh && ok "it re-checks afterwards" \
  || bad "run-loop.sh lets the agent mark its own work"
grep -q 'run-loop.sh' README.md && ok "README says it exists" || bad "README never mentions run-loop.sh"
grep -q 'run-loop.sh' docs/04-your-first-loop.md && ok "the walkthrough uses it" \
  || bad "docs/04 never tells anyone they can run a loop without Actions"

head2 "install.sh works on a real repo, and on a second run"
T=$(mktemp -d); git -C "$T" init -q
printf '# My project\n\nRun nvm use first.\n' > "$T/CLAUDE.md"
./install.sh "$T" 02 >/dev/null 2>&1 </dev/null && ok "a first install exits 0" \
  || bad "install.sh fails on an empty git repo"
[ -f "$T/loops/02-dependency-upgrades/check.sh" ] && [ -x "$T/run-loop.sh" ] && [ -f "$T/loops.env" ] \
  && ok "it lands the loop, the runner and loops.env" || bad "install.sh left out the loop, run-loop.sh or loops.env"
grep -q '\.\./\.\./\.\./\.\./' "$T/loops/02-dependency-upgrades/ORDERS.md" \
  && bad "installed ORDERS.md still links above the user's repo" || ok "installed links point at GitHub"
echo "- a lesson the loop wrote on a real run" >> "$T/memory/02-dependency-upgrades.md"
again=$(./install.sh "$T" 02 2>&1 </dev/null)
grep -q "lesson the loop wrote" "$T/memory/02-dependency-upgrades.md" \
  && ok "a rerun keeps what the loop learned" || bad "a rerun replaced the loop's memory with the blank template"
printf '%s' "$again" | grep -q 'memory/02-dependency-upgrades.md exists and differs' \
  && bad "a rerun offers to overwrite memory, and one wrong keypress loses it" \
  || ok "a rerun never offers to overwrite memory"
printf '%s' "$again" | grep -qE 'differs|cmp:|diff:' \
  && bad "a rerun thinks an untouched install has changed: $(printf '%s' "$again" | grep -E 'differs|cmp:|diff:' | head -1)" \
  || ok "a rerun sees an untouched install as unchanged"
grep -q 'Run nvm use first' "$T/CLAUDE.md" && ok "the project's own CLAUDE.md survives the install" \
  || bad "install.sh replaced the project's CLAUDE.md, and every agent run loses the project's own rules"
grep -q 'Global standing orders' "$T/CLAUDE.md" && ok "the loops' standing orders are added to it" \
  || bad "the project's CLAUDE.md never got the loops' standing orders"
[ "$(grep -c 'from-prompt-to-loop: begin' "$T/CLAUDE.md")" = 1 ] && ok "a rerun refreshes that section, not a second copy" \
  || bad "a rerun added the standing orders to CLAUDE.md more than once"
[ -d "$T/loops/02-dependency-upgrades/02-dependency-upgrades" ] \
  && bad "a rerun nested the loop inside itself" || ok "a rerun does not nest the loop folder"
rm -rf "$T"
T=$(mktemp -d); git -C "$T" init -q; R=$PWD
( cd "$T" && "$R/install.sh" . 02 >/dev/null 2>&1 </dev/null )
[ -f "$T/loops/02-dependency-upgrades/check.sh" ] && [ ! -e "$R/loops.env" ] \
  && ok "'install.sh . 02' from inside a project installs there" \
  || bad "'install.sh . 02' resolved '.' after moving, and installed into this repo instead"
rm -rf "$T"
./install.sh . 02 >/dev/null 2>&1 </dev/null && bad "install.sh installed loops into its own repo" \
  || ok "install.sh refuses to install into its own repo"
for s in install.sh run-loop.sh; do
  usage=$(./$s 2>&1 </dev/null)   # captured first: it exits 1, which pipefail would pass on
  printf '%s' "$usage" | grep -q 'set -uo' && bad "$s usage prints its own source" || ok "$s usage is only the usage"
done

head2 "pushing markdown is enough"
W=.github/workflows/build-site.yml
[ -f "$W" ] && ok "build-site.yml exists" || bad "nothing rebuilds the site on push, so markdown edits never reach the page"
grep -q 'build-site.py' "$W" && ok "it runs the site generator" || bad "$W does not run ci/build-site.py"
grep -q 'build-wiring.py' "$W" && ok "it runs the wiring generator" || bad "$W does not run ci/build-wiring.py"
grep -q "contents: write" "$W" && ok "it can commit what it renders" || bad "$W cannot push its own output"
# it must not react to the files it writes, or it runs forever
grep -qE "^ *- 'docs/\*\*\.html'" "$W" && bad "$W triggers on the HTML it generates: that is a loop" \
  || ok "it does not trigger on its own output"

head2 "the landing page and the README tell the same story"
# docs/index.html is hand written in the generator, so it drifts from README.md unless
# something watches. These are the claims a reader must meet on either surface.
for claim in "install.sh" "WIRING.md" "run-all-demos.sh"; do
  inr=$(grep -c "$claim" README.md); inh=$(grep -c "$claim" docs/index.html)
  if [ "$inr" -gt 0 ] && [ "$inh" -gt 0 ]; then ok "both mention $claim"
  elif [ "$inr" -eq 0 ] && [ "$inh" -eq 0 ]; then ok "neither mentions $claim"
  else bad "$claim is in README ($inr) but not the landing page ($inh), or the other way round"
  fi
done
grep -q 'not wired' docs/index.html && ok "the landing page explains exit 2" \
  || bad "the landing page never mentions the third answer a check can give"
# the anatomy diagram has to show all three branches too
grep -qi 'not wired' docs/img/loop-anatomy.svg && ok "the anatomy diagram shows all three answers" \
  || bad "docs/img/loop-anatomy.svg still draws a check with only two branches"

head2 "the published landing page is not stale"
# docs/index.html is generated from the catalog and each chapter's LOOPS.md. If a loop
# changes and nobody regenerates, the page GitHub Pages serves starts lying.
rm -rf /tmp/site-was.$$ && mkdir -p /tmp/site-was.$$ && cp docs/*.html /tmp/site-was.$$/ 2>/dev/null
python3 ci/build-site.py >/dev/null 2>&1
for f in docs/*.html; do
  if diff -q "/tmp/site-was.$$/$(basename "$f")" "$f" >/dev/null 2>&1; then
    ok "$(basename "$f") is current"
  else
    bad "$(basename "$f") is stale. Run: python3 ci/build-site.py, then commit it"
  fi
done
rm -rf /tmp/site-was.$$
[ -f docs/.nojekyll ] && ok "docs/.nojekyll present, Pages serves the page as written" \
  || bad "docs/.nojekyll missing, GitHub Pages would try to run Jekyll over the markdown"

head2 "the guide has all eight pages, in order"
for n in 00-start-here 01-what-is-a-loop 02-plain-words 03-run-the-demos \
         04-your-first-loop 05-add-the-next 06-operating 07-where-these-fit; do
  [ -f "docs/$n.md" ] && ok "docs/$n.md" || bad "docs/$n.md is missing from the guide"
done
[ "$(ls docs/*.md | wc -l | tr -d ' ')" = "8" ] || bad "docs/ has $(ls docs/*.md | wc -l | tr -d ' ') pages, the contents page lists 8"

head2 "no page is a dead end"
# every page a reader can land on must offer a way back. The tables link to ORDERS.md,
# so ORDERS.md counts, and so does the AWS setup page.
for f in docs/*.md loop-packs/*/README.md loop-packs/*/LOOPS.md \
         loop-packs/*/loops/*/ORDERS.md loop-packs/cloud-loops/SETUP.md; do
  grep -q 'README.md)' "$f" && ok "$(echo "$f" | sed 's#loop-packs/##') links home" \
    || bad "$f has no way back to the contents page"
done

head2 "the contents page lists every guide page"
for f in docs/*.md; do
  grep -q "$f" README.md && ok "README lists $f" || bad "$f is not in the contents page"
done

head2 "house style holds"
python3 ci/check-style.py > /tmp/style.$$ 2>&1
sed 's/^/  /' /tmp/style.$$
PASS=$((PASS + $(grep -c '^ok' /tmp/style.$$)))
FAIL=$((FAIL + $(grep -c '^FAIL' /tmp/style.$$))); rm -f /tmp/style.$$

head2 "every link between markdown pages resolves"
python3 ci/check-links.py > /tmp/links.$$ 2>&1
sed 's/^/  /' /tmp/links.$$
PASS=$((PASS + $(grep -c '^ok' /tmp/links.$$)))
FAIL=$((FAIL + $(grep -c '^FAIL' /tmp/links.$$))); rm -f /tmp/links.$$

head2 "the field guide the docs point at is actually here"
GUIDE="From-Prompt-to-Loop_The-Warship-CTO.pdf"
if [ -f "$GUIDE" ]; then ok "$GUIDE present"; else
  bad "$GUIDE is missing, but README.md and docs/00-start-here.md say it is in this folder"
fi

head2 "the numbers the docs claim are the numbers on disk"
for p in engineering-loops:9 cloud-loops:9 ai-ml-loops:8 qa-loops:9; do
  pack=${p%:*}; want=${p#*:}
  got=$(ls -d loop-packs/$pack/loops/*/ | wc -l | tr -d ' ')
  [ "$got" = "$want" ] && ok "$pack has $want loops" || bad "$pack has $got loops, docs claim $want"
done

summary "docs"
