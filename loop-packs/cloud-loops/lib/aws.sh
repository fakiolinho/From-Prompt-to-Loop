# Mock-aware `aws` wrapper.
# With DRY_RUN=1, every `aws` call returns a canned value from ../mock so the cloud loops run
# offline with no account. The fixtures are obvious stand-ins, not real data. To hit real AWS,
# leave DRY_RUN unset (or 0) and configure credentials (see SETUP.md); the same checks then run live.
aws() {
  if [ "${DRY_RUN:-0}" = "1" ]; then
    local dir f
    dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../mock" && pwd)"
    f="$dir/${1}_${2}.txt"          # keyed by service_subcommand, e.g. ec2_describe-volumes
    [ -f "$f" ] && cat "$f" || echo ""
    return 0
  fi
  command aws "$@"
}

# Is this chapter wired to an account at all?
#
# "cannot read ECR" is not "there is work". It is "I cannot tell". A loop that answers
# 1 to that wakes an agent, on a schedule, to investigate an account it cannot reach,
# and bills you for a run that can only fail. Every cloud check calls this first.
require_aws() {
  [ "${DRY_RUN:-0}" = "1" ] && return 0
  command -v aws >/dev/null 2>&1 || {
    echo "the AWS CLI is not installed, so this loop cannot read your account."
    echo "Install AWS CLI v2, or run the whole chapter offline first:"
    echo "  DRY_RUN=1 bash loops/<loop>/check.sh"
    echo "See SETUP.md."
    exit 2
  }
  command aws sts get-caller-identity >/dev/null 2>&1 || {
    echo "no working AWS credentials, so this loop cannot read your account."
    echo "Assume the scoped loop role (SETUP.md), or try it offline first:"
    echo "  DRY_RUN=1 bash loops/<loop>/check.sh"
    exit 2
  }
}
