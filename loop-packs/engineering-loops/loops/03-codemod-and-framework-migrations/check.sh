#!/usr/bin/env bash
set -uo pipefail
# Dispatch-driven: you point this at a migration, so there is always work when it runs.
# note: pass the codemod/target via ORDERS or a MIGRATION env var the agent reads.
echo "codemod run requested"; exit 1
