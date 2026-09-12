#!/usr/bin/env bash
set -uo pipefail
# Non-zero when a source is newer than its index entry (re-embed needed).
# note: mtime heuristic; wire to your vector store's real freshness signal.
src="${RAG_SOURCES:-sources}"; idx="${RAG_INDEX:-index}"
[ -d "$src" ] || { echo "no sources dir ($src); wire your store"; exit 1; }
work=0
for f in "$src"/*; do [ -e "$f" ] || continue; b=$(basename "$f")
  { [ ! -f "$idx/$b.json" ] || [ "$f" -nt "$idx/$b.json" ]; } && { echo "stale index for $b"; work=1; }
done
[ "$work" -eq 0 ] && { echo "index fresh"; exit 0; } || exit 1
