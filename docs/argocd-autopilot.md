# Argo CD Autopilot

This guide walks you through bootstrapping Argo CD into your local cluster using
`argocd-autopilot`. It’s designed to be repeatable: set a token, run a command,
and you’re ready to sync manifests with GitOps.

## Prerequisites

- A running kind cluster (see `docs/kind-cluster.md`)
- `argocd-autopilot` installed and on your `PATH`
- A GitHub personal access token with repo access

## Configuration

Create a `.env` file at the repo root and set the token. This keeps secrets
out of your shell history and makes the script easy to re-run:

```bash
ARGOCD_AUTOPILOT_TOKEN=your-token-here
```

Optional overrides. You can usually skip these unless you’re working in a fork
or a different org:

```bash
GIT_REPO_OWNER=YourOrg
GIT_REPO_NAME=your-repo
GIT_REPO=https://github.com/YourOrg/your-repo.git
CLUSTER_NAME=local-dev-cluster
```

`CLUSTER_NAME` must contain only lowercase letters, `-`, or `_`. This matches
the naming constraints used by the bootstrap path.

## Bootstrap

Once the token is in place, run the bootstrap. On the first run it will create
the Argo CD structure in your repo and install Argo CD into the cluster.
If `platform/clusters/<cluster>/bootstrap` already exists, the script switches
to recovery mode automatically and re-installs Argo CD from the manifests that
are already committed in Git instead of trying to bootstrap the repo again.

```bash
make argocd-autopilot
```

Or:

```bash
./scripts/argocd_autopilot.sh
```

The bootstrap repo is computed as:

```
${GIT_REPO_BASE}/platform/clusters/${CLUSTER_NAME}
```

`GIT_REPO_BASE` is derived from `GIT_REPO` (if set) or from
`GIT_REPO_OWNER` and `GIT_REPO_NAME`.

In recovery mode the Argo CD manifests are loaded from:

```
${GIT_REPO_BASE without .git}/platform/clusters/${CLUSTER_NAME}/bootstrap/argo-cd
```
