# Contributing

1. Branch from `dev`: `feature/<short-desc>`, `fix/<short-desc>`, or `chore/<short-desc>`.
2. Change a workflow, its fixture or example, and its docs together.
3. Run actionlint and the fixture checks listed in [AGENTS.md](AGENTS.md).
4. Commit with [Conventional Commits](https://www.conventionalcommits.org/), for example `feat(python-ci): add cache input`.
5. Open a pull request into `dev`. The title follows the same format.

Renaming an input, removing one, or adding a required one breaks every caller. Make it additive, or plan a new major tag.
