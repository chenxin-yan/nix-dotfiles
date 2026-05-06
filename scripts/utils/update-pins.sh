#!/usr/bin/env bash
# Update pinned fetchFromGitHub dependencies to their latest commits.
#
# Auto-discovers every `fetchFromGitHub { ... }` block under the repo —
# there is no hardcoded pin list. Replacements are scoped to the matched
# block's line range so a branch-name rev like "master" cannot bleed
# into other parts of the file.
#
# Usage: ./scripts/utils/update-pins.sh [--dry-run] [filter]
#   --dry-run   Show what would change without modifying files
#   filter      Only update pins whose owner/repo contains this substring
#               (e.g. "yazi", "anthropics")

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

DRY_RUN=false
FILTER=""

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h|--help)
      cat <<'EOF'
Usage: ./scripts/utils/update-pins.sh [--dry-run] [filter]

Auto-discovers every fetchFromGitHub block in the repo and updates its
rev + hash to the latest commit.

  --dry-run   Show what would change without modifying files
  filter      Only update pins whose owner/repo contains this substring
EOF
      exit 0 ;;
    *) FILTER="$arg" ;;
  esac
done

# Colors (disabled when stdout is not a tty).
if [[ -t 1 ]]; then
  RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
  CYAN=$'\033[0;36m'; NC=$'\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; CYAN=''; NC=''
fi

# ── Preflight ───────────────────────────────────────────────────────────
preflight() {
  local missing=()
  command -v jq   >/dev/null 2>&1 || missing+=("jq")
  command -v nix  >/dev/null 2>&1 || missing+=("nix")
  command -v awk  >/dev/null 2>&1 || missing+=("awk")
  command -v find >/dev/null 2>&1 || missing+=("find")
  if (( ${#missing[@]} )); then
    printf "%sMissing required tools: %s%s\n" "$RED" "${missing[*]}" "$NC" >&2
    exit 1
  fi
  # `nix-prefetch-github` is fetched via `nix run nixpkgs#...`, so just
  # needing `nix` is enough.
}

# ── Discovery ───────────────────────────────────────────────────────────
# Walks every *.nix file under the repo and emits a TSV record for each
# `fetchFromGitHub { ... }` block:
#   file<TAB>start_line<TAB>end_line<TAB>owner<TAB>repo<TAB>rev<TAB>hash
#
# Block boundaries are tracked by brace depth so nested attrsets are
# handled correctly. Blocks missing any of owner/repo/rev/hash are
# skipped (they're either incomplete or use a non-string form we can't
# safely rewrite).
discover_pins() {
  local root="$1"
  find "$root" -type f -name '*.nix' \
    -not -path '*/.git/*' \
    -not -path '*/.direnv/*' \
    -not -path '*/result/*' \
    -not -path '*/result-*' \
    -print0 \
  | while IFS= read -r -d '' file; do
    awk -v FILE="$file" '
      function brace_delta(line,    i, ch, o, c) {
        o = 0; c = 0
        for (i = 1; i <= length(line); i++) {
          ch = substr(line, i, 1)
          if (ch == "{") o++
          else if (ch == "}") c++
        }
        return o - c
      }
      function strvalue(line, key,    re, s) {
        re = key "[ \t]*=[ \t]*\"[^\"]+\""
        if (match(line, re)) {
          s = substr(line, RSTART, RLENGTH)
          sub("^" key "[ \t]*=[ \t]*\"", "", s)
          sub("\"$", "", s)
          return s
        }
        return ""
      }
      BEGIN { in_block = 0; depth = 0 }
      {
        if (!in_block) {
          if (match($0, /fetchFromGitHub[ \t]*\{/)) {
            in_block = 1
            start_line = NR
            owner = ""; repo = ""; rev = ""; hashv = ""
            depth = brace_delta($0)
            if (depth <= 0) in_block = 0
            next
          }
        } else {
          if (owner == "") owner = strvalue($0, "owner")
          if (repo  == "") repo  = strvalue($0, "repo")
          if (rev   == "") rev   = strvalue($0, "rev")
          if (hashv == "") {
            v = strvalue($0, "hash")
            if (v == "") v = strvalue($0, "sha256")
            hashv = v
          }
          depth += brace_delta($0)
          if (depth <= 0) {
            end_line = NR
            if (owner != "" && repo != "" && rev != "" && hashv != "")
              printf "%s\t%d\t%d\t%s\t%s\t%s\t%s\n", \
                FILE, start_line, end_line, owner, repo, rev, hashv
            in_block = 0
          }
        }
      }
    ' "$file"
  done
}

# ── Prefetch with retries ───────────────────────────────────────────────
# If `ref` is non-empty it's passed as --rev; otherwise prefetch follows
# the repo's default branch (HEAD).
prefetch() {
  local owner="$1" repo="$2" ref="$3"
  local stderr; stderr=$(mktemp)
  local attempt result
  for attempt in 1 2 3; do
    : > "$stderr"
    if [[ -n "$ref" ]]; then
      result=$(nix run nixpkgs#nix-prefetch-github -- \
        "$owner" "$repo" --rev "$ref" --json 2>"$stderr") || result=""
    else
      result=$(nix run nixpkgs#nix-prefetch-github -- \
        "$owner" "$repo" --json 2>"$stderr") || result=""
    fi
    if [[ -n "$result" ]] && echo "$result" | jq -e . >/dev/null 2>&1; then
      printf '%s\n' "$result"
      rm -f "$stderr"
      return 0
    fi
    if (( attempt < 3 )); then
      sleep $((1 << (attempt - 1)))
    fi
  done
  printf "%s    nix-prefetch-github failed after 3 attempts:%s\n" "$RED" "$NC" >&2
  sed 's/^/      /' "$stderr" >&2
  rm -f "$stderr"
  return 1
}

# ── In-place rewrite scoped to a line range ─────────────────────────────
# Replaces the first occurrence of `key = "..."` inside [start, end].
# Uses a temp file + mv so it works on macOS and Linux without `sed -i`.
replace_in_range() {
  local file="$1" start="$2" end="$3" key="$4" new_value="$5"
  local tmp; tmp=$(mktemp)
  KEY="$key" NEW="$new_value" awk \
    -v LO="$start" -v HI="$end" '
      BEGIN {
        KEY = ENVIRON["KEY"]
        NEW = ENVIRON["NEW"]
        re = KEY "[ \t]*=[ \t]*\"[^\"]+\""
        done = 0
      }
      {
        if (!done && NR >= LO && NR <= HI && match($0, re)) {
          before = substr($0, 1, RSTART - 1)
          after  = substr($0, RSTART + RLENGTH)
          print before KEY " = \"" NEW "\"" after
          done = 1
          next
        }
        print
      }
    ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

# ── Update one pin ──────────────────────────────────────────────────────
# Side-effect: appends a record to the SUMMARY array.
# Returns: 0 = unchanged, 1 = updated (or would-update in dry-run),
#          2 = failed.
update_pin() {
  local file="$1" start="$2" end="$3" owner="$4" repo="$5"
  local cur_rev="$6" cur_hash="$7"
  local rel_file="${file#"$DOTFILES_DIR"/}"

  if [[ -n "$FILTER" && "$owner/$repo" != *"$FILTER"* ]]; then
    return 0
  fi

  printf "%sFetching %s/%s @ %s...%s\n" "$CYAN" "$owner" "$repo" "$cur_rev" "$NC"

  # If cur_rev is a 40-char hex SHA we follow the default branch (HEAD).
  # Otherwise treat it as a branch/tag name and pass it through so the
  # same moving target keeps moving.
  local ref=""
  if ! [[ "$cur_rev" =~ ^[0-9a-f]{40}$ ]]; then
    ref="$cur_rev"
  fi

  local result
  if ! result=$(prefetch "$owner" "$repo" "$ref"); then
    printf "%s  ✗ %s/%s: prefetch failed%s\n" "$RED" "$owner" "$repo" "$NC"
    SUMMARY+=("${owner}/${repo}"$'\t'"${cur_rev:0:12}"$'\t'"?"$'\t'"${rel_file}"$'\t'"failed")
    return 2
  fi

  local new_rev new_hash
  new_rev=$(echo "$result" | jq -r '.rev')
  new_hash=$(echo "$result" | jq -r '.hash')

  if [[ -z "$new_rev" || -z "$new_hash" \
        || "$new_rev" == "null" || "$new_hash" == "null" ]]; then
    printf "%s  ✗ %s/%s: empty rev/hash from prefetch%s\n" \
      "$RED" "$owner" "$repo" "$NC"
    SUMMARY+=("${owner}/${repo}"$'\t'"${cur_rev:0:12}"$'\t'"?"$'\t'"${rel_file}"$'\t'"failed")
    return 2
  fi

  if [[ "$cur_hash" == "$new_hash" ]]; then
    printf "%s  ✓ %s/%s is up to date (%s)%s\n" \
      "$GREEN" "$owner" "$repo" "${cur_rev:0:12}" "$NC"
    SUMMARY+=("${owner}/${repo}"$'\t'"${cur_rev:0:12}"$'\t'"${cur_rev:0:12}"$'\t'"${rel_file}"$'\t'"unchanged")
    return 0
  fi

  printf "%s  ↑ %s/%s: %s → %s%s\n" \
    "$YELLOW" "$owner" "$repo" "${cur_rev:0:12}" "${new_rev:0:12}" "$NC"

  if [[ "$DRY_RUN" == true ]]; then
    printf "    rev:  %s → %s\n" "$cur_rev" "$new_rev"
    printf "    hash: %s → %s\n" "$cur_hash" "$new_hash"
    SUMMARY+=("${owner}/${repo}"$'\t'"${cur_rev:0:12}"$'\t'"${new_rev:0:12}"$'\t'"${rel_file}"$'\t'"would-update")
    return 1
  fi

  # Replacements are scoped to [start, end] — even a literal "master"
  # rev cannot leak out of the block.
  replace_in_range "$file" "$start" "$end" "rev"  "$new_rev"
  replace_in_range "$file" "$start" "$end" "hash" "$new_hash"

  printf "%s  ✓ Updated %s%s\n" "$GREEN" "$rel_file" "$NC"
  SUMMARY+=("${owner}/${repo}"$'\t'"${cur_rev:0:12}"$'\t'"${new_rev:0:12}"$'\t'"${rel_file}"$'\t'"updated")
  return 1
}

# ── Main ────────────────────────────────────────────────────────────────
preflight

printf "%sUpdating pinned GitHub dependencies...%s\n" "$CYAN" "$NC"
if [[ "$DRY_RUN" == true ]]; then
  printf "%s(dry-run mode — no files will be modified)%s\n" "$YELLOW" "$NC"
fi
echo

# Discover all pins up front so we know what we're working with.
declare -a PINS=()
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  PINS+=("$line")
done < <(discover_pins "$DOTFILES_DIR")

if (( ${#PINS[@]} == 0 )); then
  printf "%sNo fetchFromGitHub pins discovered.%s\n" "$YELLOW" "$NC"
  exit 0
fi

printf "%sDiscovered %d pin(s):%s\n" "$CYAN" "${#PINS[@]}" "$NC"
for entry in "${PINS[@]}"; do
  IFS=$'\t' read -r file start end owner repo _rev _hash <<< "$entry"
  printf "  %s/%s  (%s:%s-%s)\n" \
    "$owner" "$repo" "${file#"$DOTFILES_DIR"/}" "$start" "$end"
done
echo

declare -a SUMMARY=()
FAILED=0
UPDATED=0
UNCHANGED=0

for entry in "${PINS[@]}"; do
  IFS=$'\t' read -r file start end owner repo rev hashv <<< "$entry"
  set +e
  update_pin "$file" "$start" "$end" "$owner" "$repo" "$rev" "$hashv"
  rc=$?
  set -e
  case $rc in
    0) UNCHANGED=$((UNCHANGED + 1)) ;;
    1) UPDATED=$((UPDATED + 1)) ;;
    2) FAILED=$((FAILED + 1)) ;;
  esac
done

# ── Summary ─────────────────────────────────────────────────────────────
echo
printf "%sSummary:%s\n" "$CYAN" "$NC"
if (( ${#SUMMARY[@]} == 0 )); then
  echo "  (no pins matched filter)"
else
  printf "  %-38s  %-12s    %-12s  %s\n" "owner/repo" "old" "new" "file"
  for row in "${SUMMARY[@]}"; do
    IFS=$'\t' read -r repo_id old_short new_short rel_file status <<< "$row"
    case "$status" in
      updated)      symbol="↑" ; color="$YELLOW" ;;
      would-update) symbol="≈" ; color="$YELLOW" ;;
      unchanged)    symbol="=" ; color="$GREEN"  ;;
      failed)       symbol="✗" ; color="$RED"    ;;
      *)            symbol="?" ; color=""        ;;
    esac
    printf "  %s%s %-36s  %-12s →  %-12s  %s%s\n" \
      "$color" "$symbol" "$repo_id" "$old_short" "$new_short" "$rel_file" "$NC"
  done
fi

echo
if (( FAILED > 0 )); then
  printf "%sDone: %d updated, %d unchanged, %d failed.%s\n" \
    "$RED" "$UPDATED" "$UNCHANGED" "$FAILED" "$NC"
  exit 1
elif [[ "$DRY_RUN" == true ]]; then
  printf "%sDry-run complete: %d would update, %d already up to date.%s\n" \
    "$GREEN" "$UPDATED" "$UNCHANGED" "$NC"
else
  printf "%sDone: %d updated, %d unchanged.%s\n" \
    "$GREEN" "$UPDATED" "$UNCHANGED" "$NC"
fi
