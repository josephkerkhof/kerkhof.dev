#!/usr/bin/env bash

set -euo pipefail

bucket="${R2_BUCKET:-kerkhof-dev-media}"
manifest_key=".media-manifest.sha256"

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d ' ' -f 1
  else
    shasum -a 256 "$1" | cut -d ' ' -f 1
  fi
}

media_files() {
  git lfs ls-files --name-only | LC_ALL=C sort
}

validate_media() {
  local source

  git lfs version >/dev/null
  media_files >/dev/null

  while IFS= read -r source; do
    [[ "$source" == content/* ]] || {
      printf 'LFS media must be under content/: %s\n' "$source" >&2
      return 1
    }
    [[ -f "$source" ]] || {
      printf 'Missing LFS object: %s\n' "$source" >&2
      return 1
    }
    if LC_ALL=C head -c 42 "$source" | grep -Fq 'version https://git-lfs.github.com/spec/v1'; then
      printf 'LFS pointer was not materialized: %s\n' "$source" >&2
      return 1
    fi
  done < <(media_files)
}

content_type() {
  case "$1" in
    *.gif) printf 'image/gif' ;;
    *.jpg|*.jpeg) printf 'image/jpeg' ;;
    *.mp4) printf 'video/mp4' ;;
    *.png) printf 'image/png' ;;
    *.webp) printf 'image/webp' ;;
    *) printf 'application/octet-stream' ;;
  esac
}

content_disposition() {
  case "$1" in
    content/fun/slack-reactions/images/*)
      printf 'attachment; filename="%s"' "$(basename "$1")"
      ;;
  esac
}

build_manifest() {
  local source key hash type disposition

  while IFS= read -r source; do
    key="${source#content/}"
    hash="$(hash_file "$source")"
    type="$(content_type "$source")"
    disposition="$(content_disposition "$source")"
    printf '%s|%s|%s|%s\n' "$hash" "$type" "$disposition" "$key"
  done < <(media_files)
}

sync_media() {
  local work_dir remote_manifest local_manifest source key hash type disposition record uploaded=0 skipped=0
  local -a upload_args
  work_dir="$(mktemp -d)"
  remote_manifest="$work_dir/remote"
  local_manifest="$work_dir/local"
  trap "rm -rf '$work_dir'" EXIT

  validate_media
  build_manifest > "$local_manifest"

  if ! wrangler r2 object get "$bucket/$manifest_key" --remote --file "$remote_manifest" >/dev/null 2>&1; then
    : > "$remote_manifest"
  fi

  while IFS= read -r source; do
    key="${source#content/}"
    hash="$(hash_file "$source")"
    type="$(content_type "$source")"
    disposition="$(content_disposition "$source")"
    record="$hash|$type|$disposition|$key"
    if grep -Fqx "$record" "$remote_manifest"; then
      skipped=$((skipped + 1))
      continue
    fi

    upload_args=(
      --remote
      --file "$source"
      --content-type "$type"
      --cache-control "public, max-age=86400"
    )
    if [[ -n "$disposition" ]]; then
      upload_args+=(--content-disposition "$disposition")
    fi
    wrangler r2 object put "$bucket/$key" "${upload_args[@]}"
    uploaded=$((uploaded + 1))
  done < <(media_files)

  if ! cmp -s "$local_manifest" "$remote_manifest"; then
    wrangler r2 object put "$bucket/$manifest_key" \
      --remote \
      --file "$local_manifest" \
      --content-type "text/plain; charset=utf-8" \
      --cache-control "no-store"
  fi

  printf 'R2 media sync complete: %d uploaded, %d unchanged. No objects deleted.\n' "$uploaded" "$skipped"
}

prune_public() {
  local source output

  validate_media
  while IFS= read -r source; do
    output="public/${source#content/}"
    if [[ -f "$output" ]]; then
      rm "$output"
    fi
  done < <(media_files)
}

verify_public() {
  local work_dir expected actual source
  work_dir="$(mktemp -d)"
  expected="$work_dir/expected"
  actual="$work_dir/actual"
  trap "rm -rf '$work_dir'" EXIT

  validate_media
  while IFS= read -r source; do
    printf 'https://media.kerkhof.dev/%s\n' "${source#content/}"
  done < <(media_files) | LC_ALL=C sort > "$expected"

  grep -RhoE 'https://media\.kerkhof\.dev/[A-Za-z0-9_./-]+' public \
    | LC_ALL=C sort -u > "$actual"
  diff -u "$expected" "$actual"
}

case "${1:-}" in
  check) validate_media ;;
  sync) sync_media ;;
  verify-public) verify_public ;;
  prune-public) prune_public ;;
  *)
    printf 'Usage: %s {check|sync|verify-public|prune-public}\n' "$0" >&2
    exit 2
    ;;
esac
