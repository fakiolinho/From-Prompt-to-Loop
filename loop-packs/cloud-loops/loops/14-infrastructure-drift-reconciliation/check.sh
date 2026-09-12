#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/aws.sh"
require_aws
# Non-zero when any CloudFormation stack has drifted from its template.
stacks=$(aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query 'StackSummaries[].StackName' --output text 2>/dev/null) || { echo "cannot read CloudFormation"; exit 2; }
work=0
for s in $stacks; do
  id=$(aws cloudformation detect-stack-drift --stack-name "$s" --query StackDriftDetectionId --output text 2>/dev/null) || continue
  [ "${DRY_RUN:-0}" = "1" ] || sleep 3
  st=$(aws cloudformation describe-stack-drift-detection-status --stack-drift-detection-id "$id" --query StackDriftStatus --output text 2>/dev/null)
  [ "$st" = "DRIFTED" ] && { echo "drift in $s"; work=1; }
done
[ "$work" -eq 0 ] && { echo "no drift"; exit 0; } || exit 1
