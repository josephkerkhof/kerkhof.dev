#!/usr/bin/env bash
set -euo pipefail

project_root="$(git rev-parse --show-toplevel)"
cd "$project_root"

# Keep Git's default hook directory so Git LFS hooks continue to run.
if git config --get core.hooksPath >/dev/null; then
  printf '%s\n' \
    'A custom core.hooksPath is already configured; no hooks were changed.' \
    'Add a call to .githooks/pre-commit from your existing hook instead.' >&2
  exit 1
fi

hook_dir="$(git rev-parse --git-path hooks)"
hook="$hook_dir/pre-commit"
source_hook="$project_root/.githooks/pre-commit"

if [[ -L "$hook" && "$(readlink "$hook")" == "$source_hook" ]]; then
  printf '%s\n' 'The Markdown pre-commit hook is already installed.'
  exit 0
fi

if [[ -e "$hook" || -L "$hook" ]]; then
  printf '%s\n' 'An existing pre-commit hook was found; it has not been overwritten.' >&2
  exit 1
fi

mkdir -p "$hook_dir"
ln -s "$source_hook" "$hook"
printf '%s\n' 'Installed the Markdown pre-commit hook. Other Git hooks are unchanged.'
