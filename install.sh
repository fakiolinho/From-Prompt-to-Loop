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

if [ -n "$extra" ]; then
  echo
  echo "  Note: you also picked loops from:$(echo $extra | sed 's/^/ /')"
  echo "  Each chapter has its own law in CLAUDE.md, and only one can sit at your repo root."
  echo "  The $primary one is installed. Open these and merge in the sections you want:"
  for e in $extra; do echo "    loop-packs/$e/CLAUDE.md"; done
  echo "  Easiest path: adopt one chapter, prove it, then add the next. See docs/05-add-the-next.md."
fi

echo; echo "loops:"
for p in $picks; do
  pack="${p%%/*}"; loop="${p#*/}"
  copy "$HERE/loop-packs/$pack/loops/$loop" "$TARGET/loops/$loop"
  copy "$HERE/loop-packs/$pack/memory/$loop.md" "$TARGET/memory/$loop.md"
done

# loops.env: exactly the settings these loops read, with the example from each check
ENV="$TARGET/loops.env"
[ -f "$ENV" ] || printf '%s\n' \
  '# Settings for the loops in this repo. The runner loads this before every check.' \
  '# A loop whose setting is missing exits 2 and says so, rather than guessing.' \
  '#' \
  '# Commit this file. These are commands, not secrets, and CI has to read it.' \
  '# Secrets go in Settings > Secrets and variables > Actions, never here.' > "$ENV"
echo; echo "settings:"
for p in $picks; do
  pack="${p%%/*}"; loop="${p#*/}"
  vars=$(grep -ohE '\$\{(LOOP_[A-Z_]+|MIGRATION|BASE_REF|BASE_TAG)(:-[^}]*)?\}' \
          "$HERE/loop-packs/$pack/loops/$loop/check.sh" 2>/dev/null \
         | sed -E 's/\$\{([A-Z_]+).*/\1/' | sort -u)
  [ -n "$vars" ] || continue
  for v in $vars; do
    grep -q "^#\? *$v=" "$ENV" && continue
    ex=$(grep -oE "$v='[^']*'" "$HERE/loop-packs/$pack/loops/$loop/check.sh" | head -1 | sed "s/^$v=//")
    [ -n "$ex" ] || ex="''"
    { echo; echo "# loop ${loop%%-*}: ${loop#*-}"; echo "# $v=$ex"; } >> "$ENV"
    echo "  loops.env needs $v  (loop ${loop%%-*})"
  done
done

cat <<EOF

Done. Three things left, and only you can do them:

  1. Open loops.env and fill in the settings above. Each one is commented out with an
     example. A loop you leave unset simply exits 2 and tells you what it wanted.
  2. Add ANTHROPIC_API_KEY (or OPENAI_API_KEY) in Settings > Secrets and variables > Actions.
  3. Settings > Actions > General > Workflow permissions:
     turn on "Allow GitHub Actions to create and approve pull requests".

Then try a check by hand before you ever run the workflow:

  cd $TARGET && bash loops/$(echo $picks | awk '{print $1}' | cut -d/ -f2)/check.sh

  0 = nothing to do    1 = there is work    2 = not wired yet, and it will say what it needs
EOF
