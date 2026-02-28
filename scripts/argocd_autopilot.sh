#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ENV_FILE="$SCRIPT_DIR/../.env"

if [ -f "$ENV_FILE" ]; then
  set -a
  . "$ENV_FILE"
  set +a
fi

export ARGOCD_AUTOPILOT_TOKEN="${ARGOCD_AUTOPILOT_TOKEN:-${ARGOCD_AUTOPITOL_TOKEN:-}}"
export GIT_REPO_OWNER=${GIT_REPO_OWNER:-SerhiiK}
export GIT_REPO_NAME=${GIT_REPO_NAME:-cloud-platform-reference}
export GIT_REPO=${GIT_REPO:-}
CLUSTER_NAME=${1:-${CLUSTER_NAME:-local-dev-cluster}}

if ! [[ "$CLUSTER_NAME" =~ ^[a-z_-]+$ ]]; then
  echo "CLUSTER_NAME must contain only lowercase letters, '-' or '_'." >&2
  exit 1
fi

if [ -z "${ARGOCD_AUTOPILOT_TOKEN}" ]; then
  echo "ARGOCD_AUTOPILOT_TOKEN is not set. Add it to .env." >&2
  exit 1
fi

if [ -n "$GIT_REPO" ]; then
  GIT_REPO_BASE="${GIT_REPO%/}"
else
  GIT_REPO_BASE="https://github.com/${GIT_REPO_OWNER}/${GIT_REPO_NAME}.git"
fi

REPO_ROOT="$SCRIPT_DIR/.."
BOOTSTRAP_DIR="$REPO_ROOT/platform/clusters/${CLUSTER_NAME}/bootstrap"
BOOTSTRAP_APP_DIR="$BOOTSTRAP_DIR/argo-cd"
BOOTSTRAP_REPO="${GIT_REPO_BASE}/platform/clusters/${CLUSTER_NAME}"
BOOTSTRAP_APP_REPO="${GIT_REPO_BASE%.git}/platform/clusters/${CLUSTER_NAME}/bootstrap/argo-cd"

autopilot_args=(
  repo
  bootstrap
  --provider
  github
  --repo
  "$BOOTSTRAP_REPO"
  --git-token
  "$ARGOCD_AUTOPILOT_TOKEN"
)

if [ -d "$BOOTSTRAP_DIR" ]; then
  if [ ! -d "$BOOTSTRAP_APP_DIR" ]; then
    echo "Bootstrap directory exists, but Argo CD manifests are missing in: $BOOTSTRAP_APP_DIR" >&2
    exit 1
  fi

  echo "Bootstrap already exists in $BOOTSTRAP_DIR; running argocd-autopilot in recovery mode."
  autopilot_args+=(
    --recover
    --app
    "$BOOTSTRAP_APP_REPO"
  )
fi

argocd-autopilot "${autopilot_args[@]}"
