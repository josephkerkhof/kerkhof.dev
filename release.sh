#!/usr/bin/env bash

set -euo pipefail

version="${1:-}"
version="${version#v}"

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$ ]]; then
    echo "Usage: make release VERSION=x.y.z" >&2
    exit 1
fi

tag="v$version"

if [[ -n "$(git status --porcelain)" ]]; then
    echo "The working tree must be clean before creating a release." >&2
    exit 1
fi

if git rev-parse --verify --quiet "refs/tags/$tag" >/dev/null; then
    echo "Tag $tag already exists." >&2
    exit 1
fi

previous_tag="$(git describe --tags --abbrev=0)"
unreleased="$(perl -0ne 'print $1 if /^## \[Unreleased\]\n(.*?)(?=^## \[)/ms' CHANGELOG.md)"

if [[ "$unreleased" != *"- "* ]]; then
    echo "Add at least one entry to the Unreleased section before releasing." >&2
    exit 1
fi

release_date="${RELEASE_DATE:-$(date +%Y-%m-%d)}"
VERSION="$version" RELEASE_DATE="$release_date" perl -0pi -e \
    's/^## \[Unreleased\]\n/## [Unreleased]\n\n## [$ENV{VERSION}] - $ENV{RELEASE_DATE}\n/m' \
    CHANGELOG.md

TAG="$tag" VERSION="$version" PREVIOUS_TAG="$previous_tag" perl -0pi -e \
    's{^\[Unreleased\]:.*$}{[Unreleased]: https://github.com/josephkerkhof/kerkhof.dev/compare/$ENV{TAG}...HEAD\n[$ENV{VERSION}]: https://github.com/josephkerkhof/kerkhof.dev/compare/$ENV{PREVIOUS_TAG}...$ENV{TAG}}m' \
    CHANGELOG.md

git add CHANGELOG.md
git commit -m "release $tag"
git tag -a "$tag" -m "$tag"

echo "Created $tag. Push the commit and tag with:"
echo "  git push origin HEAD $tag"
