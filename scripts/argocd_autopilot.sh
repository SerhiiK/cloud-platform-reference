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

if [ -z "${ARGOCD_AUTOPILOT_TOKEN}" ]; then
  echo "ARGOCD_AUTOPILOT_TOKEN is not set. Add it to .env." >&2
  exit 1
fi

argocd-autopilot repo bootstrap \
  --provider github \
  --owner "$GIT_REPO_OWNER" \
  --repo "$GIT_REPO_NAME" \
  --git-token "$ARGOCD_AUTOPILOT_TOKEN"
