# The `make ci` contract

The handbook requires every repository to expose the same entry points, and `make ci` must run exactly what CI runs. The language workflows therefore do not hard-code lint, type, or test commands. They set up the toolchain, install, and run `ci-command` (default `make ci`).

## What `make ci` must do

| Stack | Must include |
| --- | --- |
| Python | Ruff check and format check, type check, pytest with the coverage gate (`fail_under = 80` in `pyproject.toml` or `--cov-fail-under=80`) |
| Frontend | Prettier check, ESLint with zero warnings, `tsc --noEmit`, `vitest run --coverage` with `coverage.thresholds.lines: 80`, build |

The gate lives in the repository's own configuration, so lowering it is a visible, reviewable change that needs an ADR update. These workflows do not read or override the threshold.

Working examples: `fixtures/python-app` and `fixtures/node-app` here, and `template-react-vite`.

## Alternatives

A repository without a Makefile can set `ci-command` to a single command, for example `ruff check . && pytest`. Prefer adding the Makefile; the point is that humans and CI run the same thing.

## Preconditions

See [usage](usage.md#preconditions) for the files each workflow expects (lockfile, node version file, pyproject glob).

## Install step

`python-ci` runs `install-command` (default `pip install -e .[dev]`) before the checks. `frontend-ci` runs `npm ci --ignore-scripts`, so Husky hooks are not installed on CI.
