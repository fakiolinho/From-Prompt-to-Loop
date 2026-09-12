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
