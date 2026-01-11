#!/usr/bin/env bash
set -euo pipefail

name="${1:-${CLUSTER_NAME:-local-dev-cluster}}"

if ! command -v kind >/dev/null 2>&1; then
  echo "kind is not installed or not on PATH" >&2
  exit 1
fi

if ! kind get clusters | grep -Fxq "$name"; then
  echo "Cluster '$name' does not exist" >&2
  exit 1
fi

kind delete cluster --name "$name"
