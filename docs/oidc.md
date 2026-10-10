# AWS access with GitHub OIDC

Workflows assume short-lived AWS roles through GitHub's OIDC provider. There are no long-lived access keys and no AWS secrets in GitHub.

This repository documents the design and ships an example Terraform module in [`oidc/terraform`](oidc/terraform). Nothing here creates AWS resources; the module is the seed for the Terraform platform repository.

## Roles

Use one role per purpose, each trusting only the subject that purpose needs.

| Role | Used by | Allows | Trusted subject (`sub`) |
| --- | --- | --- | --- |
| plan | `terraform-plan` | Read-only plus state read | `repo:<owner>/<repo>:pull_request` |
| apply | `terraform-apply` | What the stack manages, and the state lock | `repo:<owner>/<repo>:environment:<env>` |
| ecr-push | `docker-push` | Push to named ECR repositories | `repo:<owner>/<repo>:ref:refs/heads/main`, `...:refs/heads/dev`, `...:refs/tags/v*` |
| ecs-deploy | `deploy-ecs` | Register task definitions, update the service, `iam:PassRole` on its task roles | `repo:<owner>/<repo>:environment:<env>` |

Why subjects matter:

- A job that declares `environment:` gets the subject `repo:<owner>/<repo>:environment:<env>` instead of a ref subject. Trust policies for apply and deploy must therefore use the environment form, and the environment's required reviewers become the approval gate.
- Pull request runs get `repo:<owner>/<repo>:pull_request`. Only the read-only plan role should trust it.
- Pull requests from forks get no OIDC token, so plan jobs do not run for them.

## Threat model for the plan role

Anyone who can open a pull request can run arbitrary Terraform code with the plan role: an `external` data source or provider can read whatever the role can read. `ReadOnlyAccess` in the example is a starting point, not a recommendation: it reads data across the account. For real use, replace it with a custom policy limited to the services the stack manages plus read access to the state bucket, and trust the role only from repositories where every contributor is trusted. Pull requests from forks never receive a token.

## Trust policy shape

Every role needs both conditions:

- `token.actions.githubusercontent.com:aud` equals `sts.amazonaws.com`
- `token.actions.githubusercontent.com:sub` matches the subjects above

Never use `repo:*`, an organization wildcard, or a bare `:*` suffix. The example module requires a literal `repo:<owner>/<repo>:<claim>` and rejects the rest.

## Using the example module

1. Review `oidc/terraform/example.tfvars` and replace the account ID, repositories, and policies.
2. Put the module in the Terraform repository that owns IAM (Phase 3 of the roadmap).
3. Set `create_provider = false` if the account already has a GitHub OIDC provider; an account can hold only one per URL.
4. Pass the `role_arns` output values to the workflows as `role-arn`.

Validated with `terraform fmt -check`, `init -backend=false`, and `validate`. Not applied anywhere.

## Gap in the existing infra module

`open-projects-hub-infra/modules/github-oidc` trusts ref subjects only, so it cannot serve pull-request plans or environment-gated applies, and it has no ECS role. This design replaces it.
