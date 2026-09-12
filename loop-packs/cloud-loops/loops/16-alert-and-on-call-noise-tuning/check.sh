#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/aws.sh"
require_aws
# Non-zero when alarms are flapping (noisy). Engine: DevOps Agent to correlate with incidents.
since=$(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-7d +%Y-%m-%dT%H:%M:%SZ)
flips=$(aws cloudwatch describe-alarm-history --history-item-type StateUpdate --start-date "$since" --query 'length(AlarmHistoryItems)' --output text 2>/dev/null) || { echo "cannot read CloudWatch"; exit 2; }
[ "${flips:-0}" -gt 50 ] && { echo "$flips alarm state changes in 7d, tune the noise"; exit 1; } || { echo "alarm volume normal ($flips)"; exit 0; }
