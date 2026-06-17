#!/usr/bin/env bash
# Locate or clone a JS/TS dependency's source into .agent-sources/ at the
# version that's actually installed, so the agent traces facts against the
# right code. Prints structured status the calling agent acts on.
#
# Usage:
#   setup-source.sh <package-name> [repo-url] [--ref <git-ref>]
#
# Exit codes:
#   0  ready    -> source checked out at a version-matching ref (or user ref)
#   3  ask-repo -> repo URL unknown, agent must ask the user
#   4  ask-ref  -> no version-matching tag found, agent must ask the user
set -euo pipefail

pkg=""
repo_url=""
ref=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref) ref="$2"; shift 2 ;;
    *) if [[ -z "$pkg" ]]; then pkg="$1"; elif [[ -z "$repo_url" ]]; then repo_url="$1"; fi; shift ;;
  esac
done
[[ -z "$pkg" ]] && { echo "ERROR: package name required"; exit 2; }

root="$(git rev-parse --show-toplevel)"
sources="$root/.agent-sources"
exclude="$root/.git/info/exclude"

# Keep .agent-sources untracked without touching the shared .gitignore.
mkdir -p "$sources"
if [[ -f "$exclude" ]] && ! grep -qxF ".agent-sources/" "$exclude"; then
  echo ".agent-sources/" >> "$exclude"
fi

# Installed version is the source of truth for what to check out.
pkg_json="$root/node_modules/$pkg/package.json"
version=""
if [[ -f "$pkg_json" ]]; then
  version="$(node -p "require('$pkg_json').version" 2>/dev/null || true)"
  [[ -z "$repo_url" ]] && repo_url="$(node -p "(require('$pkg_json').repository?.url||require('$pkg_json').repository||'').toString()" 2>/dev/null || true)"
fi
[[ -z "$version" ]] && echo "WARN: $pkg not found in node_modules; version unknown"

# Normalize git+ssh/https junk to a plain clone URL.
repo_url="${repo_url#git+}"
repo_url="${repo_url%.git}"
repo_url="${repo_url/git@github.com:/https://github.com/}"
if [[ -z "$repo_url" ]]; then
  echo "ASK_REPO: cannot resolve repository URL for '$pkg'"
  exit 3
fi

dir="$sources/$(basename "$repo_url")"
if [[ ! -d "$dir/.git" ]]; then
  echo "Cloning $repo_url ..."
  git clone --quiet "$repo_url" "$dir"
fi

cd "$dir"
git fetch --tags --quiet origin 2>/dev/null || true

checkout() { git checkout --quiet "$1" && echo "READY: $pkg @ $1 -> $dir"; }

if [[ -n "$ref" ]]; then
  checkout "$ref"; exit 0
fi

if [[ -n "$version" ]]; then
  # Tag conventions vary; monorepos (e.g. effect) use <pkg>@<version>.
  for cand in "v$version" "$version" "$pkg@$version" "$pkg-v$version" "$pkg/v$version"; do
    if git rev-parse -q --verify "refs/tags/$cand" >/dev/null; then
      checkout "$cand"; exit 0
    fi
  done
fi

echo "ASK_REF: no tag matching version '$version' for '$pkg' in $dir"
echo "Nearby tags:"
git tag --sort=-creatordate | grep -iF "${version%%.*}" | head -20 || true
git tag --sort=-creatordate | head -20
exit 4
