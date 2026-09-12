*[Contents](../../README.md) · Chapter 2 of 4*

# Chapter 2 · Cloud and platform

**Loops 10-18.** The chapter's loops, one row each. New to all this? Start at [what a loop is](../../docs/01-what-is-a-loop.md).

Nine loops from the cloud and platform chapter of *From Prompt to Loop*. Numbers track the
master catalog in the guide. One shared runner (`.github/workflows/loop.yml`) assumes a scoped
AWS role via OIDC and runs any loop on **Claude or Codex**. Each loop is standing orders plus a
real **AWS CLI** check that answers one question: *is there work?*

Read **SETUP.md** first. It is the preliminary AWS walkthrough: CLI v2, the OIDC role, the
services to enable, the agents to turn on, and the protected environment that enforces the gate.

The law of this chapter: **reversible runs on green, irreversible never does.** Deletes, IAM
changes, prod secret rotations, and capacity changes stop and wait for a human.

| # | Loop | Trigger | Ships | AWS agent engine | The check (AWS CLI) |
|---|------|---------|-------|------------------|---------------------|
| 10 | [Container and base image bumps](loops/10-container-and-base-image-bumps/ORDERS.md) | weekly | Ships on green | plain CLI | `aws ecr describe-images` |
| 11 | [Backup restore drills](loops/11-backup-restore-drills/ORDERS.md) | weekly | Ships on green | plain CLI | `aws backup list-restore-jobs` |
| 12 | [Orphaned resource cleanup](loops/12-orphaned-resource-cleanup/ORDERS.md) | weekly | **Flags, you decide** | plain CLI | `aws ec2 describe-volumes` |
| 13 | [Certificate and secret rotation](loops/13-certificate-and-secret-rotation/ORDERS.md) | daily | **Flags, you decide** | plain CLI | `aws acm list-certificates` |
| 14 | [Infrastructure drift reconciliation](loops/14-infrastructure-drift-reconciliation/ORDERS.md) | daily | **Flags, you decide** | plain CLI | `aws cloudformation detect-stack-drift` |
| 15 | [Cost and spend anomaly watch](loops/15-cost-and-spend-anomaly-watch/ORDERS.md) | daily | **Flags, you decide** | **FinOps Agent** | `aws ce get-anomalies` |
| 16 | [Alert and on call noise tuning](loops/16-alert-and-on-call-noise-tuning/ORDERS.md) | weekly | **Flags, you decide** | **DevOps Agent** | `aws cloudwatch describe-alarm-history` |
| 17 | [Known alert auto remediation](loops/17-known-alert-auto-remediation/ORDERS.md) | on alarm | **Flags, you decide** | **DevOps Agent** | `aws cloudwatch describe-alarms` |
| 18 | [IAM and permission audit](loops/18-iam-and-permission-audit/ORDERS.md) | weekly | **Flags, you decide** | **Security Agent / Continuum** | `aws accessanalyzer list-findings` |

**Ships on green** loops open a PR on `loop/<name>` and merge once the check passes. A bad
one is one click back. **Flags, you decide** loops stop and hand you the call; they never merge.
**★** marks the guide's three easiest first builds. Both kinds are fenced, capped, and stoppable
the same way.

The four loops with an engine call an AWS frontier agent for the heavy analysis and govern the
result. Each keeps a plain-CLI fallback, so the loop runs with or without the agent.

**On testing:** these checks are real AWS CLI, syntax verified. The live proof is you running
SETUP.md and then a loop against your own account, about 20 minutes per loop. That is the
"tested against real AWS" stamp, and it is yours to earn, not something to take on faith.

## Where these tags come from

The two tags and the star on this page are the field guide's own, taken from the catalog on pages
22 to 25. They are not our shorthand. If a row here ever disagrees with the guide, the guide wins,
and `ci/test-docs.sh` says so before you find out the hard way.

**★** marks the three easiest first builds. All three sit in chapter 1, so this chapter has none.
Get one of those running first. This chapter is worth adopting once a loop opening PRs on your repo
has stopped feeling like a risk.

**[Read the field guide](../../From-Prompt-to-Loop_The-Warship-CTO.pdf)**, free, in the root of this
repo. Every loop on this page has its reasoning in there: why it is worth building, what it costs,
and when it is not a loop at all.

---

[← Chapter 1: General engineering](../engineering-loops/LOOPS.md) · [Contents](../../README.md) · [Chapter 3: AI and ML engineering →](../ai-ml-loops/LOOPS.md)
