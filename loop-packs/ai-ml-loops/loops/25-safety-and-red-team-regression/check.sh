#!/usr/bin/env bash
set -uo pipefail
# Non-zero when the red-team suite regresses. Mirrors loop 19. Wire your adversarial set.
if [ -d redteam ]; then echo "run your red-team suite here (same harness as loop 19)"; exit 1
else echo "no redteam set; wire your adversarial cases (reuse loop 19's harness)"; exit 1; fi
