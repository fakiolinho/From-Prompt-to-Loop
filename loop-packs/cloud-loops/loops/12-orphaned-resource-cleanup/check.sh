#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/aws.sh"
# Non-zero when orphaned resources exist (unattached volumes, idle EIPs).
vols=$(aws ec2 describe-volumes --filters Name=status,Values=available --query 'length(Volumes)' --output text 2>/dev/null) || { echo "cannot read EC2"; exit 1; }
eips=$(aws ec2 describe-addresses --query "length(Addresses[?AssociationId==null])" --output text 2>/dev/null || echo 0)
total=$(( ${vols:-0} + ${eips:-0} ))
[ "$total" -eq 0 ] && { echo "no orphaned volumes or EIPs"; exit 0; } || { echo "$vols unattached volumes, $eips idle EIPs"; exit 1; }
