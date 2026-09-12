#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/aws.sh"
require_aws
# Non-zero when IAM Access Analyzer has active findings. Engine: Security Agent/Continuum for depth.
arn=$(aws accessanalyzer list-analyzers --query 'analyzers[0].arn' --output text 2>/dev/null) || { echo "cannot read Access Analyzer"; exit 2; }
[ "$arn" = "None" ] && { echo "no analyzer; enable IAM Access Analyzer (see SETUP.md)"; exit 1; }
n=$(aws accessanalyzer list-findings --analyzer-arn "$arn" --filter '{"status":{"eq":["ACTIVE"]}}' --query 'length(findings)' --output text 2>/dev/null || echo 0)
[ "${n:-0}" -gt 0 ] && { echo "$n active IAM finding(s)"; exit 1; } || { echo "no active IAM findings"; exit 0; }
