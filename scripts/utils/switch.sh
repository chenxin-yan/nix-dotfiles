#!/usr/bin/env bash
# Activate this machine's registered configuration with nh.
#
# Usage: ./scripts/utils/switch.sh [TARGET]
#   (none)  The local hostname must be a target registered in hosts/default.nix.
#   TARGET  One-time explicit bootstrap for a machine not yet named after its
#           target. Platform, login, UID and checkout checks still apply.
#
# The machine inventory lives only in the flake (`hosts` output); this script
# reads it with `nix eval` and never carries its own host table.
# Keep this runnable by macOS /bin/bash 3.2: no mapfile, arrays or ${var,,}.

set -euo pipefail

die() {
  printf 'switch: %s\n' "$*" >&2
  exit 1
}

[ $# -le 1 ] || die "usage: switch.sh [TARGET]"

root="$(cd -P "$(dirname "$0")/../.." && pwd -P)"

command -v nix >/dev/null || die "nix not found"
command -v nh >/dev/null || die "nh not found; for a fresh install use the bootstrap command in README.md"

# Supported operating systems: macOS (nix-darwin) and NixOS. Other Linux
# distributions, including Raspberry Pi OS, have no target in this phase.
case "$(uname -s)" in
  Darwin) os=darwin ;;
  Linux)
    grep -qx 'ID=nixos' "${SWITCH_OS_RELEASE:-/etc/os-release}" 2>/dev/null \
      || die "this Linux host is not NixOS (Raspberry Pi OS is unsupported); nothing to activate"
    os=nixos
    ;;
  *) die "unsupported operating system: $(uname -s)" ;;
esac
case "$(uname -m)" in
  arm64 | aarch64) arch=aarch64 ;;
  x86_64) arch=x86_64 ;;
  *) die "unsupported architecture: $(uname -m)" ;;
esac
if [ "$os" = darwin ]; then system="$arch-darwin"; else system="$arch-linux"; fi

uid="$(id -u)"
login="$(id -un)"
[ "$uid" != 0 ] || die "run as the normal login user; nh elevates itself"

if [ $# -eq 1 ]; then
  target="$1"
  selection="explicit target"
else
  target="$(hostname)"
  selection="local hostname"
fi
[[ "$target" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] \
  || die "'$target' is not a valid target name; run 'just switch <target>' with a registered target"

nix_eval() {
  nix eval --raw --no-update-lock-file "$@"
}

registered="$(nix_eval "$root#hosts" --apply 'hosts: builtins.concatStringsSep " " (builtins.attrNames hosts)')"
case " $registered " in
  *" $target "*) ;;
  *) die "'$target' is not a registered target (registered: $registered); this machine's hostname must match one, or pass it explicitly to bootstrap" ;;
esac

# One evaluation, one fact per line. Command substitution (not process
# substitution) so a failing nix eval aborts under set -e.
# shellcheck disable=SC2016
facts="$(nix_eval "$root#hosts.$target" \
  --apply 'host: "${host.system}\n${host.login}\n${toString host.uid}\n${host.dotfiles}"')"
{
  IFS= read -r want_system
  IFS= read -r want_login
  IFS= read -r want_uid
  IFS= read -r want_dotfiles
} <<EOF
$facts
EOF
[ -n "$want_dotfiles" ] || die "incomplete inventory facts for $target: $facts"

[ "$system" = "$want_system" ] || die "target $target is $want_system but this machine is $system"
[ "$login" = "$want_login" ] || die "target $target expects login '$want_login' but you are '$login'"
[ "$uid" = "$want_uid" ] || die "target $target expects uid $want_uid but you are $uid"
[ "$root" = "$want_dotfiles" ] || die "checkout $root is not the target's dotfiles path $want_dotfiles"

printf 'switch: %s -> %s (%s) as %s from %s\n' "$selection" "$target" "$system" "$login" "$root"

# Local activation only; the lock file is never touched by a switch.
case "$os" in
  darwin) exec nh darwin switch --hostname "$target" --no-update-lock-file --no-write-lock-file "$root" ;;
  nixos) exec nh os switch --hostname "$target" --no-update-lock-file --no-write-lock-file "$root" ;;
esac
