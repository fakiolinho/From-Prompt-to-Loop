#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# This loop governs a tool you already run. Until you point it at that tool it has
# nothing to look at, so it exits 2 and the agent never wakes. An unwired loop that
# returned 1 would wake an agent on every scheduled run and bill you for nothing.

if [ -z "${LOOP_BUGS:-}" ]; then
  echo "Bug report to failing test is not wired to this repo."
  echo "Set LOOP_BUGS to a command that lists open bug reports with no reproducing test, for example:"
  echo "  LOOP_BUGS='gh issue list --label bug --json number,title'"
  exit 2
fi

out=$(eval "$LOOP_BUGS" 2>&1); rc=$?
printf '%s\n' "$out"
[ "$rc" -eq 0 ] && { echo "every open bug already has a reproducing test"; exit 0; }
echo "bug reports awaiting a reproducing test"
exit 1
