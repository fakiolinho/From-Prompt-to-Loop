#!/usr/bin/env bash
set -uo pipefail
# Is there work? 0 = no, 1 = yes, 2 = this loop is not wired to this repo.
#
# Until this points at something real it cannot tell you anything. Returning 1 here
# would wake an agent on every scheduled run to look at data it does not have.

if [ -z "${LOOP_RAG:-}" ]; then
  echo "Rag knowledge base sync is not wired to this repo."
  echo "Set LOOP_RAG to the command that checks your index against its sources, for example:"
  echo "  LOOP_RAG='node scripts/check-index-freshness.js'"
  exit 2
fi

out=$(eval "$LOOP_RAG" 2>&1); rc=$?
printf '%s\n' "$out"
[ "$rc" -eq 0 ] && { echo "the index is fresh"; exit 0; }
echo "sources are newer than the index"
exit 1
