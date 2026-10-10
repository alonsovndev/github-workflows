# AGENTS.md

<!-- ai-repo-setup:generated:start -->

## Overview

Central repository of reusable GitHub Actions workflows (`on: workflow_call`) for the engineering platform. Standards come from the [engineering handbook](https://github.com/alonsovndev/engineering-handbook) (ci-cd, git, testing sections). Deployment profile: not applicable (consumed by other repositories as `alonsovndev/github-workflows/.github/workflows/<name>.yml@v1`).

## Commands

| Task | Command |
| --- | --- |
| Lint workflows | `docker run --rm -v "$PWD":/repo -w /repo rhysd/actionlint:1.7.7` |
| Fixture checks (Python) | `cd fixtures/python-app && pip install -e .[dev] && make ci` |
| Fixture checks (Node) | `cd fixtures/node-app && make ci` |
| Terraform fixtures and OIDC example | `cd fixtures/terraform && terraform fmt -check && terraform init -backend=false && terraform validate` (same in `docs/oidc/terraform`; never run `plan` or `apply` there, the AWS provider would use local credentials) |

There is no Makefile at the root; CI is `.github/workflows/ci.yml`.

## Structure

```text
.github/workflows/   one reusable workflow per file (flat; GitHub requires it) + ci.yml self-test
fixtures/            minimal projects ci.yml runs the reusable workflows against
examples/callers/    caller workflows to copy
docs/                usage, contract, OIDC design, example Terraform
```

## Rules for workflows

- Top-level `permissions: contents: read`; grant `id-token: write` or `contents: write` only on the job that needs it.
- Never put `${{ github.event.* }}` or `${{ inputs.* }}` inside `run:`. Pass through `env:`.
- No local composite actions: `./` resolves to the caller's checkout inside a reusable workflow.
- Deploy and apply never cancel in progress; PR runs do.
- Never upload Terraform plans or state; they can contain secrets.
- AWS access is OIDC only. No access keys, no `pull_request_target`.
- Pin third-party actions to the major tags already in use (accepted risk; SHA pinning and Dependabot are a follow-up). Changing an input name or adding a required input is breaking: it needs a new major tag.

## Testing

Every workflow that can run without AWS is exercised by `ci.yml` against `fixtures/`. AWS-facing workflows (`docker-push`, terraform plan/apply, `deploy-ecs`) cannot be tested here; say so rather than implying they were.

## Git

- Conventional Commits. No AI or tool co-author trailers.
- Branch from `dev`; PRs target `dev`. Never commit or push on `main` or `dev`.
- Do not commit, push, or bypass hooks unless asked. Moving the `v1` tag is a release action: only on a commit on `main` that passed CI, and only when asked.

## Security

No secrets in the repository or in workflow inputs. Role ARNs in examples use the placeholder account `111111111111`. Do not call AWS or other external services without approval.

## Definition of done

actionlint is clean, fixture checks pass, docs match the inputs, and the final report states which workflows were not run on GitHub or against AWS. See the handbook's definition of done.

## Deployment

Releases are tags: `vX.Y.Z` on `main`, plus the moving `v1` tag. TBD: automate tag moves.

<!-- ai-repo-setup:generated:end -->

<!-- ai-repo-setup:custom:start -->
<!-- Add project-specific rules below this line. Preserved across re-runs. -->
<!-- ai-repo-setup:custom:end -->
