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
