#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/aws.sh"
# Non-zero when Cost Anomaly Detection has open anomalies. Engine: FinOps Agent for root cause.
since=$(date -u -d '7 days ago' +%Y-%m-%d 2>/dev/null || date -u -v-7d +%Y-%m-%d)
n=$(aws ce get-anomalies --date-interval StartDate=$since,EndDate=$(date -u +%Y-%m-%d) --query 'length(Anomalies)' --output text 2>/dev/null) || { echo "cannot read Cost Anomaly Detection (enable it; ce is us-east-1)"; exit 1; }
[ "${n:-0}" -gt 0 ] && { echo "$n cost anomaly(ies) to investigate"; exit 1; } || { echo "no cost anomalies"; exit 0; }
