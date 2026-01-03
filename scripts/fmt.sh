#!/usr/bin/env bash
set -euo pipefail

files=$(rg --files -g '*.md' -g '*.yml' -g '*.yaml' -g '*.sh' -g 'Makefile' -g 'CODEOWNERS')

for f in $files; do
  sed -i 's/[[:space:]]\+$//' "$f"

  if [[ -s "$f" ]]; then
    last_char=$(tail -c 1 "$f" || true)
    if [[ "$last_char" != $'\n' ]]; then
      printf '\n' >> "$f"
    fi
  else
    printf '\n' >> "$f"
  fi
done

echo "Format OK"

