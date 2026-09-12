#!/usr/bin/env bash
# Shared helpers for the repo's own tests. Sourced, not run.

PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '  FAIL %s\n' "$1"; }
head2(){ printf '\n== %s\n' "$1"; }

# summary <name> -> exits 1 if anything failed
summary() {
  printf '\n%s: %d passed, %d failed\n' "$1" "$PASS" "$FAIL"
  [ "$FAIL" -eq 0 ] || exit 1
}

# packs, in the order the guide lists the chapters
PACKS="engineering-loops cloud-loops ai-ml-loops qa-loops"
