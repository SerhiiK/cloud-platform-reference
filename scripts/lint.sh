#!/usr/bin/env bash
set -euo pipefail

required_dirs=(infra platform apps docs docs/adr .github/ISSUE_TEMPLATE scripts)
for dir in "${required_dirs[@]}"; do
  if [[ ! -d "$dir" ]]; then
    echo "Missing required directory: $dir" >&2
    exit 1
  fi
done

if ! rg -q '```mermaid' README.md; then
  echo "README.md must include a Mermaid diagram" >&2
  exit 1
fi

adr_count=$(ls -1 docs/adr/*.md 2>/dev/null | wc -l | tr -d ' ')
if [[ "$adr_count" -lt 3 ]]; then
  echo "docs/adr must contain at least 3 ADRs" >&2
  exit 1
fi

if [[ ! -f ".github/pull_request_template.md" ]]; then
  echo "Missing .github/pull_request_template.md" >&2
  exit 1
fi

if [[ ! -f ".github/ISSUE_TEMPLATE/bug_report.md" ]]; then
  echo "Missing issue template: bug_report.md" >&2
  exit 1
fi

if [[ ! -f ".github/ISSUE_TEMPLATE/feature_request.md" ]]; then
  echo "Missing issue template: feature_request.md" >&2
  exit 1
fi

echo "Lint OK"

