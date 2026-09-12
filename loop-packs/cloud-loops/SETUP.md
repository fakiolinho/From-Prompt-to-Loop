*[Contents](../../README.md) · [Chapter 2: Cloud and platform](LOOPS.md) · setup*

# Preliminary AWS setup

## Getting the pack into your repo

    ./install.sh ~/code/my-infra cloud

That brings the loops, the standing orders, the runner, `lib/aws.sh` and a `loops.env`. Then
everything below wires it to an account. Nothing here touches AWS until you finish step 4.

## Try it locally first, no AWS account
Every loop in this pack runs offline against canned outputs, so you can see what each one detects
before wiring any AWS. Set `DRY_RUN=1`:

    DRY_RUN=1 bash loops/15-cost-and-spend-anomaly-watch/check.sh   # -> "1 cost anomaly(ies) to investigate"

Run the whole pack the same way:

    for d in loops/*/; do printf "%-44s " "$(basename "$d")"; DRY_RUN=1 bash "$d/check.sh"; done

The canned values live in `mock/` and are obvious stand-ins; `lib/aws.sh` swaps them in only when
`DRY_RUN=1`. They let you read each loop's logic and exit behaviour with zero setup.

When you want real data, do the one-time setup below, then **drop `DRY_RUN`** (leave it unset). The
exact same checks now call real AWS through your configured credentials. Mocks off, account on,
nothing else changes.

---


Do these once. They make every loop in this pack runnable against your own account, with no
long lived keys and least privilege. Budget about 30 minutes. Replace `<ACCOUNT_ID>`,
`<ORG>/<REPO>`, and `<REGION>` with your values.

## 0. Prerequisites
- An AWS account you can administer.
- **AWS CLI v2** installed (`aws --version` should print 2.x). v1 is in maintenance mode.
- This repo pushed to GitHub.

## 1. Pick a region
    export AWS_REGION=<REGION>     # e.g. eu-central-1
Note: the **FinOps Agent** preview (loop 15) is **us-east-1 only** for now. The DevOps and
Security agents are GA in several regions. Plain-CLI loops work in any region.

## 2. Let GitHub Actions assume a role with no keys (OIDC)
Create the GitHub OIDC provider in IAM (skip if it already exists):

    aws iam create-open-id-connect-provider \
      --url https://token.actions.githubusercontent.com \
      --client-id-list sts.amazonaws.com

## 3. Create the least privilege loop role
Save this trust policy as `trust.json` (scopes the role to THIS repo only):

    {
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Principal": { "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com" },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": { "token.actions.githubusercontent.com:aud": "sts.amazonaws.com" },
          "StringLike":   { "token.actions.githubusercontent.com:sub": "repo:<ORG>/<REPO>:*" }
        }
      }]
    }

Create the role and start it **read only**. Loops investigate before they act:

    aws iam create-role --role-name cloud-loops \
      --assume-role-policy-document file://trust.json
    aws iam attach-role-policy --role-name cloud-loops \
      --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess

Add scoped **write** permissions one loop at a time, only when you turn that loop on. Each
loop's ORDERS.md names the exact actions it needs. Never attach account admin.

## 4. Wire the repo to the role
In GitHub > Settings > Secrets and variables > Actions:
- **Variables:** `LOOP_ROLE_ARN = arn:aws:iam::<ACCOUNT_ID>:role/cloud-loops`, `AWS_REGION = <REGION>`
- **Secrets:** `ANTHROPIC_API_KEY` and/or `OPENAI_API_KEY`

## 5. Turn on the services each loop reads
Enable only what you use:
- **Loop 11** backup drills -> AWS Backup with a backup plan and recovery points
- **Loop 14** drift -> AWS Config (or CloudFormation drift detection) enabled on your stacks
- **Loop 15** cost -> Cost Explorer + at least one Cost Anomaly Detection monitor
- **Loop 18** IAM audit -> IAM Access Analyzer enabled, and a credential report available

## 6. Optional: enable the AWS frontier agents (the engines for loops 15-18)
The loops run on plain CLI without these. Turn them on for heavier analysis:
- **DevOps Agent** (GA) -> loops 16, 17. Console: create the agent, connect your observability
  (CloudWatch and others) and an event source (CloudWatch alarm, PagerDuty, or webhook). The
  loop hands it an incident and governs the remediation.
- **Security Agent / AWS Continuum** (GA / preview) -> loop 18. Console: enable on-demand
  penetration testing and vulnerability findings. The loop schedules it and gates any change.
- **FinOps Agent** (preview, us-east-1) -> loop 15. Console: create the agent, create its IAM
  role, optionally add the Slack/Jira integration. The loop triggers an investigation on an
  anomaly and turns the finding into a tracked, gated action.
Each of these bills for the AWS APIs it calls; the DevOps Agent also bills per second of work.

## 7. Enforce the human gate in the platform (irreversible loops)
Loops 11, 12, 13, and 18 can destroy or change access. In GitHub > Settings > Environments,
create an environment named **cloud-loops** with **required reviewers**. The runner already
pins `environment: cloud-loops`, so **every** cloud run pauses for human approval before it touches anything. This is deliberate, one gate for the whole pack. The irreversible loops (11, 12, 13, 18) are the reason the gate exists; the reversible ones inherit it as belt and suspenders. If you want reversible loops (10, 14, 15, 16, 17) to run without approval, move them to a second job without the `environment:` line.

## You are ready
Run any loop from the Actions tab: pick the `loop` folder and the `agent`. The runner assumes
the scoped role, runs the check, and only wakes the agent if there is work.

Locally, `./run-loop.sh 15 --check` does the same thing without Actions. With no credentials it
exits 2 and says so, which is the honest answer rather than a wasted agent run.

---

[← Chapter 2: Cloud and platform](LOOPS.md) · [Contents](../../README.md) · [The cloud loops](LOOPS.md)
