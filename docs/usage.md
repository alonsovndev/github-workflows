# Using the workflows

## Reference and versioning

Call a workflow as `alonsovndev/github-workflows/.github/workflows/<name>.yml@<ref>`.

- `@v1` is a moving major tag. Compatible fixes and additions land there, so every caller picks them up.
- `@v1.2.3` pins an exact release.
- Breaking changes (removed or renamed inputs, new required inputs) ship as `@v2`.

Move the `v1` tag only to a commit on `main` that passed this repository's CI.

## Visibility

The callers' repositories must be allowed to use these workflows. If this repository is private, enable Settings > Actions > General > Access > "Accessible from repositories owned by the user".

## Permissions

A called workflow cannot hold permissions its caller does not grant. `docker-push`, `terraform-plan`, `terraform-apply`, and `deploy-ecs` declare `id-token: write`, so the calling job must grant it, as the examples do. `release` needs `contents: write`. `docker-build` needs nothing beyond `contents: read`, so it works on pull requests from forks and Dependabot, which get no OIDC token.

## Inputs worth knowing

| Workflow | Input | Default | Note |
| --- | --- | --- | --- |
| `python-ci`, `frontend-ci` | `ci-command` | `make ci` | See [the contract](contract.md) |
| `python-ci` | `postgres-image` | empty | Adds a PostgreSQL service and exports `DATABASE_URL` |
| `python-ci` | `cache-dependency-path` | `**/pyproject.toml` | Set it when the project is in a subdirectory |
| `frontend-ci` | `e2e` | `true` | Runs Playwright (chromium) in its own job |
| `docker-push` | outputs | `image-uri`, `digest` | `image-uri` is digest-pinned; pass it to `deploy-ecs` |
| `docker-build`, `docker-push` | `target` | empty | Dockerfile stage to build (for example `lambda`); empty builds the last stage |
| `docker-push` | `version-tag` | empty | Extra tag (letters, digits, `.`, `_`, `-`). The `sha-` tag is always pushed, so re-running a tag push fails if the ECR repository has immutable tags |
| `terraform-apply` | `allow-destroy` | `false` | Fails the apply when the plan deletes or replaces anything |
| `python-ci` | `coverage-artifact-name` | `coverage-xml` | Set it when the workflow is called more than once in a run |
| `terraform-*` | `backend-config` | empty | `key=value` lines passed to `terraform init -backend-config` |
| `terraform-apply`, `deploy-ecs`, `docker-push` | `environment` | required | Configure required reviewers on the GitHub environment. The OIDC role trusts this environment's subject, so tag and branch pushes need no wildcard trust |
| `terraform-plan`, `terraform-apply` | `artifact-name`, `artifact-path` | empty | Downloads an artifact uploaded earlier in the calling workflow (for example a built site for the Cloudflare static-assets module) into `working-directory/artifact-path` before init. `artifact-path` is required with `artifact-name` and must not contain `..`. In `terraform-apply` the artifact comes from a job that ran before the environment approval, so reviewers approve a build they have not seen |
| `terraform-plan`, `terraform-apply` | secret `CLOUDFLARE_API_TOKEN` | not set | Optional. Used only by the plan and apply steps. Pass a read-only token to `terraform-plan`, because pull request code can read it |

## Terraform behavior

- `terraform-plan` uses a read-only role and `-lock=false`, because that role cannot write the state lock.
- Plans can contain secrets in state. The plan file is never uploaded, and the job summary lists only resource addresses and actions.
- `terraform-apply` plans and applies in one job, after the environment approval. Reviewers therefore approve before the plan exists: they review the pull request plan, and the apply refuses plans that delete or replace resources unless `allow-destroy` is set. The plan can still differ from the reviewed one if the infrastructure drifted in between.
- GitHub keeps only one pending run per concurrency group, so a newer queued apply replaces an older queued one. Terraform waits up to 5 minutes for the state lock.
- Pass non-secret variables with `var-file`. Fetch secrets inside the stack from SSM or Secrets Manager. The only secret a caller can pass is `CLOUDFLARE_API_TOKEN`, because that provider reads it from the environment. Never call the Terraform workflows from a `pull_request_target` trigger or with `secrets: inherit`, and give `terraform-plan` a read-only token.

## Repository settings these workflows rely on

Workflows cannot enforce these; apply them by hand (see the handbook's branch-protection page):

- Require the CI jobs and `pr-title` as status checks on `main` and `dev`.
- Allow merge commits only. Delete head branches after merge.
- Restrict who can create, move, and delete `v*` tags with a tag ruleset. Run `validate-tag` first in any tag-triggered pipeline, because a tag on a feature-branch commit would otherwise build and deploy before `release` rejects it.
- Limit the `prod` environment to deployment from `v*` tags.
- Add required reviewers to the `prod` environment used by `terraform-apply`, `deploy-ecs`, and `docker-push`. The environment is the only gate on these jobs' OIDC roles (the subject carries no branch or tag), so also restrict its deployment branches or tags; otherwise any branch workflow that declares the environment can assume the role. A pipeline that pushes and deploys through the same environment asks for approval twice.

## Preconditions

- `python-ci` caches pip by `cache-dependency-path` (default `**/pyproject.toml`); the glob must match a file. A requirements-only repository must set the input.
- `frontend-ci` uses npm: it needs `package-lock.json` and the node version file (default `.nvmrc`). It does not support pnpm or yarn.
- `frontend-ci` runs Playwright by default; set `e2e: false` if the repository has no Playwright suite.
- Callers cannot pass `TF_VAR_*` environment variables or secrets other than `CLOUDFLARE_API_TOKEN` to the Terraform workflows. Read other secrets inside the stack from SSM or Secrets Manager.
- Third-party actions on the AWS path (`aws-actions/*`, `docker/*`, `hashicorp/setup-terraform`) are pinned to major tags, an accepted risk for now. SHA pinning with Dependabot is a follow-up. The Terraform version default (`1.12.0`) is repeated in three workflows; keep them in step with each stack's `required_version`.
