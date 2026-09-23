#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
prettier="$project_root/.devenv/profile/bin/prettier"

if [[ ! -x "$prettier" ]]; then
  printf '%s\n' 'Prettier is unavailable. Run `devenv shell` to prepare the project tools.' >&2
  exit 1
fi

cd "$project_root"
exec "$prettier" "$@"
