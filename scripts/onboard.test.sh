#!/usr/bin/env bash
# Focused lifecycle checks: only temporary Git fixtures, with Nix/build/sudo
# stubbed. This checks cleanup and consent, not real Nix evaluation or activation.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
mkdir "$T/bin"
# Shebang from the running bash: build sandboxes have no /usr/bin/env.
{ printf '#!%s\n' "$BASH"; cat; } >"$T/bin/stub" <<'STUB'
set -eu
activate() {
  echo ACTIVATION >>"$MOCK/calls"
  [ "${ALLOW_ACTIVATE:-no}" = yes ] || exit 99
  mkdir -p "$ONBOARD_SYSROOT/etc/profiles/per-user/alice/bin"
  touch "$ONBOARD_SYSROOT/etc/profiles/per-user/alice/bin/just" "$ONBOARD_SYSROOT/etc/profiles/per-user/alice/bin/nh"
  chmod +x "$ONBOARD_SYSROOT/etc/profiles/per-user/alice/bin/"*
}
case "${0##*/}" in
  id) case "$1" in -u) echo 1001 ;; -un) echo alice ;; esac ;;
  uname) case "$1" in -s) echo "$MOCK_OS" ;; -m) echo "$MOCK_ARCH" ;; esac ;;
  hostname) echo laptop ;;
  xcode-select) exit 0 ;;
  sudo) activate ;;
  nixos-rebuild)
    case "$1" in
      --help) echo --sudo ;;
      build) echo BUILD >>"$MOCK/calls"; ln -s "$MOCK/system" result; exit "${FAIL_BUILD:-0}" ;;
      switch) activate ;;
      *) exit 70 ;;
    esac ;;
  nix)
    case " $* " in
      *' build '*)
        echo BUILD >>"$MOCK/calls"
        while [ "$1" != --out-link ]; do shift; done
        ln -s "$MOCK/system" "$2"
        exit "${FAIL_BUILD:-0}" ;;
      *onboard-inventory.nix*) [ "$MOCK_NEW" = yes ] || printf 'laptop %s alice\n' "$MOCK_SYSTEM" ;;
      *release.json*) echo '26.11 7' ;;
      *type.check*) echo yes ;;
      *'#hosts.laptop '*) printf '%s\nalice\n1001\n%s/dotfiles\n' "$MOCK_SYSTEM" "$HOME" ;;
      *Configurations.laptop.config*)
        printf 'drv=/nix/store/test.drv\nstateVersion=25.11\nhostName=laptop\nhome=%s\nhmStateVersion=26.11\nnh=yes\njust=yes\n@files\n@brewfile\n' "$HOME" ;;
      *) echo "Unexpected nix invocation: $*" >&2; exit 70 ;;
    esac ;;
esac
STUB
chmod +x "$T/bin/stub"
for tool in id uname hostname xcode-select sudo nixos-rebuild nix; do
  ln -s stub "$T/bin/$tool"
done

fixture() {
  C="$T/$1" H="$T/$1/home" R="$T/$1/home/dotfiles"
  TEMP="$C/tmp"
  mkdir -p "$R/scripts" "$R/modules/hosts" "$C/root/etc/nixos" "$C/system" "$TEMP"
  cp "$REPO/scripts/onboard.sh" "$R/scripts/"
  if [ "$MOCK_NEW" = no ]; then
    mkdir "$R/modules/hosts/laptop"
    echo '{}' >"$R/modules/hosts/laptop/default.nix"
  fi
  printf '{\n  imports = [ ./hardware-configuration.nix ];\n  system.stateVersion = "25.11";\n}\n' >"$C/root/etc/nixos/configuration.nix"
  echo '{}' >"$C/root/etc/nixos/hardware-configuration.nix"
  echo ID=nixos >"$C/root/etc/os-release"
  cp "$C/root/etc/nixos/configuration.nix" "$C/original.nix"
  git -C "$R" init -q
  git -C "$R" add .
  : >"$C/calls"
}
run() {
  rc=0
  printf '%b' "$1" | env HOME="$H" TMPDIR="$TEMP" XDG_STATE_HOME="$C/state" \
    PATH="$T/bin:$PATH" ONBOARD_SYSROOT="$C/root" MOCK="$C" \
    MOCK_OS="$MOCK_OS" MOCK_ARCH="$MOCK_ARCH" MOCK_SYSTEM="$MOCK_SYSTEM" \
    MOCK_NEW="$MOCK_NEW" FAIL_BUILD="${FAIL_BUILD:-0}" ALLOW_ACTIVATE="${ALLOW_ACTIVATE:-no}" \
    bash "$R/scripts/onboard.sh" >"$C/out" 2>&1 || rc=$?
}
check() {
  if ! "$@"; then
    printf 'FAIL: %s\n' "$*" >&2
    cat "$C/out" >&2
    exit 1
  fi
}
clean_exit() {
  check test "$rc" -ne 0
  check test -z "$(ls -A "$TEMP")"
  check test ! -e "$C/state"
  check test ! -e "$H/.local/state/dotfiles-onboard"
  check test ! -e "$H/Backups"
  check test ! -e "$R/result"
  check cmp "$C/original.nix" "$C/root/etc/nixos/configuration.nix"
  check test -z "$(grep ACTIVATION "$C/calls" || true)"
}

MOCK_OS=Linux MOCK_ARCH=x86_64 MOCK_SYSTEM=x86_64-linux MOCK_NEW=yes
fixture new-nixos
run 'y\nlaptop\ny\n\ny\ny\ny\ny\nn\n'
check grep -q 'built but not activated' "$C/out"
check grep -q BUILD "$C/calls"
clean_exit
check cmp "$C/original.nix" "$R/modules/hosts/laptop/_installed/configuration.nix"
check grep -q 'hosts."laptop"' "$R/modules/hosts/laptop/default.nix"
echo 'ok - new NixOS preserves originals without an extra backup; build files cleaned'

MOCK_NEW=no
fixture build-eof
run 'y\nlaptop\ny'
check test ! -s "$C/calls"
clean_exit
echo 'ok - partial yes at build gate fails closed and cleans temporary files'

fixture activate-eof
run 'y\nlaptop\ny\ny'
check grep -q BUILD "$C/calls"
clean_exit
echo 'ok - partial yes at activation gate fails closed and cleans temporary files'

fixture answer-eof
run 'y\nlap'
check grep -q 'input ended' "$C/out"
check test ! -s "$C/calls"
clean_exit
echo 'ok - partial free-text answer at EOF stops cleanly'

fixture unsafe-temp
TEMP="$R/tmp"
mkdir "$TEMP"
run 'y\nlaptop\ny\nn\n'
check grep -q 'inside the checkout' "$C/out"
check test ! -s "$C/calls"
clean_exit
echo 'ok - temporary workspace inside the checkout is rejected and removed'

MOCK_OS=Darwin MOCK_ARCH=arm64 MOCK_SYSTEM=aarch64-darwin
fixture mac-decline
run 'y\nlaptop\ny\nn\n'
check grep -q 'built but not activated' "$C/out"
check grep -q BUILD "$C/calls"
clean_exit
echo 'ok - macOS declined activation leaves no persistent wizard files'

fixture mac-failed-build
FAIL_BUILD=23
run 'y\nlaptop\ny\n'
check grep -q 'build failed' "$C/out"
clean_exit
echo 'ok - failed macOS build cleans temporary files without activating'

FAIL_BUILD=0 ALLOW_ACTIVATE=yes
fixture mac-success
run 'y\nlaptop\ny\ny\n'
check test "$rc" -eq 0
check grep -q 'Setup complete' "$C/out"
check grep -q ACTIVATION "$C/calls"
check test -z "$(ls -A "$TEMP")"
check test ! -e "$C/state"
echo 'ok - successful stubbed activation also removes temporary build links'
