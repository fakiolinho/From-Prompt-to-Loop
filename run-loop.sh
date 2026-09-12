#!/usr/bin/env bash
# Run one loop, here, now. The same thing the GitHub workflow does, on your machine.
#
#   ./run-loop.sh 02              check, and if there is work, hand it to the agent
#   ./run-loop.sh 02 --check      just the check, never wakes an agent
#   ./run-loop.sh 02 --dry-run    print the agent command instead of running it
#   ./run-loop.sh 02 --agent codex
#
# Do this before you ever wire up Actions. You see the check answer, you watch the
# agent work, and you read the diff, without a secret or a schedule anywhere.
set -uo pipefail
cd "$(dirname "$0")"

LOOP="" AGENT="claude" MODE="run"
for a in "$@"; do
  case "$a" in
    --check)   MODE="check" ;;
    --dry-run) MODE="dry" ;;
    --agent)   AGENT="__next__" ;;
    claude|codex) [ "$AGENT" = "__next__" ] && AGENT="$a" ;;
    -h|--help) sed -n '2,/^[^#]/s/^# \{0,1\}//p' "$0"; exit 0 ;;
    *)         [ -z "$LOOP" ] && LOOP="$a" ;;
  esac
done
[ -n "$LOOP" ] || { sed -n '2,/^[^#]/s/^# \{0,1\}//p' "$0"; exit 1; }

# Accept 02, 2, or the full folder name
dir=$(ls -d loops/"$(printf '%02d' "$((10#${LOOP%%-*}))" 2>/dev/null || echo "$LOOP")"-*/ 2>/dev/null | head -1)
[ -n "$dir" ] || { echo "no loop '$LOOP' here. Installed loops:"; ls -1 loops/ 2>/dev/null | sed 's/^/  /'; exit 1; }
name=$(basename "$dir")

# Your settings, exactly as the workflow loads them
if [ -f loops.env ]; then set -a; . ./loops.env; set +a; fi

echo "── $name"
echo
out=$(bash "$dir/check.sh" 2>&1); rc=$?
printf '%s\n' "$out"
echo

case "$rc" in
  0) echo "Nothing to do. This is what a quiet night looks like, and it costs nothing."; exit 0 ;;
  2) echo "Not wired to this repo yet. The check said what it needs above."
     echo "Settings live in loops.env. Full list: WIRING.md"; exit 2 ;;
  1) : ;;
  *) echo "The check exited $rc, which is outside the contract. Not waking an agent."; exit "$rc" ;;
esac

[ "$MODE" = "check" ] && { echo "There is work. Drop --check to hand it to the agent."; exit 1; }

RULES=$([ "$AGENT" = "codex" ] && echo AGENTS.md || echo CLAUDE.md)
PROMPT="Read $RULES and loops/$name/ORDERS.md. Do exactly what those orders say, nothing outside \
them. Run bash loops/$name/check.sh and finish only when it exits 0 (for a \"Flags, you decide\" \
loop, when the report or issue is posted). If two runs of the check fail the same way, stop and \
open an issue; do not try a third time. Append one line to memory/$name.md. If the orders say \
open a PR, use the single branch loop/$name and never open a second. If you cannot proceed \
without guessing intent, open an issue and stop."

if [ "$AGENT" = "codex" ]; then
  CMD=(npx @openai/codex exec --sandbox workspace-write "$PROMPT")
else
  CMD=(npx @anthropic-ai/claude-code -p "$PROMPT"
       --allowedTools "Read,Edit,Write,Bash(npm:*),Bash(npx:*),Bash(git:*),Bash(gh:*),Bash(bash loops/*/check.sh)"
       --max-turns 30 --max-budget-usd 2)
fi

if [ "$MODE" = "dry" ]; then
  echo "There is work. This is what would run:"
  echo
  if [ "$AGENT" = "codex" ]; then
    echo "  npx @openai/codex exec --sandbox workspace-write \\"
  else
    echo "  npx @anthropic-ai/claude-code -p \\"
  fi
  printf '%s\n' "$PROMPT" | fold -s -w 76 | sed 's/^/      /'
  if [ "$AGENT" != "codex" ]; then
    echo "    --allowedTools \"Read,Edit,Write,Bash(npm:*),Bash(npx:*),Bash(git:*),Bash(gh:*),Bash(bash loops/*/check.sh)\" \\"
    echo "    --max-turns 30 --max-budget-usd 2"
  fi
  echo
  echo "Then the check runs again afterwards, so the agent never marks its own work."
  exit 1
fi

command -v npx >/dev/null 2>&1 || { echo "npx not found. Install Node 18 or newer."; exit 1; }
echo "There is work. Waking $AGENT, capped at 30 turns and 2 dollars."
echo
"${CMD[@]}"; arc=$?
echo

# The local stand-in for the verify job: the maker does not get to mark its own work.
echo "── verifying, with no agent in the room"
vout=$(bash "$dir/check.sh" 2>&1); vrc=$?
printf '%s\n' "$vout"
echo
if [ "$vrc" -eq 0 ]; then
  echo "Green. Read the diff before you commit any of it: git diff"
else
  echo "Still not green (check exited $vrc, agent exited $arc). Nothing here is finished."
fi
exit "$vrc"
