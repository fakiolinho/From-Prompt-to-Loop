#!/usr/bin/env bash
# Put loops into your own repo.
#
#   ./install.sh ~/code/my-app 02                 one loop, by number
#   ./install.sh ~/code/my-app 02 06 07           several
#   ./install.sh ~/code/my-app engineering        a whole chapter
#
# It copies the loop, the standing orders, the runner and the PR template, then writes
# a loops.env listing exactly the settings those loops need. Nothing is overwritten
# without asking. Run it again later to add more.
set -uo pipefail
cd "$(dirname "$0")"
HERE=$(pwd)

TARGET="${1:-}"; shift 2>/dev/null || true
[ -n "$TARGET" ] || { sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }
[ -d "$TARGET" ] || { echo "no such directory: $TARGET"; exit 1; }
[ $# -gt 0 ] || { echo "name at least one loop (02) or a chapter (engineering)"; exit 1; }
TARGET=$(cd "$TARGET" && pwd)
git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1 || { echo "$TARGET is not a git repo"; exit 1; }

chapter_of() { case "$1" in engineering*) echo engineering-loops;; cloud*) echo cloud-loops;;
  ai*|ml*) echo ai-ml-loops;; qa*|test*) echo qa-loops;; *) echo "";; esac; }

# Resolve the arguments into a list of "pack/loop-folder"
picks=""
for arg in "$@"; do
  ch=$(chapter_of "$arg")
  if [ -n "$ch" ]; then
    for d in loop-packs/"$ch"/loops/*/; do picks="$picks $ch/$(basename "$d")"; done
    continue
  fi
  n=$(printf '%02d' "$((10#${arg%%-*}))" 2>/dev/null || echo "$arg")
  found=""
  for d in loop-packs/*/loops/"$n"-*/; do
    [ -d "$d" ] || continue
    found="$(echo "$d" | cut -d/ -f2)/$(basename "$d")"
  done
  [ -n "$found" ] || { echo "no loop matches '$arg'"; exit 1; }
  picks="$picks $found"
done

copy() { # copy src dst, never clobber your work without asking
  if [ -e "$2" ] && ! cmp -s "$1" "$2"; then
    if [ -t 0 ]; then
      printf '  %s exists and differs. Overwrite? [y/N] ' "${2#$TARGET/}"
      read -r a || a=n
      case "$a" in y|Y) ;; *) echo "    kept yours"; return;; esac
    else
      echo "  ${2#$TARGET/} exists and differs, kept yours (rerun in a terminal to choose)"
      return
    fi
  fi
  mkdir -p "$(dirname "$2")"; cp -R "$1" "$2"; echo "  ${2#$TARGET/}"
}

packs=$(for p in $picks; do echo "${p%%/*}"; done | sort -u)
primary=$(echo $picks | awk '{print $1}' | cut -d/ -f1)
extra=$(echo "$packs" | grep -v "^$primary$" || true)

echo "Installing into $TARGET"
echo; echo "shared files, from $primary:"
copy "$HERE/loop-packs/$primary/CLAUDE.md"  "$TARGET/CLAUDE.md"
copy "$HERE/loop-packs/$primary/AGENTS.md"  "$TARGET/AGENTS.md"
copy "$HERE/loop-packs/$primary/.github/workflows/loop.yml" "$TARGET/.github/workflows/loop.yml"
copy "$HERE/loop-packs/$primary/.github/PULL_REQUEST_TEMPLATE.md" "$TARGET/.github/PULL_REQUEST_TEMPLATE.md"
[ -d "$HERE/loop-packs/$primary/lib" ] && copy "$HERE/loop-packs/$primary/lib" "$TARGET/lib"
copy "$HERE/run-loop.sh" "$TARGET/run-loop.sh"

if [ -n "$extra" ]; then
  echo
  echo "  Note: you also picked loops from:$(echo $extra | sed 's/^/ /')"
  echo "  Each chapter has its own law in CLAUDE.md, and only one can sit at your repo root."
  echo "  The $primary one is installed. Open these and merge in the sections you want:"
  for e in $extra; do echo "    loop-packs/$e/CLAUDE.md"; done
  echo "  Easiest path: adopt one chapter, prove it, then add the next. See docs/05-add-the-next.md."
fi

first=$(echo $picks | awk '{print $1}' | cut -d/ -f2)
REPO_URL="https://github.com/fakiolinho/From-Prompt-to-Loop/blob/main"

# ORDERS.md carries links that only resolve inside this repo. Four levels up from
# loop-packs/<chapter>/loops/<loop>/ is our root; from <your-repo>/loops/<loop>/ it is
# somewhere above your project. Point them at GitHub instead, so they work where they land.
relink() {
  f="$1"
  [ -f "$f" ] || return 0
  sed -i.bak \
    -e "s#\.\./\.\./\.\./\.\./README\.md#$REPO_URL/README.md#g" \
    -e "s#\.\./\.\./\.\./\.\./docs/#$REPO_URL/docs/#g" \
    -e "s#\.\./\.\./LOOPS\.md#$REPO_URL/loop-packs/PACKNAME/LOOPS.md#g" \
    -e "s#\.\./\.\./\.\./\.\./WIRING\.md#$REPO_URL/WIRING.md#g" \
    "$f" && rm -f "$f.bak"
  sed -i.bak "s#PACKNAME#$2#g" "$f" && rm -f "$f.bak"
}

echo; echo "loops:"
for p in $picks; do
  pack="${p%%/*}"; loop="${p#*/}"
  copy "$HERE/loop-packs/$pack/loops/$loop" "$TARGET/loops/$loop"
  copy "$HERE/loop-packs/$pack/memory/$loop.md" "$TARGET/memory/$loop.md"
  relink "$TARGET/loops/$loop/ORDERS.md" "$pack"
done

# loops.env: exactly the settings these loops read, with the example from each check
ENV="$TARGET/loops.env"
[ -f "$ENV" ] || printf '%s\n' \
  '# Settings for the loops in this repo. The runner loads this before every check.' \
  '# A loop whose setting is missing exits 2 and says so, rather than guessing.' \
  '#' \
  '# Commit this file. These are commands, not secrets, and CI has to read it.' \
  '# Secrets go in Settings > Secrets and variables > Actions, never here.' > "$ENV"
# Write every setting these loops can read into loops.env, commented out.
for p in $picks; do
  pack="${p%%/*}"; loop="${p#*/}"; chk="$HERE/loop-packs/$pack/loops/$loop/check.sh"
  vars=$(grep -ohE '\$\{(LOOP_[A-Z_]+|MIGRATION|BASE_REF|BASE_TAG)(:-[^}]*)?\}' "$chk" 2>/dev/null \
         | sed -E 's/\$\{([A-Z_]+).*/\1/' | sort -u)
  [ -n "$vars" ] || continue
  grep -q "^## loop ${loop%%-*}:" "$ENV" && continue
  { echo; echo "## loop ${loop%%-*}: ${loop#*-}"; } >> "$ENV"
  n=$(echo $vars | wc -w | tr -d ' ')
  [ "$n" -gt 1 ] && echo "# any one of these wires it:" >> "$ENV"
  for v in $vars; do
    ex=$(grep -oE "$v='[^']*'" "$chk" | head -1 | sed "s/^$v=//")
    echo "# $v=${ex:-}" >> "$ENV"
  done
done

# Now ask the loops themselves, in this repo, rather than guessing from the source.
echo; echo "where each loop stands in your repo right now:"
ready=0; wants=0; suggest=""
for p in $picks; do
  loop="${p#*/}"
  out=$( cd "$TARGET" && bash "loops/$loop/check.sh" 2>&1 ); rc=$?
  case "$rc" in
    0) printf '  %-46s nothing to do\n'  "${loop}"; ready=$((ready+1))
       [ -z "${suggest:-}" ] && suggest="${loop%%-*}" ;;
    1) printf '  %-46s THERE IS WORK\n'  "${loop}"; ready=$((ready+1))
       suggest="${loop%%-*}" ;;
    *) printf '  %-46s %s\n' "${loop}" "$(printf '%s' "$out" | head -1 | cut -c1-46)"; wants=$((wants+1)) ;;
  esac
done
echo
echo "  $ready ready to run, $wants waiting on a line in loops.env"

cat <<EOF

Installed. Now run one, right here, before you touch GitHub:

  cd $TARGET
  ./run-loop.sh ${suggest:-${first%%-*}} --check     just ask: is there work?
  ./run-loop.sh ${suggest:-${first%%-*}}             and hand it to Claude if there is

  0 = nothing to do    1 = there is work    2 = not wired yet, and it says what it needs

Anything that says 2 wants a line in loops.env. Every setting is listed there,
commented out with an example. WIRING.md has the full reference.

When you want it running without you, three more things:

  1. Commit loops.env and the loops/ folder.
  2. Add ANTHROPIC_API_KEY (or OPENAI_API_KEY) in
     Settings > Secrets and variables > Actions.
  3. Settings > Actions > General > Workflow permissions:
     turn on "Allow GitHub Actions to create and approve pull requests".

Then Actions > ${primary%-loops}-loop > Run workflow.
EOF
