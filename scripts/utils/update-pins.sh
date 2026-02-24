#!/usr/bin/env bash
# Update pinned fetchFromGitHub dependencies to their latest commits.
# Usage: ./scripts/utils/update-pins.sh [--dry-run] [filter]
#   --dry-run   Show what would change without modifying files
#   filter      Only update repos matching this substring (e.g. "yazi", "anthropics")

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

DRY_RUN=false
FILTER=""

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    *) FILTER="$arg" ;;
  esac
done

# ── Pin definitions ──────────────────────────────────────────────────────
# Format: "owner repo branch nix_file"
PINS=(
  "yazi-rs       plugins                 main    modules/home/cli/yazi/default.nix"
  "saumyajyoti   omp.yazi                main    modules/home/cli/yazi/default.nix"
  "orhnk         system-clipboard.yazi   master  modules/home/cli/yazi/default.nix"
  "KKV9          compress.yazi           main    modules/home/cli/yazi/default.nix"
  "anthropics    skills                  main    modules/home/cli/opencode/default.nix"
  "nozomio-labs  nia-skill               master  modules/home/cli/opencode/default.nix"
)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

prefetch() {
  local owner="$1" repo="$2" rev="$3"
  nix run nixpkgs#nix-prefetch-github -- \
    "$owner" "$repo" --rev "$rev" --json 2>/dev/null
}

update_pin() {
  local owner="$1" repo="$2" branch="$3" nix_file="$4"
  local full_path="${DOTFILES_DIR}/${nix_file}"

  if [[ -n "$FILTER" && "$owner/$repo" != *"$FILTER"* ]]; then
    return 0
  fi

  printf "${CYAN}Fetching latest ${owner}/${repo} @ ${branch}...${NC}\n"

  local result
  result=$(prefetch "$owner" "$repo" "$branch")

  local new_rev new_hash
  new_rev=$(echo "$result" | jq -r '.rev')
  new_hash=$(echo "$result" | jq -r '.hash')

  if [[ -z "$new_rev" || -z "$new_hash" || "$new_rev" == "null" || "$new_hash" == "null" ]]; then
    printf "${RED}  Failed to fetch ${owner}/${repo}${NC}\n"
    return 1
  fi

  # Find the fetchFromGitHub block for this owner/repo and extract current rev and hash.
  # Strategy: find the line number of `owner = "X"`, then search nearby lines for rev/hash.
  local current_rev current_hash
  local owner_line
  owner_line=$(grep -n "\"${owner}\"" "$full_path" | head -1 | cut -d: -f1)

  if [[ -z "$owner_line" ]]; then
    printf "${RED}  Could not find owner '${owner}' in ${nix_file}${NC}\n"
    return 1
  fi

  # Extract rev and hash from the ~10 lines following the owner line
  local block
  block=$(sed -n "${owner_line},$((owner_line + 10))p" "$full_path")

  current_rev=$(echo "$block" | grep 'rev *=' | head -1 | sed 's/.*rev *= *"\([^"]*\)".*/\1/')
  current_hash=$(echo "$block" | grep 'hash *=' | head -1 | sed 's/.*hash *= *"\([^"]*\)".*/\1/')

  local short_new_rev="${new_rev:0:12}"
  local short_old_rev="${current_rev:0:12}"

  if [[ "$current_hash" == "$new_hash" ]]; then
    printf "${GREEN}  ✓ ${owner}/${repo} is already up to date (${short_old_rev})${NC}\n"
    return 0
  fi

  printf "${YELLOW}  ↑ ${owner}/${repo}: ${short_old_rev} → ${short_new_rev}${NC}\n"

  if [[ "$DRY_RUN" == true ]]; then
    printf "    rev:  %s → %s\n" "$current_rev" "$new_rev"
    printf "    hash: %s → %s\n" "$current_hash" "$new_hash"
    return 0
  fi

  # Replace rev and hash in-place using the unique current values
  if [[ -n "$current_rev" ]]; then
    sed -i '' "s|${current_rev}|${new_rev}|g" "$full_path"
  fi
  if [[ -n "$current_hash" ]]; then
    sed -i '' "s|${current_hash}|${new_hash}|g" "$full_path"
  fi

  printf "${GREEN}  ✓ Updated ${nix_file}${NC}\n"
}

# ── Main ─────────────────────────────────────────────────────────────────
printf "${CYAN}Updating pinned GitHub dependencies...${NC}\n"
if [[ "$DRY_RUN" == true ]]; then
  printf "${YELLOW}(dry-run mode — no files will be modified)${NC}\n"
fi
echo

FAILED=0
for pin in "${PINS[@]}"; do
  # shellcheck disable=SC2086
  read -r owner repo branch nix_file <<< $pin
  if ! update_pin "$owner" "$repo" "$branch" "$nix_file"; then
    FAILED=$((FAILED + 1))
  fi
done

echo
if [[ "$FAILED" -gt 0 ]]; then
  printf "${RED}Done with ${FAILED} failure(s).${NC}\n"
  exit 1
else
  printf "${GREEN}All pins updated successfully.${NC}\n"
fi
