# Buildkite Agent v7 pilot deployment

This folder is a standalone repository scaffold for deploying a v7 Elastic CI Stack pilot. It deliberately does not run the baseline repository's OrgFormation tasks. The existing v6 default agent remains configured on the `default` queue; the pilot listens on `default-v7-canary` and is capped at one instance.

## AWS target

- Account: `817092971396` (Buildkite)
- Region: `us-east-1`
- Sceptre/CloudFormation stack: `infrastructure-buildkite-buildkite-agent-v7-pilot`
- Elastic CI Stack: `v7.11.0`
- Agent release channel: `stable` (v7.11.0 bundles Agent v4.10.1)

The pilot reuses the existing agent token SSM parameter and the existing VPC, security group, subnets, and Docker agent policy. It does not configure a custom AMI.

## Publish and configure Buildkite

Move this entire folder to a new directory outside `aws-org-and-account-baseline`, initialize it as its own Git repository, and publish it. Configure a Buildkite pipeline for that repository using `.buildkite/pipeline.yml`, with `main` as the deployment branch.

The deployment step uses the existing `core-infrastructure` queue and the existing AWS role chain: the Buildkite plugin assumes `AllowBuildKiteAssumeRoleOtherAccounts` in the management account, then Sceptre assumes `OrganizationAccountAccessRole` in the Buildkite account.

**Required external access setup:** the current core-infrastructure agent eligibility check only allows the old baseline repository and selected pipeline slugs. A new repository/pipeline will be rejected until its repository URL and pipeline slug are authorized for that queue, or an equivalent authorized deployment queue is configured. This scaffold does not modify the baseline repository's agent allowlist or AWS IAM policies.

## Deployment behavior

- Pull requests run YAML linting only; they do not receive AWS credentials or deploy.
- A successful Buildkite run on `main` validates and launches only this Sceptre stack config.
- The deployment command does not use `--prune` and does not run OrgFormation.
- After the stack is created, route a test job to `default-v7-canary` and verify checkout, hooks/plugins, Docker, artifacts, secrets, cancellation, and pipeline upload before planning a default-queue cutover.

Before production use, recheck Buildkite's current stable Elastic CI Stack release and review its v6-to-v7 and Agent v3-to-v4 upgrade guides. The version here is pinned so the pilot is reproducible.

## Folder contents

- `.buildkite/pipeline.yml`: PR lint and main-only deployment pipeline.
- `docker-compose.yml`: pinned Sceptre 3.2.0 runtime and YAML lint image.
- `infrastructure/config`: isolated Sceptre project for this one stack.
- `infrastructure/templates/buildkite/Agent.yaml.j2`: the baseline wrapper template, copied here so this repository is self-contained.
