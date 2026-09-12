#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# Run the project's OWN commands. Do not invent them.
#
# A project has already decided what it lints and formats, and written it down in
# package.json. Inventing `prettier --check .` instead threw away that decision and,
# on a real Laravel plus Vite repo, walked into vendor/ and flagged 10,434 files of
# third party PHP. The project's own `npm run prettify` passed cleanly. Same repo,
# same tools, opposite answer, and the loop's version would have opened a pull
# request rewriting someone else's dependencies.
[ -f package.json ] || { echo "no package.json here. Run this from your project root"; exit 2; }

# Find a script by name, skipping anything that writes rather than checks.
find_script() {
  node -e '
    const s = require("./package.json").scripts || {};
    const wanted = process.argv.slice(1);
    for (const w of wanted) {
      if (s[w] && !/(write|fix|--write)/.test(w + " " + s[w])) { console.log(w); process.exit(0); }
    }
    process.exit(1);
  ' "$@" 2>/dev/null
}

lint=$(find_script lint lint:check eslint || true)
fmt=$(find_script format:check format prettify prettier:check prettier fmt || true)
types=$(find_script typecheck type-check ts-check tsc types || true)

ran=""; dirty=""
for pair in "lint:$lint" "format:$fmt" "types:$types"; do
  label=${pair%%:*}; script=${pair#*:}
  [ -z "$script" ] && continue
  ran="$ran $label"
  npm run --silent "$script" >/dev/null 2>&1 || dirty="$dirty $label"
done

if [ -z "$ran" ]; then
  echo "Lint, format and type fixes is not wired to this repo."
  echo "This loop runs the commands you already use, so it needs at least one of a"
  echo "lint, format or typecheck script in package.json. Add one, naming the scope"
  echo "you actually mean:"
  echo "  \"lint\": \"eslint 'src/**/*.{ts,tsx}'\""
  echo "Without it the loop would have to guess your scope, and a guess here rewrites"
  echo "files you never meant it to touch."
  exit 2
fi

[ -z "$dirty" ] && { echo "clean, by this project's own commands:$ran"; exit 0; }
echo "issues found by this project's own commands:$dirty (ran:$ran)"
exit 1
