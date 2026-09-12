#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/aws.sh"
require_aws
# Non-zero when no successful restore drill ran in the last 7 days (a drill is due).
since=$(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-7d +%Y-%m-%dT%H:%M:%SZ)
done=$(aws backup list-restore-jobs --by-created-after "$since" --query "length(RestoreJobs[?Status=='COMPLETED'])" --output text 2>/dev/null) || { echo "cannot read AWS Backup"; exit 2; }
[ "${done:-0}" -gt 0 ] && { echo "restore drill ran in last 7 days"; exit 0; } || { echo "restore drill due"; exit 1; }
