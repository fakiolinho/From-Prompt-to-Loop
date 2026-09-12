#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/aws.sh"
require_aws
# portable ISO8601 -> epoch (GNU date -d, else BSD/macOS date -j -f). note: if both fail (0), we do NOT green.
to_epoch(){ date -u -d "$1" +%s 2>/dev/null || date -j -u -f "%Y-%m-%dT%H:%M:%S" "${1%%[+.]*}" +%s 2>/dev/null || echo 0; }
# Non-zero when a repo's newest image is older than the freshness window (base image likely stale).
# note: compares newest imagePushedAt per repo to a 90-day window. For true base-image diffing,
# wire your upstream base-registry digest check; this age heuristic is the ceiling.
WINDOW_DAYS=90
repos=$(aws ecr describe-repositories --query 'repositories[].repositoryName' --output text 2>/dev/null) || { echo "cannot read ECR (check role/region)"; exit 2; }
[ -z "$repos" ] && { echo "no ECR repos"; exit 0; }
cutoff=$(date -u -d "-${WINDOW_DAYS} days" +%s 2>/dev/null || date -u -v-${WINDOW_DAYS}d +%s 2>/dev/null || echo 0)
stale=""
for r in $repos; do
  newest=$(aws ecr describe-images --repository-name "$r" --query 'sort_by(imageDetails,&imagePushedAt)[-1].imagePushedAt' --output text 2>/dev/null)
  { [ -z "$newest" ] || [ "$newest" = "None" ]; } && { stale="$stale $r(no-images)"; continue; }
  ts=$(to_epoch "$newest")
  { [ "$cutoff" -eq 0 ] && stale="$stale $r(age-unknown)"; } || { [ "$ts" -lt "$cutoff" ] && stale="$stale $r"; }
done
[ -z "$stale" ] && { echo "base images within ${WINDOW_DAYS}d"; exit 0; }
echo "base images to review (older than ${WINDOW_DAYS}d):$stale"; exit 1
