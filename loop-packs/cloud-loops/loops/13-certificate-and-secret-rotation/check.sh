#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/aws.sh"
# Non-zero when a certificate expires within 30 days.
soon=$(date -u -d '+30 days' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v+30d +%Y-%m-%dT%H:%M:%SZ)
n=$(aws acm list-certificates --query "length(CertificateSummaryList[?NotAfter!=null && NotAfter<='$soon'])" --output text 2>/dev/null) || { echo "cannot read ACM"; exit 1; }
[ "${n:-0}" -gt 0 ] && { echo "$n certificate(s) expiring within 30 days"; exit 1; } || { echo "no certs expiring soon"; exit 0; }
