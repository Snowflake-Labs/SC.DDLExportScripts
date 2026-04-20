# Workflows Index

Index of every workflow under [`.github/workflows/`](../workflows/), grouped by role.
Naming follows the convention used across the `migrations-*` repos:

- `ci.yml` / `cd.yml` — top-level pipelines.
- `release.yml` / `prepare-release.yml` — release flow.
- `use-*.yml` — reusable workflows (called via `workflow_call`).
- `migrations-pr-*.yml` — PR checks shared across repos.

## Top-level pipelines

| File | Trigger | Purpose |
|---|---|---|
| [`cd.yml`](../workflows/cd.yml) | `push` to `main`, any `pull_request`, `workflow_call` | Orchestrator. Decides whether to build only (PR/branch) or build **and** publish a GitHub Release (main). |
| [`ci.yml`](../workflows/ci.yml) | `push` to `support/*`, `feature/*`, `bugfix/*`, `sfc-gh-*/*`; any `pull_request`; `workflow_call` | PR/branch build. Produces per-engine ZIP artifacts only — no tag, no release. |

## Release flow

| File | Called by | Purpose |
|---|---|---|
| [`prepare-release.yml`](../workflows/prepare-release.yml) | `cd.yml` | Reads `VERSION`, computes the three version forms, creates the `v<X.Y.Z>` git tag (only on `main`). |
| [`release.yml`](../workflows/release.yml) | `cd.yml` (only on `main`) | Builds the ZIPs, generates release notes, creates permalink ZIPs, publishes the GitHub Release with all assets. |

## Reusable building blocks

| File | Called by | Purpose |
|---|---|---|
| [`use-build.yml`](../workflows/use-build.yml) | `ci.yml`, `release.yml` | Validates required engine folders, zips each engine into `<engine>_v<X.Y.Z>.zip`, verifies, and uploads as an artifact. Exposes `version`, `version_dots`, `version_clean` outputs. |

## PR checks

| File | Trigger | Purpose |
|---|---|---|
| [`migrations-pr-draft.yml`](../workflows/migrations-pr-draft.yml) | `pull_request` lifecycle | Adds `DO NOT MERGE` to draft PRs and removes it once they're ready for review. |
| [`migrations-pr-precommit.yml`](../workflows/migrations-pr-precommit.yml) | `push` and `pull_request` | Re-runs `pre-commit` so a missed local hook can't bypass the `VERSION` bump rule. |

## Dependency graph

```
                push to main / PR
                         │
                         ▼
                      cd.yml
                    /        \
                   ▼          ▼
       prepare-release.yml   (is_main?)
                              /     \
                       yes  ▼       ▼ no
                       release.yml  ci.yml
                              \     /
                               ▼   ▼
                            use-build.yml
```

For a deeper explanation of the release flow, see [`RELEASE_PROCESS.md`](./RELEASE_PROCESS.md).
