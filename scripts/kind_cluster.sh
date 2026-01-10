#!/usr/bin/env bash
set -euo pipefail

name="local-dev-cluster"

if ! command -v kind >/dev/null 2>&1; then
  echo "kind is not installed or not on PATH" >&2
  exit 1
fi

if kind get clusters | grep -Fxq "$name"; then
  echo "Cluster '$name' already exists" >&2
  exit 1
fi

config="$(mktemp)"
trap 'rm -f "$config"' EXIT
cat <<'EOF' >"$config"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
EOF

kind create cluster --name "$name" --config "$config"
