#!/usr/bin/env bash
# Minimal smoke runner the loop calls right after a deploy. Reads smoke.example.json, hits each path,
# fails the deploy gate on a bad status. Swap in your real base URL and paths. (needs curl + jq)
set -uo pipefail
base=$(jq -r .baseUrl smoke.example.json); fail=0
while read -r c; do
  path=$(jq -r .path <<<"$c"); want=$(jq -r .expectStatus <<<"$c")
  code=$(curl -s -o /dev/null -w '%{http_code}' "$base$path" || echo 000)
  [ "$code" = "$want" ] || { echo "SMOKE FAIL $path got $code want $want"; fail=1; }
done < <(jq -c '.checks[]' smoke.example.json)
[ "$fail" -eq 0 ] && echo "smoke passed" || echo "smoke failed, gate the deploy"
exit $fail
