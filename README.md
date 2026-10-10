# github-workflows

Reusable GitHub Actions workflows for the engineering platform. Repositories call these instead of copying large workflow files, so one fix improves every repository. Standards come from the [engineering handbook](https://github.com/alonsovndev/engineering-handbook).

## Workflows

| Workflow | Purpose |
| --- | --- |
| `python-ci.yml` | Install, run `make ci` (lint, types, tests, 80% coverage gate), optional PostgreSQL service |
| `frontend-ci.yml` | `npm ci`, `make ci`, optional Playwright job |
| `pr-title.yml` | Conventional Commits check on the pull request title |
| `docker-build.yml` | Build an image with no AWS access (safe on pull requests) |
| `docker-push.yml` | Build and push to ECR through OIDC; outputs a digest-pinned `image-uri` |
| `validate-tag.yml` | Check a pushed tag is `vX.Y.Z` and on `main`, before building or deploying |
| `terraform-validate.yml` | `fmt -check`, `init -backend=false`, `validate` |
| `terraform-plan.yml` | Read-only plan on pull requests; summary only |
| `terraform-apply.yml` | Gated plan and apply in one job |
| `deploy-ecs.yml` | Swap the image in a task definition and deploy, waiting for stability |
| `release.yml` | Create a GitHub release for a `vX.Y.Z` tag on `main` |

## Use a workflow

```yaml
jobs:
  python:
    uses: alonsovndev/github-workflows/.github/workflows/python-ci.yml@v1
    with:
      postgres-image: postgres:16-alpine
```

Copy a starting point from [`examples/callers`](examples/callers). Details: [usage](docs/usage.md), [the `make ci` contract](docs/contract.md), [AWS OIDC setup](docs/oidc.md).

## Repository layout

```text
.github/workflows/   reusable workflows, plus ci.yml that tests them on fixtures
fixtures/            minimal Python, Node, Terraform, and Docker projects used by ci.yml
examples/callers/    caller workflows to copy
docs/                usage, contract, OIDC design, example Terraform
```

## Status

Not yet run on GitHub: the repository's own `ci.yml` is the first real execution. The AWS-facing workflows (`docker-push`, `terraform-plan`, `terraform-apply`, `deploy-ecs`) have not been exercised against a real account.

## License

MIT. See [LICENSE](LICENSE).
