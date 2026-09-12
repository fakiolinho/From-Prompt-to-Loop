#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/aws.sh"
require_aws
# Non-zero when an alarm is currently firing. Engine: DevOps Agent for RCA + runbook.
n=$(aws cloudwatch describe-alarms --state-value ALARM --query 'length(MetricAlarms)' --output text 2>/dev/null) || { echo "cannot read CloudWatch"; exit 2; }
[ "${n:-0}" -gt 0 ] && { echo "$n alarm(s) firing, run the known-alarm runbook"; exit 1; } || { echo "no alarms firing"; exit 0; }
